import 'package:dashboard/dashborder/controller/parcel_controller/parcel_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/prcel_model/hive_parcel.dart';
import '../shipment_card_disgin.dart';
import 'shipping_history_helpers.dart';
import 'shipping_history_widgets.dart';

class ShippingHistoryScreen extends StatefulWidget {
  const ShippingHistoryScreen({super.key});

  @override
  State<ShippingHistoryScreen> createState() => _ShippingHistoryScreenState();
}

class _ShippingHistoryScreenState extends State<ShippingHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'all';
  bool _isRefreshing = false;


  @override
  void initState()  {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isRefreshing = false);
  }

  void _loadCachedData() {
    final cachedShipments =     Provider.of<ParcelController>(context,listen: false).parcel;


    if (cachedShipments.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يتم عرض البيانات المحفوظة')),
      );
    }
  }

  void _showShipmentDetails(Parcel shipment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('تفاصيل الشحنة'),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: ShipmentDetailsWidget(
              shipment: shipment,
              showFullDetails: true,
            ),
          ),
        ),
      ),
    );
  }

  void _showStatistics() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return buildStatisticsBottomSheet(
          context: context,
          onShare: _shareStatistics,
          onExport: _exportStatistics,
        );
      },
    );
  }

  void _shareStatistics() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم نسخ الإحصائيات للمشاركة')),
    );
  }

  void _exportStatistics() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('جاري تصدير الإحصائيات...')),
    );
  }

  void _addNewShipment() {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => const NewShipmentScreen(),
    //     fullscreenDialog: true,
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: buildShippingHistoryAppBar(context, onStatisticsPressed: _showStatistics),
      body: Column(
        children: [
          buildSearchAndFilterBar(
            searchController: _searchController,
            selectedFilter: _selectedFilter,
            onFilterChanged: (filter) => setState(() => _selectedFilter = filter),
            onSearchChanged: (query) => setState(() => _searchQuery = query),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshData,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('parcel')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return buildErrorWidget(
                      onRetry: _refreshData,
                      onLoadCachedData: _loadCachedData,
                    );
                  }

                  if (!snapshot.hasData || _isRefreshing) {
                    return buildLoadingShimmer();
                  }

                  final shipments = parseShipments(snapshot.data!.docs);

                  final filteredShipments = filterShipments(
                    shipments: shipments,
                    searchQuery: _searchQuery,
                    selectedFilter: _selectedFilter,
                  );

                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: filteredShipments.isEmpty
                        ? buildEmptyState(
                      searchQuery: _searchQuery,
                      onClearSearch: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                        : buildShipmentsList(
                      shipments: filteredShipments,
                      onShipmentTap: _showShipmentDetails,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: buildFloatingActionButton(onPressed: _addNewShipment),
    );
  }
}