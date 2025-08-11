import 'package:dashboard/data/models/prcel_model/hive_parcel.dart';
import 'package:dashboard/mobil/modules/view_data_shipments/desgin_status_shipment.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:intl/intl.dart'as intl;
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

class OperationsScreenUser extends StatelessWidget {
  final String recePhone;

  const OperationsScreenUser({super.key, required this.recePhone});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الطرد'),
        backgroundColor: Colors.orange.shade400,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('parcel')
            .where(
              'receiverPhone',
              isEqualTo: '775479401',
            )
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // تصفية البيانات حسب رقم هاتف المستقبل
          final parcels = snapshot.data!.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();

          if (parcels.isEmpty) {
            return const Center(child: Text('لا توجد طرود متاحة'));
          }

          return ListView.builder(
            itemCount: parcels.length,
            itemBuilder: (context, index) {
              final parcel = parcels[index];
              return _buildParcelCard(context, parcel);
            },
          );
        },
      ),
    );
  }

  Widget _buildParcelCard(BuildContext context, Map<String, dynamic> parcel) {
    return GestureDetector(
      onTap: () => _showParcelDetailsDialog(context, parcel),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // عنوان الطرد
              Text(
                parcel['orderName'] ?? 'بدون عنوان',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // معلومات أساسية
              Row(
                children: [
                  _buildInfoItem(Icons.confirmation_number, 'رقم التتبع',
                      parcel['trackingNumber'] ?? 'غير متوفر'),
                  const SizedBox(width: 16),
                  _buildInfoItem(
                      Icons.star, 'الحالة', parcel['status'] ?? 'غير معروفة'),
                ],
              ),
              const SizedBox(height: 8),

              // معلومات المرسل والمستقبل
              Row(
                children: [
                  _buildInfoItem(Icons.person_outline, 'المرسل',
                      parcel['senderName'] ?? 'غير معروف'),
                  const SizedBox(width: 16),
                  _buildInfoItem(Icons.person, 'المستقبل',
                      parcel['receiverName'] ?? 'غير معروف'),
                ],
              ),
              const SizedBox(height: 8),

              // معلومات إضافية
              Row(
                children: [
                  _buildInfoItem(Icons.location_on, 'الوجهة',
                      parcel['destination'] ?? 'غير معروفة'),
                  const SizedBox(width: 16),
                  _buildInfoItem(Icons.local_shipping, 'نوع الشحنة',
                      parcel['preType'] ?? 'غير معروف'),
                ],
              ),

              const SizedBox(height: 12),
              // زر لعرض المزيد من التفاصيل
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  icon: const Icon(Icons.info_outline, size: 16),
                  label: const Text('عرض التفاصيل'),
                  onPressed: () => _showParcelDetailsDialog(context, parcel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 10, color: Colors.orange.shade400),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showParcelDetailsDialog(
      BuildContext context, Map<String, dynamic> parcel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Center(
                      child: Text(
                        'تفاصيل الطرد',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildDetailRow(
                        'رقم التتبع', parcel['trackingNumber'] ?? 'غير متوفر'),
                    _buildDetailRow('الحالة', parcel['status'] ?? 'غير معروفة'),
                    _buildDetailRow(
                        'تاريخ الشحن',
                        parcel['shippingDate']?.toDate().toString() ??
                            'غير معروف'),
                    _buildDetailRow(
                        'المرسل', parcel['senderName'] ?? 'غير معروف'),
                    _buildDetailRow(
                        'المستقبل', parcel['receiverName'] ?? 'غير معروف'),
                    _buildDetailRow('هاتف المستقبل',
                        parcel['receiverPhone'] ?? 'غير متوفر'),
                    _buildDetailRow(
                        'الوجهة', parcel['destination'] ?? 'غير معروفة'),
                    _buildDetailRow('وزن الطرد',
                        parcel['prWight']?.toString() ?? 'غير معروف'),
                    _buildDetailRow(
                        'ملاحظات', parcel['noted'] ?? 'لا توجد ملاحظات'),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade400,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('إغلاق'),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: -10,
                top: -10,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.black54),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ParcelDetailsScreen extends StatefulWidget {
  final String id;
  final String trackingNumber;
  final String status;
  final String shippingDate;
  final String senderName;
  final String receiverName;
  final String orderName;
  final double? longitude;
  final double? latitude;
  final String senderAddress;
  final String receiverAddress;
  final String senderPhone;
  final String receiverPhone;
  final String shipmentWeight;
  final String shipmentType;
  final String paymentMethod;
  final double shipmentCost;

  const ParcelDetailsScreen({
    Key? key,
    required this.id,
    required this.trackingNumber,
    required this.status,
    required this.shippingDate,
    required this.senderName,
    required this.receiverName,
    required this.orderName,
    this.longitude,
    this.latitude,
    this.senderAddress = "عنوان المرسل غير محدد",
    this.receiverAddress = "عنوان المستلم غير محدد",
    this.senderPhone = "0000000000",
    this.receiverPhone = "0000000000",
    this.shipmentWeight = "1 كجم",
    this.shipmentType = "طرد صغير",
    this.paymentMethod = "الدفع عند الاستلام",
    this.shipmentCost = 25.0,
  }) : super(key: key);

  @override
  _ParcelDetailsScreenState createState() => _ParcelDetailsScreenState();
}

class _ParcelDetailsScreenState extends State<ParcelDetailsScreen> {
  bool _showFullDetails = false;
  bool _showRatingDialog = false;
  double _userRating = 0.0;
  String _ratingComment = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    // ألوان التصميم
    const Color primaryColor = Color(0xFF2E5BFF);
    const Color successColor = Color(0xFF2ED573);
    const Color warningColor = Color(0xFFFFB648);
    const Color dangerColor = Color(0xFFFF4E4E);
    const Color darkColor = Color(0xFF1E1E2D);
    const Color lightGrey = Color(0xFFF4F6FC);

    // تحديد لون الحالة
    Color statusColor;
    switch (widget.status) {
      case "في مكتب التسليم":
        statusColor = warningColor;
        break;
      case "تم الشحن":
        statusColor = primaryColor;
        break;
      case "تم التوصيل":
        statusColor = successColor;
        break;
      case "متأخر":
        statusColor = dangerColor;
        break;
      default:
        statusColor = primaryColor;
    }

    // تنسيق التاريخ
    String formattedDate = "غير محدد";
    try {
      final date = DateTime.parse(widget.shippingDate);
      formattedDate =intl. DateFormat('yyyy/MM/dd - hh:mm a').format(date);
    } catch (e) {
      debugPrint("Error parsing date: $e");
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الطرد'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => shareShipmentDetails(
              Parcel(
                id: '1',
                trackingNumber: widget.trackingNumber,
                status: widget.status,
                senderName: widget.senderName,
                receiverName: widget.receiverName,
                orderName: widget.orderName,
                destination: '',
                parceID: 0,
                receverName: widget.receiverName,
                prWight: 0.0,
                preType: 'قياسي',
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Directionality(textDirection:TextDirection.rtl ,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // بطاقة حالة الشحنة
              _buildStatusCard(theme, statusColor, formattedDate),

              const SizedBox(height: 20),

              // معلومات المرسل والمستلم
              _buildSenderReceiverSection(theme),

              const SizedBox(height: 20),

              // خط سير الشحنة
              _buildShipmentTimeline(statusColor),

              const SizedBox(height: 20),

              // تفاصيل إضافية
              _buildAdditionalDetails(theme),

              if (widget.longitude != null && widget.latitude != null) ...[
                const SizedBox(height: 20),
                _buildMapSection(),
              ],

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomActionBar(theme),
    );
  }

  Widget _buildStatusCard(
      ThemeData theme, Color statusColor, String formattedDate) {
    return Directionality(textDirection: TextDirection.rtl,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.orderName,
                      style: theme.textTheme.headline6?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.confirmation_number_outlined, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    widget.trackingNumber,
                    style: theme.textTheme.subtitle1,
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(
                          ClipboardData(text: widget.trackingNumber));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم نسخ رقم التتبع')),
                      );
                    },
                    child: const Icon(Icons.copy, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "تاريخ الشحن: $formattedDate",
                    style: theme.textTheme.bodyText2,
                  ),
                ],
              ),
              if (_showFullDetails) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.local_shipping_outlined, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "نوع الشحنة: ${widget.shipmentType}",
                      style: theme.textTheme.bodyText2,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.monitor_weight_outlined, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "الوزن: ${widget.shipmentWeight}",
                      style: theme.textTheme.bodyText2,
                    ),
                  ],
                ),
              ],
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _showFullDetails = !_showFullDetails;
                    });
                  },
                  child: Text(
                    _showFullDetails
                        ? "إخفاء التفاصيل"
                        : "عرض المزيد من التفاصيل",
                    style: const TextStyle(color: Color(0xFF2E5BFF)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSenderReceiverSection(ThemeData theme) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // معلومات المرسل
            _buildPersonInfo(
              icon: Icons.person_outline,
              name: widget.senderName,
              address: widget.senderAddress,
              phone: widget.senderPhone,
              isSender: true,
              theme: theme,
            ),

            const SizedBox(height: 16),

            // سهم الشحن
            const Icon(Icons.arrow_downward_rounded, color: Colors.grey),

            const SizedBox(height: 16),

            // معلومات المستلم
            _buildPersonInfo(
              icon: Icons.person,
              name: widget.receiverName,
              address: widget.receiverAddress,
              phone: widget.receiverPhone,
              isSender: false,
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonInfo({
    required IconData icon,
    required String name,
    required String address,
    required String phone,
    required bool isSender,
    required ThemeData theme,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSender ? const Color(0xFFE6F7FF) : const Color(0xFFF6F1FF),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isSender ? const Color(0xFF1890FF) : const Color(0xFF722ED1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isSender ? "المرسل" : "المستلم",
                style: theme.textTheme.caption?.copyWith(
                  color: Colors.grey,
                ),
              ),
              Text(
                name,
                style: theme.textTheme.subtitle1?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      address,
                      style: theme.textTheme.bodyText2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              InkWell(
                onTap: () => _makePhoneCall(phone),
                child: Row(
                  children: [
                    const Icon(Icons.phone_outlined, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      phone,
                      style: theme.textTheme.bodyText2?.copyWith(
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShipmentTimeline(Color statusColor) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "خط سير الشحنة",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 16),

            // الخط الزمني
            _buildTimelineItem(
              icon: Icons.inventory_rounded,
              title: "تم استلام الطلب",
              subtitle: "تم استلام الطلب من المرسل",
              date: "15 مايو 2025 - 10:30 ص",
              isCompleted: true,
              isActive: true,
            ),

            _buildTimelineConnector(isActive: true),

            _buildTimelineItem(
              icon: Icons.local_shipping_rounded,
              title: "في طريق التسليم",
              subtitle: "الشحنة في طريقها إلى مركز التوزيع",
              date: "16 مايو 2025 - 02:45 م",
              isCompleted: widget.status == "في المستودع" ||
                  widget.status == "تم التسليم" ||
                  widget.status == "تم الطرد",
              isActive: widget.status == "في المستودع" ||
                  widget.status == "تم التسليم" ||
                  widget.status == "تم الطرد",
            ),

            _buildTimelineConnector(
              isActive: widget.status == "في المستودع" ||
                  widget.status == "تم التسليم" ||
                  widget.status == "تم الطرد",
            ),

            _buildTimelineItem(
              icon: Icons.store_rounded,
              title: "في مكتب التسليم",
              subtitle: "الشحنة وصلت إلى مكتب التسليم المحلي",
              date: widget.status == "تم التسليم" || widget.status == "تم الطرد"
                  ? "17 مايو 2025 - 09:15 ص"
                  : "متوقع 25 مايو 2025",
              isCompleted: widget.status == "تم التسليم" || widget.status == "تم الطرد",
              isActive: widget.status == "في مكتب التسليم" ||
                  widget.status == "تم التسليم" ||
                  widget.status == "تم الطرد",
            ),

            if (widget.status == "تم التسليم" || widget.status == "تم الطرد") ...[
              _buildTimelineConnector(isActive: true),
              _buildTimelineItem(
                icon: widget.status == "تم التسليم"
                    ? Icons.check_circle_rounded
                    : Icons.block_rounded,
                title: widget.status == "تم التسليم" ? "تم التسليم" : "تم الطرد",
                subtitle: widget.status == "تم التسليم"
                    ? "تم تسليم الشحنة إلى المستلم"
                    : "تم طرد الشحنة من قبل المستلم",
                date: "17 مايو 2025 - 03:20 م",
                isCompleted: true,
                isActive: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String date,
    required bool isCompleted,
    required bool isActive,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? isActive
                ? const Color(0xFF2E5BFF)
                : Colors.red // لون مختلف لحالة الطرد
                : isActive
                ? const Color(0xFF2E5BFF).withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            border: isActive && !isCompleted
                ? Border.all(color: const Color(0xFF2E5BFF), width: 2)
                : null,
          ),
          child: Center(
            child: Icon(
              icon,
              size: 16,
              color: isCompleted
                  ? Colors.white
                  : isActive
                  ? const Color(0xFF2E5BFF)
                  : Colors.grey,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isActive ? Colors.black87 : Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontStyle: isActive ? FontStyle.normal : FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineConnector({required bool isActive}) {
    return Container(
      margin: const EdgeInsets.only(left: 14, top: 2, bottom: 2),
      width: 2,
      height: 30,
      color: isActive
          ? const Color(0xFF2E5BFF).withOpacity(0.4)
          : Colors.grey.withOpacity(0.1),
    );
  }
  Widget _buildAdditionalDetails(ThemeData theme) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "تفاصيل إضافية",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              icon: Icons.credit_card_outlined,
              title: "طريقة الدفع",
              value: widget.paymentMethod,
            ),
            const Divider(height: 24),
            _buildDetailRow(
              icon: Icons.money_outlined,
              title: "تكلفة الشحن",
              value: "${widget.shipmentCost} ريال",
            ),
            const Divider(height: 24),
            _buildDetailRow(
              icon: Icons.description_outlined,
              title: "ملاحظات",
              value: "لا توجد ملاحظات",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMapSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 150,
            color: Colors.grey.shade200,
            alignment: Alignment.center,
            child: Container(
              height: 200,
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: FlutterMap(
                  options: MapOptions(
                    center: LatLng(widget.latitude!, widget.longitude!),
                    zoom: 14.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app',
                      tileProvider:
                          CancellableNetworkTileProvider(), // أهم تحسين للأداء
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(widget.latitude!, widget.longitude!),
                          child: const Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // في التطبيق الحقيقي يمكنك استخدام خرائط جوجل هنا
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "موقع التسليم",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.receiverAddress,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.directions),
                    label: const Text("فتح في خرائط جوجل"),
                    onPressed: () => _openMaps(),
                    style: ElevatedButton.styleFrom(
                      primary: const Color(0xFF2E5BFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(ThemeData theme) {
    // إظهار زر التقييم فقط إذا كانت حالة الشحنة "تم التوصيل"
    final bool showRateButton = widget.status == "تم التسليم";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (showRateButton) ...[
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.star_border),
                label: const Text("تقييم الشحنة"),
                onPressed: _showRatingBottomSheet,
                style: ElevatedButton.styleFrom(
                  primary: Colors.amber.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.headset_mic_outlined),
              label: const Text("الدعم الفني"),
              onPressed: () => _contactSupport(),
              style: OutlinedButton.styleFrom(
                primary: const Color(0xFF2E5BFF),
                side: const BorderSide(color: Color(0xFF2E5BFF)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          if (!showRateButton) ...[
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.receipt_outlined),
                label: const Text("إيصال الشحن"),
                onPressed: () => _downloadReceipt(),
                style: ElevatedButton.styleFrom(
                  primary: const Color(0xFF2E5BFF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showRatingBottomSheet() {
    setState(() {
      _showRatingDialog = true;
      _userRating = 0.0; // إعادة تعيين التقييم عند كل فتح
      _ratingComment = ''; // إعادة تعيين التعليق
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Directionality(textDirection: TextDirection.rtl,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 20,
                  right: 20,
                  top: 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'كيف كانت تجربة الشحن لديك؟',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'شاركنا رأيك لمساعدتنا في تحسين الخدمة',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 15),
                    Center(
                      child: RatingBar.builder(
                        initialRating: _userRating,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemSize: 40,
                        itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {
                          setState(() {
                            _userRating = rating;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_userRating > 0 && _userRating < 3) ...[
                      const Text(
                        'نأسف لتجربتك! الرجاء مشاركة التفاصيل لمساعدتنا على التحسين',
                        style: TextStyle(color: Colors.redAccent),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                    ],
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'مشاركة تفاصيل أكثر (اختياري)',
                        border: OutlineInputBorder(),
                        hintText: 'ما الذي يمكننا تحسينه في خدمتنا؟',
                      ),
                      maxLines: 3,
                      onChanged: (value) => _ratingComment = value,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: _userRating > 0
                            ? Colors.orange.shade400
                            : Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('إرسال التقييم',
                          style: TextStyle(fontSize: 16)),
                      onPressed: _userRating > 0 ? _submitRating : null,
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      child: const Text('تخطي',
                          style: TextStyle(color: Colors.grey)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      setState(() {
        _showRatingDialog = false;
      });
    });
  }

  Future<void> _submitRating() async {
    if (_userRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار تقييم قبل الإرسال')),
      );
      return;
    }

    try {
      // إظهار مؤشر تحميل
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // الحصول على معرف المستخدم الحالي (يمكن استخدام Firebase Auth إذا كان متوفراً)
   // إنشاء مرجع لمجموعة التقييمات في Firestore
 FirebaseFirestore.instance.collection('parcel').doc(widget.id).update({
        'rating': _userRating,
        'comment': _ratingComment,
      });



      // إغلاق مؤشر التحميل
      Navigator.pop(context);

      // إظهار رسالة نجاح
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إرسال تقييمك بنجاح ($_userRating نجوم)'),
          duration: const Duration(seconds: 2),
        ),
      );

      // إعادة تعيين القيم
      setState(() {
        _userRating = 0.0;
        _ratingComment = '';
      });

      // إغلاق البوتوم شيت
      Navigator.pop(context);
    } catch (e) {
      // إغلاق مؤشر التحميل في حالة الخطأ
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء إرسال التقييم: ${e.toString()}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // === الوظائف المساعدة ===

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel+967',
      path: phoneNumber,
    );
    if (await canLaunch(launchUri.toString())) {
      await launch(launchUri.toString());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر فتح تطبيق الهاتف')),
      );
    }
  }

  Future<void> _openMaps() async {
    if (widget.longitude == null || widget.latitude == null) return;

    final url =
        'https://www.google.com/maps/search/?api=1&query=${widget.latitude},${widget.longitude}';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر فتح تطبيق الخرائط')),
      );
    }
  }

  void _contactSupport() {
    // TODO: Implement contact support
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('فتح شاشة الدعم الفني')),
    );
  }

  void _downloadReceipt() {
    // TODO: Implement download receipt
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('جاري تحميل إيصال الشحن')),
    );
  }

  void shareShipmentDetails(Parcel shipment) {
    final text = '''
تفاصيل الشحنة:
رقم التتبع: ${shipment.trackingNumber}
المرسل: ${shipment.senderName}
المستلم: ${shipment.receiverName}
الحالة: ${ParcelStatusFormatter.getStatusInfo(shipment.status).text}
''';

    Share.share(text);
  }
}
// حفظ التقارير pdf

// class ParcelDetailsScreens extends StatelessWidget {
//   final List<Parcel> parcelData;
//
//   const ParcelDetailsScreens({Key? key, required this.parcelData}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('تفاصيل الطرد'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.picture_as_pdf),
//             onPressed: () => _generateAndSavePdf(context),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildDetailRow('رقم التتبع', parcelData.where((element) => element.trackingNumber)),
//             _buildDetailRow('الحالة',      parcelData.status),
//             _buildDetailRow('تاريخ الشحن', _formatDate(parcelData.shippingDate?.toIso8601String())),
//             _buildDetailRow('اسم المرسل', parcelData.senderName),
//             _buildDetailRow('اسم المستلم', parcelData.receiverName),
//             _buildDetailRow('اسم الطلب', parcelData.orderName),
//             _buildDetailRow('خط الطول', parcelData.longitude?.toString() ?? 'غير متوفر'),
//             _buildDetailRow('خط العرض', parcelData.latitude?.toString() ?? 'غير متوفر'),
//             _buildDetailRow('عنوان المرسل', parcelData.destination),
//             _buildDetailRow('هاتف المستلم', parcelData.receiverPhone),
//             SizedBox(height: 20),
//             Center(
//               child: ElevatedButton.icon(
//                 icon: Icon(Icons.save),
//                 label: Text('حفظ كملف PDF'),
//                 onPressed: () => _generateAndSavePdf(context),
//                 style: ElevatedButton.styleFrom(
//                   padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDetailRow(String label, String? value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             '$label: ',
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 16,
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value ?? 'غير متوفر',
//               style: TextStyle(fontSize: 16),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   String _formatDate(String? dateString) {
//     if (dateString == null) return 'غير متوفر';
//     try {
//       final date = DateTime.parse(dateString);
//       return DateFormat('yyyy/MM/dd - hh:mm a').format(date);
//     } catch (e) {
//       return dateString;
//     }
//   }
//
//   Future<void> _generateAndSavePdf(BuildContext context) async {
//     try {
//       // إنشاء مستند PDF
//       final pdf = pw.Document();
//
//       // إضافة صفحة إلى المستند
//       pdf.addPage(
//         pw.Page(
//           pageFormat: PdfPageFormat.a4,
//           build: (pw.Context context) {
//             return _buildPdfContent();
//           },
//         ),
//       );
//
//       // عرض معاينة PDF وإمكانية الحفظ
//       await Printing.layoutPdf(
//         onLayout: (PdfPageFormat format) async => pdf.save(),
//       );
//
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('حدث خطأ أثناء إنشاء الملف: $e')),
//       );
//     }
//   }
//
//   pw.Widget _buildPdfContent() {
//     return pw.Padding(
//       padding: pw.EdgeInsets.all(24),
//       child: pw.Column(
//         crossAxisAlignment: pw.CrossAxisAlignment.start,
//         children: [
//           // رأس التقرير
//           pw.Center(
//             child: pw.Text(
//               'تقرير بيانات الطرد',
//               style: pw.TextStyle(
//                 fontSize: 24,
//                 fontWeight: pw.FontWeight.bold,
//               ),
//             ),
//           ),
//           pw.SizedBox(height: 20),
//           pw.Divider(thickness: 2),
//           pw.SizedBox(height: 20),
//
//           // معلومات الشركة
//           pw.Row(
//             mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//             children: [
//               pw.Text(
//                 'شركة الشحن',
//                 style: pw.TextStyle(
//                   fontSize: 18,
//                   fontWeight: pw.FontWeight.bold,
//                 ),
//               ),
//               pw.Text(
//                 'تاريخ التقرير: ${DateFormat('yyyy/MM/dd').format(DateTime.now())}',
//                 style: pw.TextStyle(fontSize: 14),
//               ),
//             ],
//           ),
//           pw.SizedBox(height: 30),
//
//           // تفاصيل الطرد
//           pw.Text(
//             'معلومات الطرد',
//             style: pw.TextStyle(
//               fontSize: 18,
//               fontWeight: pw.FontWeight.bold,
//               decoration: pw.TextDecoration.underline,
//             ),
//           ),
//           pw.SizedBox(height: 15),
//           _buildPdfRow('رقم التتبع', parcelData.trackingNumber),
//           _buildPdfRow('حالة الطرد',   parcelData.status),
//           _buildPdfRow('تاريخ الشحن', _formatDate(parcelData.shippingDate?.toIso8601String())),
//           _buildPdfRow('اسم المرسل', parcelData.senderName),
//           _buildPdfRow('اسم المستلم', parcelData.receiverName),
//           _buildPdfRow('اسم الطلب',  parcelData.orderName),
//           _buildPdfRow('خط الطول', parcelData.longitude?.toString() ?? 'غير متوفر'),
//           _buildPdfRow('خط العرض', parcelData.latitude?.toString() ?? 'غير متوفر'),
//           _buildPdfRow('عنوان المرسلل', parcelData.destination),
//           _buildPdfRow('هاتف المستلمم', parcelData.receiverPhone),
//           pw.SizedBox(height: 30),
//
//           // خريطة مصغرة (إذا كانت هناك إحداثيات)
//           if (parcelData.latitude != null && parcelData.longitude != null)
//             pw.Column(
//               children: [
//                 pw.Text(
//                   'موقع الطرد',
//                   style: pw.TextStyle(
//                     fontSize: 18,
//                     fontWeight: pw.FontWeight.bold,
//                     decoration: pw.TextDecoration.underline,
//                   ),
//                 ),
//                 pw.SizedBox(height: 10),
//                 pw.Container(
//                   height: 200,
//                   decoration: pw.BoxDecoration(
//                     border: pw.Border.all(width: 1),
//                   ),
//                   child: pw.FlutterLogo(), // يمكن استبدالها بصورة خريطة حقيقية
//                 ),
//                 pw.SizedBox(height: 10),
//                 pw.Text(
//                   'الإحداثيات: ${parcelData.latitude}, ${parcelData.longitude}',
//                   style: pw.TextStyle(fontSize: 12),
//                 ),
//               ],
//             ),
//
//           // تذييل الصفحة
//           pw.SizedBox(height: 40),
//           pw.Divider(thickness: 1),
//           pw.Center(
//             child: pw.Text(
//               'شكراً لاستخدامكم خدماتنا',
//               style: pw.TextStyle(fontSize: 14),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   pw.Widget _buildPdfRow(String label, String? value) {
//     return pw.Padding(
//       padding: pw.EdgeInsets.symmetric(vertical: 4),
//       child: pw.Row(
//         crossAxisAlignment: pw.CrossAxisAlignment.start,
//         children: [
//           pw.Text(
//             '$label: ',
//             style: pw.TextStyle(
//               fontWeight: pw.FontWeight.bold,
//               fontSize: 14,
//             ),
//           ),
//           pw.Text(
//             value ?? 'غير متوفر',
//             style: pw.TextStyle(fontSize: 14),
//           ),
//         ],
//       ),
//     );
//   }
// }
