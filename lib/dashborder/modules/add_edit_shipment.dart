import 'package:dashboard/dashborder/controller/parcel_controller/parcel_controller.dart';
import 'package:dashboard/data/models/prcel_model/hive_parcel.dart';
import 'package:dashboard/mobil/shard/qr_code/parcel_qr_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ParcelInputScreen extends StatefulWidget {
  final Parcel? parcel;
  final String? shipmentId;

  const ParcelInputScreen({Key? key, this.parcel, this.shipmentId})
      : super(key: key);

  @override
  _ParcelInputScreenState createState() => _ParcelInputScreenState();
}

class _ParcelInputScreenState extends State<ParcelInputScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _trackingNumberController;
  late TextEditingController _senderNameController;
  late TextEditingController _receiverNameController;
  late TextEditingController _orderNameController;
  late TextEditingController _receiverPhoneController;
  late TextEditingController _weightController;

  late String _selectedStatus;
  late String _selectedDestination;
  late String _selectedType;

  final List<String> statusOptions = [
    'في المستودع',
    'في الطريق',
    'تم التسليم',
    'ملغى',
  ];

  final List<String> destinationOptions = [
    'عدن',
    'صنعاء',
    'تعز',
    'إب',
    'الحديدة',
  ];

  final List<String> typeOptions = [
    'قياسي',
    'سريع',
    'ثقيل',
    'هام',
  ];

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _trackingNumberController = TextEditingController();
    _senderNameController = TextEditingController();
    _receiverNameController = TextEditingController();
    _orderNameController = TextEditingController();
    _receiverPhoneController = TextEditingController();
    _weightController = TextEditingController(text: '0.0');

    // Initialize dropdown values
    _selectedStatus = 'في المستودع';
    _selectedDestination = 'عدن';
    _selectedType = 'قياسي';

    // Fill form if editing existing parcel
    if (widget.parcel != null) {
      _fillFormData(widget.parcel!);
    } else {
      _trackingNumberController.text = generateTrackingNumber();
    }
  }

  void _fillFormData(Parcel parcel) {
    _trackingNumberController.text = parcel.trackingNumber;
    _senderNameController.text = parcel.senderName ?? '';
    _receiverNameController.text = parcel.receiverName;
    _orderNameController.text = parcel.orderName ?? '';
    _receiverPhoneController.text = parcel.receiverPhone ?? '';
    _weightController.text = parcel.prWight?.toString() ?? '0.0';
    _selectedStatus = parcel.status;
    _selectedDestination = parcel.destination ?? 'عدن';
    _selectedType = parcel.preType ?? 'قياسي';
  }

  String generateTrackingNumber() {
    final now = DateTime.now();
    return 'TRK-${now.millisecondsSinceEpoch}';
  }

  @override
  void dispose() {
    _trackingNumberController.dispose();
    _senderNameController.dispose();
    _receiverNameController.dispose();
    _orderNameController.dispose();
    _receiverPhoneController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
     textDirection: TextDirection.rtl, child: Scaffold(
        appBar: AppBar(
          title: Text(widget.parcel == null ? 'إضافة طرد جديد' : 'تعديل الطرد'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                buildTrackingNumberField(),
                const SizedBox(height: 16),
                buildSenderField(),
                const SizedBox(height: 16),
                buildReceiverField(),
                const SizedBox(height: 16),
                buildOrderField(),
                const SizedBox(height: 16),
                buildPhoneField(),
                const SizedBox(height: 16),
                buildWeightField(),
                const SizedBox(height: 16),
                buildStatusDropdown(),
                const SizedBox(height: 16),
                buildDestinationDropdown(),
                const SizedBox(height: 16),
                buildTypeDropdown(),
                const SizedBox(height: 24),
                buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTrackingNumberField() {
    return TextFormField(
      controller: _trackingNumberController,
      decoration: InputDecoration(
        labelText: 'رقم التتبع',
        prefixIcon: const Icon(Icons.confirmation_number),
        border: OutlineInputBorder(),
      ),
      readOnly: widget.parcel != null,
      validator: (value) => value!.isEmpty ? 'هذا الحقل مطلوب' : null,
    );
  }

  Widget buildSenderField() {
    return TextFormField(
      controller: _senderNameController,
      decoration: InputDecoration(
        labelText: 'اسم المرسل',
        prefixIcon: const Icon(Icons.person),
        border: OutlineInputBorder(),
      ),
      validator: (value) => value!.isEmpty ? 'هذا الحقل مطلوب' : null,
    );
  }

  Widget buildReceiverField() {
    return TextFormField(
      controller: _receiverNameController,
      decoration: InputDecoration(
        labelText: 'اسم المستلم',
        prefixIcon: const Icon(Icons.person_outline),
        border: OutlineInputBorder(),
      ),
      validator: (value) => value!.isEmpty ? 'هذا الحقل مطلوب' : null,
    );
  }

  Widget buildOrderField() {
    return TextFormField(
      controller: _orderNameController,
      decoration: InputDecoration(
        labelText: 'اسم الطلب',
        prefixIcon: const Icon(Icons.shopping_basket),
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget buildPhoneField() {
    return TextFormField(
      controller: _receiverPhoneController,
      decoration: InputDecoration(
        labelText: 'هاتف المستلم',
        prefixIcon: const Icon(Icons.phone),
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.phone,
      validator: (value) {
        if (value!.isEmpty) return 'هذا الحقل مطلوب';
        if (value.length < 7) return 'رقم الهاتف غير صحيح';
        return null;
      },
    );
  }

  Widget buildWeightField() {
    return TextFormField(
      controller: _weightController,
      decoration: InputDecoration(
        labelText: 'وزن الطرد (كجم)',
        prefixIcon: const Icon(Icons.scale),
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value!.isEmpty) return 'هذا الحقل مطلوب';
        final weight = double.tryParse(value);
        if (weight == null || weight <= 0) return 'يجب أن يكون الوزن رقم موجب';
        return null;
      },
    );
  }

  Widget buildStatusDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedStatus,
      decoration: InputDecoration(
        labelText: 'حالة الطرد',
        prefixIcon: const Icon(Icons.flag),
        border: OutlineInputBorder(),
      ),
      items: statusOptions.map((status) {
        return DropdownMenuItem(
          value: status,
          child: Text(status),
        );
      }).toList(),
      onChanged: (value) => setState(() => _selectedStatus = value!),
      validator: (value) => value == null ? 'اختر حالة الطرد' : null,
    );
  }

  Widget buildDestinationDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedDestination,
      decoration: InputDecoration(
        labelText: 'الوجهة',
        prefixIcon: const Icon(Icons.location_on),
        border: OutlineInputBorder(),
      ),
      items: destinationOptions.map((destination) {
        return DropdownMenuItem(
          value: destination,
          child: Text(destination),
        );
      }).toList(),
      onChanged: (value) => setState(() => _selectedDestination = value!),
      validator: (value) => value == null ? 'اختر الوجهة' : null,
    );
  }

  Widget buildTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedType,
      decoration: InputDecoration(
        labelText: 'نوع الطرد',
        prefixIcon: const Icon(Icons.category),
        border: OutlineInputBorder(),
      ),
      items: typeOptions.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(type),
        );
      }).toList(),
      onChanged: (value) => setState(() => _selectedType = value!),
    );
  }

  Widget buildActionButtons(BuildContext context) {
    final parcelController = Provider.of<ParcelController>(context, listen: false);

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => submitForm(parcelController),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              widget.parcel == null ? 'إضافة الطرد' : 'حفظ التعديلات',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
        if (widget.parcel != null) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => showQRCode(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code),
                  SizedBox(width: 8),
                  Text('عرض رمز QR'),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> submitForm(ParcelController controller) async {
    if (!_formKey.currentState!.validate()) return;

    final scaffold = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      final parcel = Parcel(
        id: widget.parcel?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        trackingNumber: _trackingNumberController.text,
        status: _selectedStatus,
        shippingDate: widget.parcel?.shippingDate ?? DateTime.now(),
        senderName: _senderNameController.text,
        receiverName: _receiverNameController.text,
        orderName: _orderNameController.text,
        longitude: widget.parcel?.longitude,
        latitude: widget.parcel?.latitude,
        receiverPhone: _receiverPhoneController.text,
        destination: _selectedDestination,
        parceID: widget.parcel?.parceID ?? DateTime.now().millisecondsSinceEpoch,
        receverName: _receiverNameController.text,
        prWight: double.parse(_weightController.text),
        preType: _selectedType ,
        shipmentID: widget.shipmentId ?? widget.parcel?.shipmentID,
      );

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      if (widget.parcel == null) {
        await controller.addParcelsToFirestore(parcel);
        scaffold.showSnackBar(
          const SnackBar(content: Text('تم إضافة الطرد بنجاح')),
        );
      } else {
        await controller.updateParcelInFirestore(parcel.id, parcel);
        scaffold.showSnackBar(
          const SnackBar(content: Text('تم تحديث الطرد بنجاح')),
        );
      }

      navigator.pop(); // Close loading dialog
      navigator.pop(true); // Return to previous screen with success
    } catch (e) {
      navigator.pop(); // Close loading dialog
      scaffold.showSnackBar(
        SnackBar(content: Text('حدث خطأ: ${e.toString()}')),
      );
    }
  }

  void showQRCode(BuildContext context) {
    if (widget.parcel == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ParcelQRWidget(parcel: widget.parcel!),
      ),
    );
  }
}