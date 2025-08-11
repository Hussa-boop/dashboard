import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// شاشة كرت او بيانات حالة الشحن
Widget buildShipmentCard({
  required BuildContext context,
  required String status,
  required String trackingNumber,
  required String orderName,
  required String senderName,
  required bool isSender,
  required VoidCallback onTap, // دالة النقر الجديدة
}) {
  // تحديد الأيقونة واللون بناءً على الحالة
  IconData iconStatu;
  Color statusColor;
  Color timelineColor;
  void _copyTrackingNumber(BuildContext context) {
    Clipboard.setData(ClipboardData(text: trackingNumber));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ رقم التتبع'),
        duration: Duration(seconds: 1),
      ),
    );
  }
  if (status == "في مكتب التسليم") {
    iconStatu = Icons.local_shipping;
    statusColor = Colors.orange;
    timelineColor = Colors.orange.withOpacity(0.6);
  }
  else if (status == "تم الشحن") {
    iconStatu = Icons.airport_shuttle;
    statusColor = Colors.blueAccent;
    timelineColor = Colors.blueAccent.withOpacity(0.6);
  }
  else if (status == "تم التوصيل") {
    iconStatu = Icons.check_circle;
    statusColor = Colors.green;
    timelineColor = Colors.green.withOpacity(0.6);
  }
  else {
    iconStatu = Icons.gpp_good;
    statusColor = Colors.green;
    timelineColor = Colors.green;
  }

  return InkWell(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black12, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                trackingNumber,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.copy, size: 18, color: Colors.grey.shade600),
                onPressed: () => _copyTrackingNumber(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(width: 0.5, color: Colors.black12),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    Text(
                      status,
                      style: TextStyle(color: statusColor, fontSize: 14),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          bottomLeft: Radius.circular(15),
                        ),
                      ),
                      child: Icon(
                        iconStatu,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
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
                  color: timelineColor,
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      orderName,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 6),
                    RichText(
                      text: TextSpan(
                        text: isSender ? 'من : ' : 'إلى :',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrangeAccent,
                            fontSize: 18),
                        children: [
                          TextSpan(
                            text: senderName,
                            style: const TextStyle(fontSize: 16, color: Colors.black87),
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
              _buildTimelineIcon(Icons.inventory, timelineColor),
              _buildDashedLine(),
              _buildTimelineIcon(Icons.local_shipping, timelineColor),
              _buildDashedLine(),
              _buildTimelineIcon(Icons.inventory_2_outlined, timelineColor),
              _buildDashedLine(),
              _buildTimelineIcon(Icons.person, timelineColor),
            ],
          ),
        ],
      ),
    ),
  );
}

// إنشاء أيقونة داخل المخطط الزمني
Widget _buildTimelineIcon(IconData icon, Color color) {
  return Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
    ),
    child: Icon(
      icon,
      color: Colors.white,
      size: 16,
    ),
  );
}

// إنشاء الخط المنقط
Widget _buildDashedLine() {
  return Container(
    width: 30,
    height: 1,
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: Colors.grey.withOpacity(0.5),
          width: 1,
          style: BorderStyle.solid,
        ),
      ),
    ),
  );
}