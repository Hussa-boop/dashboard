import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EmployeesScreen extends StatefulWidget {
  @override
  _EmployeesScreenState createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _employeeIdController = TextEditingController();
  final TextEditingController _employeeNameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _socialStateController = TextEditingController();
  final TextEditingController _hireDateController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _branchController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime? _selectedBirthDate;
  DateTime? _selectedHireDate;
  String? _selectedDepartment;
  String? _selectedBranch;
  String? _selectedSocialState;

  // بيانات نموذجية للقوائم المنسدلة
  final List<String> _departments = [
    'الموارد البشرية',
    'المالية',
    'تكنولوجيا المعلومات',
    'التسويق',
    'العمليات'
  ];

  final List<String> _branches = [
    'الفرع الرئيسي',
    'الفرع الشمالي',
    'الفرع الجنوبي',
    'الفرع الشرقي',
    'الفرع الغربي'
  ];

  final List<String> _socialStates = [
    'أعزب',
    'متزوج',
    'مطلق',
    'أرمل'
  ];

  @override
  void dispose() {
    _employeeIdController.dispose();
    _employeeNameController.dispose();
    _birthDateController.dispose();
    _phoneController.dispose();
    _socialStateController.dispose();
    _hireDateController.dispose();
    _jobTitleController.dispose();
    _departmentController.dispose();
    _branchController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> selectDate(BuildContext context, bool isBirthDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade800,
              onPrimary: Colors.white,
              surface: Colors.blue.shade50,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isBirthDate) {
          _selectedBirthDate = picked;
          _birthDateController.text = DateFormat('yyyy-MM-dd').format(picked);
        } else {
          _selectedHireDate = picked;
          _hireDateController.text = DateFormat('yyyy-MM-dd').format(picked);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نظام إدارة الموظفين', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue.shade800,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // تنفيذ وظيفة البحث
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // قسم البيانات الشخصية
              buildSectionHeader('البيانات الشخصية'),
              buildEmployeeIdField(),
              const SizedBox(height: 16),
              buildEmployeeNameField(),
              const SizedBox(height: 16),
              buildBirthDateField(context),
              const SizedBox(height: 16),
              buildPhoneField(),
              const SizedBox(height: 16),
              buildSocialStateDropdown(),

              // قسم بيانات التوظيف
              buildSectionHeader('بيانات التوظيف'),
              buildHireDateField(context),
              const SizedBox(height: 16),
              buildJobTitleField(),
              const SizedBox(height: 16),
              buildDepartmentDropdown(),
              const SizedBox(height: 16),
              buildBranchDropdown(),

              // الملاحظات
              buildSectionHeader('معلومات إضافية'),
              buildNotesField(),

              const SizedBox(height: 24),
              buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue.shade800,
        ),
      ),
    );
  }

  Widget buildEmployeeIdField() {
    return TextFormField(
      controller: _employeeIdController,
      decoration: InputDecoration(
        labelText: 'رقم الموظف',
        hintText: 'أدخل الرقم التعريفي للموظف',
        prefixIcon: const Icon(Icons.badge),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'الرجاء إدخال رقم الموظف';
        }
        return null;
      },
    );
  }

  Widget buildEmployeeNameField() {
    return TextFormField(
      controller: _employeeNameController,
      decoration: InputDecoration(
        labelText: 'اسم الموظف',
        hintText: 'أدخل الاسم الكامل للموظف',
        prefixIcon: const Icon(Icons.person),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'الرجاء إدخال اسم الموظف';
        }
        return null;
      },
    );
  }

  Widget buildBirthDateField(BuildContext context) {
    return TextFormField(
      controller: _birthDateController,
      decoration: InputDecoration(
        labelText: 'تاريخ الميلاد',
        hintText: 'اختر تاريخ الميلاد',
        prefixIcon: const Icon(Icons.cake),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey.shade50,
        suffixIcon: IconButton(
          icon: const Icon(Icons.date_range),
          onPressed: () => selectDate(context, true),
        ),
      ),
      readOnly: true,
      onTap: () => selectDate(context, true),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'الرجاء اختيار تاريخ الميلاد';
        }
        return null;
      },
    );
  }

  Widget buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      decoration: InputDecoration(
        labelText: 'رقم الهاتف',
        hintText: 'أدخل رقم الهاتف',
        prefixIcon: const Icon(Icons.phone),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      keyboardType: TextInputType.phone,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'الرجاء إدخال رقم الهاتف';
        }
        if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
          return 'رقم الهاتف يجب أن يحتوي على أرقام فقط';
        }
        return null;
      },
    );
  }

  Widget buildSocialStateDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedSocialState,
      decoration: InputDecoration(
        labelText: 'الحالة الاجتماعية',
        prefixIcon: const Icon(Icons.people),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      items: _socialStates.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedSocialState = newValue;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'الرجاء اختيار الحالة الاجتماعية';
        }
        return null;
      },
    );
  }

  Widget buildHireDateField(BuildContext context) {
    return TextFormField(
      controller: _hireDateController,
      decoration: InputDecoration(
        labelText: 'تاريخ التعيين',
        hintText: 'اختر تاريخ التعيين',
        prefixIcon: const Icon(Icons.calendar_today),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey.shade50,
        suffixIcon: IconButton(
          icon: const Icon(Icons.date_range),
          onPressed: () => selectDate(context, false),
        ),
      ),
      readOnly: true,
      onTap: () => selectDate(context, false),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'الرجاء اختيار تاريخ التعيين';
        }
        return null;
      },
    );
  }

  Widget buildJobTitleField() {
    return TextFormField(
      controller: _jobTitleController,
      decoration: InputDecoration(
        labelText: 'المسمى الوظيفي',
        hintText: 'أدخل المسمى الوظيفي',
        prefixIcon: const Icon(Icons.work),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'الرجاء إدخال المسمى الوظيفي';
        }
        return null;
      },
    );
  }

  Widget buildDepartmentDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedDepartment,
      decoration: InputDecoration(
        labelText: 'اسم القسم',
        prefixIcon: const Icon(Icons.business),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      items: _departments.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedDepartment = newValue;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'الرجاء اختيار القسم';
        }
        return null;
      },
    );
  }

  Widget buildBranchDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedBranch,
      decoration: InputDecoration(
        labelText: 'اسم الفرع',
        prefixIcon: const Icon(Icons.location_city),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      items: _branches.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedBranch = newValue;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'الرجاء اختيار الفرع';
        }
        return null;
      },
    );
  }

  Widget buildNotesField() {
    return TextFormField(
      controller: _notesController,
      decoration: InputDecoration(
        labelText: 'ملاحظات',
        hintText: 'أدخل أي ملاحظات إضافية',
        prefixIcon: const Icon(Icons.note),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      maxLines: 3,
      keyboardType: TextInputType.multiline,
    );
  }

  Widget buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade800,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('حفظ', style: TextStyle(color: Colors.white)),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // حفظ البيانات
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم حفظ بيانات الموظف بنجاح')),
                );
              }
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.blue.shade800),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('مسح', style: TextStyle(color: Colors.blue.shade800)),
            onPressed: () {
              _formKey.currentState!.reset();
              setState(() {
                _selectedBirthDate = null;
                _selectedHireDate = null;
                _selectedDepartment = null;
                _selectedBranch = null;
                _selectedSocialState = null;
              });
            },
          ),
        ),
      ],
    );
  }
}