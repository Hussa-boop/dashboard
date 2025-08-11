import 'package:dashboard/data/models/shipment_model/hive_shipment.dart';
import 'package:hive/hive.dart';



class DatabaseHelperShipment {
  static final DatabaseHelperShipment _instance = DatabaseHelperShipment._internal();
  Box<Shipment>? _parcelBox;

  factory DatabaseHelperShipment() {
    return _instance;
  }

  DatabaseHelperShipment._internal();

  Future<void> init() async {

    _parcelBox = await Hive.openBox('shipments', compactionStrategy: (entries, deletedEntries) => deletedEntries > (entries * 0.2));

  }

  Box<Shipment> get parcelBox {
    if (_parcelBox == null) {
      throw Exception('Shipments box is not initialized');
    }
    return _parcelBox!;
  }

  List<Shipment> getShipments() {
    return _parcelBox?.values.toList() ?? [];
  }
}