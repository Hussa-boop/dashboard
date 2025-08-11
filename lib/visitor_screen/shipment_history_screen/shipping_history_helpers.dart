import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/prcel_model/hive_parcel.dart';

// =============== Helper Methods ===============
List<Parcel> parseShipments(List<DocumentSnapshot> docs) {
  return docs.map((doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Parcel(
      id: doc.id,
      trackingNumber: data['trackingNumber'] ?? '',
      status: data['status'] ?? 'pending',
      shippingDate: data['shippingDate']?.toDate(),
      senderName: data['senderName'] ?? '',
      receiverName: data['receiverName'] ?? '',
      orderName: data['orderName'] ?? '',
      longitude: data['longitude']?.toDouble() ?? 0.0,
      latitude: data['latitude']?.toDouble() ?? 0.0,
      destination: data['destination'] ?? '',
      parceID: data['parceID'] ?? 0,
      receverName: data['receverName'] ?? data['receiverName'] ?? '',
      prWight: data['prWight']?.toDouble() ?? 0.0,
      noted: data['noted'],
      preType: data['preType'] ?? 'standard',
      shipmentID: data['shipmentID'],
    );
  }).toList();
}

List<Parcel> filterShipments({
  required List<Parcel> shipments,
  required String searchQuery,
  required String selectedFilter,
}) {
  return shipments.where((shipment) {
    final matchesSearch = shipment.trackingNumber.contains(searchQuery) ||
        shipment.orderName.toLowerCase().contains(searchQuery.toLowerCase()) ||
        shipment.senderName.toLowerCase().contains(searchQuery.toLowerCase()) ||
        shipment.receiverName.toLowerCase().contains(searchQuery.toLowerCase());

    final matchesFilter =
        selectedFilter == 'all' || shipment.status == selectedFilter;

    return matchesSearch && matchesFilter;
  }).toList();
}
