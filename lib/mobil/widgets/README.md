# ShippingWidget

واجهة احترافية لعرض خدمات الشحن في التطبيق.

## الميزات

- تصميم عصري وجذاب
- دعم كامل للغة العربية (RTL)
- تأثيرات حركية عند النقر
- تدرجات لونية جميلة
- متوافق مع الوضع الفاتح والداكن

## كيفية الاستخدام

### 1. استيراد الملف

```dart
import 'package:dashboard/mobil/widgets/shipping_widget.dart';
```

### 2. استخدام الواجهة

```dart
// إضافة واجهة الشحن إلى الشاشة
const ShippingWidget(),
```

### 3. تخصيص الواجهة (اختياري)

يمكنك تخصيص الواجهة عن طريق تعديل الملف `shipping_widget.dart` وتغيير:

- الألوان
- الأيقونات
- النصوص
- الحجم والأبعاد

## مثال كامل

```dart
import 'package:flutter/material.dart';
import 'package:dashboard/mobil/widgets/shipping_widget.dart';

class ShippingScreen extends StatelessWidget {
  const ShippingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('خدمات الشحن'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // استخدام واجهة الشحن
            const ShippingWidget(),
            // محتوى إضافي...
          ],
        ),
      ),
    );
  }
}
```

## الاختبارات

تم إضافة اختبارات للتأكد من عمل الواجهة بشكل صحيح. يمكنك تشغيل الاختبارات باستخدام:

```
flutter test test/shipping_widget_test.dart
```