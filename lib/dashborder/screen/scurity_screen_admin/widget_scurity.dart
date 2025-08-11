// Widget buildLogItem(LogEntry log) {
//   return Card(
//     margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//     child: ListTile(
//       leading: CircleAvatar(
//         backgroundColor: log.eventColor.withOpacity(0.2),
//         child: Text(log.eventIcon, style: const TextStyle(fontSize: 20)),),
//       title: Text(
//         log.details,
//         style: TextStyle(
//           fontWeight: FontWeight.bold,
//           color: log.eventColor,
//         ),
//       ),
//       subtitle: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text('الوقت: ${log.formattedTime}'),
//           if (log.ipAddress != null) Text('IP: ${log.ipAddress}'),
//         ],
//       ),
//       trailing: IconButton(
//         icon: const Icon(Icons.info_outline),
//         onPressed: () => showLogDetails(log),
//       ),
//     ),);
// }
//
// Widget buildFilterChips() {
//   return SingleChildScrollView(
//     scrollDirection: Axis.horizontal,
//     child: Row(
//       children: [
//         if (_selectedEventType != null)
//           Chip(
//             label: Text(
//                 _selectedEventType == 'all' ? 'الكل' : _selectedEventType!),
//             onDeleted: () => setState(() => _selectedEventType = null),
//           ),
//         if (_startDate != null)
//           Chip(
//             label: Text(
//                 'من: ${DateFormat('yyyy-MM-dd').format(_startDate!)}'),
//             onDeleted: () => setState(() => _startDate = null),
//           ),
//         if (_endDate != null)
//           Chip(
//             label: Text('إلى: ${DateFormat('yyyy-MM-dd').format(_endDate!)}'),
//             onDeleted: () => setState(() => _endDate = null),
//           ),
//         if (_selectedUserId != null)
//           Chip(
//             label: Text('المستخدم: ${_selectedUserId!}'),
//             onDeleted: () => setState(() => _selectedUserId = null),
//           ),
//       ],
//     ),
//   );
// }
//
// Future<void> showFilterDialog() async {
//   await showDialog(
//     context: context,
//     builder: (context) {
//       return AlertDialog(
//         title: const Text('تصفية السجلات'),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               DropdownButtonFormField<String>(
//                 value: _selectedEventType,
//                 items: _eventTypes.map((type) {
//                   return DropdownMenuItem(
//                     value: type,
//                     child: Text(type == 'all' ? 'الكل' : type),
//                   );
//                 }).toList(),
//                 onChanged: (value) =>
//                     setState(() => _selectedEventType = value),
//                 decoration: const InputDecoration(labelText: 'نوع الحدث'),
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 children: [
//                   Expanded(
//                     child: TextButton(
//                       onPressed: () async {
//                         final date = await showDatePicker(
//                           context: context,
//                           initialDate: DateTime.now(),
//                           firstDate: DateTime(2020),
//                           lastDate: DateTime.now(),
//                         );
//                         if (date != null) {
//                           setState(() => _startDate = date);
//                         }
//                       },
//                       child: Text(
//                         _startDate == null
//                             ? 'اختر تاريخ البداية'
//                             : DateFormat('yyyy-MM-dd').format(_startDate!),
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     child: TextButton(
//                       onPressed: () async {
//                         final date = await showDatePicker(
//                           context: context,
//                           initialDate: DateTime.now(),
//                           firstDate: _startDate ?? DateTime(2020),
//                           lastDate: DateTime.now(),
//                         );
//                         if (date != null) {
//                           setState(() => _endDate = date);
//                         }
//                       },
//                       child: Text(
//                         _endDate == null
//                             ? 'اختر تاريخ النهاية'
//                             : DateFormat('yyyy-MM-dd').format(_endDate!),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               TextField(
//                 decoration: const InputDecoration(
//                   labelText: 'رقم المستخدم',
//                   hintText: 'أدخل رقم المستخدم للتصفية',
//                 ),
//                 onChanged: (value) =>
//                 _selectedUserId = value.isEmpty ? null : value,
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('إلغاء'),
//           ),
//           TextButton(
//             onPressed: () {
//               setState(() {});
//               Navigator.pop(context);
//             },
//             child: const Text('تطبيق'),
//           ),
//         ],
//       );
//     },
//   );
// }
//
// void showLogDetails(LogEntry log) {
//   showDialog(
//     context: context,
//     builder: (context) {
//       return AlertDialog(
//         title: Text('تفاصيل السجل'),
//         content: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text('النوع: ${log.eventType}',
//                   style: TextStyle(fontWeight: FontWeight.bold)),
//               const SizedBox(height: 8),
//               Text('التفاصيل: ${log.details}'),
//               const SizedBox(height: 8),
//               Text('الوقت: ${log.formattedTime}'),
//               if (log.ipAddress != null) ...[
//                 const SizedBox(height: 8),
//                 Text('عنوان IP: ${log.ipAddress}'),
//               ],
//               if (log.deviceInfo != null) ...[
//                 const SizedBox(height: 8),
//                 Text('معلومات الجهاز: ${log.deviceInfo}'),
//               ],
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('إغلاق'),
//           ),
//         ],
//       );
//     },
//   );
// }