import 'package:dashboard/dashborder/controller/parcel_controller/parcel_controller.dart';
import 'package:dashboard/dashborder/controller/user_controller.dart';
import 'package:dashboard/dashborder/screen/statistics/statistics.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
Widget buildStatsGrid(ParcelController controller,UserController userController) {
  return GridView.count(
    shrinkWrap: true,
    crossAxisCount: 2,
    childAspectRatio: 1.5,
    crossAxisSpacing: 16,
    mainAxisSpacing: 16,
    children: [
      buildStatCard('المستخدمين', userController.totalUser.toString(), Icons.people_alt, Colors.blue),
      buildStatCard('الطرود', controller.totalParcel.toString(), Icons.local_shipping, Colors.green),
      buildStatCard('المعلقة', controller.pendingParcel.toString(), Icons.pending_actions, Colors.orange),
      buildStatCard('الإيرادات', '2500 ر.ي', Icons.attach_money, Colors.purple),
    ],
  );
}

Widget buildStatCard(String title, String value, IconData icon, Color color) {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          Text(title,
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600)),
        ],
      ),
    ),
  );
}

Widget buildChartHeader() {
  return const Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text('توزيع الشحنات',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      Text('آخر 30 يوم',
          style: TextStyle(color: Colors.grey)),
    ],
  );
}

Widget buildPieChart(ParcelController shipmentController) {
  // ✅ جلب البيانات من قاعدة البيانات (Hive) عبر `shipmentController`
  final List<ChartData> chartData = [
    ChartData('المكتملة', shipmentController.completedParcel, Colors.green),
    ChartData('المعلقة', shipmentController.pendingParcel, Colors.orange),
    ChartData('الملغاة', shipmentController.cancelledParcel, Colors.red),
  ];

  // ✅ حساب إجمالي الشحنات
  int totalShipments = shipmentController.totalParcel;

  return SizedBox(
    height: 300,
    child: SfCircularChart(
      palette: chartData.map((e) => e.color).toList(),
      series: <CircularSeries>[
        PieSeries<ChartData, String>(
          dataSource: chartData,
          xValueMapper: (ChartData data, _) => data.category,
          yValueMapper: (ChartData data, _) => data.value,
          dataLabelMapper: (ChartData data, _) =>
          '${data.value} (${totalShipments > 0 ? (data.value / totalShipments * 100).toStringAsFixed(1) : 0}%)',
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            labelPosition: ChartDataLabelPosition.outside,
            textStyle: TextStyle(fontSize: 14),
          ),
          enableTooltip: true,
          explode: true,
          explodeIndex: 0,
          animationDuration: 1000,
        ),
      ],
      legend: Legend(
        isVisible: true,
        overflowMode: LegendItemOverflowMode.wrap,
        position: LegendPosition.bottom,
      ),
    ),
  );
}


Widget buildLegend(List<ChartData> data) {
  return Wrap(
    spacing: 16,
    runSpacing: 8,
    children: data.map((item) => buildLegendItem(item.category, item.color)).toList(),
  );
}
Widget buildLegendItem(String text, Color color) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
      const SizedBox(width: 8),
      Text(text),
    ],
  );
}class ChartData {
  final String category;
  final int value;
  final Color color;

  ChartData(this.category, this.value, this.color);
}