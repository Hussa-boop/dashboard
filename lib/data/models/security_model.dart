// models/log_entry.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LogEntry {
  final String id;
  final String userId;
  final String eventType;
  final String details;
  final DateTime timestamp;
  final String? ipAddress;
  final String? deviceInfo;

  LogEntry({
    required this.id,
    required this.userId,
    required this.eventType,
    required this.details,
    required this.timestamp,
    this.ipAddress,
    this.deviceInfo,
  });

  factory LogEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LogEntry(
      id: doc.id,
      userId: data['userId'] ?? 'unknown',
      eventType: data['eventType'] ?? 'action',
      details: data['details'] ?? 'No details',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      ipAddress: data['ipAddress'],
      deviceInfo: data['deviceInfo'],
    );
  }

  String get formattedTime {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp);
  }
  Color get eventColor {
    switch (eventType) {
      case 'login':
        return Colors.green;
      case 'logout':
        return Colors.blue;
      case 'error':
        return Colors.red;
      default: // للعمليات الأخرى
        return Colors.orange;
    }
  }
  String get eventIcon {
    switch (eventType) {
      case 'login':
        return '🔑';
      case 'logout':
        return '🚪';
      case 'error':
        return '❌';
      default:
        return '⚙️';
    }
  }
}