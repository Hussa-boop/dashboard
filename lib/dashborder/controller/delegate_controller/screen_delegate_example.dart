
import 'package:dashboard/data/models/delegate_model/hive_delegate.dart';
import 'package:dashboard/data/models/prcel_model/hive_parcel.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_maps/maps.dart';

class DelegateShipmentsScreen extends StatefulWidget {
  final Delegate delegate;

  const DelegateShipmentsScreen({Key? key, required this.delegate}) : super(key: key);

  @override
  _DelegateShipmentsScreenState createState() => _DelegateShipmentsScreenState();
}

class _DelegateShipmentsScreenState extends State<DelegateShipmentsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _filterStatus = 'الكل';
  String _searchQuery = '';
  late MapZoomPanBehavior _zoomPanBehavior;

  @override
  void initState() {
    super.initState();
    print("Initiate the mapZoom");
    _zoomPanBehavior = MapZoomPanBehavior(
      zoomLevel: 4,
      minZoomLevel: 3,
      maxZoomLevel: 15,
    );
    print("end initiate the mapZoom");

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('شحنات المندوب: ${widget.delegate.deveName}'),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[800]!, Colors.blue[600]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.map),
            onPressed: () => _showShipmentsMap(),
          ),
        ],
      ),
      body: Column(
        children: [
           _buildFilterSection(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getFilteredShipments(),
              builder: (context, snapshot) {

                if (snapshot.hasError) {
                  return Center(child: Text('حدث خطأ في جلب البيانات'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('لا توجد شحنات متاحة'));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final shipment = snapshot.data!.docs[index];
                    return _buildShipmentCard(shipment);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _addNewShipment(),
        backgroundColor: Colors.blue[700],
      ),
    );
  }

  Stream<QuerySnapshot> _getFilteredShipments() {
    Query query = _firestore
        .collection('shipments')
        .where('delegateID', isEqualTo: 1745087164225);

    try {

      if (_filterStatus != 'الكل') {
        query = query.where('parcels.status', isEqualTo: _filterStatus);
      }

      if (_searchQuery.isNotEmpty) {
        query = query.where('trackingNumber', isGreaterThanOrEqualTo: _searchQuery)
            .where('trackingNumber', isLessThanOrEqualTo: '$_searchQuery\uf8ff');
      }

      return query.snapshots();
    } on Exception catch (e) {
      print("--------------------------------------------------------");
    }
    return query.snapshots();
  }

  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'ابحث برقم التتبع...',
                  border: InputBorder.none,
                  suffixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
          ),
          SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['الكل', 'في الانتظار', 'في الطريق', 'تم التسليم', 'ملغية'].map((status) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(status),
                    selected: _filterStatus == status,
                    onSelected: (selected) {
                      setState(() {
                        _filterStatus = selected ? status : 'الكل';
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShipmentCard(QueryDocumentSnapshot shipment) {
    final data = shipment.data() as Map<String, dynamic>;
    final parcels = (data['parcels'] as List).map((p) => Parcel.fromJsonMap(p)).toList();
    final shippingDate = (data['shippingDate'] as Timestamp).toDate();
    final deliveryDate = data['deliveryDate'] != null
        ? (data['deliveryDate'] as Timestamp).toDate()
        : null;

    // حساب إحصائيات الطرود
    final totalParcels = parcels.length;
    final deliveredCount = parcels.where((p) => p.status == 'تم التسليم').length;
    final inTransitCount = parcels.where((p) => p.status == 'في الطريق').length;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showShipmentDetails(shipment.id, data),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'رقم الشحنة: ${data['shippingID']}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(_getOverallStatus(parcels)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getOverallStatus(parcels),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'تاريخ الشحن: ${DateFormat('yyyy/MM/dd - HH:mm').format(shippingDate)}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              if (deliveryDate != null)
                Text(
                  'تاريخ التسليم: ${DateFormat('yyyy/MM/dd - HH:mm').format(deliveryDate)}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              SizedBox(height: 12),
              Row(
                children: [
                  _buildParcelStat('الكل', totalParcels, Colors.blue),
                  SizedBox(width: 8),
                  _buildParcelStat('تم التسليم', deliveredCount, Colors.green),
                  SizedBox(width: 8),
                  _buildParcelStat('في الطريق', inTransitCount, Colors.orange),
                ],
              ),
              SizedBox(height: 12),
              Text(
                'العنوان: ${data['shippingAddress']}',
                style: TextStyle(fontWeight: FontWeight.w500),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParcelStat(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 16,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getOverallStatus(List<Parcel> parcels) {
    if (parcels.every((p) => p.status == 'تم التسليم')) return 'تم التسليم';
    if (parcels.any((p) => p.status == 'ملغية')) return 'ملغية جزئياً';
    if (parcels.any((p) => p.status == 'في الطريق')) return 'في الطريق';
    return 'في الانتظار';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'تم التسليم': return Colors.green;
      case 'في الطريق': return Colors.orange;
      case 'ملغية': return Colors.red;
      case 'ملغية جزئياً': return Colors.purple;
      default: return Colors.blue;
    }
  }

  void _showShipmentDetails(String docId, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  'تفاصيل الشحنة #${data['shippingID']}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                _buildDetailRow('تاريخ الشحن',
                    DateFormat('yyyy/MM/dd - HH:mm').format((data['shippingDate'] as Timestamp).toDate())),
                if (data['deliveryDate'] != null)
                  _buildDetailRow('تاريخ التسليم',
                      DateFormat('yyyy/MM/dd - HH:mm').format((data['deliveryDate'] as Timestamp).toDate())),
                _buildDetailRow('العنوان', data['shippingAddress']),
                SizedBox(height: 16),
                Text(
                  'الطرود (${(data['parcels'] as List).length})',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                ...(data['parcels'] as List).map((parcel) {
                  final p = Parcel.fromJsonMap(parcel);
                  return _buildParcelItem(p);
                }).toList(),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('إغلاق'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _editShipment(docId, data),
                        child: Text('تعديل'),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.blue[700],
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParcelItem(Parcel parcel) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                parcel.trackingNumber,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getStatusColor(parcel.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: _getStatusColor(parcel.status).withOpacity(0.3)),
                ),
                child: Text(
                  parcel.status,
                  style: TextStyle(
                    color: _getStatusColor(parcel.status),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Text('المرسل: ${parcel.senderName}'),
          Text('المستلم: ${parcel.receiverName}'),
          Text('الوزن: ${parcel.prWight} كغ'),
          if (parcel.noted!.isNotEmpty)
            Text(
              'ملاحظات: ${parcel.noted}',
              style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
            ),
        ],
      ),
    );
  }

  void _showShipmentsMap() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          insetPadding: EdgeInsets.all(16),
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height * 0.7,
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('shipments')
                  .where('delegateID', isEqualTo: widget.delegate.delevID)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final shipments = snapshot.data!.docs;
                final markers = <MapMarker>[];

                for (var shipment in shipments) {
                  final data = shipment.data() as Map<String, dynamic>;
                  final parcels = (data['parcels'] as List).map((p) => Parcel.fromJsonMap(p)).toList();

                  for (var parcel in parcels) {
                    if (parcel.latitude != null && parcel.longitude != null) {
                      markers.add(
                        MapMarker(
                          latitude: parcel.latitude!,
                          longitude: parcel.longitude!,
                          child: GestureDetector(
                            // onTap: () => showParcelDetails(parcel),
                            child: Icon(
                              Icons.location_on,
                              color: _getStatusColor(parcel.status),
                              size: 30,
                            ),
                          ),
                        ),
                      );
                    }
                  }
                }

                return SfMaps(
                  layers: [
                    MapTileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      zoomPanBehavior: _zoomPanBehavior,
                      initialMarkersCount: markers.length,
                      markerBuilder: (BuildContext context, int index) {
                        return markers[index];
                      },
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إغلاق'),
            ),
          ],
        );
      },
    );
  }

  void _addNewShipment() {
    // تنفيذ إضافة شحنة جديدة
  }

  void _editShipment(String docId, Map<String, dynamic> data) {
    // تنفيذ تعديل الشحنة
  }
}



