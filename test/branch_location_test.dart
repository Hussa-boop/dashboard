// import 'package:dashboard/mobil/modules/branch_location/branch_location_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:flutter_map/flutter_map.dart';
//
// void main() {
//   testWidgets('BranchLocationScreen should display map and branch list', (WidgetTester tester) async {
//     // Build our app and trigger a frame.
//     await tester.pumpWidget(
//       const MaterialApp(
//         home: BranchLocationScreen(),
//       ),
//     );
//
//     // Verify that the app bar title is displayed
//     expect(find.text('موقع الفرع'), findsOneWidget);
//
//     // Verify that the map is displayed
//     expect(find.byType(FlutterMap), findsOneWidget);
//
//     // Verify that branch list is displayed (at least one branch)
//     expect(find.byIcon(Icons.location_on), findsAtLeastNWidgets(1));
//   });
// }