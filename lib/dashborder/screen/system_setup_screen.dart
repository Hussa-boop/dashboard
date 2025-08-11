import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_treeview/flutter_treeview.dart';
class SystemConfigurationScreen extends StatefulWidget {
  @override
  _SystemConfigurationScreenState createState() =>
      _SystemConfigurationScreenState();
}

class _SystemConfigurationScreenState extends State<SystemConfigurationScreen> {
  TreeViewController _treeViewController = TreeViewController(
    children: [
      Node(key: 'system', label: '🌍 تهيئة النظام', expanded: true, children: [
        Node(
          key: 'countries',
          label: '🌍 الدول',
          expanded: true,
          children: [
  Node(key: 'addcountries', label: 'إضافة دولة'),
  Node(key: 'deletecountries', label: 'حذف دولة'),
  Node(key: 'updatecountries', label: 'تعديل دولة'),

          ],
        ),
        Node(
            key: 'governorates',
            label: '🏛 المحافظات',
            expanded: false,
            children: []),
        Node(
            key: 'districts',
            label: '🏘 المديريات',
            expanded: false,
            children: []),
        Node(
            key: 'branches', label: '🏢 الفروع', expanded: false, children: []),
        Node(
            key: 'departments',
            label: '📂 الأقسام',
            expanded: false,
            children: []),
        Node(
            key: 'warehouses',
            label: '📦 المخازن',
            expanded: false,
            children: []),
        Node(
            key: 'shipments',
            label: '📦 الشحنات',
            expanded: false,
            children: []),
      ]),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Directionality(
     textDirection: TextDirection.rtl, child: Scaffold(
        appBar: AppBar(title: Text("تهيئة النظام")),
        body: TreeView(
          controller: _treeViewController,
          allowParentSelect: true,
          onNodeTap: (key) {
            _onNodeTap(context, key);
          },
        ),
      ),
    );
  }

  void _onNodeTap(BuildContext context, String key) {
    // تحديد ما إذا كان سيتم الانتقال إلى شاشة جديدة أو فتح مربع حوار
    switch (key) {
      case 'countries':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CountryConfigurationScreen(),
          ),
        );
        break;
      case 'governorates':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GovernorateConfigurationScreen(),
          ),
        );
        break;
      case 'districts':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DistrictConfigurationScreen(),
          ),
        );
        break;
      case 'branches':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BranchConfigurationScreen(),
          ),
        );
        break;
      case 'departments':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DepartmentConfigurationScreen(),
          ),
        );
        break;
      case 'warehouses':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WarehouseConfigurationScreen(),
          ),
        );
        break;
      case 'shipments':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShipmentConfigurationScreen(),
          ),
        );
        break;
      default:
        _showConfigurationDialog(key);
    }
  }

  void _showConfigurationDialog(String key) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("إدارة ${_getLabelByKey(key)}"),
          content: Text("إجراءات التهيئة لـ ${_getLabelByKey(key)}"),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context), child: Text("إغلاق")),
          ],
        );
      },
    );
  }

  String _getLabelByKey(String key) {
    switch (key) {
      case 'system':
        return "تهيئة النظام";
      case 'countries':
        return "الدول";

      case 'governorates':
        return "المحافظات";
      case 'districts':
        return "المديريات";
      case 'branches':
        return "الفروع";
      case 'departments':
        return "الأقسام";
      case 'warehouses':
        return "المخازن";
      case 'shipments':
        return "الشحنات";
      default:
        return "مجهول";
    }
  }
}

// شاشة إعدادات الدول


class CountryConfigurationScreen extends StatefulWidget {
  @override
  _CountryConfigurationScreenState createState() => _CountryConfigurationScreenState();
}

class _CountryConfigurationScreenState extends State<CountryConfigurationScreen> {
  final CollectionReference _countriesRef = FirebaseFirestore.instance.collection('countries');
  List<Map<String, dynamic>> _countries = [];
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _currencyController = TextEditingController();
  bool _isActive = true;
  String? _editingCountryId;

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  void _loadCountries() {
    _countriesRef.snapshots().listen((snapshot) {
      setState(() {
        _countries = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'name': data['name'],
            'code': data['code'],
            'currency': data['currency'],
            'isActive': data['isActive'] ?? true,
          };
        }).toList();
      });
    });
  }

  Future<void> _saveCountry() async {
    if (_formKey.currentState!.validate()) {
      final countryData = {
        'name': _nameController.text.trim(),
        'code': _codeController.text.trim(),
        'currency': _currencyController.text.trim(),
        'isActive': _isActive,
      };

      if (_editingCountryId == null) {
        // Add new country
        await _countriesRef.add(countryData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تمت إضافة الدولة بنجاح')),
        );
      } else {
        // Update existing country
        await _countriesRef.doc(_editingCountryId).update(countryData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم تحديث الدولة بنجاح')),
        );
      }
      _clearForm();
    }
  }

  void _editCountry(Map<String, dynamic> country) {
    setState(() {
      _editingCountryId = country['id'];
      _nameController.text = country['name'];
      _codeController.text = country['code'];
      _currencyController.text = country['currency'];
      _isActive = country['isActive'];
    });
  }

  Future<void> _deleteCountry(String countryId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('حذف الدولة'),
        content: Text('هل أنت متأكد من أنك تريد حذف هذه الدولة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _countriesRef.doc(countryId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم حذف الدولة بنجاح')),
      );
    }
  }

  void _clearForm() {
    setState(() {
      _editingCountryId = null;
      _nameController.clear();
      _codeController.clear();
      _currencyController.clear();
      _isActive = true;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
     textDirection: TextDirection.rtl, child: Scaffold(
        appBar: AppBar(
          title: Text("تهيئة الدول"),
          actions: [
            if (_editingCountryId != null)
              IconButton(
                icon: Icon(Icons.clear),
                onPressed: _clearForm,
              ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(labelText: 'اسم الدولة'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال اسم الدولة';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _codeController,
                          decoration: InputDecoration(labelText: 'كود الدولة'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال كود الدولة';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _currencyController,
                          decoration: InputDecoration(labelText: 'العملة'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال العملة';
                            }
                            return null;
                          },
                        ),
                        SwitchListTile(
                          title: Text('مفعل'),
                          value: _isActive,
                          onChanged: (value) {
                            setState(() {
                              _isActive = value;
                            });
                          },
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _saveCountry,
                          child: Text(_editingCountryId == null ? 'إضافة دولة' : 'حفظ التعديلات'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _countries.length,
                  itemBuilder: (context, index) {
                    final country = _countries[index];
                    return Card(
                      child: ListTile(
                        title: Text(country['name']),
                        subtitle: Text('${country['code']} - ${country['currency']}'),
                        leading: country['isActive']
                            ? Icon(Icons.check_circle, color: Colors.green)
                            : Icon(Icons.remove_circle, color: Colors.grey),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editCountry(country),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteCountry(country['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// شاشة إعدادات المحافظات

class GovernorateConfigurationScreen extends StatefulWidget {
  @override
  _GovernorateConfigurationScreenState createState() => _GovernorateConfigurationScreenState();
}

class _GovernorateConfigurationScreenState extends State<GovernorateConfigurationScreen> {
  final CollectionReference _governoratesRef = FirebaseFirestore.instance.collection('governorates');

  List<Map<String, dynamic>> _governorates = [];
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  bool _isActive = true;
  String? _editingGovernorateId;

  @override
  void initState() {
    super.initState();
    _loadGovernorates();
  }

  void _loadGovernorates() {
    _governoratesRef.snapshots().listen((snapshot) {
      setState(() {
        _governorates = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'name': data['name'],
            'code': data['code'],
            'isActive': data['isActive'] ?? true,
          };
        }).toList();
      });
    });
  }

  void _saveGovernorate() {
    if (_formKey.currentState!.validate()) {
      final governorateData = {
        'name': _nameController.text.trim(),
        'code': _codeController.text.trim(),
        'isActive': _isActive,
      };

      if (_editingGovernorateId == null) {
        // Add new governorate
        _governoratesRef.add(governorateData).then((_) {
          _clearForm();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تمت إضافة المحافظة بنجاح')),
          );
        });
      } else {
        // Update existing governorate
        _governoratesRef.doc(_editingGovernorateId).update(governorateData).then((_) {
          _clearForm();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تم تحديث المحافظة بنجاح')),
          );
        });
      }
    }
  }

  void _editGovernorate(Map<String, dynamic> governorate) {
    setState(() {
      _editingGovernorateId = governorate['id'];
      _nameController.text = governorate['name'];
      _codeController.text = governorate['code'];
      _isActive = governorate['isActive'];
    });
  }

  void _deleteGovernorate(String governorateId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('حذف المحافظة'),
        content: Text('هل أنت متأكد أنك تريد حذف هذه المحافظة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              _governoratesRef.doc(governorateId).delete().then((_) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('تم حذف المحافظة بنجاح')),
                );
              });
            },
            child: Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    setState(() {
      _editingGovernorateId = null;
      _nameController.clear();
      _codeController.clear();
      _isActive = true;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
     textDirection: TextDirection.rtl, child: Scaffold(
        appBar: AppBar(
          title: Text("تهيئة المحافظات"),
          actions: [
            if (_editingGovernorateId != null)
              IconButton(
                icon: Icon(Icons.clear),
                onPressed: _clearForm,
              ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(labelText: 'اسم المحافظة'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال اسم المحافظة';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _codeController,
                          decoration: InputDecoration(labelText: 'كود المحافظة'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال كود المحافظة';
                            }
                            return null;
                          },
                        ),
                        SwitchListTile(
                          title: Text('مفعل'),
                          value: _isActive,
                          onChanged: (value) {
                            setState(() {
                              _isActive = value;
                            });
                          },
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _saveGovernorate,
                          child: Text(_editingGovernorateId == null ? 'إضافة محافظة' : 'حفظ التعديلات'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _governorates.length,
                  itemBuilder: (context, index) {
                    final governorate = _governorates[index];
                    return Card(
                      child: ListTile(
                        title: Text(governorate['name']),
                        subtitle: Text('كود: ${governorate['code']}'),
                        leading: governorate['isActive']
                            ? Icon(Icons.check_circle, color: Colors.green)
                            : Icon(Icons.remove_circle, color: Colors.grey),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editGovernorate(governorate),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteGovernorate(governorate['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// شاشة إعدادات المديريات

class DistrictConfigurationScreen extends StatefulWidget {
  @override
  _DistrictConfigurationScreenState createState() => _DistrictConfigurationScreenState();
}

class _DistrictConfigurationScreenState extends State<DistrictConfigurationScreen> {
  final CollectionReference _districtsRef = FirebaseFirestore.instance.collection('districts');
  final CollectionReference _governoratesRef = FirebaseFirestore.instance.collection('governorates');

  List<Map<String, dynamic>> _districts = [];
  List<Map<String, dynamic>> _governorates = [];

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  String? _selectedGovernorateId;
  bool _isActive = true;
  String? _editingDistrictId;

  @override
  void initState() {
    super.initState();
    _loadGovernorates();
    _loadDistricts();
  }

  void _loadGovernorates() {
    _governoratesRef.where('isActive', isEqualTo: true).snapshots().listen((snapshot) {
      setState(() {
        _governorates = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'name': data['name'],
          };
        }).toList();
      });
    });
  }

  void _loadDistricts() {
    _districtsRef.snapshots().listen((snapshot) {
      setState(() {
        _districts = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'name': data['name'],
            'code': data['code'],
            'governorateId': data['governorateId'],
            'isActive': data['isActive'] ?? true,
          };
        }).toList();
      });
    });
  }

  void _saveDistrict() {
    if (_formKey.currentState!.validate()) {
      if (_selectedGovernorateId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('الرجاء اختيار المحافظة')),
        );
        return;
      }

      final districtData = {
        'name': _nameController.text.trim(),
        'code': _codeController.text.trim(),
        'governorateId': _selectedGovernorateId,
        'isActive': _isActive,
      };

      if (_editingDistrictId == null) {
        _districtsRef.add(districtData).then((_) {
          _clearForm();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تمت إضافة المديرية بنجاح')),
          );
        });
      } else {
        _districtsRef.doc(_editingDistrictId).update(districtData).then((_) {
          _clearForm();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تم تحديث المديرية بنجاح')),
          );
        });
      }
    }
  }

  void _editDistrict(Map<String, dynamic> district) {
    setState(() {
      _editingDistrictId = district['id'];
      _nameController.text = district['name'];
      _codeController.text = district['code'];
      _selectedGovernorateId = district['governorateId'];
      _isActive = district['isActive'];
    });
  }

  void _deleteDistrict(String districtId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('حذف المديرية'),
        content: Text('هل أنت متأكد أنك تريد حذف هذه المديرية؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              _districtsRef.doc(districtId).delete().then((_) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('تم حذف المديرية بنجاح')),
                );
              });
            },
            child: Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    setState(() {
      _editingDistrictId = null;
      _nameController.clear();
      _codeController.clear();
      _selectedGovernorateId = null;
      _isActive = true;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  String? _getGovernorateNameById(String id) {
    return _governorates.firstWhere((g) => g['id'] == id, orElse: () => {'name': 'غير معروف'})['name'];
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
     textDirection: TextDirection.rtl, child: Scaffold(
        appBar: AppBar(
          title: Text("تهيئة المديريات"),
          actions: [
            if (_editingDistrictId != null)
              IconButton(
                icon: Icon(Icons.clear),
                onPressed: _clearForm,
              ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(labelText: 'اسم المديرية'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال اسم المديرية';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _codeController,
                          decoration: InputDecoration(labelText: 'كود المديرية'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال كود المديرية';
                            }
                            return null;
                          },
                        ),
                      DropdownButtonFormField<String>(
                        value: _selectedGovernorateId,
                        decoration: InputDecoration(labelText: 'المحافظة'),
                        items: _governorates.map<DropdownMenuItem<String>>((gov) {
                          return DropdownMenuItem<String>(
                            value: gov['id'].toString(), // تأكد أن القيمة String
                            child: Text(gov['name']),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          setState(() {
                            _selectedGovernorateId = value;
                          });
                        },
                        validator: (value) => value == null ? 'اختر محافظة' : null,
                      ),
                        SwitchListTile(
                          title: Text('مفعل'),
                          value: _isActive,
                          onChanged: (value) {
                            setState(() {
                              _isActive = value;
                            });
                          },
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _saveDistrict,
                          child: Text(_editingDistrictId == null ? 'إضافة مديرية' : 'حفظ التعديلات'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _districts.length,
                  itemBuilder: (context, index) {
                    final district = _districts[index];
                    return Card(
                      child: ListTile(
                        title: Text(district['name']),
                        subtitle: Text('كود: ${district['code']} - محافظة: ${_getGovernorateNameById(district['governorateId'])}'),
                        leading: district['isActive']
                            ? Icon(Icons.check_circle, color: Colors.green)
                            : Icon(Icons.remove_circle, color: Colors.grey),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editDistrict(district),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteDistrict(district['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class BranchConfigurationScreen extends StatefulWidget {
  @override
  _BranchConfigurationScreenState createState() => _BranchConfigurationScreenState();
}

class _BranchConfigurationScreenState extends State<BranchConfigurationScreen> {
  final CollectionReference _branchesRef = FirebaseFirestore.instance.collection('branches');
  final CollectionReference _districtsRef = FirebaseFirestore.instance.collection('districts');

  List<Map<String, dynamic>> _branches = [];
  List<Map<String, dynamic>> _districts = [];

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  String? _selectedDistrictId;
  bool _isActive = true;
  String? _editingBranchId;

  @override
  void initState() {
    super.initState();
    _loadDistricts();
    _loadBranches();
  }

  void _loadDistricts() {
    _districtsRef.where('isActive', isEqualTo: true).snapshots().listen((snapshot) {
      setState(() {
        _districts = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'name': data['name'],
          };
        }).toList();
      });
    });
  }

  void _loadBranches() {
    _branchesRef.snapshots().listen((snapshot) {
      setState(() {
        _branches = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'name': data['name'],
            'code': data['code'],
            'districtId': data['districtId'],
            'isActive': data['isActive'] ?? true,
          };
        }).toList();
      });
    });
  }

  void _saveBranch() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDistrictId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('الرجاء اختيار المديرية')),
        );
        return;
      }

      final branchData = {
        'name': _nameController.text.trim(),
        'code': _codeController.text.trim(),
        'districtId': _selectedDistrictId,
        'isActive': _isActive,
      };

      if (_editingBranchId == null) {
        _branchesRef.add(branchData).then((_) {
          _clearForm();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تمت إضافة الفرع بنجاح')),
          );
        });
      } else {
        _branchesRef.doc(_editingBranchId).update(branchData).then((_) {
          _clearForm();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تم تحديث بيانات الفرع')),
          );
        });
      }
    }
  }

  void _editBranch(Map<String, dynamic> branch) {
    setState(() {
      _editingBranchId = branch['id'];
      _nameController.text = branch['name'];
      _codeController.text = branch['code'];
      _selectedDistrictId = branch['districtId'];
      _isActive = branch['isActive'];
    });
  }

  void _deleteBranch(String branchId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('حذف الفرع'),
        content: Text('هل أنت متأكد أنك تريد حذف هذا الفرع؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              _branchesRef.doc(branchId).delete().then((_) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('تم حذف الفرع')),
                );
              });
            },
            child: Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    setState(() {
      _editingBranchId = null;
      _nameController.clear();
      _codeController.clear();
      _selectedDistrictId = null;
      _isActive = true;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  String? _getDistrictNameById(String id) {
    return _districts.firstWhere((d) => d['id'] == id, orElse: () => {'name': 'غير معروف'})['name'];
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
     textDirection: TextDirection.rtl, child: Scaffold(
        appBar: AppBar(
          title: Text("تهيئة الفروع"),
          actions: [
            if (_editingBranchId != null)
              IconButton(
                icon: Icon(Icons.clear),
                onPressed: _clearForm,
              ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(labelText: 'اسم الفرع'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال اسم الفرع';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _codeController,
                          decoration: InputDecoration(labelText: 'كود الفرع'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال كود الفرع';
                            }
                            return null;
                          },
                        ),
                        DropdownButtonFormField<String>(
                          value: _selectedDistrictId,
                          decoration: InputDecoration(labelText: 'المديرية'),
                          items: _districts.map<DropdownMenuItem<String>>((district) {
                            return DropdownMenuItem(
                              value: district['id'],
                              child: Text(district['name']),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedDistrictId = value;
                            });
                          },
                          validator: (value) => value == null ? 'اختر مديرية' : null,
                        ),
                        SwitchListTile(
                          title: Text('مفعل'),
                          value: _isActive,
                          onChanged: (value) {
                            setState(() {
                              _isActive = value;
                            });
                          },
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _saveBranch,
                          child: Text(_editingBranchId == null ? 'إضافة فرع' : 'حفظ التعديلات'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _branches.length,
                  itemBuilder: (context, index) {
                    final branch = _branches[index];
                    return Card(
                      child: ListTile(
                        title: Text(branch['name']),
                        subtitle: Text('كود: ${branch['code']} - المديرية: ${_getDistrictNameById(branch['districtId'])}'),
                        leading: branch['isActive']
                            ? Icon(Icons.check_circle, color: Colors.green)
                            : Icon(Icons.remove_circle, color: Colors.grey),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editBranch(branch),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteBranch(branch['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




// شاشة إعدادات الأقسام


class DepartmentConfigurationScreen extends StatefulWidget {
  @override
  _DepartmentConfigurationScreenState createState() => _DepartmentConfigurationScreenState();
}

class _DepartmentConfigurationScreenState extends State<DepartmentConfigurationScreen> {
  final CollectionReference _departmentsRef = FirebaseFirestore.instance.collection('departments');
  final CollectionReference _branchesRef = FirebaseFirestore.instance.collection('branches');

  List<Map<String, dynamic>> _departments = [];
  List<Map<String, dynamic>> _branches = [];

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  String? _selectedBranchId;
  bool _isActive = true;
  String? _editingDepartmentId;

  @override
  void initState() {
    super.initState();
    _loadBranches();
    _loadDepartments();
  }

  void _loadBranches() {
    _branchesRef.where('isActive', isEqualTo: true).snapshots().listen((snapshot) {
      setState(() {
        _branches = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'name': data['name'],
          };
        }).toList();
      });
    });
  }

  void _loadDepartments() {
    _departmentsRef.snapshots().listen((snapshot) {
      setState(() {
        _departments = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'name': data['name'],
            'code': data['code'],
            'branchId': data['branchId'],
            'isActive': data['isActive'] ?? true,
          };
        }).toList();
      });
    });
  }

  void _saveDepartment() {
    if (_formKey.currentState!.validate()) {
      if (_selectedBranchId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('الرجاء اختيار الفرع')),
        );
        return;
      }

      final departmentData = {
        'name': _nameController.text.trim(),
        'code': _codeController.text.trim(),
        'branchId': _selectedBranchId,
        'isActive': _isActive,
      };

      if (_editingDepartmentId == null) {
        _departmentsRef.add(departmentData).then((_) {
          _clearForm();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تمت إضافة القسم بنجاح')),
          );
        });
      } else {
        _departmentsRef.doc(_editingDepartmentId).update(departmentData).then((_) {
          _clearForm();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تم تحديث بيانات القسم')),
          );
        });
      }
    }
  }

  void _editDepartment(Map<String, dynamic> department) {
    setState(() {
      _editingDepartmentId = department['id'];
      _nameController.text = department['name'];
      _codeController.text = department['code'];
      _selectedBranchId = department['branchId'];
      _isActive = department['isActive'];
    });
  }

  void _deleteDepartment(String departmentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('حذف القسم'),
        content: Text('هل أنت متأكد أنك تريد حذف هذا القسم؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              _departmentsRef.doc(departmentId).delete().then((_) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('تم حذف القسم')),
                );
              });
            },
            child: Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    setState(() {
      _editingDepartmentId = null;
      _nameController.clear();
      _codeController.clear();
      _selectedBranchId = null;
      _isActive = true;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  String? _getBranchNameById(String id) {
    return _branches.firstWhere((b) => b['id'] == id, orElse: () => {'name': 'غير معروف'})['name'];
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
     textDirection: TextDirection.rtl, child: Scaffold(
        appBar: AppBar(
          title: Text("تهيئة الأقسام"),
          actions: [
            if (_editingDepartmentId != null)
              IconButton(
                icon: Icon(Icons.clear),
                onPressed: _clearForm,
              ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(labelText: 'اسم القسم'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال اسم القسم';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _codeController,
                          decoration: InputDecoration(labelText: 'كود القسم'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال كود القسم';
                            }
                            return null;
                          },
                        ),
                        DropdownButtonFormField<String>(
                          value: _selectedBranchId,
                          decoration: InputDecoration(labelText: 'الفرع'),
                          items: _branches.map<DropdownMenuItem<String>>((branch) {
                            return DropdownMenuItem(
                              value: branch['id'],
                              child: Text(branch['name']),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedBranchId = value;
                            });
                          },
                          validator: (value) => value == null ? 'اختر فرع' : null,
                        ),
                        SwitchListTile(
                          title: Text('مفعل'),
                          value: _isActive,
                          onChanged: (value) {
                            setState(() {
                              _isActive = value;
                            });
                          },
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _saveDepartment,
                          child: Text(_editingDepartmentId == null ? 'إضافة قسم' : 'حفظ التعديلات'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _departments.length,
                  itemBuilder: (context, index) {
                    final department = _departments[index];
                    return Card(
                      child: ListTile(
                        title: Text(department['name']),
                        subtitle: Text('كود: ${department['code']} - الفرع: ${_getBranchNameById(department['branchId'])}'),
                        leading: department['isActive']
                            ? Icon(Icons.check_circle, color: Colors.green)
                            : Icon(Icons.remove_circle, color: Colors.grey),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editDepartment(department),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteDepartment(department['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// شاشة إعدادات المخازن


class WarehouseConfigurationScreen extends StatefulWidget {
  @override
  _WarehouseConfigurationScreenState createState() => _WarehouseConfigurationScreenState();
}

class _WarehouseConfigurationScreenState extends State<WarehouseConfigurationScreen> {
  final CollectionReference _warehousesRef = FirebaseFirestore.instance.collection('warehouses');
  final CollectionReference _branchesRef = FirebaseFirestore.instance.collection('branches');

  List<Map<String, dynamic>> _warehouses = [];
  List<Map<String, dynamic>> _branches = [];

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  String? _selectedBranchId;
  bool _isActive = true;
  String? _editingWarehouseId;

  @override
  void initState() {
    super.initState();
    _loadBranches();
    _loadWarehouses();
  }

  void _loadBranches() {
    _branchesRef.where('isActive', isEqualTo: true).snapshots().listen((snapshot) {
      setState(() {
        _branches = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'name': data['name'],
          };
        }).toList();
      });
    });
  }

  void _loadWarehouses() {
    _warehousesRef.snapshots().listen((snapshot) {
      setState(() {
        _warehouses = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'name': data['name'],
            'code': data['code'],
            'branchId': data['branchId'],
            'isActive': data['isActive'] ?? true,
          };
        }).toList();
      });
    });
  }

  void _saveWarehouse() {
    if (_formKey.currentState!.validate()) {
      if (_selectedBranchId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('الرجاء اختيار الفرع')),
        );
        return;
      }

      final warehouseData = {
        'name': _nameController.text.trim(),
        'code': _codeController.text.trim(),
        'branchId': _selectedBranchId,
        'isActive': _isActive,
      };

      if (_editingWarehouseId == null) {
        _warehousesRef.add(warehouseData).then((_) {
          _clearForm();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تمت إضافة المخزن بنجاح')),
          );
        });
      } else {
        _warehousesRef.doc(_editingWarehouseId).update(warehouseData).then((_) {
          _clearForm();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تم تحديث بيانات المخزن')),
          );
        });
      }
    }
  }

  void _editWarehouse(Map<String, dynamic> warehouse) {
    setState(() {
      _editingWarehouseId = warehouse['id'];
      _nameController.text = warehouse['name'];
      _codeController.text = warehouse['code'];
      _selectedBranchId = warehouse['branchId'];
      _isActive = warehouse['isActive'];
    });
  }

  void _deleteWarehouse(String warehouseId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('حذف المخزن'),
        content: Text('هل أنت متأكد أنك تريد حذف هذا المخزن؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              _warehousesRef.doc(warehouseId).delete().then((_) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('تم حذف المخزن')),
                );
              });
            },
            child: Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    setState(() {
      _editingWarehouseId = null;
      _nameController.clear();
      _codeController.clear();
      _selectedBranchId = null;
      _isActive = true;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  String? _getBranchNameById(String id) {
    return _branches.firstWhere((b) => b['id'] == id, orElse: () => {'name': 'غير معروف'})['name'];
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
     textDirection: TextDirection.rtl, child: Scaffold(
        appBar: AppBar(
          title: Text("تهيئة المخازن"),
          actions: [
            if (_editingWarehouseId != null)
              IconButton(
                icon: Icon(Icons.clear),
                onPressed: _clearForm,
              ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(labelText: 'اسم المخزن'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال اسم المخزن';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _codeController,
                          decoration: InputDecoration(labelText: 'كود المخزن'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال كود المخزن';
                            }
                            return null;
                          },
                        ),
                        DropdownButtonFormField<String>(
                          value: _selectedBranchId,
                          decoration: InputDecoration(labelText: 'الفرع'),
                          items: _branches.map<DropdownMenuItem<String>>((branch) {
                            return DropdownMenuItem(
                              value: branch['id'],
                              child: Text(branch['name']),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedBranchId = value;
                            });
                          },
                          validator: (value) => value == null ? 'اختر فرع' : null,
                        ),
                        SwitchListTile(
                          title: Text('مفعل'),
                          value: _isActive,
                          onChanged: (value) {
                            setState(() {
                              _isActive = value;
                            });
                          },
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _saveWarehouse,
                          child: Text(_editingWarehouseId == null ? 'إضافة مخزن' : 'حفظ التعديلات'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _warehouses.length,
                  itemBuilder: (context, index) {
                    final warehouse = _warehouses[index];
                    return Card(
                      child: ListTile(
                        title: Text(warehouse['name']),
                        subtitle: Text('كود: ${warehouse['code']} - الفرع: ${_getBranchNameById(warehouse['branchId'])}'),
                        leading: warehouse['isActive']
                            ? Icon(Icons.check_circle, color: Colors.green)
                            : Icon(Icons.remove_circle, color: Colors.grey),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editWarehouse(warehouse),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteWarehouse(warehouse['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



// شاشة إعدادات الشحنات
class ShipmentConfigurationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("تهيئة الشحنات")),
      body: Center(
        child: Text("شاشة إعدادات الشحنات"),
      ),
    );
  }
}
