import 'package:flutter/material.dart';

class FilterController with ChangeNotifier {
  String _selectedRole = 'الكل';
  String _selectedStatus = 'الكل';

  String get selectedRole => _selectedRole;
  String get selectedStatus => _selectedStatus;

  void setSelectedRole(String role) {
    _selectedRole = role;
    notifyListeners();
  }

  void setSelectedStatus(String status) {
    _selectedStatus = status;
    notifyListeners();
  }
}