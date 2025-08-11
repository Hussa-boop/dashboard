import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:io';
import 'package:dashboard/data/models/prcel_model/hive_parcel.dart';


class ShipmentQRScanner extends StatefulWidget {
  @override
  _ShipmentQRScannerState createState() => _ShipmentQRScannerState();
}

class _ShipmentQRScannerState extends State<ShipmentQRScanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  Parcel? scannedParcel;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) controller?.pauseCamera();
    controller?.resumeCamera();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      controller.pauseCamera();
      try {
        final data = jsonDecode(scanData.code ?? '');
        final shipment = Parcel.fromJson(data);
        setState(() => scannedParcel = shipment);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("فشل في قراءة بيانات الطرد")));
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Widget _buildShipmentDetails() {
    if (scannedParcel == null) return Text("لم يتم المسح بعد...");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: scannedParcel!.toJson().entries.map((e) => Text("${e.key}: ${e.value}")).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("مسح QR للطرد")),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: _buildShipmentDetails(),
            ),
          ),
          ElevatedButton.icon(
            icon: Icon(Icons.restart_alt),
            label: Text("إعادة المسح"),
            onPressed: () => controller?.resumeCamera(),
          ),
        ],
      ),
    );
  }
}
