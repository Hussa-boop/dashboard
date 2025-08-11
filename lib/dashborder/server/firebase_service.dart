import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard/data/models/delegate_model/hive_delegate.dart';
import 'package:hive/hive.dart';
import 'package:dashboard/data/models/shipment_model/hive_shipment.dart';
import 'package:dashboard/data/models/prcel_model/hive_parcel.dart';


class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Box< Shipment> _shipmentBox;
  final Box<Parcel> _parcelBox;
  final Box<Delegate> _delegateBox;

  FirebaseService({
    required Box<Shipment> shipmentBox,
    required Box<Parcel> parcelBox,
    required Box<Delegate> delegateBox,
  })  : _shipmentBox = shipmentBox,
        _parcelBox = parcelBox,
        _delegateBox = delegateBox;

  // Shipment Methods
  Future<void> syncShipments() async {
    try {
      final snapshot = await _firestore.collection('shipments').get();
      for (var doc in snapshot.docs) {
        final shipment = Shipment.fromJson(doc.data());
        await _shipmentBox.put(shipment.shippingID.toString(), shipment);
      }
    } catch (e) {
      print('Error syncing shipments: $e');
      rethrow;
    }
  }

  Future<void> addShipment(Shipment shipment) async {
    try {
      await _firestore
          .collection('shipments')
          .doc(shipment.shippingID.toString())
          .set(shipment.toJson());
      await _shipmentBox.put(shipment.shippingID.toString(), shipment);
    } catch (e) {
      print('Error adding shipment: $e');
      rethrow;
    }
  }

  // Parcel Methods
  Future<void> syncParcels() async {
    try {
      final snapshot = await _firestore.collection('parcels').get();
      for (var doc in snapshot.docs) {
        final parcel = Parcel.fromJsonMap(doc.data());
        await _parcelBox.put(parcel.parceID.toString(), parcel);
      }
    } catch (e) {
      print('Error syncing parcels: $e');
      rethrow;
    }
  }

  Future<void> addParcel(Parcel parcel) async {
    try {
      await _firestore
          .collection('parcels')
          .doc(parcel.parceID.toString())
          .set(parcel.toJson());
      await _parcelBox.put(parcel.parceID.toString(), parcel);
    } catch (e) {
      print('Error adding parcel: $e');
      rethrow;
    }
  }

  // Delegate Methods
  Future<void> syncDelegates() async {
    try {
      final snapshot = await _firestore.collection('delegates').get();
      for (var doc in snapshot.docs) {
        final delegate = Delegate.fromJson(doc.data());
        await _delegateBox.put(delegate.delevID.toString(), delegate);
      }
    } catch (e) {
      print('Error syncing delegates: $e');
      rethrow;
    }
  }

  Future<void> addDelegate(Delegate delegate) async {
    try {
      await _firestore
          .collection('delegates')
          .doc(delegate.delevID.toString())
          .set(delegate.toJson());
      await _delegateBox.put(delegate.delevID.toString(), delegate);
    } catch (e) {
      print('Error adding delegate: $e');
      rethrow;
    }
  }

  // Relationship Methods
  Future<List<Parcel>> getParcelsForShipment(int shippingID) async {
    try {
      final snapshot = await _firestore
          .collection('parcels')
          .where('shippingID', isEqualTo: shippingID)
          .get();

      return snapshot.docs
          .map((doc) => Parcel.fromJsonMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting parcels for shipment: $e');
      rethrow;
    }
  }

  Future<List<Shipment>> getShipmentsForDelegate(int delegateID) async {
    try {
      final snapshot = await _firestore
          .collection('shipments')
          .where('delegateID', isEqualTo: delegateID)
          .get();

      return snapshot.docs.map((doc) => Shipment.fromJson(doc.data())).toList();
    } catch (e) {
      print('Error getting shipments for delegate: $e');
      rethrow;
    }
  }

  // Sync All Data
  Future<void> syncAllData() async {
    try {
      await Future.wait([
        syncShipments(),
        syncParcels(),
        syncDelegates(),
      ]);
    } catch (e) {
      print('Error syncing all data: $e');
      rethrow;
    }
  }
}
