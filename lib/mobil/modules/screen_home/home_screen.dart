
import 'package:dashboard/mobil/modules/delegate/deliv.dart';
import 'package:dashboard/mobil/modules/screen_home/screen_map_parcel/map_screen.dart';
import 'package:dashboard/mobil/modules/screen_home/screen_login/profiled_user.dart';
import 'package:dashboard/mobil/modules/screen_home/screen_login/settings_screen.dart';
import 'package:dashboard/mobil/modules/screen_home/widget_home.dart';
import 'package:dashboard/mobil/shard/qr_code/Shipment_qr_scaner.dart';
import 'package:dashboard/mobil/widgets/shipping_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../customer_drawer.dart';
import '../view_data_shipments/data_shipmnets.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../view_data_shipments/desgin_status_shipment.dart';
import 'home_cubit/home_cubit.dart';
import 'home_cubit/home_state.dart';

class HomeLayoutUser extends StatelessWidget {
  final List<PromoItem> promos = [
    PromoItem(
      title: "عرض خاص للشحن السريع",
      subtitle: "خصم25% شحن لنهاية الشهر",
      actionText: "انقر للتفاصيل",
      gradientColors: [const Color(0xFF2A5C8F), const Color(0xFF4A90E2)],
      icon: Icons.local_shipping,
      onTap: () {
      },
    ),
    PromoItem(
      title: "شحن مجاني",
      subtitle: "لطلبات فوق 200 ريال",
      actionText: "اطلب الآن",
      gradientColors: [Colors.purple, Colors.deepPurple],
      icon: Icons.airplanemode_active,
    ),
    PromoItem(
      title: "خصومات العيد",
      subtitle: "خصم 30% لمدة 3 أيام فقط",
      actionText: "استفد الآن",
      gradientColors: [Colors.orange, Colors.deepOrange],
      icon: Icons.confirmation_number,
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => HomeCubit(),
      child: BlocConsumer<HomeCubit, HomeState>(
        builder: (BuildContext context, HomeState state) {
          var cubit = HomeCubit.get(context);
          var cubitRead = context.read<HomeCubit>();

          // قائمة الشاشات المرتبطة بكل عنصر في BottomNavigationBar
          final List<Widget> screens = [
            // الشاشة الرئيسية (الصفحة 0)
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'لتتبع الطرود',
                            style: TextStyle(
                                fontSize: 25,
                                color: Colors.orange,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.black26),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: cubitRead.trackingController,
                                    textAlign: TextAlign.right,
                                    decoration: const InputDecoration(
                                      hintText:
                                      'ادخل رقم التتبع المكون من 3 ارقام ومافوق',
                                      border: InputBorder.none,
                                      contentPadding:
                                      EdgeInsets.symmetric(horizontal: 10),
                                    ),
                                    onChanged: (value) {
                                      print("القيمة المدخلة: $value");
                                      if (value.length >= 3) {
                                        cubit.searchParcel(value);
                                      } else {
                                        cubit.clearSearchResults();
                                      }
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.qr_code_scanner,
                                      color: Colors.black54),
                                  onPressed: () {
                                    // cubit.scanQRCode(context).then((qrData) {
                                    //   if (qrData != null) {
                                    //     _trackingController.text = qrData;
                                    //     cubit.searchShipment(qrData);
                                    //   }
                                    // });
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          buildSearchResults(cubit, context),
                        ],
                      ),
                    ),
                    ParcelPromoSlider(
                      promos: promos,
                      autoSlideDuration: const Duration(seconds: 3), // تغيير كل 3 ثواني
                      showIndicators: true,
                      showCloseButton: true,
                    ),
                    const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          ShippingWidget(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // شاشة الخريطة (الصفحة 1)
            MapScreen(trackingNumber: cubit.trackingController.text),



            // شاشة الإعدادات (الصفحة 3)
            const SettingsScreen()  ,
            const ProfileScreen()
          ];
          final List<AppBar> Appar = [
            // الشاشة الرئيسية (الصفحة 0)
            AppBar(
              backgroundColor: Colors.orange,
              centerTitle: true,
              actions: [
                IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ShipmentsScreen2(),
                          ));
                    },
                    icon: const Icon(Icons.pan_tool_alt_sharp),
                    color: Colors.white),
                IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AgentHomeScreen(),
                          ));
                    },
                    icon: const Icon(Icons.add),
                    color: Colors.white),
              ],
              title: const Text(
                'الشاشة الرئيسية',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
            AppBar(
              title: const Row(
                children: [
                  // إضافة صورة المستخدم الصغيرة

                  SizedBox(width: 12),
                  Text(
                    'خارطة تتبع الطرود',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.orange,
              elevation: 6, // زيادة الظل للإحساس بالعمق
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20), // زوايا مدورة من الأسفل
                ),
              ),
              toolbarHeight: 70, // زيادة الارتفاع

              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange,
                      Colors.orange,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            AppBar(
              title: const Row(
                children: [
                  Icon(Icons.settings, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'إعدادات المستخدم',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.orange,
              elevation: 6,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              toolbarHeight: 70,

              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                     Colors.orange,
                      Colors.orange,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            AppBar(
              title: const Row(
                children: [

                  Text(
                    'الملف الشخصي',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.orange,
              elevation: 6, // زيادة الظل للإحساس بالعمق
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20), // زوايا مدورة من الأسفل
                ),
              ),
              toolbarHeight: 70, // زيادة الارتفاع

              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.shade900,
                      Colors.orange.shade700,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),


          ];

          return Scaffold(
            drawer: const CustomDrawer(),
            appBar:Appar[cubit.selectedIndex] ,
            floatingActionButtonLocation:
            FloatingActionButtonLocation.centerDocked,
            floatingActionButton: FloatingActionButton(
              shape: const StadiumBorder(
                  side: BorderSide(
                      style: BorderStyle.solid, color: Colors.green)),
              backgroundColor: const Color.fromRGBO(231, 109, 18, 1.0),
              tooltip: 'Scan QR Code',
              onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => ShipmentQRScanner(),));},
              child: const Icon(Icons.qr_code_2, size: 28),
            ),
            bottomNavigationBar: BottomAppBar(
              color: Colors.orange,
              shape: const CircularNotchedRectangle(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: const Icon(Icons.home),
                    onPressed: () => cubit.onItemTapped(0),
                    color: cubit.selectedIndex == 0 ? Colors.white : Colors.black,
                  ),
                  IconButton(
                    icon: const Icon(Icons.pin_drop_outlined),
                    onPressed: () => cubit.onItemTapped(1),
                    color: cubit.selectedIndex == 1 ? Colors.white : Colors.black,
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () => cubit.onItemTapped(2),
                    color: cubit.selectedIndex == 2 ? Colors.white : Colors.black,
                  ),
                  IconButton(
                    icon: const Icon(Icons.person),
                    onPressed: () => {
                      cubit.onItemTapped(3),
                       },
                    color:
                    cubit.selectedIndex == 3 ? Colors.white : Colors.black,
                  ),
                ],
              ),
            ),
            body: screens[cubit.selectedIndex], // عرض الشاشة المحددة
          );
        },
        listener: (BuildContext context, HomeState state) {
          if (state is HomeQRScanned) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('تم مسح الباركود: ${state.qrData}')),
            );
          }
        },
      ),
    );
  }

  Widget buildSearchResults(HomeCubit cubit, BuildContext context) {
    if (cubit.isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (cubit.searchResults.isEmpty) {
      if (cubit.hasSearched) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text('لا توجد نتائج لرقم التتبع هذا',
                  style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        );
      }
      return Container();
    }

    final shipment = cubit.searchResults.first;
    final statusInfo = ParcelStatusFormatter.getStatusInfo(shipment.status);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Tracking Number and Status
            Row(
              children: [
                Text(
                  'رقم التتبع:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                ),
                const SizedBox(width: 8),
                Text(
                  shipment.trackingNumber,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: Icon(Icons.copy, size: 18, color: Colors.grey.shade600),
                  onPressed: () {
                    Clipboard.setData(
                        ClipboardData(text: shipment.trackingNumber));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم نسخ رقم التتبع')),
                    );
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const Spacer(),
                // استبدل هذا الجزء باستدعاء الويدجت الجاهز من الكلاس
                ParcelStatusFormatter.buildStatusWidget(shipment.status),
              ],
            ),
            const SizedBox(height: 12),
            // Description and Sender Info
            Row(
              children: [
                Container(
                  width: 6,
                  height: 40,
                  decoration: BoxDecoration(
                    color: statusInfo.color, // استخدام اللون من الكلاس
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shipment.orderName.isNotEmpty
                            ? shipment.orderName
                            : 'شحنة ${shipment.trackingNumber}',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                      const SizedBox(height: 6),
                      RichText(
                        text: TextSpan(
                          text: 'من : ',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrangeAccent,
                              fontSize: 18),
                          children: [
                            TextSpan(
                              text: shipment.senderName,
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      RichText(
                        text: TextSpan(
                          text: 'إلى : ',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrangeAccent,
                              fontSize: 18),
                          children: [
                            TextSpan(
                              text: shipment.receiverName,
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Icons Timeline
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildTimelineIcon(Icons.inventory, statusInfo.color),
                buildDashedLine(statusInfo.color),
                buildTimelineIcon(Icons.local_shipping, statusInfo.color),
                buildDashedLine(statusInfo.color),
                buildTimelineIcon(
                    Icons.inventory_2_outlined, statusInfo.color),
                buildDashedLine(statusInfo.color),
                buildTimelineIcon(Icons.person, statusInfo.color),
              ],),
            const SizedBox(height: 16),
            // Track on Map button
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.map),
                label: const Text('تتبع على الخريطة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () {
                  cubit.trackParcelOnMap(shipment.trackingNumber);
                },
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget buildTimelineIcon(IconData icon, Color color) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1.5),
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }

  Widget buildDashedLine(Color color) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: color.withOpacity(0.5),
              width: 1.5,
              style: BorderStyle.solid,
            ),
          ),
        ),
      ),
    );
  }
}





