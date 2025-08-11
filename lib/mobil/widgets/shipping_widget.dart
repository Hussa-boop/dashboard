import 'package:dashboard/dashborder/controller/delegate_controller/screen_delegate_example.dart';
import 'package:dashboard/data/models/delegate_model/hive_delegate.dart';

import 'package:dashboard/mobil/modules/view_data_shipments/data_shipmnets.dart';

import 'package:dashboard/visitor_screen/shipping_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShippingWidget extends StatelessWidget {
  const ShippingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // تعريف خدمات الشحن مع مسارات التنقل
    List<Map<String, dynamic>> services = [
      {
        "icon": Icons.local_shipping_rounded,
        "text": "طلب شحن طرد",
        "color": const Color(0xFF4CAF50),
        "secondaryColor": const Color(0xFF2E7D32),
        "description": "إنشاء طلب طرد جديد بسهولة",
        "route": const NewShippingScreen(),
      },
      {
        "icon": Icons.gps_fixed_rounded,
        "text": "تتبع الطرد",
        "color": const Color(0xFF2196F3),
        "secondaryColor": const Color(0xFF0D47A1),
        "description": "تتبع طردك في الوقت الحقيقي",
        "route":  AdvancedShippingHistoryScreen(),
      },
      {
        "icon": Icons.history_rounded,
        "text": "سجل الطرود",
        "color": const Color(0xFF9C27B0),
        "secondaryColor": const Color(0xFF6A1B9A),
        "description": "عرض سجل الطرود السابقة",
        "route":  ShipmentsScreen2(),
      },
      {
        "icon": Icons.discount_rounded,
        "text": "العروض",
        "color": const Color(0xFFFF9800),
        "secondaryColor": const Color(0xFFE65100),
        "description": "أحدث العروض والخصومات",
        "route": const OffersScreen(),
      },
      {
        "icon": Icons.support_agent_rounded,
        "text": "المندوب",
        "color": const Color(0xFFF44336),
        "secondaryColor": const Color(0xFFB71C1C),
        "description": "الدعم والمساعدة على مدار الساعة",
        "route":  DelegateShipmentsScreen(delegate: Delegate(delevID: 1745087164225,deveAddress: 'إب',deveName: 'حسين ابوحليقة',isActive: true)),
      },
    ];

    return Column(
      children: [
        // عنوان القسم
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          margin: const EdgeInsets.only(bottom: 8.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.05),
                Colors.transparent,
              ],
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                "خدمات الشحن",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.local_shipping,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),

        // قائمة بطاقات الخدمات
        SizedBox(
          height: 160, // ارتفاع أقل من السابق
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: services.length,
            itemBuilder: (context, index) {
              return Container(
                width: 140, // عرض أقل من السابق
                margin: const EdgeInsets.only(left: 12),
                child: PremiumServiceCard(
                  icon: services[index]["icon"],
                  text: services[index]["text"],
                  description: services[index]["description"],
                  color: services[index]["color"],
                  secondaryColor: services[index]["secondaryColor"],
                  press: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => services[index]["route"],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class PremiumServiceCard extends StatefulWidget {
  const PremiumServiceCard({
    Key? key,
    required this.icon,
    required this.text,
    required this.description,
    required this.color,
    required this.secondaryColor,
    required this.press,
  }) : super(key: key);

  final IconData icon;
  final String text;
  final String description;
  final Color color;
  final Color secondaryColor;
  final VoidCallback press;

  @override
  State<PremiumServiceCard> createState() => _PremiumServiceCardState();
}

class _PremiumServiceCardState extends State<PremiumServiceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse().then((_) => widget.press());
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.color.withOpacity(isDarkMode ? 0.3 : 0.2),
                widget.secondaryColor.withOpacity(isDarkMode ? 0.4 : 0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(_isPressed ? 0.2 : 0.3),
                blurRadius: _isPressed ? 8 : 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: _isPressed
                  ? widget.secondaryColor.withOpacity(0.5)
                  : widget.color.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: widget.press,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // أيقونة الخدمة
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            widget.color.withOpacity(isDarkMode ? 0.4 : 0.2),
                            widget.secondaryColor.withOpacity(isDarkMode ? 0.5 : 0.3),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.icon,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // عنوان الخدمة
                    Text(
                      widget.text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // وصف الخدمة
                    Text(
                      widget.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// شاشات وهمية للتوضيح (استبدلها بشاشاتك الفعلية)
class NewShippingScreen extends StatelessWidget {
  const NewShippingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('طلب شحن جديد')),
      body: const Center(child: Text('شاشة طلب شحن جديد')),
    );
  }
}

class TrackShipmentScreen extends StatelessWidget {
  const TrackShipmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تتبع الشحنة')),
      body: const Center(child: Text('شاشة تتبع الشحنة')),
    );
  }
}



class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('العروض')),
      body: const Center(child: Text('شاشة العروض')),
    );
  }
}

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المساعدة')),
      body: const Center(child: Text('شاشة المساعدة')),
    );
  }
}