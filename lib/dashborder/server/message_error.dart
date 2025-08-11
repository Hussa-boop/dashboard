import 'package:dashboard/dashborder/controller/settings_controller.dart';
import 'package:flutter/material.dart';

import '../../main.dart';

class NoConnectionApp extends StatelessWidget {
  const NoConnectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text("خطأ في الاتصال")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, size: 80, color: Colors.red),
              const SizedBox(height: 20),
              const Text(
                "تعذر الاتصال بالخادم!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "يرجى التحقق من اتصالك بالإنترنت أو المحاولة لاحقًا.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  bool isConnected = await SettingsController().checkServerConnection();
                  if (isConnected) {
                   main(); // ✅ إعادة تشغيل التطبيق عند استعادة الاتصال
                  }
                },
                child: const Text("إعادة المحاولة"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
