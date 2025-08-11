import 'package:dashboard/dashborder/controller/parcel_controller/parcel_controller.dart';
import 'package:dashboard/dashborder/controller/user_controller.dart';
import 'package:dashboard/dashborder/home_screen.dart';
import 'package:dashboard/data/models/prcel_model/hive_parcel.dart';
import 'package:dashboard/dashborder/screen/statistics/widget_statistics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
class Statistics extends StatefulWidget {
  final Widget child;

  const Statistics({super.key, required this.child});

  @override
  State<Statistics> createState() => _StatisticsState(child: child);
}

class _StatisticsState extends State<Statistics> {
  final Widget child;

  _StatisticsState({required this.child});

  @override
  Widget build(BuildContext context) {
    final shipmentController = Provider.of<ParcelController>(context);
    final userController = Provider.of<UserController>(context);

    return Scaffold(
      endDrawer: (ResponsiveWidget.isSmallScreen(context) ||
              ResponsiveWidget.isMediumScreen(context))
          ? child
          : null,
      appBar: AppBar(
        title: const Text('لوحة الإحصائيات',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade800, Colors.blue.shade600],
            ),
          ),
        ),
        actions: [
          // زر تصدير PDF
          IconButton(
            icon: Icon(Icons.picture_as_pdf, color: Colors.white),
            onPressed: () => _exportStatisticsReport(shipmentController),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              buildStatsGrid(shipmentController, userController),
              const SizedBox(height: 24),
              buildChartHeader(),
              const SizedBox(height: 16),
              buildPieChart(shipmentController),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
  Future<void> _exportStatisticsReport(ParcelController controller) async {
    // 1. تحميل خط عربي يدعم Unicode
    final arabicFontData = await rootBundle.load("assets/fonts/alfont_com_arial.ttf");
    final arabicFont = pw.Font.ttf(arabicFontData);

    // 2. إنشاء مستند PDF مع تحديد الخط الافتراضي
    final pdf = pw.Document(
      theme: pw.ThemeData(
        defaultTextStyle: pw.TextStyle(
          font: arabicFont,
          fontSize: 12,
        ),
      ),
    );

    // 3. تعريف الأنماط مع استخدام الخط العربي
    final titleStyle = pw.TextStyle(
      font: arabicFont,
      fontSize: 24,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.blue800,
    );

    final headerStyle = pw.TextStyle(
      font: arabicFont,
      fontSize: 18,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.blue700,
    );

    final subHeaderStyle = pw.TextStyle(
      font: arabicFont,
      fontSize: 16,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.blue600,
    );

    final cellHeaderStyle = pw.TextStyle(
      font: arabicFont,
      fontSize: 12,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.white,
    );

    final cellStyle = pw.TextStyle(
      font: arabicFont,
      fontSize: 12,
      color: PdfColors.grey800,
    );

    // 4. صفحة الغلاف (بدون أيقونات غير مدعومة)
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: pw.Stack(
            children: [
              pw.Container(
                decoration: pw.BoxDecoration(
                  gradient: pw.LinearGradient(
                    colors: [PdfColors.blue50, PdfColors.lightBlue100],
                  ),
                ),
              ),
              pw.Center(
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text('تقرير الإحصائيات', style: titleStyle),
                    pw.SizedBox(height: 20),
                    pw.Text(
                      'تاريخ التقرير: ${DateFormat('yyyy/MM/dd').format(DateTime.now())}',
                      style: subHeaderStyle,
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'إجمالي الطرود: ${controller.totalParcel}',
                      style: subHeaderStyle,
                    ),
                  ],
                ),
              ),
              pw.Positioned(
                bottom: 50,
                right: 0,
                left: 0,
                child: pw.Center(
                  child: pw.Text(
                    'تم إنشاؤه تلقائيًا بواسطة نظام إدارة الطرود',
                    style: pw.TextStyle(
                      font: arabicFont,
                      fontSize: 10,
                      color: PdfColors.grey600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // 5. صفحة الملخص الإحصائي
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('ملخص الإحصائيات', style: headerStyle),
              pw.SizedBox(height: 20),

              // بطاقات الإحصائيات
              pw.Row(
                children: [
                  _buildStatCard('المجموع الكلي', controller.totalParcel.toString(), PdfColors.blue400, arabicFont),
                  pw.SizedBox(width: 10),
                  _buildStatCard('تم التسليم', controller.completedParcel.toString(), PdfColors.green400, arabicFont),
                  pw.SizedBox(width: 10),
                  _buildStatCard('في الانتقال', controller.inTransitParcel.toString(), PdfColors.orange400, arabicFont),
                  pw.SizedBox(width: 10),
                  _buildStatCard('ملغاة', controller.cancelledParcel.toString(), PdfColors.red400, arabicFont),
                ],
              ),
              pw.SizedBox(height: 30),
              pw.Text('التحليل البصري للإحصائيات', style: subHeaderStyle),
              pw.SizedBox(height: 20),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    flex: 2,
                    child: drawPieChart({
                      'تم التسليم': controller.completedParcel,
                      'في الانتقال': controller.inTransitParcel,
                      'ملغاة': controller.cancelledParcel,
                      'أخرى': controller.totalParcel -
                          (controller.completedParcel +
                              controller.inTransitParcel +
                              controller.cancelledParcel),
                    }, arabicFont),
                  ),
                ],
              ),
              // جدول التفاصيل
              pw.Text('تفاصيل الإحصائيات', style: subHeaderStyle),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                columnWidths: {
                  0: pw.FlexColumnWidth(3),
                  1: pw.FlexColumnWidth(2),
                },
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.blue700),
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(10),
                        child: pw.Text('العنصر', style: cellHeaderStyle),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(10),
                        child: pw.Text('القيمة', style: cellHeaderStyle),
                      ),
                    ],
                  ),
                  _buildStatRow('المجموع الكلي', controller.totalParcel.toString(), cellStyle),
                  _buildStatRow('تم التسليم', controller.completedParcel.toString(), cellStyle),
                  _buildStatRow('في الانتقال', controller.inTransitParcel.toString(), cellStyle),
                  _buildStatRow('ملغاة', controller.cancelledParcel.toString(), cellStyle),
                  _buildStatRow(
                    'النسبة المئوية للتسليم',
                    '${controller.totalParcel == 0 ? 0 : (controller.completedParcel / controller.totalParcel * 100).toStringAsFixed(1)}%',
                    cellStyle.copyWith(fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    // 6. صفحة تفاصيل الطرود
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('تفاصيل الطرود', style: headerStyle),
              pw.SizedBox(height: 10),
              pw.Text(
                'عرض أول ${controller.filteredParcels.take(10).length} طرد',
                style: cellStyle,
              ),
              pw.SizedBox(height: 20),
              for (var parcel in controller.filteredParcels.take(10)) ...[
                _buildParcelCard(parcel, arabicFont),
                pw.SizedBox(height: 15),
              ],
            ],
          ),
        ),
      ),
    );

    // 7. حفظ وعرض المستند
    await Printing.layoutPdf(
      onLayout: (format) => pdf.save(),
    );
  }

// دالة مساعدة لإنشاء بطاقة إحصائية
  pw.Widget _buildStatCard(String title, String value, PdfColor color, pw.Font arabicFont) {
    return pw.Expanded(
      child: pw.Container(
        height: 100,
        decoration: pw.BoxDecoration(
          color: color,
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text(
              title,
              style: pw.TextStyle(
                font: arabicFont,
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
            pw.SizedBox(height: 5),
            pw.Text(
              value,
              style: pw.TextStyle(
                font: arabicFont,
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

// دالة مساعدة لإنشاء صف في الجدول
  pw.TableRow _buildStatRow(String label, String value, pw.TextStyle style) {
    return pw.TableRow(
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
        ),
      ),
      children: [
        pw.Padding(
          padding: pw.EdgeInsets.all(10),
          child: pw.Text(label, style: style),
        ),
        pw.Padding(
          padding: pw.EdgeInsets.all(10),
          child: pw.Text(value, style: style),
        ),
      ],
    );
  }

// دالة مساعدة لإنشاء بطاقة طرد
  pw.Widget _buildParcelCard(Parcel parcel, pw.Font arabicFont) {
    return pw.Container(
      width: double.infinity,
      padding: pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'رقم التتبع: ${parcel.trackingNumber}',
                style: pw.TextStyle(
                  font: arabicFont,
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue700,
                ),
              ),
              _buildStatusBadge(parcel.status, arabicFont),
            ],
          ),
          pw.Divider(color: PdfColors.grey300, height: 20),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildParcelDetail('المرسل', parcel.senderName ?? 'غير معروف', arabicFont),
                    _buildParcelDetail('المستلم', parcel.receiverName ?? 'غير معروف', arabicFont),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildParcelDetail('الوجهة', parcel.destination ?? 'غير معروف', arabicFont),
                    _buildParcelDetail('تاريخ الشحن',
                        parcel.shippingDate != null
                            ? DateFormat('yyyy/MM/dd').format(parcel.shippingDate!)
                            : 'غير معروف',
                        arabicFont),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

// دالة مساعدة لعناصر تفاصيل الطرد
  pw.Widget _buildParcelDetail(String label, String value, pw.Font arabicFont) {
    return pw.Padding(
      padding: pw.EdgeInsets.only(bottom: 8),
      child: pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(
              text: '$label: ',
              style: pw.TextStyle(
                font: arabicFont,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey700,
              ),
            ),
            pw.TextSpan(
              text: value,
              style: pw.TextStyle(
                font: arabicFont,
                color: PdfColors.grey800,
              ),
            ),
          ],
        ),
      ),
    );
  }

// دالة مساعدة لشارة الحالة
  pw.Widget _buildStatusBadge(String status, pw.Font arabicFont) {
    PdfColor color;
    switch (status.toLowerCase()) {
      case 'تم التسليم':
        color = PdfColors.green;
        break;
      case 'في الانتقال':
        color = PdfColors.orange;
        break;
      case 'ملغاة':
        color = PdfColors.red;
        break;
      default:
        color = PdfColors.grey;
    }

    return pw.Container(
      padding: pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: pw.BoxDecoration(
        color: color,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: color, width: 0.5),
      ),
      child: pw.Text(
        status,
        style: pw.TextStyle(
          font: arabicFont,
          color: color,
          fontSize: 12,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }
  pw.Widget drawPieChart(Map<String, int> data, pw.Font arabicFont) {
    final total = data.values.fold(0, (a, b) => a + b);
    final colors = [
      PdfColors.green400,
      PdfColors.orange400,
      PdfColors.red400,
      PdfColors.blue400,
      PdfColors.purple400,
      PdfColors.teal400,
    ];

    return pw.Container(
      padding: pw.EdgeInsets.all(10),
      child: pw.Column(
        children: [
          pw.Text(
            'توزيع الطرود',
            style: pw.TextStyle(
              font: arabicFont,
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue700,
            ),
          ),

          pw.SizedBox(height: 10),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: data.entries.map((entry) {
              final percent = total == 0 ? 0 : (entry.value / total * 100).toStringAsFixed(1);
              final color = colors[data.keys.toList().indexOf(entry.key) % colors.length];

              return pw.Row(
                children: [
                  pw.Container(
                    width: 12,
                    height: 12,
                    margin: pw.EdgeInsets.only(left: 5),
                    decoration: pw.BoxDecoration(
                      color: color,
                      shape: pw.BoxShape.circle,
                    ),
                  ),
                  pw.Text(
                    '${entry.key} ($percent%)',
                    style: pw.TextStyle(
                      font: arabicFont,
                      fontSize: 10,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
