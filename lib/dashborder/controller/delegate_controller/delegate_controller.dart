import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard/dashborder/controller/delegate_controller/data_helper.dart';
import 'package:dashboard/data/models/delegate_model/hive_delegate.dart';
import 'package:dashboard/data/models/shipment_model/hive_shipment.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DelegateController with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Box<Delegate> _delegateBox;
  late Box<Shipment> _shipmentBox;
  final DatabaseHelperDelegate databaseHelperDelegate;
  // State management
  List<Delegate> _delegates = [];
  List<Delegate> _filteredDelegates = [];
  bool _isLoading = false;
  String? _error;
  String? _currentFilter;

  // Getters
  List<Delegate> get delegates => List.unmodifiable(_delegates);
  List<Delegate> get filteredDelegates => List.unmodifiable(_filteredDelegates);
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentFilter => _currentFilter;
  int get totalDelegates => _delegates.length;

  DelegateController(this.databaseHelperDelegate) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      _isLoading = true;
      notifyListeners();
      _shipmentBox = await Hive.openBox<Shipment>('shipments');
      _delegateBox = await Hive.openBox<Delegate>('delegates');

      // Then load data
      await _loadInitialData();

      // Finally set up listeners
      _setupListeners();

      _error = null;
    } catch (e) {
      _error = 'Failed to initialize: ${e.toString()}';
      print('❌ Error initializing DelegateController: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  int getActiveDelegatesCount() {
    return _delegates.where((delegate) {
      // يمكنك تعديل شرط النشاط حسب منطق تطبيقك
      return delegate.isActive ?? false;
    }).length;
  }

  Future<void> loadMoreDelegates() async {
    try {
      _isLoading = true;
      notifyListeners();

      // جلب الدفعة التالية من المندوبين
      final lastDelegate = _delegates.isNotEmpty ? _delegates.last : null;
      final snapshot = await _firestore
          .collection('delegates')
          .orderBy('delevID')
          .startAfter([lastDelegate?.delevID])
          .limit(10)
          .get();

      final newDelegates =
          snapshot.docs.map((doc) => Delegate.fromJson(doc.data())).toList();
      _delegates.addAll(newDelegates);
      await _persistToHive(_delegates);
      _applyFilters();

      _error = null;
    } catch (e) {
      _error = 'Failed to load more delegates: ${e.toString()}';
      print('❌ Load more error: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  int getInactiveDelegatesCount() {
    return _delegates.where((delegate) {
      return !(delegate.isActive ?? true);
    }).length;
  }

  Future<void> _loadInitialData() async {
    try {
      // Check if boxes are open before trying to load from Hive
      if (_delegateBox.isOpen) {
        await _loadFromHive();
        if (_delegateBox.isEmpty) {
          await fetchDelegatesFromFirestore();
        }
      } else {
        print('⚠️ Delegate box is not open, loading from Firestore directly');
        await fetchDelegatesFromFirestore();
      }
    } catch (e) {
      print('⚠️ Falling back to Firestore due to Hive error: $e');
      await fetchDelegatesFromFirestore();
    }
  }

  Future<void> _loadFromHive() async {
    try {
      if (!_delegateBox.isOpen) {
        print('⚠️ Delegate box is not open, skipping load from Hive');
        return;
      }

      _delegates = _delegateBox.values.toList();
      _filteredDelegates = _delegates;
    } catch (e) {
      print('⚠️ Error loading from Hive: $e');
      _delegates = [];
      _filteredDelegates = [];
    }
  }

  void _setupListeners() {
    _firestore.collection('delegates').snapshots().listen((snapshot) async {
      try {
        _delegates =
            snapshot.docs.map((doc) => Delegate.fromJson(doc.data())).toList();
        await _persistToHive(_delegates);
        _applyFilters();

        _error = null;
        print('🔄 Real-time update: ${_delegates.length} delegates');
      } catch (e) {
        _error = 'Realtime update failed: ${e.toString()}';
        print('❌ Realtime error: $_error');
      } finally {
        notifyListeners();
      }
    }, onError: (e) {
      _error = 'Realtime listener error: ${e.toString()}';
      print('❌ Listener error: $_error');
      notifyListeners();
    });
  }

  Future<void> _persistToHive(List<Delegate> delegates) async {
    try {
      if (!_delegateBox.isOpen) {
        print('⚠️ Delegate box is not open, skipping persistence');
        return;
      }

      await _delegateBox.clear();

      for (final delegate in delegates) {
        await _delegateBox.put(delegate.delevID.toString(), delegate);
      }
    } catch (e) {
      print('⚠️ Hive persistence error: $e');
    }
  }

  /// 🔄 Fetch delegates from Firestore
  Future<void> fetchDelegatesFromFirestore() async {
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore.collection('delegates').get();
      _delegates =
          snapshot.docs.map((doc) => Delegate.fromJson(doc.data())).toList();

      await _persistToHive(_delegates);
      _applyFilters();

      _error = null;
      print('✅ Fetched ${_delegates.length} delegates from Firestore');
    } catch (e) {
      _error = 'Failed to fetch delegates: ${e.toString()}';
      print('❌ Fetch error: $_error');
      throw Exception('Failed to load delegates');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ➕ Add new delegate
  Future<void> addDelegate(Delegate delegate) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestore
          .collection('delegates')
          .doc(delegate.delevID.toString())
          .set(delegate.toJson());

      await _delegateBox.put(delegate.delevID.toString(), delegate);
      _delegates.add(delegate);
      notifyListeners();
      print("✅ تم إضافة المندوب ${delegate.delevID}");
    } catch (e) {
      print("❌ خطأ في إضافة المندوب: $e");
    }
  }

  /// ✅ تحديث مندوب
  Future<void> updateDelegate(String id, Delegate updatedDelegate) async {
    try {
      // Try to update first
      try {
        await _firestore
            .collection('delegates')
            .doc(id)
            .update(updatedDelegate.toJson());
      } catch (e) {
        // If document doesn't exist, create it
        if (e.toString().contains('not-found')) {
          await _firestore
              .collection('delegates')
              .doc(id)
              .set(updatedDelegate.toJson());
        } else {
          rethrow;
        }
      }

      await _delegateBox.put(id, updatedDelegate);

      final index = _delegates.indexWhere((d) => d.delevID.toString() == id);
      if (index != -1) {
        _delegates[index] = updatedDelegate;
      } else {
        _delegates.add(updatedDelegate);
      }
      notifyListeners();
      print("✅ تم تحديث/إنشاء المندوب $id");
    } catch (e) {
      _error = 'Failed to update delegate: ${e.toString()}';
      print("❌ Update error: $_error");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 🗑 حذف مندوب
  Future<void> deleteDelegate(String id) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestore.collection('delegates').doc(id).delete();
      await _delegateBox.delete(id);
      _delegates.removeWhere((d) => d.delevID.toString() == id);
      _applyFilters();

      _error = null;
      print("✅ Deleted delegate $id");
    } catch (e) {
      _error = 'Failed to delete delegate: ${e.toString()}';
      print("❌ Delete error: $_error");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 🔍 Filter delegates
  void filterDelegates({String? query, String? status}) {
    _currentFilter = status;
    _applyFilters(query: query, status: status);
  }

  void _applyFilters({String? query, String? status}) {
    _filteredDelegates = _delegates.where((delegate) {
      final matchesSearch = query == null ||
          query.isEmpty ||
          delegate.deveName.toLowerCase().contains(query.toLowerCase()) ||
          delegate.deveAddress.toLowerCase().contains(query.toLowerCase());

      final matchesStatus = status == null ||
          (status == 'active' && delegate.isActive == true) ||
          (status == 'inactive' && delegate.isActive == false) ||
          (status == 'with_parcels' &&
              getShipmentsByDelegateId(delegate.delevID).isNotEmpty);

      return matchesSearch && matchesStatus;
    }).toList();

    notifyListeners();
  }

  /// 🔄 Reset all filters
  void resetFilters() {
    _currentFilter = null;
    _filteredDelegates = _delegates;
    notifyListeners();
  }

  /// 👤 Get delegate by ID
  Delegate? getDelegateById(String id) {
    try {
      if (!_delegateBox.isOpen) {
        return null;
      }
      return _delegateBox.get(id);
    } catch (e) {
      print('❌ Error getting delegate by ID: $e');
      return null;
    }
  }

  /// 📦 Get shipments assigned to delegate
  List<Shipment> getShipmentsByDelegateId(int delegateId) {
    try {
      if (!_shipmentBox.isOpen) {
        return [];
      }
      return _shipmentBox.values
          .where((shipment) => shipment.delegateID == delegateId)
          .toList();
    } catch (e) {
      print('❌ Error getting shipments: $e');
      return [];
    }
  }

  /// 🔗 Assign delegate to shipment
  Future<void> assignDelegateToShipment(
      String shipmentId, int delegateId) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Convert shipmentId to int for Hive lookup
      final int shipmentIdInt = int.parse(shipmentId);
      final shipment = _shipmentBox.get(shipmentIdInt.toString());

      if (shipment != null) {
        final updatedShipment = shipment.copyWith(delegateID: delegateId);

        await _firestore
            .collection('shipments')
            .doc(shipmentId)
            .update(updatedShipment.toJson());

        await _shipmentBox.put(shipmentIdInt.toString(), updatedShipment);

        _error = null;
        print("✅ Assigned delegate $delegateId to shipment $shipmentId");
      } else {
        _error = 'Shipment $shipmentId not found';
        print("❌ $_error");
      }
    } catch (e) {
      _error = 'Failed to assign delegate: ${e.toString()}';
      print("❌ Assignment error: $_error");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 🚚 Get available delegates (not assigned to shipment)
  List<Delegate> getAvailableDelegates() {
    try {
      if (!_shipmentBox.isOpen || !_delegateBox.isOpen) {
        return _delegates;
      }

      final assignedDelegates = _shipmentBox.values
          .where((s) => s.delegateID != null)
          .map((s) => s.delegateID)
          .toSet();

      return _delegates
          .where((d) => !assignedDelegates.contains(d.delevID))
          .toList();
    } catch (e) {
      print('❌ Error getting available delegates: $e');
      return _delegates;
    }
  }
}
