import 'package:dashboard/dashborder/controller/delegate_controller/delegate_controller.dart';
import 'package:dashboard/dashborder/controller/shipment_controller/shipments_controller.dart';
import 'package:dashboard/dashborder/screen/delegates_screen/delegate_details_screen.dart';
import 'package:dashboard/data/models/delegate_model/hive_delegate.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DelegatesScreen extends StatefulWidget {
  const DelegatesScreen({Key? key}) : super(key: key);

  @override
  State<DelegatesScreen> createState() => _DelegatesScreenState();
}

class _DelegatesScreenState extends State<DelegatesScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      loadMoreDelegates();
    }
  }

  Future<void> loadMoreDelegates() async {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);
    await context.read<DelegateController>().loadMoreDelegates();
    setState(() => _isLoadingMore = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المندوبين'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => refreshData(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('إضافة مندوب'),
        onPressed: () => showAddDelegateDialog(context),
      ),
      body: Directionality(
textDirection:TextDirection.rtl ,        child: Consumer<DelegateController>(
          builder: (context, controller, _) {
            if (controller.isLoading) return buildLoadingView();
            if (controller.error != null) return buildErrorView(controller);
            return buildDelegatesList(controller);
          },
        ),
      ),
    );
  }

  Widget buildLoadingView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (_, index) => buildDelegateSkeleton(),
    );
  }

  Widget buildErrorView(DelegateController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(controller.error!),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: controller.fetchDelegatesFromFirestore,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget buildDelegatesList(DelegateController controller) {
    return RefreshIndicator(
      onRefresh: () => controller.fetchDelegatesFromFirestore(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount:
            controller.filteredDelegates.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= controller.filteredDelegates.length) {
            return const Center(child: CircularProgressIndicator());
          }
          return buildDelegateCard(
              context, controller.filteredDelegates[index]);
        },
      ),
    );
  }

  Future<void> refreshData(BuildContext context) async {
    final controller = context.read<DelegateController>();
    await controller.fetchDelegatesFromFirestore();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تحديث البيانات بنجاح')),
    );
  }

  Future<void> showAddDelegateDialog(BuildContext context) async {
    final controller = context.read<DelegateController>();
    final nameController = TextEditingController();
    final addressController = TextEditingController();

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة مندوب جديد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'اسم المندوب'),
            ),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'عنوان المندوب'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  addressController.text.isNotEmpty) {
                Navigator.pop(context, {
                  'name': nameController.text,
                  'address': addressController.text,
                });
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );

    if (result != null) {
      final newDelegate = Delegate(
        delevID: DateTime.now().millisecondsSinceEpoch,
        deveName: result['name']!,
        deveAddress: result['address']!,
      );
      await controller.addDelegate(newDelegate);
    }
  }

  Widget buildDelegateSkeleton() {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 16,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 200,
                        height: 14,
                        color: Colors.grey[300],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                3,
                (index) => Container(
                  width: 80,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> showEditDelegateDialog(
      BuildContext context, Delegate delegate) async {
    final controller = context.read<DelegateController>();
    final nameController = TextEditingController(text: delegate.deveName);
    final addressController = TextEditingController(text: delegate.deveAddress);

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل بيانات المندوب'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'اسم المندوب'),
            ),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'عنوان المندوب'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  addressController.text.isNotEmpty) {
                Navigator.pop(context, {
                  'name': nameController.text,
                  'address': addressController.text,
                });
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );

    if (result != null) {
      final updatedDelegate = Delegate(
        delevID: delegate.delevID,
        deveName: result['name']!,
        deveAddress: result['address']!,
      );
      await controller.updateDelegate(
          delegate.delevID.toString(), updatedDelegate);
    }
  }

  Future<void> showAssignShipmentDialog(
      BuildContext context, Delegate delegate) async {
    final controller = context.read<DelegateController>();
    final shipmentController = context.read<ShipmentController>();

    // Get available shipments
    final availableShipments = shipmentController.shipments
        .where((shipment) => shipment.delegateID == null)
        .toList();

    if (availableShipments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد شحنات متاحة للتعيين')),
      );
      return;
    }

    String? selectedShipmentId;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعيين شحنة للمندوب'),
        content: SizedBox(
          width: double.maxFinite,
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'اختر الشحنة'),
            items: availableShipments.map((shipment) {
              return DropdownMenuItem<String>(
                value: shipment.shippingID.toString(),
                child: Text('شحنة #${shipment.shippingID}'),
              );
            }).toList(),
            onChanged: (value) {
              selectedShipmentId = value;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              if (selectedShipmentId != null) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('تعيين'),
          ),
        ],
      ),
    );

    if (result == true && selectedShipmentId != null) {
      await controller.assignDelegateToShipment(
          selectedShipmentId!, delegate.delevID);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تعيين الشحنة بنجاح')),
      );
    }
  }

  Future<void> showDeleteConfirmation(
      BuildContext context, Delegate delegate) async {
    final controller = context.read<DelegateController>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف المندوب ${delegate.deveName}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (result == true) {
      // Show SnackBar before deleting the delegate
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('جاري حذف المندوب...')),
      );

      // Delete the delegate
      await controller.deleteDelegate(delegate.delevID.toString());

      // Show success message after deletion
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حذف المندوب بنجاح')),
        );
      }
    }
  }

  Widget buildDelegateCard(BuildContext context, Delegate delegate) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DelegateDetailsScreen(delegate: delegate),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor:
                        Theme.of(context).primaryColor.withOpacity(0.1),
                    child: Text(delegate.deveName.isNotEmpty
                        ? delegate.deveName.substring(0, 1)
                        : '?'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          delegate.deveName.isNotEmpty
                              ? delegate.deveName
                              : 'مندوب بدون اسم',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(delegate.deveAddress),
                      ],
                    ),
                  ),
                  Badge(
                    label: Text(
                        '${context.read<DelegateController>().getShipmentsByDelegateId(delegate.delevID).length}'),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  buildActionButton(
                    context,
                    icon: Icons.edit,
                    label: 'تعديل',
                    color: Colors.blue,
                    onPressed: () => showEditDelegateDialog(context, delegate),
                  ),
                  buildActionButton(
                    context,
                    icon: Icons.assignment,
                    label: 'تعيين',
                    color: Colors.green,
                    onPressed: () =>
                        showAssignShipmentDialog(context, delegate),
                  ),
                  buildActionButton(
                    context,
                    icon: Icons.delete,
                    label: 'حذف',
                    color: Colors.red,
                    onPressed: () => showDeleteConfirmation(context, delegate),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

// ... باقي الدوال المساعدة ...
}
