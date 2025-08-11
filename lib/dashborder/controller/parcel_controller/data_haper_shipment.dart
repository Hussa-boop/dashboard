import 'package:hive/hive.dart';

import 'package:dashboard/data/models/prcel_model/hive_parcel.dart';

class DatabaseHelperParcel {
  static final DatabaseHelperParcel _instance =
      DatabaseHelperParcel._internal();
  Box<Parcel>? _parcelBox;

  factory DatabaseHelperParcel() {
    return _instance;
  }

  DatabaseHelperParcel._internal();

  Future<void> init() async {
    if (!Hive.isBoxOpen('parcel')) {
      _parcelBox = await Hive.openBox<Parcel>('parcel');
    } else {
      _parcelBox = Hive.box<Parcel>('parcel');
    }
  }

  Box<Parcel> get parcelBox {
    if (_parcelBox == null) {
      throw Exception('parcel box is not initialized');
    }
    return _parcelBox!;
  }

  List<Parcel> getShipments() {
    return _parcelBox?.values.toList() ?? [];
  }
}
