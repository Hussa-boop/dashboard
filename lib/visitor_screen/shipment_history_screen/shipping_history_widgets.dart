import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../data/models/prcel_model/hive_parcel.dart';
import '../shipment_card_disgin.dart';



// =============== AppBar Widget ===============
AppBar buildShippingHistoryAppBar(BuildContext context, {VoidCallback? onStatisticsPressed}) {
  return AppBar(
    title: const Text('سجل الشحنات',
        style: TextStyle(fontWeight: FontWeight.bold)),
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
        icon: const Icon(Icons.history),
        onPressed: onStatisticsPressed,
        tooltip: 'إحصائيات الشحنات',
      ),
    ],
  );
}

// =============== Search and Filter Bar ===============
Widget buildSearchAndFilterBar({
  required TextEditingController searchController,
  required String selectedFilter,
  required ValueChanged<String> onFilterChanged,
  required ValueChanged<String> onSearchChanged,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        buildSearchField(
          controller: searchController,
          onChanged: onSearchChanged,
        ),
        const SizedBox(height: 12),
        buildFilterChips(
          selectedFilter: selectedFilter,
          onFilterChanged: onFilterChanged,
        ),
      ],
    ),
  );
}

Widget buildSearchField({
  required TextEditingController controller,
  required ValueChanged<String> onChanged,
}) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      hintText: 'ابحث برقم التتبع، اسم المرسل أو المستلم...',
      prefixIcon: Icon(Icons.search, color: Colors.blue[800]),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding:
      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      suffixIcon: controller.text.isNotEmpty
          ? IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          controller.clear();
          onChanged('');
        },
      )
          : null,
    ),
    onChanged: onChanged,
  );
}

Widget buildFilterChips({
  required String selectedFilter,
  required ValueChanged<String> onFilterChanged,
}) {
  final filters = {
    'all': 'الكل',
    'inTransit': 'قيد التوصيل',
    'delivered': 'تم التسليم',
    'cancelled': 'ملغي',
    'partial': 'تسليم جزئي',
  };

  return SizedBox(
    height: 40,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: filters.length,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (context, index) {
        final key = filters.keys.elementAt(index);
        return ChoiceChip(
          label: Text(filters[key]!),
          selected: selectedFilter == key,
          onSelected: (selected) =>
              onFilterChanged(selected ? key : 'all'),
          selectedColor: Colors.blue[800],
          labelStyle: TextStyle(
            color: selectedFilter == key ? Colors.white : Colors.grey[800],
          ),
          backgroundColor: Colors.grey[200],
          shape: const StadiumBorder(),
        );
      },
    ),
  );
}

// =============== Shipments List ===============
Widget buildShipmentsList({
  required List<Parcel> shipments,
  required ValueChanged<Parcel> onShipmentTap,
}) {
  return ListView.separated(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    itemCount: shipments.length,
    separatorBuilder: (_, __) => const SizedBox(height: 12),
    itemBuilder: (context, index) => ShipmentDetailsWidget(
      shipment: shipments[index],
      onTap: () => onShipmentTap(shipments[index]),
      showFullDetails: false,
    ),
  );
}

// =============== Loading Shimmer ===============
Widget buildLoadingShimmer() {
  return ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: 6,
    itemBuilder: (context, index) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 160,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    },
  );
}

// =============== Empty State ===============
Widget buildEmptyState({
  required String searchQuery,
  required VoidCallback onClearSearch,
}) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.local_shipping, size: 64, color: Colors.grey[400]),
        const SizedBox(height: 16),
        Text(
          'لا توجد شحنات متاحة',
          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        if (searchQuery.isNotEmpty)
          ElevatedButton(
            onPressed: onClearSearch,
            child: const Text('مسح البحث'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[800],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          )
      ],
    ),
  );
}

// =============== Error Widget ===============
Widget buildErrorWidget({
  required VoidCallback onRetry,
  required VoidCallback onLoadCachedData,
}) {
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
          onPressed: onRetry,
          child: const Text('إعادة المحاولة'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[800],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: onLoadCachedData,
          child: const Text('عرض البيانات المحفوظة'),
        ),
      ],
    ),
  );
}

// =============== Floating Action Button ===============
Widget buildFloatingActionButton({required VoidCallback onPressed}) {
  return FloatingActionButton(
    onPressed: onPressed,
    child: const Icon(Icons.add, size: 28),
    backgroundColor: Colors.blue[800],
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    tooltip: 'إضافة شحنة جديدة',
  );
}

// =============== Statistics Widgets ===============
Widget buildStatisticsBottomSheet({
  required BuildContext context,
  required VoidCallback onShare,
  required VoidCallback onExport,
}) {
  final Color primaryColor = Theme.of(context).primaryColor;
  final Color secondaryColor = Colors.blueGrey[200]!;

  return DefaultTabController(
    length: 3,
    child: Container(
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
      padding: const EdgeInsets.only(top: 16),
      height: MediaQuery.of(context).size.height * 0.85,
      child: Column(
        children: [
          // Handle for dragging
          Container(
            width: 60,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Header with title and close button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'إحصائيات الشحنات',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Statistics Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  TabBar(
                    indicatorColor: primaryColor,
                    labelColor: primaryColor,
                    unselectedLabelColor: Colors.grey,
                    tabs: const [
                      Tab(text: 'اليوم'),
                      Tab(text: 'الأسبوع'),
                      Tab(text: 'الشهر'),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Statistics Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TabBarView(
                children: [
                  buildDailyStats(primaryColor, secondaryColor),
                  buildWeeklyStats(primaryColor, secondaryColor),
                  buildMonthlyStats(primaryColor, secondaryColor),
                ],
              ),
            ),
          ),

          // Footer with action buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.share),
                    label: const Text('مشاركة'),
                    onPressed: onShare,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor,
                      side: BorderSide(color: primaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.download),
                    label: const Text('تصدير'),
                    onPressed: onExport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildStatCard({
  required String title,
  required String value,
  required IconData icon,
  required Color color,
}) {
  return Container(
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
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 28, color: color),
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
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget buildBarChart(Color primaryColor, Color secondaryColor) {
  return Container(
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
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'توزيع الشحنات خلال اليوم',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[200]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              'رسم بياني بالأعمدة سيظهر هنا',
              style: TextStyle(color: Colors.grey[400]),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget buildPieChart(Color primaryColor) {
  return Container(
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
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'نسبة حالات الشحن',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[200]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              'رسم بياني دائري سيظهر هنا',
              style: TextStyle(color: Colors.grey[400]),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget buildStatsTable() {
  return Container(
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
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تفصيل الشحنات',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('التاريخ')),
              DataColumn(label: Text('المسلمة')),
              DataColumn(label: Text('قيد التوصيل')),
              DataColumn(label: Text('الملغاة')),
            ],
            rows: List.generate(7, (index) {
              return DataRow(cells: [
                DataCell(Text('${index + 1}/7')),
                DataCell(Text('${Random().nextInt(20) + 10}')),
                DataCell(Text('${Random().nextInt(5) + 1}')),
                DataCell(Text('${Random().nextInt(3)}')),
              ]);
            }),
          ),
        ),
      ],
    ),
  );
}

Widget buildDailyStats(Color primaryColor, Color secondaryColor) {
  return SingleChildScrollView(
    child: Column(
      children: [
        _buildStatCard(
          title: 'إجمالي الشحنات',
          value: '24',
          icon: Icons.local_shipping,
          color: primaryColor,
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          title: 'تم التسليم',
          value: '18',
          icon: Icons.check_circle,
          color: Colors.green,
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          title: 'قيد التوصيل',
          value: '5',
          icon: Icons.timer,
          color: Colors.orange,
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          title: 'ملغاة',
          value: '1',
          icon: Icons.cancel,
          color: Colors.red,
        ),
        const SizedBox(height: 20),
        buildBarChart(primaryColor, secondaryColor),
      ],
    ),
  );
}

Widget buildWeeklyStats(Color primaryColor, Color secondaryColor) {
  return SingleChildScrollView(
    child: Column(
      children: [
        _buildStatCard(
          title: 'إجمالي الشحنات',
          value: '156',
          icon: Icons.local_shipping,
          color: primaryColor,
        ),
        const SizedBox(height: 12),
        buildPieChart(primaryColor),
      ],
    ),
  );
}

Widget buildMonthlyStats(Color primaryColor, Color secondaryColor) {
  return SingleChildScrollView(
    child: Column(
      children: [
        _buildStatCard(
          title: 'إجمالي الشحنات',
          value: '642',
          icon: Icons.local_shipping,
          color: primaryColor,
        ),
        const SizedBox(height: 12),
        buildStatsTable(),
      ],
    ),
  );
}