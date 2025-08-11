import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:dashboard/data/models/premission_model/permissions_hive.dart';




class DatabaseHelperPrmissions {
  static final DatabaseHelperPrmissions _instance = DatabaseHelperPrmissions._internal();
  Box<PermissionsHive>? _userBox;

  factory DatabaseHelperPrmissions() {
    return _instance;
  }


  Future<List<PermissionsHive>> fetchPermissions() async {
    try {
      final response = await http.get(
        Uri.parse("http://localhost/fetch_permissions.php"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((item) => PermissionsHive.fromJson(item)).toList();
      } else {
        throw Exception('Failed to fetch: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Server error: $e');
    }
  }

  Future<void> uploadPermissions(List<PermissionsHive> permissions,context) async {
    const url = 'http://localhost/upload_permissions.php';
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };

    try {
      // تحويل البيانات إلى JSON
      final data = permissions.map((p) => p.toJson()).toList();
      final jsonData = jsonEncode(data);

      // إرسال الطلب
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonData,
      );

      // تحقق من حالة الاستجابة
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          print('✅ تم رفع الصلاحيات بنجاح: ${responseData['message']}');
        } else {
          showDialog(
            context: context,
            barrierDismissible: false, // يمنع إغلاق النافذة بالنقر خارجها
            builder: (context) {
              return AlertDialog(
                title: const Text("خطأ في الاتصال بالخادم"),
                content: const Text("تعذر الاتصال بالخادم. يرجى التحقق من الإنترنت والمحاولة مرة أخرى."),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("موافق"),
                  ),
                ],
              );
            },
          );
        }
      } else {
        throw Exception('فشل في الاتصال بالخادم: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('خطأ في العميل: ${e.message}');
    } catch (e) {
      throw Exception('خطأ غير متوقع: $e');
    }
  }
  DatabaseHelperPrmissions._internal();

  Future<void> init() async {
    _userBox = await Hive.openBox<PermissionsHive>('permissionsBox');
  }

  Box<PermissionsHive> get userBox {
    if (_userBox == null) {
      throw Exception('User box is not initialized');
    }
    return _userBox!;
  }
  List<PermissionsHive> getShipments() {

    return _userBox?.values.toList() ?? [];
  }
}