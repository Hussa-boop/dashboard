import 'package:dashboard/data/models/prcel_model/hive_parcel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../mobil/modules/view_data_shipments/desgin_status_shipment.dart';


class ShipmentDetailsScreen extends StatelessWidget {
  final Parcel shipment;

  const ShipmentDetailsScreen({super.key, required this.shipment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الشحنة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareShipmentDetails(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(),
            const SizedBox(height: 24),
            _buildOrderInfoSection(),
            const SizedBox(height: 24),
            _buildTimelineSection(),
            const SizedBox(height: 24),
            _buildLocationSection(),
            const SizedBox(height: 24),
            _buildActionsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  shipment.trackingNumber,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ParcelStatusFormatter.buildDetailedStatusWidget(shipment.status)
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem(Icons.person, 'المرسل', shipment.senderName),
                _buildInfoItem(Icons.person_outline, 'المستلم', shipment.receiverName),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String value) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.blue),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'معلومات الطلب',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              shipment.orderName,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getStatusDescription(shipment.status),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'حالة الشحنة',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildTimelineItem(
              icon: Icons.shopping_cart,
              title: 'تم الطلب',
              subtitle: shipment.formattedDate,
              isActive: true,
              isFirst: true,
            ),
            _buildTimelineItem(
              icon: Icons.warehouse,
              title: 'في المستودع',
              subtitle: shipment.formattedDate,
              isActive: shipment.status != 'pending',
            ),
            _buildTimelineItem(
              icon: Icons.local_shipping,
              title: 'قيد التوصيل',
              subtitle: shipment.formattedDate,
              isActive: shipment.status == 'inTransit' ||
                  shipment.status == 'delivered',
            ),
            _buildTimelineItem(
              icon: Icons.check_circle,
              title: 'تم التسليم',
              subtitle: shipment.formattedDate,
              isActive: shipment.status == 'delivered',
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isActive = false,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 24),
      child: Column(
        children: [
          if (!isFirst) const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isActive ? Colors.green : Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 14,
                      color: isActive ? Colors.white : Colors.grey[600],
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 40,
                      color: isActive ? Colors.green : Colors.grey[300],
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isActive ? Colors.black : Colors.grey,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: isActive ? Colors.grey[600] : Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    if (shipment.latitude == 0.0 || shipment.longitude == 0.0) {
      return const SizedBox();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'الموقع الجغرافي',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.map, size: 48, color: Colors.grey),
                    const SizedBox(height: 8),
                    Text(
                      'خط العرض: ${shipment.latitude}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      'خط الطول: ${shipment.longitude}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsSection() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _contactSupport(),
            icon: const Icon(Icons.support_agent),
            label: const Text('الدعم الفني'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[50],
              foregroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _reportProblem(),
            icon: const Icon(Icons.report_problem),
            label: const Text('إبلاغ عن مشكلة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[50],
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getStatusDescription(String status) {
    switch (status) {
      case 'pending':
        return 'الشحنة قيد التحضير في المستودع';
      case 'inTransit':
        return 'الشحنة في طريقها إلى وجهتها';
      case 'delivered':
        return 'تم تسليم الشحنة بنجاح';
      case 'cancelled':
        return 'تم إلغاء الشحنة';
      default:
        return 'حالة الشحنة غير معروفة';
    }
  }

  void _shareShipmentDetails() {
    // TODO: Implement share functionality
    Get.snackbar('معلومة', 'مشاركة تفاصيل الشحنة');
  }

  void _contactSupport() {
    // TODO: Implement contact support
    Get.snackbar('معلومة', 'الاتصال بالدعم الفني');
  }

  void _reportProblem() {
    // TODO: Implement report problem
    Get.snackbar('معلومة', 'الإبلاغ عن مشكلة');
  }
}