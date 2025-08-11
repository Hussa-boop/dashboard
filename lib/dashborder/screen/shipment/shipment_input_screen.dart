import 'package:dashboard/dashborder/controller/shipment_controller/shipments_controller.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'as intl;
import 'package:provider/provider.dart';
class ShipmentInputScreen extends StatefulWidget {
  const ShipmentInputScreen({Key? key}) : super(key: key);

  @override
  State<ShipmentInputScreen> createState() => _ShipmentInputScreenState();
}

class _ShipmentInputScreenState extends State<ShipmentInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _shippingIDController = TextEditingController();
  final _deliverIdController = TextEditingController();
  final _deliveringAddressController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _deliverDate;
  String _selectedStatus = 'قيد الانتظار';
  String? _selectedDelegateId;

  final List<String> _statusOptions = [
    'قيد الانتظار',
    'قيد التوصيل',
    'تم التسليم',
    'ملغى'
  ];

  List<Map<String, dynamic>> _delegates = [];

  @override
  void initState() {
    super.initState();
    _loadDelegates();
  }

  Future<void> _loadDelegates() async {
    try {
      final delegatesSnapshot =
          await FirebaseFirestore.instance.collection('delegates').get();

      setState(() {
        _delegates = delegatesSnapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  'name': doc.data()['deveName'] ?? '',
                })
            .toList();
      });
    } catch (e) {
      print('خطأ في تحميل المندوبين: $e');
    }
  }

  @override
  void dispose() {
    _shippingIDController.dispose();
    _deliverIdController.dispose();
    _deliveringAddressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _deliverDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _deliverDate) {
      setState(() {
        _deliverDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final shipment = {
          'shippingID': _shippingIDController.text,
          'deliverId': _deliverIdController.text,
          'deliveringAddress': _deliveringAddressController.text,
          'deliverDate':
              _deliverDate != null ? Timestamp.fromDate(_deliverDate!) : null,
          'status': _selectedStatus,
          'delegateId': _selectedDelegateId,
          'notes': _notesController.text,
          'createdAt': FieldValue.serverTimestamp(),
        };

        await FirebaseFirestore.instance
            .collection('shipments')
            .doc(_shippingIDController.text)
            .set(shipment);
final shipments =   Provider.of<ShipmentController>(context,listen: false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إضافة الشحنة بنجاح')),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
     textDirection: TextDirection.rtl, child: Scaffold(
        appBar: AppBar(
          title: const Text('إضافة شحنة جديدة'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _shippingIDController,
                  decoration: const InputDecoration(
                    labelText: 'رقم الشحنة',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال رقم الشحنة';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _deliverIdController,
                  decoration: const InputDecoration(
                    labelText: 'رقم التوصيل',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال رقم التوصيل';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _deliveringAddressController,
                  decoration: const InputDecoration(
                    labelText: 'عنوان التوصيل',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال عنوان التوصيل';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'الحالة',
                    border: OutlineInputBorder(),
                  ),
                  items: _statusOptions.map((String status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedStatus = newValue;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedDelegateId,
                  decoration: const InputDecoration(
                    labelText: 'المندوب',
                    border: OutlineInputBorder(),
                  ),
                  items: _delegates.map((delegate) {
                    return DropdownMenuItem<String>(
                      value: delegate['id'],
                      child: Text(delegate['name']),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedDelegateId = newValue;
                    });
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'تاريخ التوصيل',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      _deliverDate == null
                          ? 'اختر التاريخ'
                          :intl. DateFormat('yyyy-MM-dd').format(_deliverDate!),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'ملاحظات',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'حفظ الشحنة',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
