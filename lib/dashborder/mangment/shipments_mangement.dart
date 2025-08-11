import 'package:dashboard/dashborder/controller/shipment_controller/shipments_controller.dart';
import 'package:dashboard/dashborder/home_screen.dart';
import 'package:dashboard/dashborder/mangment/parcels_management.dart';
import 'package:dashboard/dashborder/screen/shipment/shipment_details_screen.dart';
import 'package:dashboard/dashborder/screen/shipment/shipment_input_screen.dart';
import 'package:dashboard/data/models/shipment_model/hive_shipment.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' as intl;
import 'dart:async';
import 'dart:convert';

class ShipmentsScreen extends StatelessWidget {
  final Widget? child;
  const ShipmentsScreen({Key? key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        endDrawer: (ResponsiveWidget.isSmallScreen(context) || ResponsiveWidget.isMediumScreen(context)) ? child : null,
        appBar: AppBar(
          title: const Text('إدارة الشحنات'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => refreshData(context),
              tooltip: 'تحديث البيانات',
            ),
          ],
        ),
        body: Consumer<ShipmentController>(
          builder: (context, controller, child) {
            if (controller.isLoading && controller.shipments.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.error != null) {
              return buildErrorWidget(context, controller);
            }

            return Column(
              children: [
                buildStatsRow(context),
                buildSearchFilterRow(context),
                Expanded(child: buildShipmentsList(context)),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'addShipment',
          icon: const Icon(Icons.add),
          label: const Text('إضافة شحنة'),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ShipmentInputScreen()),
          ),
          tooltip: 'إضافة شحنة جديدة',
        ),
      ),
    );
  }

  Future<void> refreshData(BuildContext context) async {
    final scaffold = ScaffoldMessenger.of(context);
    final controller = context.read<ShipmentController>();

    try {
      await controller.fetchShipmentsFromFirestore();
      scaffold.showSnackBar(
        const SnackBar(
          content: Text('تم تحديث البيانات بنجاح', textDirection: TextDirection.rtl),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      scaffold.showSnackBar(
        SnackBar(
          content: Text('فشل في التحديث: ${e.toString()}', textDirection: TextDirection.rtl),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget buildErrorWidget(BuildContext context, ShipmentController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            controller.error!,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: controller.fetchShipmentsFromFirestore,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget buildStatsRow(BuildContext context) {
    final controller = context.watch<ShipmentController>();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.all(8),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildStatItem(
                context,
                'إجمالي الشحنات',
                controller.totalShipments,
                Icons.local_shipping,
                Colors.blue,
              ),
              buildStatItem(
                context,
                'مكتملة',
                controller.completedShipments,
                Icons.check_circle,
                Colors.green,
              ),
              buildStatItem(
                context,
                'قيد التوصيل',
                controller.pendingShipments,
                Icons.timer,
                Colors.orange,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildStatItem(
      BuildContext context,
      String title,
      int value,
      IconData icon,
      Color color,
      ) {
    return Tooltip(
      message: title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
           intl. NumberFormat.compact().format(value),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget buildSearchFilterRow(BuildContext context) {
    final controller = context.read<ShipmentController>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          TextField(
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              hintText: 'ابحث بالعنوان أو رقم الشحنة...',
              hintTextDirection: TextDirection.rtl,
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onChanged: (value) => controller.filterBy(searchQuery: value),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('الكل'),
                  selected: controller.currentFilter == null,
                  onSelected: (_) => controller.resetFilters(),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('مكتملة'),
                  selected: controller.currentFilter == 'completed',
                  onSelected: (_) => controller.filterBy(status: 'completed'),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('قيد التوصيل'),
                  selected: controller.currentFilter == 'pending',
                  onSelected: (_) => controller.filterBy(status: 'pending'),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('تحتوي على طرود'),
                  selected: controller.currentFilter == 'with_parcels',
                  onSelected: (_) => controller.filterBy(hasParcels: true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildShipmentsList(BuildContext context) {
    final controller = context.watch<ShipmentController>();
    final shipments = controller.filteredShipments;

    if (controller.isLoading && shipments.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (shipments.isEmpty) {
      return buildEmptyState(context, controller);
    }

    return RefreshIndicator(
      onRefresh: () => controller.fetchShipmentsFromFirestore(),
      child: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: shipments.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final shipment = shipments[index];
          return buildShipmentCard(context, shipment);
        },
      ),
    );
  }

  Widget buildEmptyState(BuildContext context, ShipmentController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_shipping, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'لا توجد شحنات متاحة',
            style: Theme.of(context).textTheme.titleMedium,
            textDirection: TextDirection.rtl,
          ),
          if (controller.currentFilter != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: controller.resetFilters,
              child: const Text('إعادة تعيين الفلتر'),
            ),
          ],
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ShipmentInputScreen(),
              ),
            ),
            child: const Text('إضافة شحنة جديدة'),
          ),
        ],
      ),
    );
  }

  Widget buildShipmentCard(BuildContext context, Shipment shipment) {
    final theme = Theme.of(context);
    final isCompleted = shipment.deliveryDate != null;
    final parcelsCount = shipment.parcels.length;
    final controller = Provider.of<ShipmentController>(context, listen: false);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => navigateToShipmentDetails(context, shipment),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'الشحنة #${shipment.shippingID}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isCompleted ? 'مكتملة' : 'قيد التوصيل',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: isCompleted ? Colors.green : Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                shipment.shippingAddress,
                style: theme.textTheme.bodyMedium,
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: theme.colorScheme.secondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                   intl. DateFormat('yyyy-MM-dd').format(shipment.shippingDate),
                    style: theme.textTheme.bodySmall,
                  ),
                  if (isCompleted) ...[
                    const SizedBox(width: 16),
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                     intl. DateFormat('yyyy-MM-dd').format(shipment.deliveryDate),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.green,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ActionChip(
                    label: Text('$parcelsCount طرد'),
                    avatar: const Icon(Icons.inventory, size: 16),
                    backgroundColor: theme.colorScheme.secondary.withOpacity(0.1),
                    onPressed: () => navigateToParcelManagement(context, shipment),
                  ),
                  Row(
                    children: [
                      IconButton(

                        icon: const Icon(Icons.delete_forever),
                        onPressed: () => confirmDeleteShipment(context, controller, shipment),
                        iconSize: 16,
                        tooltip: 'حذف الشحنة',
                      ),
                      IconButton(
                        icon: const Icon(Icons.inventory_2),
                        tooltip: 'إدارة الطرود',
                        onPressed: () => navigateToParcelManagement(context, shipment),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios),
                        onPressed: () => navigateToShipmentDetails(context, shipment),
                        iconSize: 16,
                        tooltip: 'تفاصيل الشحنة',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void confirmDeleteShipment(BuildContext context, ShipmentController controller, Shipment shipment) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: const Text('هل أنت متأكد من حذف هذه الشحنة؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                controller.deleteShipment(shipment.shippingID.toString());
                Navigator.pop(context);
              },
              child: const Text('حذف', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  void navigateToShipmentDetails(BuildContext context, Shipment shipment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShipmentDetailsScreen(shipment: shipment),
      ),
    );
  }

  void navigateToParcelManagement(BuildContext context, Shipment shipment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ParcelManagementScreen(shipmentId: shipment.shippingID.toString()),
      ),
    );
  }
}