import 'package:dashboard/dashborder/screen/dashboard_home_screen/widget_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:dashboard/dashborder/controller/parcel_controller/data_haper_shipment.dart';
import 'package:dashboard/data/models/prcel_model/hive_parcel.dart';
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pdf/widgets.dart' as pw;
class ParcelController extends ChangeNotifier {
  final DatabaseHelperParcel _databaseHelper;
  Box<Parcel>? _parcelBox;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  String? _error;

  ParcelController(this._databaseHelper) {
    _init();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentFilter => _selectedStatus;
  Parcel? parcelPdf ;
  List<Parcel> get parcel => _parcelBox?.values.toList() ?? [];
  List<Parcel> filteredParcels = [];
  String _searchQuery = '';
  String _selectedStatus = 'الكل';
  String _selecteddestination = 'الكل';
  DateTime? _startDate;
  DateTime? _endDate;

  String get selectedStatus => _selectedStatus;
  String get selectedDestination => _selecteddestination;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  int get totalParcel => parcel.length;

  int get pendingParcel => parcel.where((s) => s.status == 'معلق').length;

  int get completedParcel =>
      parcel.where((s) => s.status == 'تم التسليم').length;

  int get cancelledParcel => parcel.where((s) => s.status == 'ملغى').length;
  int get inTransitParcel =>
      parcel.where((s) => s.status == 'في Transit').length;

  void applyFilters({
    String? searchQuery,
    String? status,
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    _searchQuery = searchQuery ?? _searchQuery;
    _selectedStatus = status ?? _selectedStatus;
    _selecteddestination = destination ?? _selectedStatus;
    _startDate = startDate ?? _startDate;
    _endDate = endDate ?? _endDate;

    filteredParcels = parcel.where((parcel) {
      final matchesSearch = _searchQuery.isEmpty ||
          parcel.trackingNumber
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());

      final matchesStatus =
          _selectedStatus == 'الكل' || parcel.status == _selectedStatus;

      final matchesDate = (_startDate == null ||
              (parcel.shippingDate != null &&
                  parcel.shippingDate!.isAfter(_startDate!))) &&
          (_endDate == null ||
              (parcel.shippingDate != null &&
                  parcel.shippingDate!.isBefore(_endDate!)));

      return matchesSearch && matchesStatus && matchesDate;
    }).toList();

    notifyListeners();
  }

  void resetFilters() {
    applyFilters(
      searchQuery: '',
      status: 'الكل',
      destination: 'الكل',
      startDate: null,
      endDate: null,
    );
  }

  void filterBy({String? status, bool? unlinked}) {
    if (status != null) {
      _selectedStatus = status;
    }

    if (unlinked != null && unlinked) {
      filteredParcels = parcel
          .where((p) => p.shipmentID == null || p.shipmentID!.isEmpty)
          .toList();
    } else {
      applyFilters();
    }

    notifyListeners();
  }

  /// 🔹 **تهيئة البيانات عند بدء التطبيق**
  Future<void> _init() async {
    try {
      await _databaseHelper.init();
      _parcelBox = _databaseHelper.parcelBox;
      await fetchParcelsFromFirestore();
      setupFirestoreListener();
      applyFilters();
    } catch (e) {
      print('Error initializing ParcelController: $e');
      rethrow;
    }
  }

// ربط طرد بشحنة
  Future<void> linkParcelToShipment(String parcelId, String shipmentId) async {
    try {
      // 1. التحديث في Firestore
      await _firestore.collection('parcel').doc(parcelId).update({
        'shipmentID': shipmentId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 2. التحديث في Hive
      final parcel = _parcelBox?.get(parcelId);
      if (parcel != null) {
        await _parcelBox?.put(
            parcelId, parcel.copyWith(shipmentID: shipmentId));
      }

      // 3. تحديث القائمة المفلترة
      applyFilters();

      print("✅ تم ربط الطرد $parcelId بالشحنة $shipmentId");
    } catch (e) {
      print("❌ فشل في ربط الطرد: ${e.toString()}");
      throw Exception("فشل في ربط الطرد بالشحنة");
    }
  }

  /// إلغاء ربط طرد من شحنة
  Future<void> unlinkParcelFromShipment(String parcelId) async {
    await linkParcelToShipment(
        parcelId, ''); // Use empty string instead of null
  }

  /// الحصول على جميع الطرود المرتبطة بشحنة معينة
  List<Parcel> getParcelsByShipmentId(String shipmentId) {
    return parcel.where((p) => p.shipmentID == shipmentId).toList();
  }

  /// الحصول على الطرود غير المرتبطة بأي شحنة
  List<Parcel> getUnlinkedParcels() {
    return parcel.where((p) => p.shipmentID == null).toList();
  }

  /// ✅ **جلب الطرود من Firestore إلى Hive**
  Future<void> fetchParcelsFromFirestore() async {
    try {
      final snapshot = await _firestore.collection('parcel').get();

      final List<Parcel> shipments = snapshot.docs.map((doc) {
        final data = doc.data();

        // معالجة وتحويل أنواع البيانات
        final shippingDate = data['shippingDate'] != null
            ? (data['shippingDate'] as Timestamp).toDate()
            : null;

        final longitude = data['longitude']?.toDouble();
        final latitude = data['latitude']?.toDouble();
        final receiverPhone = data['receiverPhone'];

        return Parcel(
          id: data['id'] ?? doc.id, // استخدام معرف المستند إذا لم يكن هناك id
          trackingNumber: data['trackingNumber'] ?? '',
          status: data['status'] ?? 'pending',
          shippingDate: shippingDate,
          senderName: data['senderName'] ?? '',
          receiverName: data['receiverName'] ?? '',
          orderName: data['orderName'] ?? '',
          longitude: longitude,
          latitude: latitude,
          receiverPhone: receiverPhone,
          destination: data['destination'],
          parceID: data['parceID'] ?? 0,
          receverName: data['receverName'] ?? '',
          prWight: data['prWight']?.toDouble() ?? 0.0,
          preType: data['preType'] ?? 'قياسي',
        );
      }).toList();

      // تخزين في Hive مع معالجة الأخطاء
      await _parcelBox?.clear();
      for (var shipment in shipments) {
        try {
          await _parcelBox?.put(shipment.id, shipment);
        } catch (e) {
          print('⚠️ خطأ في تخزين الشحنة ${shipment.id}: $e');
        }
      }

      notifyListeners();
      print('✅ تم جلب ${shipments.length} شحنة بنجاح من Firestore إلى Hive');
    } catch (e) {
      print('❌ فشل في جلب الشحنات: ${e.toString()}');
      throw Exception('فشل في تحديث بيانات الشحنات');
    }
  }

// 1. إعداد مستمع Firestore للتحديثات الفورية
  void setupFirestoreListener() {
    _firestore.collection('parcel').snapshots().listen((snapshot) {
      filteredParcels = snapshot.docs.map((doc) {
        final data = doc.data();
        return Parcel(
          id: doc.id,
          trackingNumber: data['trackingNumber'] ?? '',
          status: data['status'] ?? 'معلق',
          shippingDate: data['shippingDate']?.toDate(),
          senderName: data['senderName'] ?? '',
          receiverName: data['receiverName'] ?? '',
          orderName: data['orderName'] ?? '',
          longitude: data['longitude']?.toDouble(),
          latitude: data['latitude']?.toDouble(),
          receiverPhone: data['receiverPhone'],
          destination: data['destination'],
          parceID: data['parceID'] ?? 0,
          receverName: data['receverName'] ?? '',
          prWight: data['prWight']?.toDouble() ?? 0.0,
          preType: data['preType'] ?? 'قياسي',
        );
      }).toList();

      _updateHiveBox(filteredParcels);
      applyFilters();
    });
  }

  // 2. تحديث صندوق Hive مع البيانات الجديدة
  Future<void> _updateHiveBox(List<Parcel> shipments) async {
    await _parcelBox?.clear();
    for (var shipment in shipments) {
      await _parcelBox?.put(shipment.id, shipment);
    }
    notifyListeners();
  }

  /// 📤 **إضافة طرد جديدة إلى Firestore و Hive**
  Future<void> addParcelsToFirestore(Parcel shipment) async {
    try {
      // تحويل كائن الطرد إلى Map لـ Firestore
      final shipmentData = {
        'id': shipment.id,
        'trackingNumber': shipment.trackingNumber,
        'status': shipment.status,
        'shippingDate': shipment.shippingDate != null
            ? Timestamp.fromDate(shipment.shippingDate!)
            : null,
        'senderName': shipment.senderName,
        'receiverName': shipment.receiverName,
        'orderName': shipment.orderName,
        'longitude': shipment.longitude,
        'latitude': shipment.latitude,
        'receiverPhone': shipment.receiverPhone,
        'destination': shipment.destination,
        'preType': shipment.preType,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // إضافة إلى Firestore
      await _firestore.collection('parcel').doc(shipment.id).set(shipmentData);

      // إضافة إلى Hive
      await _parcelBox?.put(shipment.id, shipment);

      notifyListeners();
      print("✅ تم إضافة الطرد ${shipment.trackingNumber} بنجاح");
    } catch (e) {
      print("❌ فشل في إضافة الطرد: ${e.toString()}");
      throw Exception("حدث خطأ أثناء إضافة الطرد");
    }
  }

  /// ✏️ **تحديث بيانات الطرود في Firestore و Hive مع جلب فوري للتحديثات**
  Future<void> updateParcelInFirestore(String id, Parcel updatedParcel) async {
    try {
      // 1. تحضير بيانات التحديث
      final updateData = {
        'trackingNumber': updatedParcel.trackingNumber,
        'status': updatedParcel.status,
        'shippingDate': updatedParcel.shippingDate != null
            ? Timestamp.fromDate(updatedParcel.shippingDate!)
            : null,
        'senderName': updatedParcel.senderName,
        'receiverName': updatedParcel.receiverName,
        'orderName': updatedParcel.orderName,
        'longitude': updatedParcel.longitude,
        'latitude': updatedParcel.latitude,
        'receiverPhone': updatedParcel.receiverPhone,
        'destination': updatedParcel.destination,
        'preType': updatedParcel.preType,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // 2. التحديث في Firestore مع الانتظار حتى اكتمال العملية
      await _firestore.collection('parcel').doc(id).update(updateData);

      // 3. جلب أحدث نسخة من Firestore بعد التحديث مباشرة
      final docSnapshot = await _firestore.collection('parcel').doc(id).get();
      final freshData = docSnapshot.data()!;

      // 4. تحديث الكائن المحلي بأحدث البيانات
      final freshShipment = Parcel(
        id: freshData['id'] ?? id,
        trackingNumber:
            freshData['trackingNumber'] ?? updatedParcel.trackingNumber,
        status: freshData['status'] ?? updatedParcel.status,
        shippingDate: freshData['shippingDate']?.toDate(),
        senderName: freshData['senderName'] ?? updatedParcel.senderName,
        receiverName: freshData['receiverName'] ?? updatedParcel.receiverName,
        orderName: freshData['orderName'] ?? updatedParcel.orderName,
        longitude: freshData['longitude']?.toDouble(),
        latitude: freshData['latitude']?.toDouble(),
        receiverPhone: freshData['receiverPhone'],
        destination: freshData['destination'],
        parceID: freshData['parceID'] ?? updatedParcel.parceID,
        receverName: freshData['receverName'] ?? updatedParcel.receverName,
        prWight: freshData['prWight']?.toDouble() ?? updatedParcel.prWight,
        preType: freshData['preType'] ?? updatedParcel.preType,
      );

      // 5. التحديث في Hive بأحدث نسخة
      await _parcelBox?.put(id, freshShipment);

      // 6. تحديث القائمة المحلية
      final index = parcel.indexWhere((s) => s.id == id);
      if (index != -1) {
        parcel[index] = freshShipment;
        applyFilters(); // إعادة تطبيق الفلاتر إذا كنت تستخدمها
      }

      notifyListeners();
      print(
          "✅ تم تحديث الشحنة ${freshShipment.trackingNumber} بنجاح مع التزامن الفوري");
    } catch (e) {
      print("❌ فشل في تحديث الشحنة: ${e.toString()}");
      throw Exception("حدث خطأ أثناء تحديث الشحنة: ${e.toString()}");
    }
  }

  /// 🗑 **حذف الطرد من Firestore و Hive**
  Future<void> deleteParcelFromFirestore(String id) async {
    try {
      await _firestore.collection('parcel').doc(id).delete();

      await _parcelBox?.delete(id);
      notifyListeners();
      // 4️⃣ إعادة تحميل الشحنات للتأكد من التزامن الفوري
      setupFirestoreListener(); // ✅ تحديث البيانات فورًا بعد الحذف
      print("✅ تم حذف الشحنة من Firestore و Hive");
    } catch (e) {
      print("❌ فشل في حذف الشحنة: $e");
    }
  }

  /// 📌 **متغيرات التحكم في الفلاتر**
  List<SalesDataHomeDash> getParcelsOverTime() {
    return [
      SalesDataHomeDash(
          'يناير', parcel.where((s) => s.shippingDate?.month == 1).length),
      SalesDataHomeDash(
          'فبراير', parcel.where((s) => s.shippingDate?.month == 2).length),
      SalesDataHomeDash(
          'مارس', parcel.where((s) => s.shippingDate?.month == 3).length),
      SalesDataHomeDash(
          'أبريل', parcel.where((s) => s.shippingDate?.month == 4).length),
      SalesDataHomeDash(
          'مايو', parcel.where((s) => s.shippingDate?.month == 5).length),
    ];
  }

  /// 📍 **الحصول على الموقع الحالي**
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // ✅ التحقق من تفعيل خدمة الموقع
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("❌ خدمة الموقع غير مفعلة");
      return null;
    }

    // ✅ طلب الإذن للوصول إلى الموقع
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("❌ لم يتم منح إذن الوصول إلى الموقع");
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print("❌ تم حظر إذن الموقع بشكل دائم!");
      return null;
    }

    // ✅ الحصول على الموقع الحالي
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    print("✅ الموقع الحالي: ${position.latitude}, ${position.longitude}");
    return position;
  }

  /// 📌 **تحديث موقع الطرد في Firestore**
  Future<void> updateParcelLocation(
      String shipmentId, double lat, double lng) async {
    try {
      await _firestore.collection('parcel').doc(shipmentId).update({
        "latitude": lat,
        "longitude": lng,
      });
      print("✅ تم تحديث موقع الشحنة في Firestore بنجاح");
    } catch (e) {
      print("❌ فشل في تحديث موقع الشحنة: $e");
    }
  }


// دالة مساعدة لإنشاء صفوف الجدول
  pw.TableRow _buildRow(String title, String? value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(4),
          child: pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(4),
          child: pw.Text(value ?? 'غير متوفر'),
        ),
      ],
    );
  }

// دالة مساعدة لإنشاء صفوف المعلومات
  pw.Widget _buildInfoRow(String title, String? value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        children: [
          pw.Text('$title: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text(value ?? 'غير متوفر'),
        ],
      ),
    );
  }
}
