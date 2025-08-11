import 'package:flutter/material.dart';
import 'package:dashboard/visitor_screen/shipping_history_screen.dart';

import 'shipment_history_screen/shipment_history.dart';
import 'package:dashboard/visitor_screen/shipment_details_screen.dart';
class AdvancedHomeScreen extends StatefulWidget {
  @override
  _AdvancedHomeScreenState createState() => _AdvancedHomeScreenState();
}

class _AdvancedHomeScreenState extends State<AdvancedHomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery
        .of(context)
        .size;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(theme),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        children: [
          _buildMainContent(theme, size),
          TrackingScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(theme),
      floatingActionButton: _buildFloatingActionButton(theme),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      title: Text('شحن الطرود', style: theme.textTheme.headline6?.copyWith(
        fontWeight: FontWeight.bold,
      )),
      centerTitle: true,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors:[Colors.orange,Colors.orange],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Badge(
            value: '3',
            child: Icon(Icons.notifications_outlined),
          ),
          onPressed: () =>
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => NotificationsScreen(),
              )),
        ),
      ],
    );
  }

  Widget _buildMainContent(ThemeData theme, Size size) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(theme),
          const SizedBox(height: 24),
          _buildQuickActions(theme),
          const SizedBox(height: 24),
          _buildPromoSlider(size),
          const SizedBox(height: 24),
          _buildSectionTitle('الخدمات المميزة', theme),
          const SizedBox(height: 12),
          _buildFeaturedServices(),
          const SizedBox(height: 24),
          _buildSectionTitle('أقرب الفروع', theme),
          const SizedBox(height: 12),
          _buildNearestBranches(),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.orange[300],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue[100],
              child: Icon(
                  Icons.person_outline, size: 30, color: Colors.blue[800]),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('مرحباً بك!', style: theme.textTheme.subtitle1?.copyWith(
                    fontWeight: FontWeight.bold,
                  )),
                  const SizedBox(height: 4),
                  Text('يمكنك الآن شحن طرودك بكل سهولة',
                      style: theme.textTheme.bodyText2?.copyWith(
                        color: Colors.grey[600],
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      childAspectRatio: 0.9,
      children: [
        _buildActionItem(
          icon: Icons.local_shipping,
          label: 'شحن جديد',
          color: Colors.blue,
          onTap: () =>
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => NewShippingScreen(),
              )),
        ),
        _buildActionItem(
          icon: Icons.track_changes,
          label: 'تتبع شحنة',
          color: Colors.green,
          onTap: () =>
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => AdvancedShippingHistoryScreen(),
              )),
        ),
        _buildActionItem(
          icon: Icons.history,
          label: 'سجل الشحنات',
          color: Colors.orange,
          onTap: () =>
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => ShippingHistoryScreen(),
              )),
        ),
        _buildActionItem(
          icon: Icons.location_pin,
          label: 'الفروع',
          color: Colors.red,
          onTap: () =>
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => BranchesMapScreen(),
              )),
        ),
        _buildActionItem(
          icon: Icons.request_quote,
          label: 'طلب سعر',
          color: Colors.purple,
          onTap: () =>
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => PriceEstimateScreen(),
              )),
        ),
        _buildActionItem(
          icon: Icons.schedule,
          label: 'مواعيد الشحن',
          color: Colors.teal,
          onTap: () =>
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => ShippingScheduleScreen(),
              )),
        ),
        _buildActionItem(
          icon: Icons.support_agent,
          label: 'الدعم',
          color: Colors.indigo,
          onTap: () =>
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => SupportScreen(),
              )),
        ),
        _buildActionItem(
          icon: Icons.qr_code,
          label: 'مسح QR',
          color: Colors.brown,
          onTap: () =>
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => QRScanScreen(),
              )),
        ),
      ],
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          )),
        ],
      ),
    );
  }

  Widget _buildPromoSlider(Size size) {
    return SizedBox(
      height: size.height * 0.2,
      child: PageView.builder(
        itemCount: 3,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange,
                      Colors.blue[600]!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    Text(
                      index == 0 ? 'خصم 25% على الشحنه' :
                      index == 1 ? 'شحن مجاني للطلبات الأولى' :
                      'خصم 15% للشحن المتكرر',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      index == 0 ? 'لطلبات الشحن الدولية حتى نهاية الشهر' :
                      index == 1 ? 'احصل على شحن مجاني لأول طلب لك' :
                      'خصومات خاصة للعملاء الدائمين',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    const Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        'اعرف المزيد',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Row(
      children: [
        Text(title, style: theme.textTheme.subtitle1?.copyWith(
          fontWeight: FontWeight.bold,
        )),
        const Spacer(),
        TextButton(
          onPressed: () {},
          child: Text('عرض الكل', style: TextStyle(
            color: Colors.blue[800],
            fontSize: 12,
          )),
        ),
      ],
    );
  }

  Widget _buildFeaturedServices() {
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildServiceCard(
            icon: Icons.airplanemode_active,
            title: 'شحن جوي',
            subtitle: 'أسرع وقت توصيل',
            color: Colors.blue,
          ),
          const SizedBox(width: 12),
          _buildServiceCard(
            icon: Icons.directions_car,
            title: 'شحن بري',
            subtitle: 'أقل تكلفة',
            color: Colors.green,
          ),
          const SizedBox(width: 12),
          _buildServiceCard(
            icon: Icons.directions_boat,
            title: 'شحن بحري',
            subtitle: 'للطرود الكبيرة',
            color: Colors.orange,
          ),
          const SizedBox(width: 12),
          _buildServiceCard(
            icon: Icons.lock_clock,
            title: 'شحن مضمون',
            subtitle: 'بوليصة تأمين',
            color: Colors.purple,
          ),
        ],
      ),
    );
  }

  _buildServiceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      width: 160,
      constraints: const BoxConstraints(
        minHeight: 96, // تحديد ارتفاع أدنى
        maxHeight: 120, // تحديد ارتفاع أقصى
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
        const BoxShadow(
        color: Colors.black12,
        blurRadius: 6,
        offset: Offset(0, 2),
        )],
      ),

      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView( // إضافة إمكانية التمرير إذا لزم الأمر
        child: Column(
          mainAxisSize: MainAxisSize.min, // مهم لتجنب التمدد غير الضروري
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8), // تقليل المساحة إذا لزم الأمر
            Text(title, style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            )),
            const SizedBox(height: 4),
            Text(subtitle,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
              maxLines: 2, // تحديد عدد الأسطر
              overflow: TextOverflow.ellipsis, // إضافة ... إذا زاد النص
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNearestBranches() {
    return Column(
      children: [
        _buildBranchItem(
          name: 'فرع صنعاء الرئيسي',
          address: 'حي شميلة شارع السبعين',
          distance: '1.5 كم',
          open: true,
        ),
        const SizedBox(height: 12),
        _buildBranchItem(
          name: 'فرع إب',
          address: 'جولة العدين شارع تعز',
          distance: '3.2 كم',
          open: false,
        ),
      ],
    );
  }

  Widget _buildBranchItem({
    required String name,
    required String address,
    required String distance,
    required bool open,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.location_on, color: Colors.blue[800]),
        ),
        title: Text(name, style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        )),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(address, style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            )),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.directions_walk, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(distance, style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                )),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: open ? Colors.green[50] : Colors.red[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    open ? 'مفتوح الآن' : 'مغلق',
                    style: TextStyle(
                      color: open ? Colors.green[800] : Colors.red[800],
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Icon(
            Icons.arrow_forward_ios, size: 16, color: Colors.grey[500]),
        onTap: () =>
            Navigator.push(context, MaterialPageRoute(
              builder: (_) => BranchDetailsScreen(),
            )),
      ),
    );
  }

  Widget _buildBottomNavBar(ThemeData theme) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.home,
                  color: _currentIndex == 0 ? theme.primaryColor : Colors.grey),
              onPressed: () =>
                  _pageController.animateToPage(0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease),
            ),
            IconButton(
              icon: Icon(Icons.track_changes,
                  color: _currentIndex == 1 ? theme.primaryColor : Colors.grey),
              onPressed: () =>
                  _pageController.animateToPage(1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease),
            ),
            const SizedBox(width: 40), // Space for FAB
            IconButton(
              icon: Icon(Icons.person,
                  color: _currentIndex == 2 ? theme.primaryColor : Colors.grey),
              onPressed: () =>
                  _pageController.animateToPage(2,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease),
            ),
            Builder(
              builder: (context) =>
                  IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(ThemeData theme) {
    return FloatingActionButton(
      onPressed: () =>
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => NewShippingScreen(),
          )),
      elevation: 2,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Colors.blue[800]!, Colors.blue[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}

// Screens Placeholders
class TrackingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('شاشة التتبع'));
  }
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('شاشة الملف الشخصي'));
  }
}

class NewShippingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('شحن جديد')),
        body: const Center(child: Text('إنشاء شحنة جديدة')));
  }
}

class TrackingDetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('تفاصيل التتبع')),
        body: const Center(child: Text('تفاصيل الشحنة')));
  }
}



class BranchesMapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('الفروع على الخريطة')),
        body: const Center(child: Text('خريطة الفروع')));
  }
}

class PriceEstimateScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('طلب سعر')),
        body: const Center(child: Text('حاسبة الأسعار')));
  }
}

class ShippingScheduleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('مواعيد الشحن')),
        body: const Center(child: Text('جدول المواعيد')));
  }
}

class SupportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('الدعم الفني')),
        body: const Center(child: Text('مركز المساعدة')));
  }
}

class QRScanScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('مسح QR')),
        body: const Center(child: Text('قارئ رمز الاستجابة السريعة')));
  }
}

class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('الإشعارات')),
        body: const Center(child: Text('قائمة الإشعارات')));
  }
}

class BranchDetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('تفاصيل الفرع')),
        body: const Center(child: Text('معلومات الفرع')));
  }
}

class Badge extends StatelessWidget {
  final String value;
  final Widget child;

  const Badge({required this.value, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(6),
            ),
            constraints: const BoxConstraints(
              minWidth: 14,
              minHeight: 14,
            ),
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}