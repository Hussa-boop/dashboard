import 'package:dashboard/data/models/prcel_model/hive_parcel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<void> exportParcelReport({
  required Parcel parcel
}) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // العنوان الرئيسي
            pw.Header(
              level: 0,
              child: pw.Text('تقرير تفاصيل الطرد',
                  style: pw.TextStyle(fontSize: 24)),
            ),

            pw.SizedBox(height: 20),

            // معلومات التتبع - بدلاً من Section
            pw.Text('المعلومات الأساسية', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.Divider(),
            pw.Table(
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FlexColumnWidth(3),
              },
              children: [
                _buildRow('رقم التتبع', parcel.trackingNumber),
                _buildRow('حالة الشحنة', parcel.status),
                _buildRow('تاريخ الشحن', parcel.shippingDate?.toString()),
                _buildRow('معرف الشحنة', parcel.shipmentID),
              ],
            ),

            pw.SizedBox(height: 20),

            // معلومات المرسل والمستلم
            pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('المرسل', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                      pw.Divider(),
                      _buildInfoRow('الاسم', parcel.senderName),
                    ],
                  ),
                ),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('المستلم', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                      pw.Divider(),
                      _buildInfoRow('الاسم', parcel.receiverName),
                      _buildInfoRow('الهاتف', parcel.receiverPhone),
                      _buildInfoRow('الوجهة', parcel.destination),
                    ],
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 20),

            // معلومات إضافية
            pw.Text('تفاصيل إضافية', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.Divider(),
            pw.Table(
              children: [
                _buildRow('الوزن (كجم)', parcel.prWight?.toString()),
                _buildRow('نوع الطرد', parcel.preType),
                _buildRow('ملاحظات', parcel.noted),
                _buildRow('الإحداثيات', '${parcel.latitude}, ${parcel.longitude}'),
              ],
            ),

            pw.Spacer(),

            // تذييل التقرير
            pw.Center(
              child: pw.Text(
                'تم إنشاء التقرير في: ${DateTime.now().toString()}',
                style: pw.TextStyle(color: PdfColors.grey600),
              ),
            ),
          ],
        );
      },
    ),
  );

  // عرض خيارات الطباعة/الحفظ
  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) => pdf.save(),
  );
}

// دالة مساعدة لإنشاء صفوف الجدول
pw.TableRow _buildRow(String title, String? value) {
  return pw.TableRow(
    children: [
      pw.Padding(
        padding: const pw.EdgeInsets.all(4),
        child: pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      ),
      pw.Padding(
        padding: const pw.EdgeInsets.all(4),
        child: pw.Text(value ?? 'غير متوفر'),
      ),
    ],
  );
}

// دالة مساعدة لإنشاء صفوف المعلومات
pw.Widget _buildInfoRow(String title, String? value) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 4),
    child: pw.Row(
      children: [
        pw.Text('$title: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.Text(value ?? 'غير متوفر'),
      ],
    ),
  );
}