import 'dart:convert';

import 'package:flutter/material.dart';
import '../../../visitor_screen/shipment_history_screen/shipment_history.dart';
import '../../customer_drawer.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data_shipment.dart';
import '../../report_operation.dart';

class ShipmentsScreen2 extends StatefulWidget {
  const ShipmentsScreen2({super.key});

  @override
  _ShipmentsScreen2State createState() => _ShipmentsScreen2State();
}

class _ShipmentsScreen2State extends State<ShipmentsScreen2> {
  int selectedIndex = 0; // 0 = واردة, 1 = صادرة
  String selectedStatusFilter = 'كل الحالات';
  String selectedTypeFilter = 'كل الأنواع';
  DateTime? selectedDateFilter;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('يرجى تسجيل الدخول')),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orange,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "الطرود",
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        endDrawer: const CustomDrawer(),
        body: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.orange,
                spreadRadius: 20,
              ),
            ],
          ),
          child: Column(
            children: [
              IconButton(
                onPressed: () => _showFilterDialog(context),
                icon: const Icon(Icons.filter_list),
              ),
              TabsWidget(
                selectedIndex: selectedIndex,
                onTabSelected: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              ),
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                    return const Center(child: Text('فشل في تحميل بيانات المستخدم'));
                  }



                  // ضبط نوع الشحنة بحسب التاب
                  if (selectedIndex == 0) {
                    selectedTypeFilter = 'واردة';
                  } else if (selectedIndex == 1) {
                    selectedTypeFilter = 'صادرة';
                  }

                  return  Expanded(
                    child: ShipmentsList(
                      selectedStatusFilter: selectedStatusFilter,
                      selectedTypeFilter: selectedTypeFilter,
                      selectedDateFilter: selectedDateFilter,
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );

  }

  Future<void> _showFilterDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return FilterDialog(
          selectedStatusFilter: selectedStatusFilter,
          selectedTypeFilter: selectedTypeFilter,
          selectedDateFilter: selectedDateFilter,
          onStatusChanged: (status) {
            setState(() {
              selectedStatusFilter = status;
            });
          },
          onTypeChanged: (type) {
            setState(() {
              selectedTypeFilter = type;
            });
          },
          onDateChanged: (date) {
            setState(() {
              selectedDateFilter = date;
            });
          },
        );
      },
    );
  }
}

class TabsWidget extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;

  const TabsWidget({  required this.onTabSelected, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        height: 50,
        width: 300,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: const BorderRadius.all(Radius.circular(15)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildTab("واردة", 0),
            _buildTab("صادرة", 1),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => onTabSelected(index),
      child: Container(
        width: 150,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.grey[300],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.deepOrangeAccent : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}

class ShipmentsList extends StatelessWidget {
  final String selectedStatusFilter;
  final String selectedTypeFilter;
  final DateTime? selectedDateFilter;

  const ShipmentsList({
    required this.selectedStatusFilter,
    required this.selectedTypeFilter,
    required this.selectedDateFilter,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('يرجى تسجيل الدخول'));
    }

    // جلب بيانات المستخدم من Firestore للحصول على اسمه
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          return const Center(child: Text('لم يتم العثور على المستخدم'));
        }

        final userData = userSnapshot.data!.data() as Map<String, dynamic>;
        final userName = userData['name'];
        final phoneReceiver = userData['receiverPhone'];

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('parcel').where('receiverPhone',isEqualTo:  phoneReceiver,).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {

              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('لا توجد طرود حالياً'));
            }

            // تحويل البيانات إلى List<Map>
            List<Map<String, dynamic>> allShipments = snapshot.data!.docs
                .map((doc) => doc.data() as Map<String, dynamic>)
                .toList();

            // تصفية الشحنات بناءً على الفلاتر واسم المستخدم
            List<Map<String, dynamic>> filteredShipments =
            _filterShipments(allShipments, userName);

            if (filteredShipments.isEmpty) {
              return const Center(
                child: Text(
                  'لا توجد طرود مطابقة للفلاتر',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.orange,
                  ),
                ),
              );
            }

            return ListView.builder(
              itemCount: filteredShipments.length,
              itemBuilder: (context, index) {
                final data = filteredShipments[index];

                // تحديد ما إذا كان المستخدم هو المرسل أو المستلم
                final isSender = data['senderName'] == userName;


                return
                  buildShipmentCard(
                  status: data['status'] ?? '',
                  trackingNumber: data['trackingNumber'] ?? '',
                  orderName: data['orderName'] ?? '',
                  senderName: isSender ? data['receiverName'] ?? '' : data['senderName'] ?? '',
                  isSender: isSender, context: context, onTap: () {
                    Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ParcelDetailsScreen(
                      id: data['id'],
                      trackingNumber: data['trackingNumber'],
                      status: data['status'],
                      shippingDate: "2023-05-15T10:30:00Z",
                      senderName: data['senderName'],
                      receiverName: data['receiverName'],
                      orderName:data['orderName'],
                      longitude:data['longitude'],
                      latitude: data['latitude'],
                      senderAddress: data['destination'],
                      receiverAddress: "صنعاء",
                      senderPhone: "0501234567",
                      receiverPhone: data['receiverPhone'],
                      shipmentWeight: "1.5 كجم",
                      shipmentType: "طرد صغير",
                      paymentMethod: "الدفع عند الاستلام",
                      shipmentCost: 25.0,
                    ),
                  ),
                );  },
                );
              },
            );
          },
        );
      },
    );
  }

  List<Map<String, dynamic>> _filterShipments(
      List<Map<String, dynamic>> shipments, String userName) {
    return shipments.where((shipment) {
      bool isUserSender = shipment['senderName'] == userName;
      bool isUserReceiver = shipment['receiverName'] == userName;

      // نوع الشحنة: صادرة، واردة، أو الكل
      bool matchesType = selectedTypeFilter == 'كل الأنواع' ||
          (selectedTypeFilter == 'صادرة' && isUserSender) ||
          (selectedTypeFilter == 'واردة' && isUserReceiver);

      // حالة الشحنة
      bool matchesStatus = selectedStatusFilter == 'كل الحالات' ||
          shipment['status'] == selectedStatusFilter;

      // التاريخ
      bool matchesDate = true;
      if (selectedDateFilter != null && shipment['shippingDate'] != null) {
        Timestamp timestamp = shipment['shippingDate'];
        DateTime shippingDate = timestamp.toDate();
        matchesDate =
            shippingDate.year == selectedDateFilter!.year &&
                shippingDate.month == selectedDateFilter!.month &&
                shippingDate.day == selectedDateFilter!.day;
      }

      return matchesType && matchesStatus && matchesDate;
    }).toList();
  }
}

class FilterDialog extends StatelessWidget {
  final String selectedStatusFilter;
  final String selectedTypeFilter;
  final DateTime? selectedDateFilter;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onTypeChanged;
  final ValueChanged<DateTime?> onDateChanged;

  const FilterDialog({
    required this.selectedStatusFilter,
    required this.selectedTypeFilter,
    required this.selectedDateFilter,
    required this.onStatusChanged,
    required this.onTypeChanged,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("تطبيق الفلاتر"),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("حالة الشحنة:", style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8.0, // المسافة بين الـ Chips
              children: [
                'كل الحالات',
                'تم الالغاء من المرسل',
                'تم الرفض مع الدفع',
                'تم الرفض مع سداد جزء',
                'تم الرفض ولم يتم الدفع',
                'تم التأجيل',
                'في مكتب الشحن',
                'في مكتب التسليم',
                'تم التسليم جزئياً',
                'يتم الشحن',
                'مستلم',
                'مفقود'
              ].map((String value) {
                return FilterChip(
                  label: Text(value),
                  selected: selectedStatusFilter == value,
                  onSelected: (bool selected) {
                    onStatusChanged(value);
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16), // مسافة بين الأقسام
            const Text("نوع الشحنة:", style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8.0,
              children: [
                'كل الأنواع',
                'واردة',
                'صادرة',
              ].map((String value) {
                return FilterChip(
                  label: Text(value),
                  selected: selectedTypeFilter == value,
                  onSelected: (bool selected) {
                    onTypeChanged(value);
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16), // مسافة بين الأقسام
            const Text("التاريخ:", style: TextStyle(fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  onDateChanged(pickedDate);
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("إغلاق"),
        ),
      ],
    );
  }
}