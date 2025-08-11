import 'dart:convert';
import 'package:dashboard/data/models/prcel_model/hive_parcel.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:cross_file/cross_file.dart';


class ParcelQRWidget extends StatefulWidget {
  final Parcel parcel;

  const ParcelQRWidget({Key? key, required this.parcel}) : super(key: key);

  @override
  State<ParcelQRWidget> createState() => _ParcelQRWidgetState();
}



class _ParcelQRWidgetState extends State<ParcelQRWidget> {
  GlobalKey qrKey = GlobalKey();

  Future<void> _saveQrToImage() async {
    try {
      final boundary = qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // استخدام cross_file بدلاً من path_provider
      final file = XFile.fromData(
        pngBytes,
        name: 'shipment_qr_${widget.parcel.id}.png',
        mimeType: 'image/png',
      );

      await file.saveTo('shipment_qr_${widget.parcel.id}.png');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("✅ تم حفظ QR كصورة!"))
        );
      }
    } catch (e) {
      print(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("❌ فشل في حفظ الصورة: ${e.toString()}"))
        );
      }
    }
  }

  void _showShipmentDetails() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("تفاصيل الطرد"),
        content: SingleChildScrollView(
          child: Text(jsonEncode(widget.parcel.toJson())),
        ),
        actions: [
          TextButton(child: Text("تم"), onPressed: () => Navigator.pop(context)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final qrData = jsonEncode(widget.parcel.toJson());

    return Scaffold(
      appBar: AppBar(title: Text("QR خاص بالطرد")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: RepaintBoundary(
                key: qrKey,
                child: QrImageView(
                  data: qrData,
                  size: 220,
                  version: QrVersions.auto,
                  gapless: false,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _saveQrToImage,
              icon: Icon(Icons.save),
              label: Text("حفظ كصورة"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(

              onPressed: _showShipmentDetails ,
              icon: Icon(Icons.info_outline),
              label:Text("عرض البيانات") ,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[300]),
            ),
          ],
        ),
      ),
    );
  }
}
