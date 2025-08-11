import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dashboard/mobil/widgets/shipping_widget.dart';

void main() {
  testWidgets('ShippingWidget displays correctly', (WidgetTester tester) async {
    // Build our widget and trigger a frame.
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ShippingWidget(),
        ),
      ),
    );

    // Verify that the title is displayed
    expect(find.text('خدمات الشحن'), findsOneWidget);

    // Verify that all service cards are displayed
    expect(find.text('طلب شحن جديد'), findsOneWidget);
    expect(find.text('تتبع الشحنة'), findsOneWidget);
    expect(find.text('سجل الشحنات'), findsOneWidget);
    expect(find.text('العروض'), findsOneWidget);
    expect(find.text('المساعدة'), findsOneWidget);

    // Verify that all icons are displayed
    expect(find.byIcon(Icons.local_shipping_rounded), findsOneWidget);
    expect(find.byIcon(Icons.gps_fixed_rounded), findsOneWidget);
    expect(find.byIcon(Icons.history_rounded), findsOneWidget);
    expect(find.byIcon(Icons.discount_rounded), findsOneWidget);
    expect(find.byIcon(Icons.support_agent_rounded), findsOneWidget);
    
    // Verify that descriptions are displayed
    expect(find.text('إنشاء طلب شحن جديد بسهولة'), findsOneWidget);
    expect(find.text('تتبع شحنتك في الوقت الحقيقي'), findsOneWidget);
    expect(find.text('عرض سجل الشحنات السابقة'), findsOneWidget);
    expect(find.text('أحدث العروض والخصومات'), findsOneWidget);
    expect(find.text('الدعم والمساعدة على مدار الساعة'), findsOneWidget);
  });

  testWidgets('PremiumServiceCard responds to tap', (WidgetTester tester) async {
    bool tapped = false;

    // Build a single service card
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PremiumServiceCard(
            icon: Icons.local_shipping_rounded,
            text: 'طلب شحن جديد',
            description: 'إنشاء طلب شحن جديد بسهولة',
            color: const Color(0xFF4CAF50),
            secondaryColor: const Color(0xFF2E7D32),
            press: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    // Verify the card is displayed
    expect(find.text('طلب شحن جديد'), findsOneWidget);
    expect(find.text('إنشاء طلب شحن جديد بسهولة'), findsOneWidget);
    expect(find.byIcon(Icons.local_shipping_rounded), findsOneWidget);

    // Tap the card
    await tester.tap(find.byType(PremiumServiceCard));
    await tester.pumpAndSettle();

    // Verify the callback was called
    expect(tapped, isTrue);
  });
  
  testWidgets('ShippingWidget has proper layout and spacing', (WidgetTester tester) async {
    // Build our widget and trigger a frame.
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ShippingWidget(),
        ),
      ),
    );

    // Verify the height of the ListView
    final listViewFinder = find.byType(ListView);
    expect(listViewFinder, findsOneWidget);
    
    final SizedBox sizedBox = tester.widget<SizedBox>(
      find.ancestor(
        of: listViewFinder,
        matching: find.byType(SizedBox),
      ).first,
    );
    
    // Verify the height is 180
    expect(sizedBox.height, 180);
    
    // Verify the card width
    final containerFinder = find.descendant(
      of: listViewFinder,
      matching: find.byType(Container),
    ).first;
    
    final Container container = tester.widget<Container>(containerFinder);
    expect(container.margin, const EdgeInsets.only(left: 16));
    expect(container.constraints?.widthConstraints().maxWidth, 150);
  });
}
