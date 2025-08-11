import 'package:dashboard/mobil/modules/screen_home/home_screen.dart';
import 'package:dashboard/mobil/modules/screen_home/screen_login/settings_screen.dart';
import 'package:dashboard/mobil/modules/view_data_shipments/data_shipmnets.dart';
import 'package:dashboard/mobil/report_operation.dart';
import 'package:dashboard/mobil/shard/network/firebase/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../dashborder/controller/auth_controller.dart';
import 'package:provider/provider.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  int _selectedIndex = -1;
  late Future<UserProfile> _userProfileFuture;

  @override
  void initState() {
    super.initState();
    _userProfileFuture = _fetchUserProfile();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuint),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<UserProfile> _fetchUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return UserProfile.guest();

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final shipments = await FirebaseFirestore.instance
          .collection('parcel')
          .where('receiverPhone', isEqualTo: userDoc['phoneNumber'])
          .get();

      return UserProfile(
        name: userDoc['name'] ?? 'مستخدم',
        shipmentCount: shipments.docs.length,
        email: user.email ?? '',
        phone: userDoc['phoneNumber'] ?? '',
      );
    } catch (e) {
      return UserProfile.error();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.82,
      elevation: 10,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [Colors.grey.shade900, Colors.grey.shade800]
                : [Colors.white, Colors.grey.shade100],
          ),
        ),
        child: Column(
          children: [
            // Header Section
            _buildHeader(theme, isDarkMode),

            // Menu Items
            Expanded(child: _buildMenuItems(theme, isDarkMode)),

            // Footer Section
            _buildFooter(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDarkMode) {
    return FutureBuilder<UserProfile>(
      future: _userProfileFuture,
      builder: (context, snapshot) {
        final profile = snapshot.data ?? UserProfile.loading();

        return Container(
          padding:
              const EdgeInsets.only(top: 40, bottom: 20, left: 20, right: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade700, Colors.orange.shade400],
            ),
            borderRadius: const BorderRadius.only(
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Hero(
                    tag: 'user-avatar',
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        onTap: () => _showProfileDetails(profile),
                        borderRadius: BorderRadius.circular(40),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/DeliveryTruckLoading.png',
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.person,
                                size: 30,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 3,
                                offset: const Offset(1, 1),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${profile.shipmentCount} الطرد',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              if (profile.email.isNotEmpty)
                Row(
                  children: [
                    Icon(Icons.email,
                        size: 16, color: Colors.white.withOpacity(0.8)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        profile.email,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItems(ThemeData theme, bool isDarkMode) {
    final menuItems = [
      DrawerMenuItem(Icons.home_filled, 'الرئيسية', HomeLayoutUser()),
      DrawerMenuItem(Icons.local_shipping, 'طرودي', ShipmentsScreen2()),
      DrawerMenuItem(
          Icons.assignment,
          'المهام',
          OperationsScreenUser(
            recePhone: '775479401',
          )),
      DrawerMenuItem(Icons.settings, 'الإعدادات', SettingsScreen()),
    ];

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 15),
      physics: const BouncingScrollPhysics(),
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: Colors.grey.withOpacity(0.1),
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        return _buildMenuItem(
          item: menuItems[index],
          index: index,
          theme: theme,
          isDarkMode: isDarkMode,
        );
      },
    );
  }

  Widget _buildMenuItem({
    required DrawerMenuItem item,
    required int index,
    required ThemeData theme,
    required bool isDarkMode,
  }) {
    final isSelected = _selectedIndex == index;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: isSelected ? _scaleAnimation.value : 1.0,
          child: child,
        );
      },
      child: InkWell(
        onTap: () {
          _animationController.reset();
          _animationController.forward();
          setState(() => _selectedIndex = index);
          Future.delayed(const Duration(milliseconds: 150), () {
            Navigator.pop(context); // إغلاق الـ Drawer بعد التأخير

            if (item.destination != null) {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => item.destination!,
                  transitionsBuilder: (_, animation, __, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                ),
              );
            }
          });
        },
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.orange.withOpacity(0.2),
        highlightColor: Colors.orange.withOpacity(0.1),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.orange.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: Colors.orange.withOpacity(0.4), width: 1)
                : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(
                item.icon,
                size: 24,
                color: isSelected
                    ? Colors.orange.shade700
                    : isDarkMode
                        ? Colors.grey.shade400
                        : Colors.grey.shade700,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  item.title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected
                        ? Colors.orange.shade700
                        : isDarkMode
                            ? Colors.grey.shade300
                            : Colors.grey.shade800,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.orange.shade700,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Column(
      children: [
        const Divider(height: 1),
        ListTile(
          leading: Icon(Icons.help_outline, color: theme.colorScheme.secondary),
          title: Text(
            'المساعدة والدعم',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.secondary,
            ),
          ),
          onTap: () => _showHelpDialog(),
        ),
        ListTile(
          leading: Icon(Icons.exit_to_app, color: Colors.red.shade400),
          title: Text(
            'تسجيل الخروج',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.red.shade400,
              fontWeight: FontWeight.w500,
            ),
          ),
          onTap: () => _confirmLogout(),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            'الإصدار 1.0.0',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.disabledColor,
            ),
          ),
        ),
      ],
    );
  }

  void _showProfileDetails(UserProfile profile) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.orange.shade100,
                child:
                    Icon(Icons.person, size: 50, color: Colors.orange.shade700),
              ),
              const SizedBox(height: 15),
              Text(
                profile.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              if (profile.email.isNotEmpty) ...[
                _buildProfileDetailItem(Icons.email, profile.email),
                const SizedBox(height: 8),
              ],
              if (profile.phone.isNotEmpty) ...[
                _buildProfileDetailItem(Icons.phone, profile.phone),
                const SizedBox(height: 8),
              ],
              _buildProfileDetailItem(
                  Icons.local_shipping, '${profile.shipmentCount} طرد'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('حسناً'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileDetailItem(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(text, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await Provider.of<AuthController>(context, listen: false).logout();
        await AuthService().logoutUser(context);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('حدث خطأ: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.help, size: 50, color: Colors.orange),
              const SizedBox(height: 15),
              Text(
                'مركز المساعدة',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              const Text(
                'للاستفسارات والدعم الفني، يرجى التواصل مع فريق الدعم عبر البريد الإلكتروني أو رقم الهاتف.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('حسناً'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserProfile {
  final String name;
  final int shipmentCount;
  final String email;
  final String phone;

  UserProfile({
    required this.name,
    required this.shipmentCount,
    this.email = '',
    this.phone = '',
  });

  factory UserProfile.guest() => UserProfile(name: 'زائر', shipmentCount: 0);

  factory UserProfile.loading() =>
      UserProfile(name: 'جاري التحميل...', shipmentCount: 0);

  factory UserProfile.error() => UserProfile(name: 'حدث خطأ', shipmentCount: 0);
}

class DrawerMenuItem {
  final IconData icon;
  final String title;
  final Widget? destination;

  DrawerMenuItem(this.icon, this.title, this.destination);
}
