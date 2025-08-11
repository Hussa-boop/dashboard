import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard/dashborder/controller/parcel_controller/parcel_controller.dart';
import 'package:dashboard/dashborder/home_screen.dart';
import 'package:dashboard/data/models/prcel_model/hive_parcel.dart';
import 'package:dashboard/dashborder/modules/add_edit_shipment.dart';
import 'package:dashboard/dashborder/screen/shipment_map_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart'as intl;
import 'package:provider/provider.dart';

class ParcelManagementScreen extends StatelessWidget {
  final String? shipmentId;
  final Widget? child;

  const ParcelManagementScreen({
    Key? key,
    this.shipmentId,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Directionality(
     textDirection: TextDirection.rtl, child: Scaffold(
        endDrawer: (ResponsiveWidget.isSmallScreen(context)) ||
                ResponsiveWidget.isMediumScreen(context)
            ? child
            : null,
        appBar: AppBar(
          title: Text(
            shipmentId != null ? 'طرود الشحنة #$shipmentId' : 'إدارة الطرود',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onPrimary,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.refresh, color: theme.colorScheme.onPrimary),
              onPressed: () => refreshData(context),
            ),
          ],
        ),
        floatingActionButton: buildFloatingActionButton(context),
        body: Consumer<ParcelController>(
          builder: (context, controller, child) {
            if (controller.isLoading && controller.filteredParcels.isEmpty) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              );
            }

            if (controller.error != null) {
              return buildErrorWidget(context, controller);
            }

            return Column(
              children: [
                buildSearchFilterRow(context, controller),
                Expanded(child: buildParcelsList(context, controller)),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> refreshData(BuildContext context) async {
    final scaffold = ScaffoldMessenger.of(context);
    final controller = context.read<ParcelController>();

    try {
      await controller.fetchParcelsFromFirestore();
      scaffold.showSnackBar(
        SnackBar(

          content: Text('تم تحديث البيانات بنجاح'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      scaffold.showSnackBar(
        SnackBar(
          content: Text('فشل في التحديث: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Widget buildErrorWidget(BuildContext context, ParcelController controller) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: theme.colorScheme.error,
          ),
          SizedBox(height: 16),
          Text(
            controller.error!,
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: controller.fetchParcelsFromFirestore,
            child: Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget buildFloatingActionButton(BuildContext context) {
    final theme = Theme.of(context);

    return FloatingActionButton.extended(
      heroTag: 'addParcel',
      icon: Icon(Icons.add, color: theme.colorScheme.onPrimary),
      label: Text('إضافة طرد',
          style: TextStyle(color: theme.colorScheme.onPrimary)),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ParcelInputScreen(shipmentId: shipmentId),
        ),
      ),
    );
  }

  Widget buildSearchFilterRow(
      BuildContext context, ParcelController controller) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'ابحث برقم التتبع أو اسم المستلم...',
              prefixIcon: Icon(Icons.search, color: theme.hintColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: theme.cardColor,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onChanged: (value) => controller.applyFilters(searchQuery: value),
          ),
          SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                buildFilterChip(
                  context: context,
                  label: 'الكل',
                  selected: controller.currentFilter == null,
                  onSelected: (_) => controller.resetFilters(),
                ),
                SizedBox(width: 8),
                buildFilterChip(
                  context: context,
                  label: 'في المستودع',
                  selected: controller.currentFilter == 'in_stock',
                  onSelected: (_) => controller.filterBy(status: 'في المستودع'),
                ),
                SizedBox(width: 8),
                buildFilterChip(
                  context: context,
                  label: 'في الطريق',
                  selected: controller.currentFilter == 'in_transit',
                  onSelected: (_) => controller.filterBy(status: 'في الطريق'),
                ),
                SizedBox(width: 8),
                buildFilterChip(
                  context: context,
                  label: 'تم التسليم',
                  selected: controller.currentFilter == 'delivered',
                  onSelected: (_) => controller.filterBy(status: 'تم التسليم'),
                ),
                if (shipmentId == null) ...[
                  SizedBox(width: 8),
                  buildFilterChip(
                    context: context,
                    label: 'غير مرتبطة',
                    selected: controller.currentFilter == 'unlinked',
                    onSelected: (_) => controller.filterBy(unlinked: true),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFilterChip({
    required BuildContext context,
    required String label,
    required bool selected,
    required Function(bool) onSelected,
  }) {
    final theme = Theme.of(context);

    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: theme.colorScheme.primary.withOpacity(0.2),
      checkmarkColor: theme.colorScheme.primary,
      labelStyle: TextStyle(
        color: selected
            ? theme.colorScheme.primary
            : theme.textTheme.bodyMedium?.color,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: selected ? theme.colorScheme.primary : theme.dividerColor,
        ),
      ),
    );
  }

  Widget buildParcelsList(BuildContext context, ParcelController controller) {
    final theme = Theme.of(context);
    final parcels = shipmentId != null
        ? controller.getParcelsByShipmentId(shipmentId!)
        : controller.filteredParcels;

    if (parcels.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory,
              size: 64,
              color: theme.disabledColor,
            ),
            SizedBox(height: 16),
            Text(
              shipmentId != null
                  ? 'لا توجد طرود في هذه الشحنة'
                  : 'لا توجد طرود متاحة',
              style: theme.textTheme.titleMedium,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ParcelInputScreen(shipmentId: shipmentId),
                ),
              ),
              child: Text('إضافة طرد جديد'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.fetchParcelsFromFirestore(),
      color: theme.colorScheme.primary,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: parcels.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) =>
            buildParcelCard(context, parcels[index]),
      ),
    );
  }

  Widget buildParcelCard(BuildContext context, Parcel parcel) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('parcel')
          .where('id', isEqualTo: parcel.id)
          .limit(1)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return buildParcelCardContent(parcel, theme, null,context); // عرض البطاقة بدون تقييم أثناء التحميل
        }

        if (snapshot.hasError) {
          return buildParcelCardContent(parcel, theme, null,context); // عرض البطاقة بدون تقييم في حالة الخطأ
        }

        final ratingData = snapshot.data?.docs.isNotEmpty == true
            ? snapshot.data!.docs.first.data() as Map<String, dynamic>
            : null;

        return buildParcelCardContent(parcel, theme, ratingData,context);
      },
    );
  }
// دالة مساعدة لعرض قسم التقييم
  Widget buildRatingSection(Map<String, dynamic> ratingData, ThemeData theme) {
    final rating = ratingData['rating'] as double;
    final comment = ratingData['comment'] as String?;
    final date = ratingData['created_at'] as Timestamp?;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'تقييم العميل:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              RatingBarIndicator(
                rating: rating,
                itemBuilder: (context, index) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                itemCount: 5,
                itemSize: 20.0,
                direction: Axis.horizontal,
              ),
              Spacer(),
              if (date != null)
                Text(
                intl.  DateFormat('yyyy-MM-dd').format(date.toDate()),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                  ),
                ),
            ],
          ),

            SizedBox(height: 8),
            Text(
              'ملاحظات العميل:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(comment!.isNotEmpty?
              comment:'لايوجد ملاحظات على الطرد',
              style: theme.textTheme.bodySmall,
            ),

        ],
      ),
    );
  }

  Widget buildParcelCardContent(Parcel parcel, ThemeData theme, Map<String, dynamic>? ratingData,BuildContext context) {
    final hasRating = ratingData != null;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: theme.cardColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => showParcelDetails(context, parcel),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  buildStatusBadge(parcel.status, theme),
                  Spacer(),
                  Text(
                    parcel.trackingNumber,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  buildDeleteButton(context, parcel),
                ],
              ),
              SizedBox(height: 16),

              if (hasRating) ...[
                buildRatingSection(ratingData, theme),
                SizedBox(height: 12),
              ],

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 3,
                children: [
                  buildParcelDetail(
                    icon: Icons.person,
                    label: 'المستلم',
                    value: parcel.receiverName,
                    theme: theme,
                  ),
                  buildParcelDetail(
                    icon: Icons.phone,
                    label: 'الهاتف',
                    value: parcel.receiverPhone ?? 'غير محدد',
                    theme: theme,
                  ),
                  buildParcelDetail(
                    icon: Icons.location_on,
                    label: 'الوجهة',
                    value: parcel.destination ?? 'غير محدد',
                    theme: theme,
                  ),
                  buildParcelDetail(
                    icon: Icons.calendar_today,
                    label: 'التاريخ',
                    value: parcel.shippingDate != null
                        ?intl. DateFormat('yyyy-MM-dd').format(parcel.shippingDate!)
                        : 'غير محدد',
                    theme: theme,
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  if (parcel.latitude != null && parcel.longitude != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: Icon(Icons.map, size: 18),
                        label: Text('عرض الخريطة'),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => showOnMap(context, parcel),
                      ),
                    ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.edit, size: 18),
                      label: Text('تعديل'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => editParcel(context, parcel),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget buildDeleteButton(BuildContext context, Parcel parcel) {
    final theme = Theme.of(context);

    return IconButton(
      icon: Icon(Icons.delete, color: theme.colorScheme.error),
      onPressed: () => showDeleteConfirmationDialog(context, parcel),
    );
  }

  void showDeleteConfirmationDialog(BuildContext context, Parcel parcel) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('حذف الطرد', style: theme.textTheme.titleLarge),
        content: Text(
          'هل أنت متأكد من رغبتك في حذف الطرد رقم ${parcel.trackingNumber}؟',
          style: theme.textTheme.bodyLarge,
        ),
        actions: [
          TextButton(
            child: Text('إلغاء',
                style: TextStyle(color: theme.colorScheme.onSurface)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child:
                Text('حذف', style: TextStyle(color: theme.colorScheme.error)),
            onPressed: () {
              Navigator.of(context).pop();
              deleteParcel(context, parcel);
            },
          ),
        ],
      ),
    );
  }

  Future<void> deleteParcel(BuildContext context, Parcel parcel) async {
    final controller = context.read<ParcelController>();
    final scaffold = ScaffoldMessenger.of(context);

    try {
      await controller.deleteParcelFromFirestore(parcel.id);
      scaffold.showSnackBar(
        SnackBar(
          content: Text('تم حذف الطرد بنجاح'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      scaffold.showSnackBar(
        SnackBar(
          content: Text('فشل في حذف الطرد: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Widget buildStatusBadge(String status, ThemeData theme) {
    final color = getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 12, color: color),
          SizedBox(width: 6),
          Text(
            status,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildParcelDetail({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.textTheme.bodySmall?.color),
        SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.bodySmall),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void showParcelDetails(BuildContext context, Parcel parcel) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54, // تحسين لون الخلفية الخارجية
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 5,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              // مقبض السحب لإغلاق الصفحة
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: theme.dividerColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),

              // عنوان الطرد
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.close, color: theme.iconTheme.color),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'تفاصيل الطرد #${parcel.trackingNumber}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // شريط الحالة مع لون مميز
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _getStatusColor(parcel.status, isDarkMode).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      parcel.status,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: _getStatusColor(parcel.status, isDarkMode),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      _getStatusIcon(parcel.status),
                      color: _getStatusColor(parcel.status, isDarkMode),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // تفاصيل الطرد
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildDetailCard(
                        context: context,
                        title: "معلومات المستلم",
                        items: [
                          _buildDetailItem("الاسم", parcel.receiverName),
                          _buildDetailItem("الهاتف", parcel.receiverPhone ?? 'غير محدد'),
                        ],
                      ),

                      const SizedBox(height: 12),

                      _buildDetailCard(
                        context: context,
                        title: "معلومات الشحن",
                        items: [
                          _buildDetailItem("المرسل", parcel.senderName ?? 'غير محدد'),
                          _buildDetailItem("الوجهة", parcel.destination ?? 'غير محدد'),
                          _buildDetailItem("نوع الطرد", parcel.preType ?? 'قياسي'),
                          _buildDetailItem("الوزن", '${parcel.prWight} كجم'),
                          if (parcel.shippingDate != null)
                            _buildDetailItem(
                              "تاريخ الشحن",
                              intl.DateFormat('yyyy-MM-dd - HH:mm').format(parcel.shippingDate!),
                            ),
                          if (parcel.shipmentID != null)
                            _buildDetailItem("رقم الشحنة", parcel.shipmentID!),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // زر الإغلاق
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: theme.colorScheme.onPrimary,
                    backgroundColor: theme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('إغلاق'),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// دالة مساعدة لبناء بطاقة التفاصيل
  Widget _buildDetailCard({
    required BuildContext context,
    required String title,
    required List<Widget> items,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          ...items,
        ],
      ),
    );
  }

// دالة مساعدة لبناء عنصر التفاصيل
  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

// دالة مساعدة للحصول على لون الحالة
  Color _getStatusColor(String status, bool isDarkMode) {
    switch (status.toLowerCase()) {
      case 'تم التسليم':
        return Colors.green;
      case 'في الطريق':
        return Colors.orange;
      case 'في المستودع':
        return Colors.blue;
      case 'ملغى':
        return Colors.red;
      default:
        return isDarkMode ? Colors.white : Colors.black;
    }
  }

// دالة مساعدة للحصول على أيقونة الحالة
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'تم التسليم':
        return Icons.check_circle;
      case 'في الطريق':
        return Icons.local_shipping;
      case 'في المستودع':
        return Icons.warehouse;
      case 'ملغى':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  Widget buildDetailRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  void showOnMap(BuildContext context, Parcel parcel) {
    if (parcel.latitude == null || parcel.longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('لا يوجد موقع متاح لهذا الطرد'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShipmentMapScreen(
          latitude: parcel.latitude!,
          longitude: parcel.longitude!,
        ),
      ),
    );
  }

  void editParcel(BuildContext context, Parcel parcel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ParcelInputScreen(
          shipmentId: shipmentId,
          parcel: parcel,
        ),
      ),
    );
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'تم التسليم':
        return Colors.green;
      case 'ملغى':
        return Colors.red;
      case 'في المستودع':
        return Colors.blue;
      case 'في الطريق':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
