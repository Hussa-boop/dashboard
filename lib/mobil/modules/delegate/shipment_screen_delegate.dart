import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Dummy Shipment Data for Agents (Replace with API calls later)
List<Map<String, dynamic>> generateAgentDummyShipments() {
  return [
    {
      'status': 'في مكتب التسليم',
      'trackingNumber': 'TRK123456',
      'orderName': 'طلب من المتجر A',
      'senderName': 'عبدالرحمن بن علي ابوحليقة',
      'receiverName': 'ايمن امين العواضي',
      'isSender': false, // Receiver
      'agentAssigned':  true, // Not yet assigned to an agent
      'agentName': 'حسين ابوحليقة',
      'agentNote': '',
    },
    {
      'status': 'تم الشحن',
      'trackingNumber': 'TRK789012',
      'orderName': 'شحنة اكسسوارات',
      'senderName': 'ايمن امين العواضي',
      'receiverName': 'حسين عبدالحكيم ابوحليقة',
      'isSender': true, // Sender
      'agentAssigned': true, // Assigned to an agent
      'agentName': 'حسين ابوحليقة',
      'agentNote': '',
    },
    {
      'status': 'تم التوصيل',
      'trackingNumber': 'TRK345678',
      'orderName': 'مجموعة هدايا',
      'senderName': 'ايمن امين العواضي',
      'receiverName': 'محمد ابراهيم عضابي',
      'isSender': false, // Receiver
      'agentAssigned': true,
      'agentName': 'حسين ابوحليقة',
      'agentNote': '',
    },
    {
      'status': 'في مكتب التسليم',
      'trackingNumber': 'TRK901234',
      'orderName': 'أدوات مكتبية',
      'senderName': 'متجر B',
      'receiverName': 'ايمن امين العواضي',
      'isSender': false, // Receiver
      'agentAssigned': true,
      'agentName': 'حسين ابوحليقة',
      'agentNote': '',
    },
    {
      'status': 'تم الشحن',
      'trackingNumber': 'TRK567890',
      'orderName': 'ملابس رياضية',
      'senderName': 'ايمن العواضي',
      'receiverName': 'حسين عبدالحكيم ابوحليقة',
      'isSender': true, // Sender
      'agentAssigned': true,
      'agentName': 'حسين ابوحليقة',
      'agentNote': '',
    },
    {
      'status': 'مؤمن',
      'trackingNumber': 'TRK567450',
      'orderName': 'ملابس رياضية',
      'senderName': 'عبدالرحمن بن علي ابوحليقة',
      'receiverName': 'حسين بن عبدالحكيم ابوحليقة',
      'isSender': true, // Sender
      'agentAssigned':  true,
      'agentName': 'حسين ابوحليقة',
      'agentNote': '',
    },
    // Add more dummy data as needed
  ];
}

//AgentShipmentsCubit
class AgentShipmentsCubit extends Cubit<AgentShipmentsState> {
  AgentShipmentsCubit() : super(AgentShipmentsInitial());
  static AgentShipmentsCubit get(context) => BlocProvider.of(context);
  final List<Map<String, dynamic>> shipments = generateAgentDummyShipments();
  void updateShipmentStatus(String trackingNumber, String newStatus) {
    final index = shipments.indexWhere((s) => s['trackingNumber'] == trackingNumber);
    if (index != -1) {
      shipments[index]['status'] = newStatus;
      emit(AgentShipmentsStatusUpdated());
    }
  }
  void addNote(String trackingNumber, String newNote) {
    final index = shipments.indexWhere((s) => s['trackingNumber'] == trackingNumber);
    if (index != -1) {
      shipments[index]['agentNote'] = newNote;
      emit(AgentShipmentsNoteAdded());
    }
  }
  List<Map<String, dynamic>> getAgentShipments() {

    return shipments;
  }

}

//AgentShipmentsState
class AgentShipmentsState {}
class AgentShipmentsInitial extends AgentShipmentsState {}
class AgentShipmentsStatusUpdated extends AgentShipmentsState {}
class AgentShipmentsNoteAdded extends AgentShipmentsState {}

class AgentShipments extends StatelessWidget {
  const AgentShipments({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AgentShipmentsCubit(),
      child: BlocConsumer<AgentShipmentsCubit, AgentShipmentsState>(
        listener: (context, state) {},
        builder: (context, state) {
          var cubit = AgentShipmentsCubit.get(context);
          // Get all shipments for the agent
          List<Map<String, dynamic>> agentShipments = cubit.getAgentShipments();
          return Directionality(
           textDirection: TextDirection.rtl, child: Scaffold(
              body: ListView.builder(
                itemCount: agentShipments.length,
                padding: const EdgeInsets.all(10),
                itemBuilder: (context, index) {
                  Map<String, dynamic> shipment = agentShipments[index];
                  return buildAgentShipmentCard(
                      context: context,
                      shipment: shipment,
                      onStatusChanged: (newStatus) {
                        cubit.updateShipmentStatus(shipment['trackingNumber'], newStatus);
                      },
                      onAddNote: (note) {
                        cubit.addNote(shipment['trackingNumber'], note);
                      }
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  // Agent-specific Shipment Card
  Widget buildAgentShipmentCard({required BuildContext context, required Map<String, dynamic> shipment, required Function(String) onStatusChanged,required Function(String) onAddNote,
  }) {
    // ... (rest of the code is very similar, but with agent-specific changes)
    IconData iconStatu;
    Color statusColor;
    Color timelineColor;
    void _copyTrackingNumber(BuildContext context) {
      Clipboard.setData(ClipboardData(text: shipment['trackingNumber']));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم نسخ رقم التتبع'),
          duration: Duration(seconds: 1),
        ),
      );
    }

    if (shipment['status'] == "في مكتب التسليم") {
      iconStatu = Icons.local_shipping;
      statusColor = Colors.orange;
      timelineColor = Colors.orange.withOpacity(0.6);
    } else if (shipment['status'] == "تم الشحن") {
      iconStatu = Icons.airport_shuttle;
      statusColor = Colors.blueAccent;
      timelineColor = Colors.blueAccent.withOpacity(0.6);
    } else if (shipment['status'] == "تم التوصيل") {
      iconStatu = Icons.check_circle;
      statusColor = Colors.green;
      timelineColor = Colors.green.withOpacity(0.6);
    } else {
      iconStatu = Icons.gpp_good;
      statusColor = Colors.green;
      timelineColor = Colors.green;
    }

    return InkWell(
      onTap: () {
        // Open agent shipment details.
        _showAgentShipmentDetailsDialog(context, shipment, onStatusChanged, onAddNote);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.black12, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tracking Number and Status
            Row(
              children: [
                Text(
                  'رقم التتبع:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  shipment['trackingNumber'],
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.copy, size: 18, color: Colors.grey.shade600),
                  onPressed: () => _copyTrackingNumber(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(width: 0.5, color: Colors.black12),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 8),
                      Text(
                        shipment['status'],
                        style: TextStyle(color: statusColor, fontSize: 14),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(15),
                            bottomLeft: Radius.circular(15),
                          ),
                        ),
                        child: Icon(
                          iconStatu,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Description and Sender Info
            Row(
              children: [
                Container(
                  width: 6,
                  height: 40,
                  decoration: BoxDecoration(
                    color: timelineColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shipment['orderName'],
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                      const SizedBox(height: 6),
                      RichText(
                        text: TextSpan(
                          text: shipment['isSender'] ? 'من : ' : 'إلى :',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrangeAccent,
                              fontSize: 18),
                          children: [
                            TextSpan(
                              text: shipment['isSender'] ? shipment['senderName'] : shipment['receiverName'] ,
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Icons Timeline
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTimelineIcon(Icons.inventory, timelineColor),
                _buildDashedLine(),
                _buildTimelineIcon(Icons.local_shipping, timelineColor),
                _buildDashedLine(),
                _buildTimelineIcon(Icons.inventory_2_outlined, timelineColor),
                _buildDashedLine(),
                _buildTimelineIcon(Icons.person, timelineColor),
              ],
            ),
            // Show the Agent Name if assigned.
            if (shipment['agentAssigned'])
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text('المندوب: ${shipment['agentName']}'),
              ),
            if (shipment['agentNote'].isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text('ملاحظات: ${shipment['agentNote']}'),
              ),
          ],
        ),
      ),
    );
  }

// إنشاء أيقونة داخل المخطط الزمني
  Widget _buildTimelineIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 16,
      ),
    );
  }

// إنشاء الخط المنقط
  Widget _buildDashedLine() {
    return Container(
      width: 30,
      height: 1,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.5),
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
      ),
    );
  }
  void _showAgentShipmentDetailsDialog(BuildContext context, Map<String, dynamic> shipment, Function(String) onStatusChanged, Function(String) onAddNote) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Status Dropdown Options
        List<String> statusOptions = [
          'في مكتب التسليم',
          'تم الشحن',
          'تم التوصيل',
          'مؤمن',
        ];

        // Current selected status
        String selectedStatus = shipment['status'];

        // Note Text Field Controller
        TextEditingController noteController = TextEditingController(text: shipment['agentNote']);

        return AlertDialog(
          title: Center(child: Text('تفاصيل الشحنة : ${shipment['trackingNumber']}')),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('رقم التتبع: ${shipment['trackingNumber']}'),
                Text('الحالة :'),
                DropdownButton<String>(
                  value: selectedStatus,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      selectedStatus = newValue;
                      onStatusChanged(selectedStatus); // Update the status
                      // Navigator.of(context).pop(); // Close the dialog
                      // _showAgentShipmentDetailsDialog(context, shipment, onStatusChanged); // Reopen it with updated data
                    }
                  },
                  items: statusOptions.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                Text('اسم الشحنة : ${shipment['orderName']}'),
                Text('${shipment['isSender'] ? 'المرسل' : 'المستقبل'}: ${shipment['isSender'] ? shipment['senderName'] : shipment['receiverName']}'),
                const SizedBox(height: 12),
                const Text('إضافة ملاحظة:'),
                TextField(
                  controller: noteController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'أدخل ملاحظتك هنا',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('إضافة الملاحظه'),
              onPressed: () {
                onAddNote(noteController.text);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('إغلاق'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
