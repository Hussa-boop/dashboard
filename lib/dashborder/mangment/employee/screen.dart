import 'package:flutter/material.dart';
import 'package:provider/provider.dart';






class EmployeeProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _employees = [
    {
      'id': 1,
      'name': 'حسين عبدالحكيم ابوحليقة',
      'jobTitle': 'مطور برمجيات',
      'department': 'تكنولوجيا المعلومات',
      'branch': 'الفرع الرئيسي',
      'hireDate': '2020-05-15',
      'phone': '777370341',
      'socialState': 'متزوج',
      'email': 'hussain@company.com',
      'photo': 'assets/DeliveryTruckLoading.png',
    },
    {
      'id': 2,
      'name': 'ايمن امين العواضي',
      'jobTitle': 'مدير موارد بشرية',
      'department': 'الموارد البشرية',
      'branch': 'الفرع الشمالي',
      'hireDate': '2018-03-10',
      'phone': '775479401',
      'socialState': 'أعزب',
      'email': 'ayman@company.com',
      'photo': 'assets/DeliveryTruckLoading.png',
    },
  ];

  List<Map<String, dynamic>> get employees => _employees;

  void addEmployee(Map<String, dynamic> employee) {
    employee['id']  =( _employees.length + 1).toString();
    _employees.add(employee);
    notifyListeners();
  }

  void updateEmployee(int id, Map<String, dynamic> updatedEmployee) {
    final index = _employees.indexWhere((emp) => emp['id'] == id);
    if (index != -1) {
      _employees[index] = {..._employees[index], ...updatedEmployee};
      notifyListeners();
    }
  }

  void deleteEmployee(int id) {
    _employees.removeWhere((emp) => emp['id'] == id);
    notifyListeners();
  }
}

class EmployeesListScreen extends StatefulWidget {
  @override
  _EmployeesListScreenState createState() => _EmployeesListScreenState();
}

class _EmployeesListScreenState extends State<EmployeesListScreen> {
  String _searchQuery = '';
  String _selectedDepartment = 'الكل';
  String _selectedBranch = 'الكل';
  Map<String, dynamic>? selectedEmployee;

  final List<String> departments = [
    'الكل',
    'الموارد البشرية',
    'المالية',
    'تكنولوجيا المعلومات',
    'التسويق',
    'العمليات'
  ];

  final List<String> branches = [
    'الكل',
    'الفرع الرئيسي',
    'الفرع الشمالي',
    'الفرع الجنوبي',
    'الفرع الشرقي',
    'الفرع الغربي'
  ];

  @override
  Widget build(BuildContext context) {
    final employeeProvider = Provider.of<EmployeeProvider>(context);
    final filteredEmployees = employeeProvider.employees.where((emp) {
      final matchesSearch = emp['name'].contains(_searchQuery) ||
          emp['jobTitle'].contains(_searchQuery);
      final matchesDepartment = _selectedDepartment == 'الكل' ||
          emp['department'] == _selectedDepartment;
      final matchesBranch = _selectedBranch == 'الكل' ||
          emp['branch'] == _selectedBranch;
      return matchesSearch && matchesDepartment && matchesBranch;
    }).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('قائمة الموظفين'),
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () => showSearchDialog(context),
            ),
          ],
        ),
        body: Column(
          children: [
            buildFilterRow(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await Future.delayed(Duration(seconds: 1));
                  setState(() {});
                },
                child: ListView.builder(
                  itemCount: filteredEmployees.length,
                  itemBuilder: (context, index) {
                    final employee = filteredEmployees[index];
                    return buildEmployeeCard(employee, context);
                  },
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (selectedEmployee != null)
              FloatingActionButton(
                heroTag: 'editEmployee',
                mini: true,
                backgroundColor: Colors.orange,
                child: Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddEditEmployeeScreen(
                        isEditing: true,
                        employeeData: selectedEmployee,
                      ),
                    ),
                  ).then((_) => setState(() => selectedEmployee = null));
                },
              ),
            SizedBox(height: 10),
            FloatingActionButton(
              heroTag: 'addEmployee',
              child: Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEditEmployeeScreen(
                      isEditing: false,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(child: buildDepartmentFilter()),
          SizedBox(width: 8),
          Expanded(child: buildBranchFilter()),
        ],
      ),
    );
  }

  Widget buildDepartmentFilter() {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'القسم',
        prefixIcon: Icon(Icons.business),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: EdgeInsets.symmetric(horizontal: 12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedDepartment,
          onChanged: (newValue) {
            setState(() => _selectedDepartment = newValue!);
          },
          items: departments.map((value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget buildBranchFilter() {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'الفرع',
        prefixIcon: Icon(Icons.location_city),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: EdgeInsets.symmetric(horizontal: 12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedBranch,
          onChanged: (newValue) {
            setState(() => _selectedBranch = newValue!);
          },
          items: branches.map((value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget buildEmployeeCard(Map<String, dynamic> employee, BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() => selectedEmployee = employee);
          showEmployeeDetails(employee, context);
        },
        onLongPress: () => showDeleteDialog(employee['id'], context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage(employee['photo']),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          employee['name'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(employee['jobTitle']),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.business, size: 16),
                            SizedBox(width: 4),
                            Text(employee['department']),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Chip(
                    label: Text(employee['branch']),
                    backgroundColor: Colors.blue,
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              Divider(height: 24, thickness: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildInfoChip(Icons.phone, employee['phone']),
                  buildInfoChip(Icons.email, employee['email']),
                  buildInfoChip(Icons.calendar_today, employee['hireDate']),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInfoChip(IconData icon, String text) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(text),
    );
  }

  void showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('بحث عن موظف'),
        content: TextField(
          decoration: InputDecoration(
            hintText: 'ابحث بالاسم أو المسمى الوظيفي',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => setState(() => _searchQuery = value),
        ),
        actions: [
          TextButton(
            child: Text('إلغاء'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void showEmployeeDetails(Map<String, dynamic> employee, BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 4,
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage(employee['photo']),
            ),
            SizedBox(height: 16),
            Text(employee['name'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(employee['jobTitle'], style: TextStyle(fontSize: 16)),
            SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  buildDetailItem(Icons.business, 'القسم', employee['department']),
                  buildDetailItem(Icons.location_city, 'الفرع', employee['branch']),
                  buildDetailItem(Icons.phone, 'الهاتف', employee['phone']),
                  buildDetailItem(Icons.email, 'البريد الإلكتروني', employee['email']),
                  buildDetailItem(Icons.calendar_today, 'تاريخ التعيين', employee['hireDate']),
                  buildDetailItem(Icons.people, 'الحالة الاجتماعية', employee['socialState']),
                ],
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    child: Text('إغلاق'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 24),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey)),
              SizedBox(height: 4),
              Text(value),
            ],
          ),
        ],
      ),
    );
  }

  void showDeleteDialog(int employeeId, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('حذف الموظف'),
        content: Text('هل أنت متأكد من حذف هذا الموظف؟'),
        actions: [
          TextButton(
            child: Text('إلغاء'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('حذف', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Provider.of<EmployeeProvider>(context, listen: false).deleteEmployee(employeeId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('تم حذف الموظف بنجاح')),
              );
            },
          ),
        ],
      ),
    );
  }
}

class AddEditEmployeeScreen extends StatefulWidget {
  final bool isEditing;
  final Map<String, dynamic>? employeeData;

  const AddEditEmployeeScreen({
    required this.isEditing,
    this.employeeData,
    Key? key,
  }) : super(key: key);

  @override
  _AddEditEmployeeScreenState createState() => _AddEditEmployeeScreenState();
}

class _AddEditEmployeeScreenState extends State<AddEditEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _jobTitleController;
  late TextEditingController _departmentController;
  late TextEditingController _branchController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _hireDateController;
  late TextEditingController _socialStateController;

  final List<String> departments = [
    'الموارد البشرية',
    'المالية',
    'تكنولوجيا المعلومات',
    'التسويق',
    'العمليات'
  ];

  final List<String> branches = [
    'الفرع الرئيسي',
    'الفرع الشمالي',
    'الفرع الجنوبي',
    'الفرع الشرقي',
    'الفرع الغربي'
  ];

  final List<String> socialStates = ['أعزب', 'متزوج', 'مطلق', 'أرمل'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.employeeData?['name'] ?? '');
    _jobTitleController = TextEditingController(text: widget.employeeData?['jobTitle'] ?? '');
    _departmentController = TextEditingController(text: widget.employeeData?['department'] ?? '');
    _branchController = TextEditingController(text: widget.employeeData?['branch'] ?? '');
    _phoneController = TextEditingController(text: widget.employeeData?['phone'] ?? '');
    _emailController = TextEditingController(text: widget.employeeData?['email'] ?? '');
    _hireDateController = TextEditingController(text: widget.employeeData?['hireDate'] ?? '');
    _socialStateController = TextEditingController(text: widget.employeeData?['socialState'] ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final employeeProvider = Provider.of<EmployeeProvider>(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isEditing ? 'تعديل موظف' : 'إضافة موظف جديد'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'الاسم الكامل'),
                  validator: (value) => value!.isEmpty ? 'الرجاء إدخال الاسم' : null,
                ),
                TextFormField(
                  controller: _jobTitleController,
                  decoration: InputDecoration(labelText: 'المسمى الوظيفي'),
                  validator: (value) => value!.isEmpty ? 'الرجاء إدخال المسمى الوظيفي' : null,
                ),
                DropdownButtonFormField<String>(
                  value: _departmentController.text.isEmpty ? null : _departmentController.text,
                  decoration: InputDecoration(labelText: 'القسم'),
                  items: departments.map((dept) {
                    return DropdownMenuItem<String>(
                      value: dept,
                      child: Text(dept),
                    );
                  }).toList(),
                  onChanged: (value) => _departmentController.text = value!,
                  validator: (value) => value == null ? 'الرجاء اختيار القسم' : null,
                ),
                DropdownButtonFormField<String>(
                  value: _branchController.text.isEmpty ? null : _branchController.text,
                  decoration: InputDecoration(labelText: 'الفرع'),
                  items: branches.map((branch) {
                    return DropdownMenuItem<String>(
                      value: branch,
                      child: Text(branch),
                    );
                  }).toList(),
                  onChanged: (value) => _branchController.text = value!,
                  validator: (value) => value == null ? 'الرجاء اختيار الفرع' : null,
                ),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: 'رقم الهاتف'),
                  keyboardType: TextInputType.phone,
                  validator: (value) => value!.isEmpty ? 'الرجاء إدخال رقم الهاتف' : null,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'البريد الإلكتروني'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value!.isEmpty ? 'الرجاء إدخال البريد الإلكتروني' : null,
                ),
                TextFormField(
                  controller: _hireDateController,
                  decoration: InputDecoration(
                    labelText: 'تاريخ التعيين',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () => selectDate(context),
                    ),
                  ),
                  validator: (value) => value!.isEmpty ? 'الرجاء إدخال تاريخ التعيين' : null,
                ),
                DropdownButtonFormField<String>(
                  value: _socialStateController.text.isEmpty ? null : _socialStateController.text,
                  decoration: InputDecoration(labelText: 'الحالة الاجتماعية'),
                  items: socialStates.map((state) {
                    return DropdownMenuItem<String>(
                      value: state,
                      child: Text(state),
                    );
                  }).toList(),
                  onChanged: (value) => _socialStateController.text = value!,
                  validator: (value) => value == null ? 'الرجاء اختيار الحالة الاجتماعية' : null,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => submitForm(employeeProvider),
                  child: Text(widget.isEditing ? 'حفظ التعديلات' : 'إضافة موظف'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _hireDateController.text = "${picked.year}-${picked.month}-${picked.day}";
      });
    }
  }

  void submitForm(EmployeeProvider employeeProvider) {
    if (_formKey.currentState!.validate()) {
      final employeeData = {
        'name': _nameController.text,
        'jobTitle': _jobTitleController.text,
        'department': _departmentController.text,
        'branch': _branchController.text,
        'phone': _phoneController.text,
        'email': _emailController.text,
        'hireDate': _hireDateController.text,
        'socialState': _socialStateController.text,
        'photo': 'assets/DeliveryTruckLoading.png',
      };

      if (widget.isEditing) {
        employeeProvider.updateEmployee(widget.employeeData!['id'], employeeData);
      } else {
        employeeProvider.addEmployee(employeeData);
      }

      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _jobTitleController.dispose();
    _departmentController.dispose();
    _branchController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _hireDateController.dispose();
    _socialStateController.dispose();
    super.dispose();
  }
}