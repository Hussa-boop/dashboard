import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ParcelHistoryScreen extends StatefulWidget {


  const ParcelHistoryScreen({Key? key}) : super(key: key);

  @override
  _ParcelHistoryScreenState createState() => _ParcelHistoryScreenState();
}

class _ParcelHistoryScreenState extends State<ParcelHistoryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm');
  final user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل الشحنات', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blue.shade800,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: _showFilterDialog,
            tooltip: 'تصفية النتائج',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('parcels')
            .where('userId', isEqualTo: user?.uid)

            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data?.docs.isEmpty ?? true) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد شحنات مسجلة',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final parcel = _parseParcelData(doc, data);

              return _buildParcelCard(parcel, context);
            },
          );
        },
      ),
    );
  }

  Map<String, dynamic> _parseParcelData(QueryDocumentSnapshot doc, Map<String, dynamic> data) {
    return {
      'id': doc.id,
      'trackingNumber': data['trackingNumber'] ?? 'غير متوفر',
      'status': data['status'] ?? 'غير معروف',
      'senderName': data['senderName'] ?? 'غير معروف',
      'receiverName': data['receiverName'] ?? 'غير معروف',
      'orderName': data['orderName'] ?? 'غير محدد',
      'shippingDate': data['shippingDate'] != null
          ? DateTime.tryParse(data['shippingDate'])
          : null,
      'longitude': (data['longitude'] as num?)?.toDouble(),
      'latitude': (data['latitude'] as num?)?.toDouble(),
      'receiverPhone': data['receiverPhone'] ?? 'غير متوفر',
      'destination': data['destination'] ?? 'غير محدد',
      'parceID': data['parceID'] ?? 0,
      'prWight': (data['prWight'] as num?)?.toDouble() ?? 0.0,
      'noted': data['noted'] ?? '',
      'preType': data['preType'] ?? 'عادي',
      'shipmentID': data['shipmentID'] ?? '',
    };
  }

  Widget _buildParcelCard(Map<String, dynamic> parcel, BuildContext context) {
    final statusColor = _getStatusColor(parcel['status']);
    final dateText = parcel['shippingDate'] != null
        ? _dateFormat.format(parcel['shippingDate'])
        : 'غير محدد';

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          HapticFeedback.lightImpact();
          _showParcelDetails(parcel, context);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'رقم التتبع: ${parcel['trackingNumber']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      parcel['status'],
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.person, 'المرسل:', parcel['senderName']),
              _buildInfoRow(Icons.person_outline, 'المستلم:', parcel['receiverName']),
              _buildInfoRow(Icons.location_on, 'الوجهة:', parcel['destination']),
              _buildInfoRow(Icons.date_range, 'تاريخ الشحن:', dateText),
              _buildInfoRow(Icons.local_shipping, 'نوع الشحنة:', parcel['preType']),
              _buildInfoRow(Icons.scale, 'الوزن:', '${parcel['prWight']} كغ'),
              if (parcel['noted'].isNotEmpty)
                _buildInfoRow(Icons.note, 'ملاحظات:', parcel['noted']),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blueGrey),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'تم التسليم':
        return Colors.green;
      case 'قيد التوصيل':
        return Colors.orange;
      case 'في المستودع':
        return Colors.blue;
      case 'ملغى':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showParcelDetails(Map<String, dynamic> parcel, BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 60,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const Text(
                'تفاصيل الشحنة',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildDetailItem('رقم التتبع', parcel['trackingNumber']),
              _buildDetailItem('حالة الشحنة', parcel['status']),
              _buildDetailItem('اسم الطلب', parcel['orderName']),
              _buildDetailItem('المرسل', parcel['senderName']),
              _buildDetailItem('المستلم', parcel['receiverName']),
              _buildDetailItem('هاتف المستلم', parcel['receiverPhone']),
              _buildDetailItem('الوجهة', parcel['destination']),
              _buildDetailItem('تاريخ الشحن',
                  parcel['shippingDate'] != null
                      ? _dateFormat.format(parcel['shippingDate'])
                      : 'غير محدد'),
              _buildDetailItem('نوع الشحنة', parcel['preType']),
              _buildDetailItem('الوزن', '${parcel['prWight']} كغ'),
              if (parcel['noted'].isNotEmpty)
                _buildDetailItem('ملاحظات', parcel['noted']),
              const SizedBox(height: 20),
              if (parcel['latitude'] != null && parcel['longitude'] != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.map),
                    label: const Text('عرض الموقع على الخريطة'),
                    onPressed: () {
                      // تنفيذ فتح الخريطة
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Divider(height: 20),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    // تنفيذ واجهة تصفية النتائج
  }
}