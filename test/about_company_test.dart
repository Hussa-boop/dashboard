// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
//
// void main() {
//   testWidgets('AboutCompanyScreen should display company information', (WidgetTester tester) async {
//     // Build our app and trigger a frame.
//     await tester.pumpWidget(
//       const MaterialApp(
//         home: AboutCompanyScreen(),
//       ),
//     );
//
//     // Verify that the app bar title is displayed
//     expect(find.text('عن الشركة'), findsOneWidget);
//
//     // Verify that company name is displayed
//     expect(find.text('شركة الشحن السريع'), findsOneWidget);
//
//     // Verify that company slogan is displayed
//     expect(find.text('نوصل شحنتك بسرعة وأمان'), findsOneWidget);
//
//     // Verify that section titles are displayed
//     expect(find.text('من نحن'), findsOneWidget);
//     expect(find.text('خدماتنا'), findsOneWidget);
//     expect(find.text('معلومات الاتصال'), findsOneWidget);
//     expect(find.text('تواصل معنا'), findsOneWidget);
//
//     // Verify that service items are displayed
//     expect(find.text('شحن محلي'), findsOneWidget);
//     expect(find.text('شحن دولي'), findsOneWidget);
//     expect(find.text('تخزين البضائع'), findsOneWidget);
//     expect(find.text('تتبع الشحنات'), findsOneWidget);
//
//     // Verify that contact information is displayed
//     expect(find.text('رقم الهاتف'), findsOneWidget);
//     expect(find.text('البريد الإلكتروني'), findsOneWidget);
//     expect(find.text('العنوان'), findsOneWidget);
//     expect(find.text('ساعات العمل'), findsOneWidget);
//
//     // Verify that social media icons are displayed
//     expect(find.byIcon(Icons.facebook), findsOneWidget);
//     expect(find.byIcon(Icons.telegram), findsOneWidget);
//     expect(find.byIcon(Icons.whatshot), findsOneWidget);
//     expect(find.byIcon(Icons.email), findsOneWidget);
//   });
// }