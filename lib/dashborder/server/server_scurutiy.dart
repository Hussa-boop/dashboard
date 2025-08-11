// services/log_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard/data/models/security_model.dart';
import 'package:flutter/material.dart';

class LogService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<LogEntry>> getLogsStream({
    String? userId,
    String? eventType,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    Query query = _firestore.collection('logs').orderBy('timestamp', descending: true);

    if (userId != null) {
      query = query.where('userId', isEqualTo: userId);
    }

    if (eventType != null) {
      query = query.where('eventType', isEqualTo: eventType);
    }

    if (startDate != null) {
      query = query.where('timestamp', isGreaterThanOrEqualTo: startDate);
    }

    if (endDate != null) {
      query = query.where('timestamp', isLessThanOrEqualTo: endDate);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => LogEntry.fromFirestore(doc)).toList();
    });
  }
  Future<List<LogEntry>> getFilteredLogs({
    String? userId,
    String? eventType,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }) async {
    try {
      Query query = FirebaseFirestore.instance
          .collection('login_logs')
          .orderBy('timestamp', descending: true)
          .limit(limit);

      if (userId != null) {
        query = query.where('userId', isEqualTo: userId);
      }

      if (eventType != null) {
        query = query.where('eventType', isEqualTo: eventType);
      }

      if (startDate != null) {
        query = query.where('timestamp', isGreaterThanOrEqualTo: startDate);
      }

      if (endDate != null) {
        query = query.where('timestamp', isLessThanOrEqualTo: endDate);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => LogEntry.fromFirestore(doc)).toList();
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition') {
        // يمكنك إضافة إشعار للمستخدم هنا
        debugPrint('Missing index. Please create it in Firebase console.');
      }
      rethrow;
    } catch (e) {
      debugPrint('Error getting logs: $e');
      return [];
    }
  }
}