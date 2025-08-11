import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard/dashborder/controller/parcel_controller/parcel_controller.dart';
import 'package:dashboard/dashborder/controller/shipment_controller/data_init_shipment.dart';
import 'package:dashboard/data/models/shipment_model/hive_shipment.dart';
import 'package:dashboard/data/models/prcel_model/hive_parcel.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ShipmentController with ChangeNotifier {
  final DatabaseHelperShipment dataInit;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Box<Shipment> _shipmentBox;
  late Box<Parcel> _parcelBox;

  List<Shipment> _shipments = [];
  List<Shipment> get shipments => List.unmodifiable(_shipments);

  List<Shipment> _filteredShipments = [];
  List<Shipment> get filteredShipments => List.unmodifiable(_filteredShipments);

  String? _currentFilter;
  String? get currentFilter => _currentFilter;

  int get totalShipments => _shipments.length;

  int get completedShipments =>
      _shipments.where((s) => s.deliveryDate != null).length;

  int get pendingShipments =>
      _shipments.where((s) => s.deliveryDate == null).length;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  ShipmentController(this.dataInit) {
    _init();
    _filteredShipments = List.from(_shipments);
  }

  Future<void> _init() async {
    try {
      _isLoading = true;
      notifyListeners();

      _shipmentBox = await Hive.openBox<Shipment>('shipments');
      _parcelBox = await Hive.openBox<Parcel>('parcel');

      await _loadInitialData();
      _listenToRealtimeUpdates();

      _error = null;
    } catch (e) {
      _error = 'Failed to initialize: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadInitialData() async {
    try {
      await _loadFromHive();
      await fetchShipmentsFromFirestore();
    } catch (e) {
      print("⚠️ Falling back to Firestore due to Hive error: $e");
      await fetchShipmentsFromFirestore();
    }
  }

  /// إضافة طرد إلى شحنة
  Future<void> addParcelToShipment(String shipmentId, Parcel parcel,
      ParcelController parcelController) async {
    try {
      // 1. ربط الطرد بالشحنة
      await parcelController.linkParcelToShipment(parcel.id, shipmentId);

      // 2. تحديث الشحنة
      final shipment = getShipmentById(shipmentId);
      if (shipment != null) {
        final updatedParcels = List<Parcel>.from(shipment.parcels)..add(parcel);
        final updatedShipment = shipment.copyWith(parcels: updatedParcels);

        await updateShipment(shipmentId, updatedShipment);
      }

      print("✅ تم إضافة الطرد ${parcel.trackingNumber} إلى الشحنة $shipmentId");
    } catch (e) {
      print("❌ خطأ في إضافة الطرد إلى الشحنة: $e");
      rethrow;
    }
  }

  /// إزالة طرد من شحنة
  Future<void> removeParcelFromShipment(String shipmentId, String parcelId,
      ParcelController parcelController) async {
    try {
      // 1. إلغاء ربط الطرد من الشحنة
      await parcelController.unlinkParcelFromShipment(parcelId);

      // 2. تحديث الشحنة
      final shipment = getShipmentById(shipmentId);
      if (shipment != null) {
        final updatedParcels =
            shipment.parcels.where((p) => p.id != parcelId).toList();
        final updatedShipment = shipment.copyWith(parcels: updatedParcels);

        await updateShipment(shipmentId, updatedShipment);
      }

      print("✅ تم إزالة الطرد $parcelId من الشحنة $shipmentId");
    } catch (e) {
      print("❌ خطأ في إزالة الطرد من الشحنة: $e");
      rethrow;
    }
  }

  Future<void> _loadFromHive() async {
    _shipments = _shipmentBox.values.toList();
    notifyListeners();
  }

  Future<void> fetchShipmentsFromFirestore() async {
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore.collection('shipments').get();

      _shipments = await Future.wait(snapshot.docs.map((doc) async {
        try {
          return Shipment.fromJson(doc.data());
        } catch (e) {
          print("⚠️ Error parsing document ${doc.id}: $e");
          return Shipment.empty(); // Fallback to empty shipment
        }
      }));

      await _persistToHive();

      _error = null;
      print("✅ Successfully loaded ${_shipments.length} shipments");
    } catch (e) {
      _error = 'Failed to fetch shipments: ${e.toString()}';
      print("❌ Fetch error: $_error");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _persistToHive() async {
    try {
      await _shipmentBox.clear();

      // Use a loop instead of batch
      for (final shipment in _shipments) {
        await _shipmentBox.put(shipment.shippingID.toString(), shipment);
      }
    } catch (e) {
      print("⚠️ Hive persistence error: $e");
    }
  }

  Future<void> addShipment(Shipment shipment) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestore
          .collection('shipments')
          .doc(shipment.shippingID.toString())
          .set(_convertShipmentForFirestore(shipment));

      await _shipmentBox.put(shipment.shippingID.toString(), shipment);
      _shipments.add(shipment);

      _error = null;
      print("✅ Added shipment ${shipment.shippingID}");
    } catch (e) {
      _error = 'Failed to add shipment: ${e.toString()}';
      print("❌ Add error: $_error");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Map<String, dynamic> _convertShipmentForFirestore(Shipment shipment) {
    final json = shipment.toJson();
    // Convert nested parcels
    json['parcels'] = shipment.parcels.map((p) => p.toJson()).toList();
    return json;
  }

  Future<void> updateShipment(String id, Shipment updatedShipment) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestore
          .collection('shipments')
          .doc(id)
          .update(_convertShipmentForFirestore(updatedShipment));

      await _shipmentBox.put(id, updatedShipment);

      final index = _shipments.indexWhere((s) => s.shippingID.toString() == id);
      if (index != -1) {
        _shipments[index] = updatedShipment;
      }

      _error = null;
      print("✅ Updated shipment $id");
    } catch (e) {
      _error = 'Failed to update shipment: ${e.toString()}';
      print("❌ Update error: $_error");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteShipment(String id) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestore.collection('shipments').doc(id).delete();
      await _shipmentBox.delete(id);
      _shipments.removeWhere((s) => s.shippingID.toString() == id);

      _error = null;
      print("✅ Deleted shipment $id");
    } catch (e) {
      _error = 'Failed to delete shipment: ${e.toString()}';
      print("❌ Delete error: $_error");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _listenToRealtimeUpdates() {
    _firestore.collection('shipments').snapshots().listen((snapshot) async {
      try {
        _shipments = snapshot.docs.map((doc) {
          try {
            return Shipment.fromJson(doc.data());
          } catch (e) {
            print("⚠️ Realtime update parsing error: $e");
            return Shipment.empty();
          }
        }).toList();

        await _persistToHive();
        _error = null;
        print("🔄 Real-time update: ${_shipments.length} shipments");
      } catch (e) {
        _error = 'Realtime update failed: ${e.toString()}';
        print("❌ Realtime error: $_error");
      } finally {
        notifyListeners();
      }
    }, onError: (e) {
      _error = 'Realtime listener error: ${e.toString()}';
      print("❌ Listener error: $_error");
      notifyListeners();
    });
  }

  void filterBy(
      {String? address,
      String? status,
      String? searchQuery,
      bool? hasParcels,
      String? supervisorId}) {
    _currentFilter = status;

    if (address == null &&
        status == null &&
        searchQuery == null &&
        hasParcels == null &&
        supervisorId == null) {
      _filteredShipments = List.from(_shipments);
      notifyListeners();
      return;
    }

    _filteredShipments = _shipments.where((shipment) {
      bool matchesAddress = true;
      bool matchesStatus = true;
      bool matchesSearch = true;
      bool matchesHasParcels = true;
      bool matchesSupervisor = true;

      if (address != null && address.isNotEmpty) {
        matchesAddress = shipment.shippingAddress
                .toLowerCase()
                .contains(address.toLowerCase()) ||
            shipment.shippingID.toString().contains(address);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        matchesSearch = shipment.shippingAddress
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            shipment.shippingID.toString().contains(searchQuery);
      }

      if (status != null) {
        if (status == 'completed') {
          matchesStatus = shipment.deliveryDate != null;
        } else if (status == 'pending') {
          matchesStatus = shipment.deliveryDate == null;
        }
      }

      if (hasParcels != null && hasParcels) {
        matchesHasParcels = shipment.parcels.isNotEmpty;
      }
      
      if (supervisorId != null) {
        matchesSupervisor = shipment.supervisorId == supervisorId;
      }

      return matchesAddress &&
          matchesStatus &&
          matchesSearch &&
          matchesHasParcels &&
          matchesSupervisor;
    }).toList();

    notifyListeners();
  }

  /// Reset all filters
  void resetFilters() {
    _currentFilter = null;
    _filteredShipments = List.from(_shipments);
    notifyListeners();
  }

  /// Get a shipment by its ID
  Shipment? getShipmentById(String id) {
    try {
      final intId = int.parse(id);
      return _shipments.firstWhere((s) => s.shippingID == intId);
    } catch (e) {
      print("❌ Error getting shipment by ID: $e");
      return null;
    }
  }

  /// Get shipments assigned to a specific delegate
  List<Shipment> getShipmentsByDelegateId(int delegateId) {
    try {
      return _shipments
          .where((shipment) => shipment.delegateID == delegateId)
          .toList();
    } catch (e) {
      print("❌ Error getting shipments by delegate ID: $e");
      return [];
    }
  }

  Future<void> assignSupervisor(String shipmentId, String supervisorId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final shipment = getShipmentById(shipmentId);
      if (shipment != null) {
        final updatedShipment = shipment.copyWith(supervisorId: supervisorId);
        await updateShipment(shipmentId, updatedShipment);
        print("✅ تم تعيين المشرف $supervisorId للشحنة $shipmentId");
      } else {
        throw Exception("لم يتم العثور على الشحنة");
      }
    } catch (e) {
      _error = 'فشل في تعيين المشرف: ${e.toString()}';
      print("❌ خطأ في تعيين المشرف: $_error");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeSupervisor(String shipmentId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final shipment = getShipmentById(shipmentId);
      if (shipment != null) {
        final updatedShipment = shipment.copyWith(supervisorId: null);
        await updateShipment(shipmentId, updatedShipment);
        print("✅ تم إزالة المشرف من الشحنة $shipmentId");
      } else {
        throw Exception("لم يتم العثور على الشحنة");
      }
    } catch (e) {
      _error = 'فشل في إزالة المشرف: ${e.toString()}';
      print("❌ خطأ في إزالة المشرف: $_error");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Shipment> getShipmentsBySupervisorId(String supervisorId) {
    try {
      return _shipments
          .where((shipment) => shipment.supervisorId == supervisorId)
          .toList();
    } catch (e) {
      print("❌ خطأ في الحصول على الشحنات بواسطة معرف المشرف: $e");
      return [];
    }
  }
}



