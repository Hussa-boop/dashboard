import 'package:dashboard/dashborder/controller/auth_controller.dart';
import 'package:dashboard/dashborder/controller/parcel_controller/parcel_controller.dart';
import 'package:dashboard/dashborder/controller/user_controller.dart';
import 'package:dashboard/dashborder/home_screen.dart';
import 'package:dashboard/dashborder/modules/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../mobil/modules/screen_home/screen_login/login_screen.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

PreferredSizeWidget buildAppBarHomeDash(
    BuildContext context,
    ThemeProvider themeProvider,
    ParcelController shipmentController,
    UserController userController,
    ) {
  return AppBar(
    title: const Text('لوحة التحكم'),
    centerTitle: true,
    leading: IconButton(
      icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
      tooltip: 'تبديل الوضع الليلي',
      onPressed: themeProvider.toggleTheme,
    ),
  );
}

Widget buildSyncButtonHomeDash(
    BuildContext context,
    ParcelController shipmentController,
    UserController userController,
    ) {
  return Tooltip(
    message: "مزامنة البيانات",
    child: IconButton(
      icon: const Icon(Icons.sync),
      onPressed: () async {
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        try {
          await Future.wait([
            shipmentController.fetchParcelsFromFirestore(),
            userController.fetchUsersFromServer(),
          ]);
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: const Text("✅ تمت مزامنة البيانات بنجاح!"),
              backgroundColor: Colors.green[700],
              behavior: SnackBarBehavior.floating,
            ),
          );
        } catch (e) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text("❌ فشل المزامنة: ${e.toString()}"),
              backgroundColor: Colors.red[700],
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    ),
  );
}

Widget buildLogoutButtonHomeDash(BuildContext context) {
  return Tooltip(
    message: "تسجيل الخروج",
    child: IconButton(
      icon: const Icon(Icons.logout),
      onPressed: () async {
        await Provider.of<AuthController>(context, listen: false).logout();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) =>  LoginScreen()),
        );
      },
    ),
  );
}

Widget buildBody(
    BuildContext context,
    ThemeData theme,
    ParcelController shipmentController,
    UserController userController,
    bool isDarkMode,
    ) {
  return RefreshIndicator(
    onRefresh: () async {
      await shipmentController.fetchParcelsFromFirestore();
      await userController.fetchUsersFromServer();
    },
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildHeaderHomeDash(theme),
          const SizedBox(height: 24),
          buildQuickStatsHomeDash(userController, shipmentController,context),
          const SizedBox(height: 24),
          buildChartsSectionHomeDash(shipmentController, isDarkMode),
        ],
      ),
    ),
  );
}

Widget buildHeaderHomeDash(ThemeData theme) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('مرحبًا بك', style: theme.textTheme.headline5?.copyWith(
        fontWeight: FontWeight.bold,
      )),
      const SizedBox(height: 8),
      Text('نظرة عامة على أداء النظام', style: theme.textTheme.subtitle1),
    ],
  );
}

Widget buildQuickStatsHomeDash(UserController userController, ParcelController shipmentController, BuildContext context,
    ) {
  return GridView.count(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisCount:MediaQuery.of(context).size.width < 465?1: 2,
    childAspectRatio: 1.5,
    crossAxisSpacing: 16,
    mainAxisSpacing: 16,
    children: [
      buildStatCardHomeDash(
          title: 'إجمالي المستخدمين',
          value: userController.totalUser.toString(),
          icon: Icons.people_alt,
          color: Colors.blue,
          context: context
      ),
      buildStatCardHomeDash(
          title: 'إجمالي الطرود',
          value: shipmentController.totalParcel.toString(),
          icon: Icons.local_shipping,
          color: Colors.green,          context: context

      ),
      buildStatCardHomeDash(
          title: 'الشحنات المعلقة',
          value: shipmentController.pendingParcel.toString(),
          icon: Icons.pending_actions,
          color: Colors.orange,          context: context

      ),
      buildStatCardHomeDash(
          title: 'الشحنات الملغاة',
          value: shipmentController.cancelledParcel.toString(),
          icon: Icons.cancel,
          color: Colors.red,          context: context

      ),
    ],
  );
}

Widget buildStatCardHomeDash({
  required BuildContext context,

  required String title,
  required String value,
  required IconData icon,
  required Color color,
}) {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size:ResponsiveWidget.isSmallScreen(context)?MediaQuery.of(context).size.width < 465?24:15 :24, color: color),
          ),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(
            fontSize:ResponsiveWidget.isSmallScreen(context)?MediaQuery.of(context).size.width < 489?MediaQuery.of(context).size.width < 465?24:18: 20:24,
            fontWeight: FontWeight.bold,
            color: color,
          )),
          const SizedBox(height: 4),
          Text(title, style:  TextStyle(
            fontSize:ResponsiveWidget.isSmallScreen(context)?MediaQuery.of(context).size.width < 489?MediaQuery.of(context).size.width < 465?14:7:10:14,
            color: Colors.grey,
          )),
        ],
      ),
    ),
  );
}

Widget buildChartsSectionHomeDash(ParcelController shipmentController, bool isDarkMode) {
  return Column(
    children: [
      buildLineChartCardHomeDash(shipmentController, isDarkMode),
      const SizedBox(height: 24),
      buildPieChartCardHomeDash(shipmentController, isDarkMode),
    ],
  );
}

Widget buildLineChartCardHomeDash(ParcelController shipmentController, bool isDarkMode) {
  final chartData = shipmentController.getParcelsOverTime();

  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('أداء الشحنات الشهري', style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          )),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: SfCartesianChart(
              palette: isDarkMode
                  ? [Colors.tealAccent, Colors.amber, Colors.pinkAccent]
                  : [Colors.blue, Colors.green, Colors.orange],
              plotAreaBorderWidth: 0,
              tooltipBehavior: TooltipBehavior(enable: true),
              legend: Legend(isVisible: true, position: LegendPosition.bottom),
              primaryXAxis: CategoryAxis(
                labelRotation: -45,
                majorGridLines: const MajorGridLines(width: 0),
              ),
              primaryYAxis: NumericAxis(
                axisLine: const AxisLine(width: 0),
                majorTickLines: const MajorTickLines(size: 0),
              ),
              series: <CartesianSeries>[
                LineSeries<SalesDataHomeDash, String>(
                  name: 'عدد الشحنات',
                  dataSource: chartData,
                  xValueMapper: (SalesDataHomeDash data, _) => data.month,
                  yValueMapper: (SalesDataHomeDash data, _) => data.sales,
                  markerSettings: const MarkerSettings(
                    isVisible: true,
                    height: 6,
                    width: 6,
                    shape: DataMarkerType.circle,
                  ),
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    labelAlignment: ChartDataLabelAlignment.top,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buildPieChartCardHomeDash(ParcelController shipmentController, bool isDarkMode) {
  final chartData = [
    ChartDataHomeDash('تم التسليم', shipmentController.completedParcel, Colors.green),
    ChartDataHomeDash('في الطريق', shipmentController.inTransitParcel, Colors.blue),
    ChartDataHomeDash('معلقة', shipmentController.pendingParcel, Colors.orange),
    ChartDataHomeDash('ملغاة', shipmentController.cancelledParcel, Colors.red),
  ];

  final total = shipmentController.totalParcel;

  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('توزيع الشحنات حسب الحالة', style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          )),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: SfCircularChart(
              palette: isDarkMode
                  ? [Colors.tealAccent, Colors.amber, Colors.pinkAccent, Colors.purpleAccent]
                  : [Colors.green, Colors.blue, Colors.orange, Colors.red],
              legend: Legend(
                isVisible: true,
                position: LegendPosition.bottom,
                overflowMode: LegendItemOverflowMode.wrap,
              ),
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <CircularSeries>[
                PieSeries<ChartDataHomeDash, String>(
                  dataSource: chartData,
                  xValueMapper: (ChartDataHomeDash data, _) => data.category,
                  yValueMapper: (ChartDataHomeDash data, _) => data.value,
                  dataLabelMapper: (ChartDataHomeDash data, _) =>
                  '${data.value} (${total > 0 ? (data.value / total * 100).toStringAsFixed(1) : 0}%)',
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    labelPosition: ChartDataLabelPosition.outside,
                    useSeriesColor: true,
                  ),
                  explode: true,
                  explodeIndex: 0,
                  explodeOffset: '10%',
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}


class SalesDataHomeDash {
  final String month;
  final int sales;
  SalesDataHomeDash(this.month, this.sales);
}

class ChartDataHomeDash {
  final String category;
  final int value;
  final Color color;
  ChartDataHomeDash(this.category, this.value, this.color);
}