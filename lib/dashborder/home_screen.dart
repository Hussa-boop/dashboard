import 'package:dashboard/dashborder/mangment/employee/screen.dart';
import 'package:dashboard/dashborder/mangment/parcels_management.dart';
import 'package:dashboard/dashborder/mangment/shipments_mangement.dart';
import 'package:dashboard/dashborder/modules/theme.dart';
import 'package:dashboard/dashborder/screen/system_setup_screen.dart';
import 'package:dashboard/dashborder/drawer_helper.dart';
import 'package:dashboard/dashborder/mangment/delegate_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controller/auth_controller.dart';
import 'controller/menu_controller.dart';
import 'controller/user_controller.dart';
import 'mangment/permissions_management.dart';

import 'mangment/users_management.dart';
import 'screen/dashboard_home_screen/dashboard.dart';

import 'screen/settings.dart';
import 'screen/statistics/statistics.dart';
import 'package:flutter_treeview/flutter_treeview.dart';
import '../mobil/modules/screen_home/screen_login/login_screen.dart';

class HomePagesDashBoard extends StatefulWidget {
  const HomePagesDashBoard({Key? key}) : super(key: key);

  @override
  _HomePagesDashBoardState createState() => _HomePagesDashBoardState();
}

class _HomePagesDashBoardState extends State<HomePagesDashBoard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final TreeViewController _treeViewController;
  late final MenusController _menuController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  static const Map<String, int> _keyToIndexMap = {
    'dashboard': 0,
    'users': 1,
    'shipments': 2,
    'delegate': 3,
    'employment': 4,
    'parcel': 5,
    'statistics': 6,
    'settings': 7,
    'permissions': 8,
    'systemConfig': 9,



  };

  @override
  void initState() {
    super.initState();
    initializeControllers();
    setupPostFrameCallback();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void initializeControllers() {
    _treeViewController = TreeViewController(

      children: buildTreeNodes(),
    );
    _menuController = Provider.of<MenusController>(context, listen: false);
  }

  List<Node> buildTreeNodes() {
    return [
      const Node(key: 'dashboard', label: '📊 لوحة التحكم'),
      const Node(
        key: 'management',
        label: '⚙️ الإدارة',
        expanded: true,
        children: [
          Node(key: 'users', label: '👤 إدارة المستخدمين'),
          Node(key: 'shipments', label: '📦 إدارة الشحنات'),
          Node(key: 'delegate', label: '🔑 إدارة المناديب'),
          Node(key: 'employment', label: '🔑 إدارة الموظفين'),
          Node(key: 'parcel', label: '🔑 إدارة الطرود'),
          Node(key: 'permissions', label: '🔑 إدارة الصلاحيات'),
        ],
      ),
      const Node(
        key: 'reports',
        label: '📈 التقارير والإحصائيات',
        children: [
          Node(key: 'statistics', label: '📉 الإحصائيات'),
        ],
      ),
      const Node(
        key: 'settings',
        label: '⚙️ الإعدادات',
        children: [
          Node(key: 'systemConfig', label: '🛠 تهيئة النظام'),
        ],
      ),
    ];
  }

  void setupPostFrameCallback() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _menuController.setScaffoldKey(_scaffoldKey);
    });
  }

  void onNodeTap(String key) {
    final index = _keyToIndexMap[key];
    if (index != null) {
      _menuController.updateSelectedIndex(index);
      setState(() {
        _treeViewController.expandToNode(key);
      });
      _scaffoldKey.currentState?.closeDrawer(); // إغلاق الدراور بعد الاختيار
    }
  }

  List<Node> filterNodes(List<Node> nodes, String query) {
    if (query.isEmpty) return nodes;

    return nodes.where((node) {
      final bool matches =
          node.label.toLowerCase().contains(query.toLowerCase());
      if (node.children.isNotEmpty) {
        return matches || filterNodes(node.children, query).isNotEmpty;
      }
      return matches;
    }).toList();
  }


  List<Widget> get pages => [
        Dashboard(child: buildDrawer()),
        UsersManagement(child: buildDrawer()),
        ShipmentsScreen(child: buildDrawer()),
        DelegateManagementScreen(child: buildDrawer()),
        EmployeesListScreen(),
       ParcelManagementScreen(child: buildDrawer(),),
        Statistics(child: buildDrawer()),
        Settings(),
        PermissionsManagement(),
        SystemConfigurationScreen(),
      ];
  Widget buildDrawer() {
    final filteredNodes =
        filterNodes(_treeViewController.children, _searchQuery);

    return Consumer<ThemeProvider>(
      builder: (BuildContext context, ThemeProvider value, Widget? child) {
        final theme = value.currentTheme;
        return Consumer<AuthController>(
          builder: (BuildContext context, AuthController authController,
              Widget? child) {
            return Consumer<UserController>(
              builder: (context, userController, _) {
                // الحصول على بيانات المستخدم الحالي
                final currentUser = authController.currentUserId != null
                    ? userController.getUserById(authController.currentUserId!)
                    : null;

                if (currentUser == null || currentUser.id.isEmpty) {
                  // إذا لم يتم العثور على المستخدم، قم بتسجيل الخروج
                  WidgetsBinding.instance.addPostFrameCallback((_) async {
                    await authController.logout();
                    if (mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    }
                  });
                  return const Center(child: CircularProgressIndicator());
                }

                // تحميل بيانات المستخدم إذا لم تكن موجودة
                if (currentUser.name.isEmpty) {
                  userController.loadUser(currentUser.id).then((_) {
                    if (mounted) setState(() {});
                  });
                  return const Center(child: CircularProgressIndicator());
                }

                return Directionality(
                  textDirection: TextDirection.rtl,
                  child: Drawer(
                    child: Column(
                      children: [
                        buildDrawerHeader(context, currentUser, theme),
                        buildSearchField(
                            context, theme, _searchController, _searchQuery,
                            () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        }, (value) => setState(() => _searchQuery = value)),
                        buildMenuItems(context, theme, filteredNodes,
                            _keyToIndexMap, _treeViewController, onNodeTap),
                        buildLogoutButton(authController, theme, context),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = Provider.of<MenusController>(context).selectedIndex;
    final safeIndex = selectedIndex.clamp(0, pages.length - 1);

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: (ResponsiveWidget.isSmallScreen(context) ||
              ResponsiveWidget.isMediumScreen(context))
          ? buildDrawer()
          : null,
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child: IndexedStack(
              index:
                  safeIndex, // ✅ استخدام `safeIndex` بدلاً من `selectedIndex`
              children: pages,
            ),
          ),
          if (ResponsiveWidget.isLargeScreen(context))
            Flexible(
              flex: 1,
              child: buildDrawer(),
            ),
        ],
      ),
    );
  }
}
// مزود الحالة لإدارة الفهرس المحدد

// فئة لتحديد نوع الجهاز
class ResponsiveWidget {
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 800;
  }

  static bool isMediumScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 800;
  }
}
