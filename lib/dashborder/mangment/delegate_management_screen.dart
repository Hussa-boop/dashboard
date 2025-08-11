import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard/dashborder/mangment/employee/screen.dart';
import 'package:dashboard/dashborder/screen/delegates_screen/delegates_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dashboard/dashborder/controller/delegate_controller/delegate_controller.dart';
import 'package:dashboard/data/models/delegate_model/hive_delegate.dart';
import 'package:dashboard/data/models/shipment_model/hive_shipment.dart';
import 'package:intl/intl.dart'as intl;

import '../screen/delegates_screen/delegate_details_screen.dart';

class DelegateManagementScreen extends StatefulWidget {
  final Widget? child;
  const DelegateManagementScreen({Key? key, this.child}) : super(key: key);

  @override
  State<DelegateManagementScreen> createState() =>
      _DelegateManagementScreenState(child);
}

class _DelegateManagementScreenState extends State<DelegateManagementScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final intl.DateFormat _dateFormat = intl.DateFormat('yyyy-MM-dd');
  bool _isLoadingMore = false;
  final Widget? child;
  _DelegateManagementScreenState(this.child);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    final controller = context.read<DelegateController>();
    if (controller.delegates.isEmpty) {
      await controller.fetchDelegatesFromFirestore();
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreDelegates();
    }
  }

  Future<void> _loadMoreDelegates() async {
    if (_isLoadingMore) return;

    setState(() => _isLoadingMore = true);
    try {
      await context.read<DelegateController>().loadMoreDelegates();
    } finally {
      setState(() => _isLoadingMore = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: buildAppBar(context),
        floatingActionButton: buildFloatingActionButton(context),
        body: buildBody(context),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('إدارة المندوبين'),
      centerTitle: true,
      leading: IconButton(onPressed: () =>  Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EmployeesListScreen(),
          )), icon: Icon(Icons.person)),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => refreshData(context),
          tooltip: 'تحديث البيانات',
        ),
        IconButton(
          icon: const Icon(Icons.person),
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DelegatesScreen(),
              )),
          tooltip: 'تحديث البيانات',
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: buildSearchBar(context),
      ),
    );
  }

  Widget buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(12),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'ابحث باسم المندوب أو العنوان...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              icon: const Icon(Icons.filter_alt),
              onPressed: () => showFilterDialog(context),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          onChanged: (value) =>
              context.read<DelegateController>().filterDelegates(query: value),
        ),
      ),
    );
  }

  void showFilterDialog(BuildContext context) {
    final controller = context.read<DelegateController>();
    String? selectedStatus;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('تصفية المندوبين'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: const InputDecoration(labelText: 'حالة المندوب'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('الكل')),
                    const DropdownMenuItem(value: 'active', child: Text('نشط')),
                    const DropdownMenuItem(
                        value: 'inactive', child: Text('غير نشط')),
                  ],
                  onChanged: (value) {
                    setState(() => selectedStatus = value);
                  },
                ),
                FilterChip(
                  label: const Text('تحتوي على طرود'),
                  selected: controller.currentFilter == 'with_parcels',
                  onSelected: (_) =>
                      controller.filterDelegates(status: 'with_parcels'),
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
                  controller.filterDelegates(status: selectedStatus);
                  Navigator.pop(context);
                },
                child: const Text('تطبيق'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: 'addDelegate',
      icon: const Icon(Icons.add),
      label: const Text('إضافة مندوب'),
      onPressed: () => showAddDelegateDialog(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    return Consumer<DelegateController>(
      builder: (context, controller, child) {
        if (controller.isLoading && controller.delegates.isEmpty) {
          return buildLoadingSkeleton();
        }

        if (controller.error != null) {
          return buildErrorWidget(controller);
        }

        return buildDelegatesList(context, controller);
      },
    );
  }

  Widget buildLoadingSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10,
      itemBuilder: (context, index) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey[300],
                child: const Icon(Icons.person, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      width: 120,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 14,
                      width: 200,
                      color: Colors.grey[300],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildErrorWidget(DelegateController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              controller.error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.red,
                  ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
            onPressed: controller.fetchDelegatesFromFirestore,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDelegatesList(
      BuildContext context, DelegateController controller) {
    final delegates = controller.filteredDelegates;

    if (delegates.isEmpty) {
      return buildEmptyState(context, controller);
    }

    return RefreshIndicator(
      onRefresh: () => controller.fetchDelegatesFromFirestore(),
      child: Column(
        children: [
          buildStatsHeader(context, controller),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: delegates.length + (_isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= delegates.length) {
                  return const Center(child: CircularProgressIndicator());
                }
                return buildDelegateCard(
                    context, delegates[index], controller);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStatsHeader(
      BuildContext context, DelegateController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          buildStatItem(
            context,
            'المجموع',
            controller.totalDelegates.toString(),
            Icons.people,
            Colors.blue,
          ),
          const SizedBox(width: 8),
          buildStatItem(
            context,
            'نشط',
            controller.getActiveDelegatesCount().toString(),
            Icons.check_circle,
            Colors.green,
          ),
          const SizedBox(width: 8),
          buildStatItem(
            context,
            'غير نشط',
            controller.getInactiveDelegatesCount().toString(),
            Icons.remove_circle,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget buildStatItem(BuildContext context, String title, String value,
      IconData icon, Color color) {
    return Expanded(
      child: Material(
        borderRadius: BorderRadius.circular(12),
        color: color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.bodySmall),
                  Text(value,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEmptyState(BuildContext context, DelegateController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/empty_delegates.png', width: 200),
          const SizedBox(height: 24),
          Text(
            'لا توجد مندوبين متاحين',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'انقر على زر "إضافة مندوب" لبدء الإضافة',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (controller.currentFilter != null) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: controller.resetFilters,
              child: const Text('إعادة تعيين الفلتر'),
            ),
          ],
        ],
      ),
    );
  }

  Widget buildDelegateCard(
      BuildContext context, Delegate delegate, DelegateController controller) {
    final shipments = controller.getShipmentsByDelegateId(delegate.delevID);
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DelegateDetailsScreen(delegate: delegate),)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    child: Icon(Icons.person, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          delegate.deveName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          delegate.deveAddress,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Badge(
                    label: Text(shipments.length.toString()),
                    backgroundColor: theme.colorScheme.secondary,
                    textColor: Colors.white,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildActionButton(
                    context,
                    icon: Icons.edit,
                    label: 'تعديل',
                    color: Colors.blue,
                    onPressed: () =>
                        showEditDelegateDialog(context, delegate, controller),
                  ),
                  buildActionButton(
                    context,
                    icon: Icons.assignment,
                    label: 'تعيين',
                    color: Colors.green,
                    onPressed: () => showAssignShipmentDialog(
                        context, delegate, controller),
                  ),
                  buildActionButton(
                    context,
                    icon: Icons.delete,
                    label: 'حذف',
                    color: Colors.red,
                    onPressed: () =>
                        showDeleteConfirmation(context, delegate, controller),
                  ),
                ],
              ),
            ],
          ),
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
    return SizedBox(
      width: 100,
      child: TextButton.icon(
        icon: Icon(icon, size: 16, color: color),
        label: Text(label, style: TextStyle(color: color)),
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Future<void> refreshData(BuildContext context) async {
    final scaffold = ScaffoldMessenger.of(context);
    final controller = context.read<DelegateController>();

    try {
      await controller.fetchDelegatesFromFirestore();
      scaffold.showSnackBar(
        const SnackBar(content: Text('تم تحديث البيانات بنجاح')),
      );
    } catch (e) {
      scaffold.showSnackBar(
        SnackBar(content: Text('فشل في التحديث: ${e.toString()}')),
      );
    }
  }

  Widget buildSearchFilterRow(
      BuildContext context, DelegateController controller) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'ابحث باسم المندوب أو العنوان...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onChanged: (value) => controller.filterDelegates(query: value),
          ),
        ],
      ),
    );
  }

  void showDelegateDetails(
      BuildContext context, Delegate delegate, List<Shipment> shipments) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text('تفاصيل المندوب: ${delegate.deveName}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                buildDetailRow('العنوان', delegate.deveAddress),
                buildDetailRow('عدد الشحنات', shipments.length.toString()),
                if (shipments.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('الشحنات الموكلة:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...shipments
                      .map((shipment) => ListTile(
                            title: Text('شحنة #${shipment.shippingID}'),
                            subtitle: Text(
                                'التاريخ: ${_dateFormat.format(shipment.shippingDate)}'),
                            dense: true,
                          ))
                      .toList(),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void showAddDelegateDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة مندوب جديد'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'اسم المندوب'),
                validator: (value) => value!.isEmpty ? 'هذا الحقل مطلوب' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'العنوان'),
                validator: (value) => value!.isEmpty ? 'هذا الحقل مطلوب' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final controller = context.read<DelegateController>();
                final delegate = Delegate(
                  delevID: DateTime.now().millisecondsSinceEpoch,
                  deveName: nameController.text,
                  deveAddress: addressController.text,
                  isActive: true,
                );

                try {
                  await controller.addDelegate(delegate);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تمت إضافة المندوب بنجاح')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('فشل في الإضافة: ${e.toString()}')),
                    );
                  }
                }
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void showEditDelegateDialog(
      BuildContext context, Delegate delegate, DelegateController controller) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: delegate.deveName);
    final addressController = TextEditingController(text: delegate.deveAddress);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل بيانات المندوب'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'اسم المندوب'),
                validator: (value) => value!.isEmpty ? 'هذا الحقل مطلوب' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'العنوان'),
                validator: (value) => value!.isEmpty ? 'هذا الحقل مطلوب' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final updatedDelegate = Delegate(
                  delevID: delegate.delevID,
                  deveName: nameController.text,
                  deveAddress: addressController.text,
                  isActive: true,
                );

                try {
                  await controller.updateDelegate(
                      delegate.delevID.toString(), updatedDelegate);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم تحديث بيانات المندوب')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('فشل في التحديث: ${e.toString()}')),
                    );
                  }
                }
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void showAssignShipmentDialog(
      BuildContext context, Delegate delegate, DelegateController controller) {
    String? selectedShipmentId;
    List<Shipment> availableShipments = [];

    Future<void> loadAvailableShipments() async {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('shipments')
            .where('delegateID', isEqualTo: null)
            .get();

        print('Fetched ${snapshot.docs.length} shipments from Firestore');

        availableShipments = snapshot.docs.map((doc) {
          print('Shipment data: ${doc.data()}');
          return Shipment.fromJson(doc.data());
        }).toList();

        if (availableShipments.isEmpty) {
          print('No shipments found with delegateID=null');
        }
      } catch (e) {
        print('Error loading shipments: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('فشل في جلب الشحنات: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    showDialog(
      context: context,
      builder: (context) => FutureBuilder(
        future: loadAvailableShipments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return AlertDialog(
              title: const Text('جاري تحميل الشحنات...'),
              content: const Center(child: CircularProgressIndicator()),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
              ],
            );
          }

          if (snapshot.hasError) {
            return AlertDialog(
              title: const Text('خطأ'),
              content: Text('حدث خطأ: ${snapshot.error}'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('حسناً'),
                ),
              ],
            );
          }

          if (availableShipments.isEmpty) {
            return AlertDialog(
              title: const Text('لا توجد شحنات متاحة'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('لا يوجد شحنات يمكن تعيينها لهذا المندوب'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      showAllShipmentsDialog(context, delegate, controller);
                    },
                    child: const Text('عرض جميع الشحنات'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إغلاق'),
                ),
              ],
            );
          }

          return buildShipmentSelectionDialog(
            context,
            delegate,
            controller,
            availableShipments,
            selectedShipmentId,
          );
        },
      ),
    );
  }

  Widget buildShipmentSelectionDialog(
    BuildContext context,
    Delegate delegate,
    DelegateController controller,
    List<Shipment> shipments,
    String? selectedId,
  ) {
    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: const Text('تعيين شحنة للمندوب'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${shipments.length} شحنة متاحة'),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedId,
                  items: shipments.map((shipment) {
                    return DropdownMenuItem(
                      value: shipment.shippingID.toString(),
                      child: Text(
                        'شحنة #${shipment.shippingID} - ${shipment.shippingAddress}',
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => selectedId = value),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'اختر شحنة',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: selectedId == null
                  ? null
                  : () => showAssignConfirmation(
                      context, delegate, controller, selectedId!),
              child: const Text('تعيين'),
            ),
          ],
        );
      },
    );
  }

  Future<void> showAllShipmentsDialog(
    BuildContext context,
    Delegate delegate,
    DelegateController controller,
  ) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('shipments')
          .limit(100)
          .get();

      final allShipments =
          snapshot.docs.map((doc) => Shipment.fromJson(doc.data())).toList();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('جميع الشحنات'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: allShipments.length,
              itemBuilder: (context, index) {
                final shipment = allShipments[index];
                return ListTile(
                  title: Text('شحنة #${shipment.shippingID}'),
                  subtitle:
                      Text('المندوب: ${shipment.delegateID ?? "غير معين"}'),
                  onTap: () {
                    Navigator.pop(context);
                    showAssignConfirmation(context, delegate, controller,
                        shipment.shippingID.toString());
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في جلب الشحنات: $e')),
      );
    }
  }

  Future<void> showAssignConfirmation(
    BuildContext context,
    Delegate delegate,
    DelegateController controller,
    String shipmentId,
  ) async {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 10),
            Text('تأكيد التعيين'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('هل أنت متأكد من تعيين الشحنة للمندوب:'),
            SizedBox(height: 10),
            Text(
              delegate.deveName,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
            SizedBox(height: 20),
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('shipments')
                  .doc(shipmentId)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                if (snapshot.hasError || !snapshot.hasData) {
                  return Text('تعذر تحميل بيانات الشحنة');
                }

                final shipmentData =
                    snapshot.data!.data() as Map<String, dynamic>;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('تفاصيل الشحنة:'),
                    SizedBox(height: 5),
                    Text(
                        'رقم الشحنة: #${shipmentData['shippingID'] ?? shipmentId}'),
                    if (shipmentData['shippingAddress'] != null)
                      Text('العنوان: ${shipmentData['shippingAddress']}'),
                  ],
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
            ),
            onPressed: () async {
              Navigator.pop(context); // إغلاق dialog التأكيد

              final scaffold = ScaffoldMessenger.of(context);
              try {
                await controller.assignDelegateToShipment(
                  shipmentId,
                  delegate.delevID,
                );

                scaffold.showSnackBar(
                  SnackBar(
                    content: Text('تم تعيين الشحنة بنجاح'),
                    backgroundColor: Colors.green,
                  ),
                );

                // تحديث الواجهة بعد التعيين
                if (mounted) {
                  Navigator.pop(context); // إغلاق dialog التعيين إن كان مفتوحًا
                }
              } catch (e) {
                scaffold.showSnackBar(
                  SnackBar(
                    content: Text('فشل التعيين: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('تأكيد التعيين'),
          ),
        ],
      ),
    );
  }

  void showDeleteConfirmation(
      BuildContext context, Delegate delegate, DelegateController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف المندوب "${delegate.deveName}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await controller.deleteDelegate(delegate.delevID.toString());
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم حذف المندوب بنجاح')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('فشل في الحذف: ${e.toString()}')),
                  );
                }
              }
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
