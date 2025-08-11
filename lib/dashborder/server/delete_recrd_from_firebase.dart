import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

class MaintenanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // حذف البيانات القديمة تلقائيًا
  Future<void> autoCleanData() async {
    await _cleanFirestoreCollections();
    await _cleanHiveBoxes();
  }

  // حذف مجموعات Firestore
  Future<void> _cleanFirestoreCollections() async {
    const retentionDays = 30; // احتفظ بالبيانات لآخر 30 يومًا فقط
    final cutoffDate = DateTime.now().subtract(Duration(days: retentionDays));

    // 1. تنظيف سجلات الدخول (login_logs)
    await _deleteOldDocuments('login_logs', 'timestamp', cutoffDate);

    // 2. تنظيف الجلسات النشطة (active_sessions)
    await _deleteOldDocuments('active_sessions', 'lastLogin', cutoffDate);

    // 3. تنظيف إجراءات المستخدم (user_actions)
    await _deleteOldDocuments('user_actions', 'timestamp', cutoffDate);

    // 4. تنظيف الأخطاء (errors)
    await _deleteOldDocuments('errors', 'timestamp', cutoffDate);
  }

  Future<void> _deleteOldDocuments(
      String collection, String dateField, DateTime cutoffDate) async {
    final query = _firestore
        .collection(collection)
        .where(dateField, isLessThan: cutoffDate);

    final snapshot = await query.get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
    print('تم حذف ${snapshot.size} وثيقة قديمة من $collection');
  }

  // حذف بيانات Hive
  Future<void> _cleanHiveBoxes() async {
    try {
      final boxes = [
        'login_logs',
        'active_sessions',
        'user_actions',
        'errors',

      ];

      for (final box in boxes) {
        if (Hive.isBoxOpen(box)) {
          await Hive.box(box).clear();
        } else {
          await Hive.openBox(box).then((box) => box.clear());
        }
        print('تم تنظيف صندوق Hive: $box');
      }
    } catch (e) {
      print('خطأ أثناء تنظيف Hive: $e');
    }
  }
}