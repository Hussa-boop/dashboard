import 'package:flutter/material.dart';


class MenusController extends ChangeNotifier {
  GlobalKey<ScaffoldState>? scaffoldKey; // ✅ اجعل المفتاح قابلاً للتحديث

  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  void updateSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void setScaffoldKey(GlobalKey<ScaffoldState> key) {
    scaffoldKey = key; // ✅ السماح بتحديث المفتاح عند إنشاء `HomePagesDashBoard`
    notifyListeners();
  }

  void controlMenu() {
    if (scaffoldKey?.currentState?.isDrawerOpen == false) {
      scaffoldKey?.currentState?.openDrawer();
    }
  }
}
