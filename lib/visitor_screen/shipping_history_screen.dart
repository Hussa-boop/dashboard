import 'package:dashboard/data/models/prcel_model/hive_parcel.dart';
import 'package:dashboard/mobil/modules/view_data_shipments/desgin_status_shipment.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart'as intl;
import 'package:shimmer/shimmer.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
class AdvancedShippingHistoryScreen extends StatefulWidget {
  @override
  _AdvancedShippingHistoryScreenState createState() => _AdvancedShippingHistoryScreenState();
}

class _AdvancedShippingHistoryScreenState extends State<AdvancedShippingHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _hasSearchError = false;
  String _searchError = '';
  List<Parcel> _searchResults = [];
  bool _hasSearched = false;
  String _searchQuery = '';
  String _selectedFilter = 'all';
  final intl.DateFormat _dateFormatter =intl. DateFormat('yyyy-MM-dd – HH:mm');
  bool _isRefreshing = false;
  Future<void> _searchparcel(String trackingNumber) async {
    if (trackingNumber.isEmpty) {
      _clearSearchResults();
      return;
    }

    setState(() {
      _isSearching = true;
      _hasSearched = true;
      _hasSearchError = false;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('parcel')
          .where('trackingNumber', isEqualTo: trackingNumber.trim())
          .limit(1)
          .get();

      setState(() {
        _searchResults = snapshot.docs.map((doc) {
          final data = doc.data();
          return Parcel(
            id: doc.id,
            trackingNumber: data['trackingNumber']?.toString() ?? '',
            status: data['status']?.toString() ?? 'pending',
            senderName: data['senderName']?.toString() ?? '',
            receiverName: data['receiverName']?.toString() ?? '',
            orderName: data['orderName']?.toString() ?? '',
            shippingDate: _parseShippingDate(data['shippingDate']),
            longitude: _parseDouble(data['longitude']),
            latitude: _parseDouble(data['latitude']),
            receiverPhone: data['receiverPhone']?.toString(),
            destination: data['destination']?.toString(),
            parceID: (data['parceID'] as num?)?.toInt() ?? 0,
            receverName: data['receverName']?.toString() ?? '',
            prWight: _parseDouble(data['prWight']) ?? 0.0,
            noted: data['noted']?.toString(),
            preType: data['preType']?.toString() ?? 'standard',
            shipmentID: data['shipmentID']?.toString(),
          );
        }).toList();
      });



    } catch (e) {
      setState(() {
        _searchResults = [];
        _hasSearchError = true;
        _searchError = e.toString();
        print(e);
      });
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }
// دوال مساعدة للتحويل الآمن
DateTime? _parseShippingDate(dynamic date) {
  if (date == null) return null;
  if (date is Timestamp) return date.toDate();
  if (date is DateTime) return date;
  if (date is String) return DateTime.tryParse(date);
  return null;
}

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
  void _clearSearchResults() {
    setState(() {
      _searchResults = [];
      _hasSearched = false;
      _hasSearchError = false;
    });
  }
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
     textDirection: TextDirection.rtl, child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: _buildAppBar(),
        body: Column(
          children: [
            _buildSearchAndFilterBar(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshData,
                child: _hasSearched
                    ? _buildSearchResults()
                    :_buildEmptyState(),
              ),
            ),
          ],
        ),
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  // ================ Widget Builders ================
  Widget _buildSearchResults() {
    if (_isSearching) {
      return _buildLoadingShimmer();
    }

    if (_hasSearchError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'حدث خطأ في البحث: $_searchError',
              style: TextStyle(color: Colors.red),
            ),
            ElevatedButton(
              onPressed: _clearSearchResults,
              child: Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'لا توجد نتائج للبحث',
              style: TextStyle(color: Colors.grey[600]),
            ),
            TextButton(
              onPressed: _clearSearchResults,
              child: Text('عرض جميع الطرود'),
            ),
          ],
        ),
      );
    }

    return _buildparcelsList(_searchResults);
  }
  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('تتبع الطرد', style: TextStyle(fontWeight: FontWeight.bold)),
      centerTitle: true,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange, Colors.deepOrangeAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSearchField(),
          const SizedBox(height: 12),
          _buildFilterChips(),
        ],
      ),
    );
  }
  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'ابحث برقم التتبع...',
        prefixIcon: Icon(Icons.search, color: Colors.blue[800]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            _searchController.clear();
            _clearSearchResults();
          },
        )
            : null,
      ),
      onChanged: (value) {
        if(value.length>=3)
        // يمكنك هنا إما البحث أثناء الكتابة أو عند الضغط على زر البحث
         _searchparcel(value); // للبحث الفوري أثناء الكتابة
      },
      onSubmitted: (value) {
        _searchparcel(value); // للبحث عند الضغط على Enter
      },
    );
  }


  Widget _buildFilterChips() {
    final filters = {
      'all': 'الكل',
    'يتم الشحن':
    'يتم الشحن'
    , 'في المستودع':
    'في المستودع'
    ,
    'مستلم':
    'مستلم'
    ,
    'مفقود':
    'مفقود',
      'ملغي': 'ملغي'
      ,
      'تم التسليم': 'تم التسليم',
      'قيد التوصيل': 'قيد التوصيل',

      'تم الالغاء من المرسل':
      'تم الالغاء من المرسل'
      ,
      'تم الرفض مع الدفع':
      'تم الرفض مع الدفع'
      ,
      'تم الرفض مع سداد جزء':
      'تم الرفض مع سداد جزء'
      ,
      'تم الرفض ولم يتم الدفع':
      'تم الرفض ولم يتم الدفع'
      ,
      'تم التأجيل':
      'تم التأجيل'
      ,
      'في مكتب الشحن':
      'في مكتب الشحن'
      ,
      'في مكتب التسليم':
      'في مكتب التسليم'
      ,
      'تم التسليم جزئياً':
      'تم التسليم جزئياً'


    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(

              label: Text(entry.value),
              selected: _selectedFilter == entry.key,
              onSelected: (selected) => setState(() => _selectedFilter = selected ? entry.key : 'all'),
              selectedColor: Colors.blue[800],
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: _selectedFilter == entry.key ? Colors.white : Colors.grey[800],
              ),
              backgroundColor: Colors.grey[200],
              shape: const StadiumBorder(),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildparcelsList(List<Parcel> parcels) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: parcels.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildShippingCard(parcels[index]),
    );
  }

  Widget _buildShippingCard(Parcel parcel) {
    final statusInfo = ParcelStatusFormatter.getStatusInfo(parcel.status);

    return Directionality(
     textDirection: TextDirection.rtl, child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showparcelDetails(parcel),
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
                  // Header Row (Tracking + Status)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          parcel.trackingNumber,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Container(
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
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Order Info
                  Container(
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
                      children: [
                        Row(
                          children: [
                            Icon(Icons.shopping_bag, size: 20, color: Colors.blue[800]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                parcel.orderName.isNotEmpty
                                    ? parcel.orderName
                                    : 'طرد ${parcel.trackingNumber}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Sender & Receiver
                        Row(
                          children: [
                            Expanded(
                              child: _buildPersonInfo(
                                icon: Icons.person_outline,
                                title: 'المرسل',
                                name: parcel.senderName,
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
                                name: parcel.receiverName,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Shipping Details
                  Row(
                    children: [
                      _buildDetailChip(
                        icon: Icons.calendar_today,
                        value: parcel.shippingDate != null
                            ? intl.DateFormat('yyyy/MM/dd').format(parcel.shippingDate!)
                            : 'غير محدد',
                        label: 'تاريخ الشحن',
                      ),

                      const Spacer(),

                      if (parcel.latitude != 0.0 && parcel.longitude != 0.0)
                        _buildDetailChip(
                          icon: Icons.location_on,
                          value: 'عرض الموقع',
                          label: 'التتبع',
                          onTap: () => _showLocationMap(parcel),
                        ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Progress Timeline
                  _buildParcelProgress(parcel.status),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
// ويدجت مساعدة لعرض تفاصيل الطرد
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

// ويدجت مساعدة لعرض خط التقدم
  Widget _buildParcelProgress(String status) {
    // تعريف مراحل التتبع مع تحديد الحالة الحالية
    final steps = [
      {
        'title': 'تم الطلب',
        'icon': Icons.shopping_cart,
        'completed': true,
        'active': status == 'تم الطلب'
      },
      {
        'title': 'في المستودع',
        'icon': Icons.warehouse,
        'completed': status != 'تم الطلب',
        'active': status == 'في المستودع'
      },
      {
        'title': 'قيد الشحن',
        'icon': Icons.local_shipping,
        'completed': status == 'في طريق التسليم' ||
            status == 'تم التسليم' ||
            status == 'تم الطرد',
        'active': status == 'في طريق التسليم'
      },
      {
        'title': status == 'تم الطرد' ? 'تم الطرد' : 'تم التسليم',
        'icon': status == 'تم الطرد' ? Icons.block : Icons.check_circle,
        'completed': status == 'تم التسليم' || status == 'تم الطرد',
        'active': status == 'تم التسليم' || status == 'تم الطرد',
        'isRejected': status == 'تم الطرد'
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'حالة التوصيل',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (int i = 0; i < steps.length; i++) ...[
                Expanded(
                  child: Column(
                    children: [
                      // دائرة المرحلة
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: steps[i]['active'] as bool
                              ? Colors.blue[50]
                              : (steps[i]['completed'] as bool
                              ? (steps[i]['isRejected'] as bool? ?? false
                              ? Colors.red[50]
                              : Colors.green[50])
                              : Colors.grey[100]),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: steps[i]['active'] as bool
                                ? Colors.blue
                                : (steps[i]['completed'] as bool
                                ? (steps[i]['isRejected'] as bool? ?? false
                                ? Colors.red
                                : Colors.green)
                                : Colors.grey),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            steps[i]['icon'] as IconData,
                            size: 18,
                            color: steps[i]['active'] as bool
                                ? Colors.blue[800]
                                : (steps[i]['completed'] as bool
                                ? (steps[i]['isRejected'] as bool? ?? false
                                ? Colors.red[800]
                                : Colors.green[800])
                                : Colors.grey[600]),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // نص المرحلة
                      Text(
                        steps[i]['title'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: steps[i]['active'] as bool
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: steps[i]['active'] as bool
                              ? Colors.blue[800]
                              : (steps[i]['completed'] as bool
                              ? (steps[i]['isRejected'] as bool? ?? false
                              ? Colors.red[800]
                              : Colors.green[800])
                              : Colors.grey[600]),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                      // مؤشر المرحلة الحالية
                      if (steps[i]['active'] as bool)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          height: 3,
                          width: 24,
                          decoration: BoxDecoration(
                            color: steps[i]['isRejected'] as bool? ?? false
                                ? Colors.red
                                : Colors.blue,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                    ],
                  ),
                ),
                // الخط الفاصل بين المراحل
                if (i < steps.length - 1)
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 18),
                      child: Divider(
                        thickness: 2,
                        color: steps[i]['completed'] as bool
                            ? (steps[i]['isRejected'] as bool? ?? false
                            ? Colors.red[300]
                            : Colors.green[300])
                            : Colors.grey[200],
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
// ويدجت مساعدة لعرض معلومات الشخص
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


  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () => _addNewparcel(),
      child: const Icon(Icons.add, size: 28),
      backgroundColor: Colors.blue[800],
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      tooltip: 'إضافة طرد جديدة',
    );
  }
  Widget _buildLoadingShimmer() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    );
  }
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_shipping, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'لا توجد شحنات مسجلة',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _addNewparcel,
            child: const Text('إضافة طرد جديدة'),
            style: ElevatedButton.styleFrom(
              primary: Colors.blue[800],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'حدث خطأ في تحميل البيانات',
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _refreshData,
            child: const Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(
              primary: Colors.blue[800],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================ Helper Methods ================

  List<Parcel> _parseparcels(List<DocumentSnapshot> docs) {
    return docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Parcel(
        id: doc.id ?? '',
        trackingNumber: data['trackingNumber'] ?? '',
        status: data['status'] ?? '',
        senderName: data['senderName'] ?? '',
        receiverName: data['receiverName'] ?? '',
        orderName: data['orderName'] ?? '',
        shippingDate: data['shippingDate'] != null
            ? DateTime.tryParse(data['shippingDate'])
            : null,
        longitude: (data['longitude'] as num?)?.toDouble(),
        latitude: (data['latitude'] as num?)?.toDouble(),
        receiverPhone: data['receiverPhone'],
        destination: data['destination'] ?? '',
        parceID: data['parceID'] ?? 0,
        receverName: data['receverName'] ?? '',
        prWight: (data['prWight'] as num?)?.toDouble() ?? 0.0,
        noted: data['noted'],
        preType: data['preType'] ?? '',
        shipmentID:  data['shipmentID'],
      );
    }).toList();
  }

  List<Parcel> _filterRecords(List<Parcel> records) {
    return records.where((parcel) {
      // إذا كان هناك بحث، نتحقق من تطابق كامل لرقم التتبع
      if (_searchQuery.isNotEmpty) {
        return parcel.trackingNumber == _searchQuery;
      }
      final matchesSearch = parcel.trackingNumber.contains(_searchQuery) ||
          parcel.orderName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          parcel.senderName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          parcel.receiverName.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesFilter = _selectedFilter == 'all' ||
          parcel.status == _selectedFilter;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  // ================ Action Methods ================

  void _showparcelDetails(Parcel parcel) {
    final statusInfo = ParcelStatusFormatter.getStatusInfo(parcel.status);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Directionality(
         textDirection: TextDirection.rtl, child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle for dragging
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Container(
                      width: 60,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  // Header with close button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'تفاصيل الطرد',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.grey[600]),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),

                  // Status Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: statusInfo.backgroundColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: statusInfo.color.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(statusInfo.icon, size: 28, color: statusInfo.color),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'حالة الطرد',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  statusInfo.text,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: statusInfo.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Details List
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Column(
                        children: [
                          _buildDetailCard(
                            icon: Icons.confirmation_number,
                            title: 'رقم التتبع',
                            value: parcel.trackingNumber,
                            isImportant: true,
                          ),

                          _buildDetailCard(
                            icon: Icons.shopping_bag,
                            title: 'اسم الطلب',
                            value: parcel.orderName,
                          ),

                          _buildDetailCard(
                            icon: Icons.calendar_today,
                            title: 'تاريخ الشحن',
                            value: parcel.shippingDate != null
                                ? _dateFormatter.format(parcel.shippingDate!)
                                : 'غير محدد',
                          ),

                          _buildDetailCard(
                            icon: Icons.person_outline,
                            title: 'المرسل',
                            value: parcel.senderName,
                          ),

                          _buildDetailCard(
                            icon: Icons.person,
                            title: 'المستلم',
                            value: parcel.receiverName,
                          ),

                          if (parcel.latitude != null && parcel.longitude != null) ...[
                            const SizedBox(height: 16),
                            _buildMapCard(parcel),
                          ],

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),

                  // Action Buttons
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(
                          color: Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton.icon(
                            icon: Icon(Icons.share, color: Colors.blue[800]),
                            label: Text(
                              'مشاركة',
                              style: TextStyle(color: Colors.blue[800]),
                            ),
                            onPressed: () => _shareparcelDetails(parcel),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.support_agent, color: Colors.white),
                            label: const Text('الدعم الفني'),
                            onPressed: () => _contactSupport(parcel),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[800],
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String value,
    bool isImportant = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 24,
            color: isImportant ? Colors.blue[800] : Colors.grey[600],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isImportant ? FontWeight.bold : FontWeight.normal,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          if (isImportant)
            IconButton(
              icon: Icon(Icons.copy, size: 20, color: Colors.blue[800]),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم نسخ النص')),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMapCard(Parcel parcel) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(Icons.map, color: Colors.blue[800]),
                const SizedBox(width: 8),
                Text(
                  'الموقع الجغرافي',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ],
            ),
          ),
          Container(
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
                  center: LatLng(parcel.latitude!, parcel.longitude!),
                  zoom: 14.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(parcel.latitude!, parcel.longitude!),
                        child:  const Icon(
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${parcel.latitude!.toStringAsFixed(4)}, ${parcel.longitude!.toStringAsFixed(4)}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                TextButton(
                  onPressed: () => _openInMaps(parcel.latitude!, parcel.longitude!),
                  child: Text(
                    'فتح في الخرائط',
                    style: TextStyle(color: Colors.blue[800]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _shareparcelDetails(Parcel parcel) {
    // TODO: Implement share functionality
    final text = '''
تفاصيل الطرد:
رقم التتبع: ${parcel.trackingNumber}
المرسل: ${parcel.senderName}
المستلم: ${parcel.receiverName}
الحالة: ${ParcelStatusFormatter.getStatusInfo(parcel.status).text}
''';

    Share.share(text);
  }

  void _contactSupport(Parcel parcel) {
    // TODO: Implement contact support
    launchUrl(Uri.parse('tel:+967775479401'));
  }

  void _openInMaps(double lat, double lng) async {
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (!await launchUrl(uri)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر فتح الخرائط')),
      );
    }
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }



  void _showLocationMap(Parcel parcel) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'موقع الطرد',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              height: 300,
              width: double.maxFinite,
              child: FlutterMap(
                options: MapOptions(
                  center: LatLng(parcel.latitude!, parcel.longitude!),
                  zoom: 14.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                    tileProvider: CancellableNetworkTileProvider(), // أهم تحسين للأداء
                    maxZoom: 18,
                    minZoom: 1,
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(parcel.latitude!, parcel.longitude!),
                        child:  const Icon(
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
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق'),
            ),
          ],
        ),
      ),
    );
  }

  void _addNewparcel() {
    // TODO: Implement navigation to add new parcel screen
    print('Navigate to add new parcel screen');
  }
}

