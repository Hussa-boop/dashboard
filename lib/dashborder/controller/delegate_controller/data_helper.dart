import 'package:dashboard/data/models/delegate_model/hive_delegate.dart';
import 'package:hive/hive.dart';



class DatabaseHelperDelegate {
  static final DatabaseHelperDelegate _instance = DatabaseHelperDelegate._internal();
  Box<Delegate>? _parcelBox;

  factory DatabaseHelperDelegate() {
    return _instance;
  }

  DatabaseHelperDelegate._internal();

  Future<void> init() async {

    _parcelBox = await Hive.openBox('delegates', compactionStrategy: (entries, deletedEntries) => deletedEntries > (entries * 0.2));

  }

  Box<Delegate> get parcelBox {
    if (_parcelBox == null) {
      throw Exception('delegates box is not initialized');
    }
    return _parcelBox!;
  }


}