import 'package:flutter/material.dart';
import 'package:dashboard/data/models/shipment_model/hive_shipment.dart';
import 'package:intl/intl.dart'as intl;

class ShipmentDetailsScreen extends StatelessWidget {
  final Shipment shipment;

  const ShipmentDetailsScreen({Key? key, required this.shipment})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:  TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('تفاصيل الشحنة #${shipment.shippingID}'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(
                title: 'معلومات الشحنة',
                children: [
                  _buildInfoRow('رقم الشحنة', shipment.shippingID.toString()),
                  _buildInfoRow('عنوان التوصيل', shipment.shippingAddress),
                  _buildInfoRow(
                      'تاريخ الشحن', _formatDate(shipment.shippingDate)),
                  _buildInfoRow(
                      'تاريخ التوصيل', _formatDate(shipment.deliveryDate)),
                  if (shipment.delegateID != null)
                    _buildInfoRow('المندوب', shipment.delegateID.toString()),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                title: 'الطرود (${shipment.parcels.length})',
                children: shipment.parcels.map((parcel) {
                  return ListTile(
                    title: Text('طرد #${parcel.parceID}'),
                    subtitle: Text('${parcel.trackingNumber} - ${parcel.status}'),
                    trailing: Text('${parcel.prWight} كجم'),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      {required String title, required List<Widget> children}) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return intl. DateFormat('yyyy-MM-dd').format(date);
  }
}
