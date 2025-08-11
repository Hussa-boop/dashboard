// import 'package:dashboard/mobil/modules/share_app/share_app_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
//
// void main() {
//   testWidgets('ShareAppScreen should display sharing options', (WidgetTester tester) async {
//     // Build our app and trigger a frame.
//     await tester.pumpWidget(
//       const MaterialApp(
//         home: ShareAppScreen(),
//       ),
//     );
//
//     // Verify that the app bar title is displayed
//     expect(find.text('شارك التطبيق'), findsOneWidget);
//
//     // Verify that app name is displayed
//     expect(find.text('تطبيق الشحن السريع'), findsOneWidget);
//
//     // Verify that app description is displayed
//     expect(find.text('تطبيق لإدارة وتتبع الشحنات بكل سهولة'), findsOneWidget);
//
//     // Verify that sharing options title is displayed
//     expect(find.text('شارك التطبيق عبر'), findsOneWidget);
//
//     // Verify that sharing options are displayed
//     expect(find.text('واتساب'), findsOneWidget);
//     expect(find.text('تلجرام'), findsOneWidget);
//     expect(find.text('رسائل'), findsOneWidget);
//     expect(find.text('المزيد'), findsOneWidget);
//
//     // Verify that referral section is displayed
//     expect(find.text('شارك واحصل على مكافأة!'), findsOneWidget);
//     expect(find.text('FRIEND2023'), findsOneWidget);
//
//     // Verify that sharing icons are displayed
//     expect(find.byIcon(Icons.whatshot), findsOneWidget);
//     expect(find.byIcon(Icons.telegram), findsOneWidget);
//     expect(find.byIcon(Icons.message), findsOneWidget);
//     expect(find.byIcon(Icons.more_horiz), findsOneWidget);
//     expect(find.byIcon(Icons.copy), findsAtLeastNWidgets(1));
//   });
// }