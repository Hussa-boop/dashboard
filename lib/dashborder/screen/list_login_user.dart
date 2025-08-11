// screens/login_history_screen.dart
import 'package:dashboard/data/models/login_trak_model/trak_login_user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/auth_controller.dart';


class LoginHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('سجل الدخول والخروج'),
      ),
      body: FutureBuilder<List<LoginLog>>(
        future: authController.getUserLoginHistory(authController.currentUserId ?? ''),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('لا توجد سجلات متاحة'));
          }

          final logs = snapshot.data!;

          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return ListTile(
                leading: Icon(
                  log.action == 'login' ? Icons.login : Icons.logout,
                  color: log.action == 'login' ? Colors.green : Colors.red,
                ),
                title: Text(log.actionDescription),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('الوقت: ${log.formattedTime}'),
                    if (log.ipAddress != null) Text('ipAddress: ${log.ipAddress}'),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}