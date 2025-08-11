import 'package:dashboard/dashborder/controller/shipment_controller/shipments_controller.dart';
import 'package:dashboard/data/models/shipment_model/hive_shipment.dart';
import 'package:dashboard/data/models/delegate_model/hive_delegate.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'as intl;
import 'package:provider/provider.dart';

class DelegateDetailsScreen extends StatelessWidget {
  final Delegate delegate;

  const DelegateDetailsScreen({Key? key, required this.delegate})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
     textDirection: TextDirection.rtl, child: Scaffold(
        appBar: AppBar(
          title: Text('تفاصيل المندوب: ${delegate.deveName}'),
        ),
        body: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              buildDelegateInfo(context),
              const TabBar(
                tabs: [
                  Tab(text: 'الشحنات', icon: Icon(Icons.local_shipping)),
                  Tab(text: 'الإحصائيات', icon: Icon(Icons.analytics)),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    buildShipmentsTab(context),
                    buildStatisticsTab(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDelegateInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                child: Text(delegate.deveName.isNotEmpty
                    ? delegate.deveName.substring(0, 1)
                    : '?'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      delegate.deveName.isNotEmpty
                          ? delegate.deveName
                          : 'مندوب بدون اسم',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              Chip(
                label: Text(delegate.isActive ? 'نشط' : 'غير نشط'),
                backgroundColor: delegate.isActive
                    ? Colors.green.withOpacity(0.2)
                    : Colors.red.withOpacity(0.2),
              ),
            ],
          ),
          const SizedBox(height: 16),
          buildInfoRow(context, Icons.location_on, delegate.deveAddress),
          buildInfoRow(context, Icons.date_range,
              'تاريخ التسجيل: ${intl.DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(delegate.delevID))}'),
        ],
      ),
    );
  }

  Widget buildShipmentsTab(BuildContext context) {
    return Consumer<ShipmentController>(
      builder: (context, controller, _) {
        final shipments = controller.getShipmentsByDelegateId(delegate.delevID);

        if (shipments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_shipping, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text('لا توجد شحنات معينة'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: shipments.length,
          itemBuilder: (_, index) =>
              buildShipmentCard(context, shipments[index]),
        );
      },
    );
  }

  Widget buildShipmentCard(BuildContext context, Shipment shipment) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ExpansionTile(
        leading: const Icon(Icons.local_shipping),
        title: Text('شحنة #${shipment.shippingID}'),
        subtitle: Text(intl.DateFormat('yyyy-MM-dd').format(shipment.shippingDate)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildShipmentDetail('العنوان', shipment.shippingAddress),
                buildShipmentDetail('الحالة', getShipmentStatus(shipment)),
                buildShipmentDetail(
                    'عدد الطرود', '${shipment.parcels.length}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => showParcelsDialog(context, shipment),
                  child: const Text('عرض الطرود'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void showParcelsDialog(BuildContext context, Shipment shipment) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('طرود الشحنة #${shipment.shippingID}'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: shipment.parcels.length,
            itemBuilder: (_, index) => ListTile(
              leading: const Icon(Icons.inventory),
              title: Text(shipment.parcels[index].trackingNumber),
              subtitle: Text('الحالة: ${shipment.parcels[index].status}'),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Widget buildStatisticsTab(BuildContext context) {
    return Consumer<ShipmentController>(
      builder: (context, controller, _) {
        final shipments = controller.getShipmentsByDelegateId(delegate.delevID);
        final completed = shipments.where((s) => s.deliveryDate != null).length;
        final pending = shipments.length - completed;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              buildStatCard(
                context,
                title: 'إجمالي الشحنات',
                value: shipments.length,
                icon: Icons.local_shipping,
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: buildStatCard(
                      context,
                      title: 'مكتملة',
                      value: completed,
                      icon: Icons.check_circle,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: buildStatCard(
                      context,
                      title: 'قيد التنفيذ',
                      value: pending,
                      icon: Icons.pending,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: shipments.isEmpty
                    ? const Center(child: Text('لا توجد بيانات إحصائية'))
                    : buildPerformanceChart(shipments),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildPerformanceChart(List<Shipment> shipments) {
    // يمكنك استخدام أي مكتبة للرسوم البيانية مثل fl_chart
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          'رسم بياني لأداء المندوب',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ),
    );
  }

  Widget buildInfoRow(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget buildShipmentDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String getShipmentStatus(Shipment shipment) {
    if (shipment.deliveryDate != null) {
      return 'تم التسليم';
    } else if (shipment.shippingDate
        .isBefore(DateTime.now().subtract(const Duration(days: 7)))) {
      return 'متأخر';
    } else {
      return 'قيد التوصيل';
    }
  }

  Widget buildStatCard(
    BuildContext context, {
    required String title,
    required int value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              value.toString(),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
