import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../data/models/prcel_model/hive_parcel.dart';
import '../mobil/modules/view_data_shipments/desgin_status_shipment.dart';


class ShipmentDetailsWidget extends StatelessWidget {
  final Parcel shipment;
  final bool showFullDetails;
  final VoidCallback? onTap;
  final bool showStatusBadge;
  final bool showProgressTimeline;

  const ShipmentDetailsWidget({
    Key? key,
    required this.shipment,
    this.showFullDetails = true,
    this.onTap,
    this.showStatusBadge = true,
    this.showProgressTimeline = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusInfo = ParcelStatusFormatter.getStatusInfo(shipment.status);
    final theme = Theme.of(context);
    final dateFormatter = DateFormat('yyyy/MM/dd - hh:mm a');

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [statusInfo.backgroundColor.withOpacity(0.3), Colors.white],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                _buildHeaderSection(statusInfo, context),
                const SizedBox(height: 16),

                // Order Info Section
                _buildOrderInfoSection(),


                // Sender & Receiver Section
                if (showFullDetails) _buildSenderReceiverSection(),
                if (showFullDetails) const SizedBox(height: 16),

                // Details Section
                _buildDetailsSection(dateFormatter),
                if (showProgressTimeline && showFullDetails) const SizedBox(height: 8),

                // Progress Timeline
                if (showProgressTimeline && showFullDetails)
                  _buildProgressTimeline(statusInfo),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(StatusInfo statusInfo, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'رقم التتبع',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      shipment.trackingNumber,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.copy, size: 18, color: Colors.grey[600]),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: shipment.trackingNumber));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم نسخ رقم التتبع')),
                      );
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (showStatusBadge) _buildStatusBadge(statusInfo),
      ],
    );
  }

  Widget _buildStatusBadge(StatusInfo statusInfo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusInfo.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusInfo.color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusInfo.icon, size: 16, color: statusInfo.color),
          const SizedBox(width: 6),
          Text(
            statusInfo.text,
            style: TextStyle(
              color: statusInfo.color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfoSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'معلومات الطلب',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.shopping_bag, size: 20, color: Colors.blue[800]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  shipment.orderName.isNotEmpty
                      ? shipment.orderName
                      : 'شحنة ${shipment.trackingNumber}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSenderReceiverSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'المرسل والمستلم',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildPersonInfo(
                  icon: Icons.person_outline,
                  title: 'المرسل',
                  name: shipment.senderName,
                  color: Colors.deepOrangeAccent,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_forward, size: 20, color: Colors.grey),
              ),
              Expanded(
                child: _buildPersonInfo(
                  icon: Icons.person,
                  title: 'المستلم',
                  name: shipment.receiverName,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPersonInfo({
    required IconData icon,
    required String title,
    required String name,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(DateFormat dateFormatter) {
    return Row(
      children: [
        _buildDetailChip(
          icon: Icons.calendar_today,
          value: shipment.shippingDate != null
              ? dateFormatter.format(shipment.shippingDate!)
              : 'غير محدد',
          label: 'تاريخ الشحن',
        ),
        const Spacer(),
        if (shipment.latitude != 0.0 && shipment.longitude != 0.0)
          _buildDetailChip(
            icon: Icons.location_on,
            value: 'عرض الموقع',
            label: 'التتبع',
            onTap: onTap,
          ),
      ],
    );
  }

  Widget _buildDetailChip({
    required IconData icon,
    required String value,
    required String label,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: Colors.blue[800]),
                const SizedBox(width: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressTimeline(StatusInfo statusInfo) {
    final steps = [
      {
        'title': 'تم الطلب',
        'icon': Icons.shopping_cart,
        'completed': true,
        'color': Colors.green
      },
      {
        'title': 'في المستودع',
        'icon': Icons.warehouse,
        'completed': shipment.status != 'pending'||shipment.status=='في المستودع',
        'color': Colors.blue
      },
      {
        'title': 'قيد الشحن',
        'icon': Icons.local_shipping,
        'completed': shipment.status == 'قيد الشحن' ||
            shipment.status == 'delivered' ||
            shipment.status == 'partial',
        'color': Colors.orange
      },
      {
        'title': 'تم التسليم',
        'icon': Icons.check_circle,
        'completed': shipment.status == 'تم التسليم' ||
            shipment.status == 'partial',
        'color': statusInfo.color
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'حالة التوصيل',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (int i = 0; i < steps.length; i++) ...[
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: steps[i]['completed'] as bool
                            ? (steps[i]['color'] as Color).withOpacity(0.2)
                            : Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        steps[i]['icon'] as IconData,
                        size: 16,
                        color: steps[i]['completed'] as bool
                            ? steps[i]['color'] as Color
                            : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      steps[i]['title'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        color: steps[i]['completed'] as bool
                            ? steps[i]['color'] as Color
                            : Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              if (i < steps.length - 1)
                Expanded(
                  child: Divider(
                    thickness: 2,
                    color: steps[i]['completed'] as bool
                        ? (steps[i]['color'] as Color).withOpacity(0.5)
                        : Colors.grey[200],
                  ),
                ),
            ],
          ],
        ),
      ],
    );
  }
}