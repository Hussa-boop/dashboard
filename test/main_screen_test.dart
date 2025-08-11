// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:provider/provider.dart';
// import 'package:dashboard/dashborder/modules/theme.dart';
//
// void main() {
//   testWidgets('MainScreen should display all required sections', (WidgetTester tester) async {
//     // Build our app and trigger a frame.
//     await tester.pumpWidget(
//       MaterialApp(
//         home: ChangeNotifierProvider(
//           create: (_) => ThemeProvider(),
//           child: const MainScreen(),
//         ),
//       ),
//     );
//
//     // Verify that the main screen title is displayed
//     expect(find.text('الشاشة الرئيسية'), findsOneWidget);
//
//     // Verify that all section titles are displayed
//     expect(find.text('موقع الفرع'), findsAtLeastNWidgets(1));
//     expect(find.text('الإعدادات'), findsOneWidget);
//     expect(find.text('بيانات الشحنات'), findsOneWidget);
//
//     // Verify that all feature cards are displayed
//     expect(find.text('عن الشركة'), findsOneWidget);
//     expect(find.text('البيانات الشخصية'), findsOneWidget);
//     expect(find.text('شارك التطبيق'), findsOneWidget);
//     expect(find.text('إعدادات التطبيق'), findsOneWidget);
//     expect(find.text('عرض شحناتي'), findsAtLeastNWidgets(1));
//     expect(find.text('بيانات الموقع'), findsOneWidget);
//
//     // Verify that all icons are displayed
//     expect(find.byIcon(Icons.location_on), findsOneWidget);
//     expect(find.byIcon(Icons.business), findsOneWidget);
//     expect(find.byIcon(Icons.person), findsOneWidget);
//     expect(find.byIcon(Icons.share), findsOneWidget);
//     expect(find.byIcon(Icons.settings), findsOneWidget);
//     expect(find.byIcon(Icons.inventory_2), findsOneWidget);
//     expect(find.byIcon(Icons.map), findsOneWidget);
//   });
//
//   testWidgets('MainScreen should navigate to other screens when tapped', (WidgetTester tester) async {
//     // This test can't fully test navigation in widget tests without mocking navigation observer
//     // But we can at least verify that the InkWell widgets are present
//     await tester.pumpWidget(
//       MaterialApp(
//         home: ChangeNotifierProvider(
//           create: (_) => ThemeProvider(),
//           child: const MainScreen(),
//         ),
//       ),
//     );
//
//     // Verify that we have the correct number of InkWell widgets (one for each feature card)
//     expect(find.byType(InkWell), findsNWidgets(7)); // 7 feature cards
//   });
// }