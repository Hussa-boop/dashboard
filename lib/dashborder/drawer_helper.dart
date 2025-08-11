import 'package:flutter/material.dart';

import '../main.dart';
import '../mobil/modules/screen_home/screen_login/login_screen.dart';
import 'controller/auth_controller.dart';
import 'package:flutter_treeview/flutter_treeview.dart';
import 'package:provider/provider.dart';

import 'controller/menu_controller.dart';
import 'package:dashboard/data/models/user_model/user_hive.dart';

Widget buildDrawerHeader(BuildContext context, UserHive? currentUser, ThemeData theme) {
  return Expanded(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [

        DrawerHeader(
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withOpacity(0.8),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: (currentUser?.profileImage != null)
                    ? AssetImage(currentUser!.profileImage)
                    : const AssetImage('assets/DeliveryTruckLoading.png'),
                backgroundColor: theme.cardColor,
              ),
              const SizedBox(height: 12),
              Text(
                currentUser?.name ?? "مستخدم غير معروف",
                style: theme.textTheme.subtitle1?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  "القائمة الرئيسية",
                  style: theme.textTheme.caption?.copyWith(
                    color: theme.colorScheme.onPrimary.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget buildSearchField(
    BuildContext context,
    ThemeData theme,
    TextEditingController? _searchController,
    String _searchQuery,
void Function()? onPressed,
void Function(String)? chang) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
    child: TextField(
      textAlign: TextAlign.right,
      controller: _searchController,
      decoration: InputDecoration(
        hintText: '...ابحث في القائمة',
        hintStyle: theme.textTheme.caption,
        prefixIcon: Icon(Icons.search, color: theme.textTheme.caption?.color),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),

        fillColor: theme.colorScheme.surface,
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
          icon: Icon(Icons.clear, size: 20),
          onPressed:onPressed,
        )
            : null,
      ),
      onChanged: chang,
    ),
  );
}
IconData? getForNode(String key) {
  switch (key) {
    case 'dashboard':
      return Icons.dashboard;
    case 'management':
      return Icons.settings;
    case 'users':
      return Icons.people;
    case 'shipments':
      return Icons.local_shipping;
    case 'permissions':
      return Icons.lock;
    case 'reports':
      return Icons.analytics;
    case 'statistics':
      return Icons.show_chart;
    case 'settings':
      return Icons.settings_applications;
    case 'systemConfig':
      return Icons.build;
      case 'delegate':
      return Icons.person;
      case 'employment':
      return Icons.person_outline;
      case 'parcel':
      return Icons.local_shipping_outlined;
    default:
      return Icons.folder;
  }
}
Widget buildMenuItems(
    BuildContext context,
    ThemeData theme,
    List<Node<dynamic>>? filteredNodes,
Map<String, int> _keyToIndexMap,
    TreeViewController _treeViewController,

dynamic Function(String)? _onNodeTap) {
  return Expanded(
    flex: 3,
    child: Theme(
      data: theme.copyWith(
        highlightColor: theme.colorScheme.primary.withOpacity(0.1),
        hoverColor: theme.colorScheme.primary.withOpacity(0.05),
      ),
      child: TreeView(
        controller: _treeViewController.copyWith(children: filteredNodes),
        allowParentSelect: true,
        supportParentDoubleTap: false,
        onNodeTap: _onNodeTap,
        nodeBuilder: (context, node) {
          final isSelected = _keyToIndexMap[node.key] ==
              Provider.of<MenusController>(context).selectedIndex;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary.withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary.withOpacity(0.1)
                        : theme.colorScheme.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                   getForNode(node.key),
                    size: 18,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.textTheme.bodyText1?.color,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    node.label,
                    textAlign: TextAlign.right,
                    style: theme.textTheme.bodyText1?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.textTheme.bodyText1?.color,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}

Widget buildLogoutButton(AuthController authController, ThemeData theme,BuildContext context) {
  return Container(
    margin: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: theme.colorScheme.surface,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, -4),
        ),
      ],
    ),
    child: ListTile(
      leading: Icon(Icons.logout, color: theme.colorScheme.error),
      title: Text(
        "تسجيل الخروج",
        textAlign: TextAlign.right,
        style: theme.textTheme.bodyText1?.copyWith(
          color: theme.colorScheme.error,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onTap: () async {

          await authController.logout();
          navigatorKey.currentState?.pushReplacement(
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );

      },
    ),
  );
}