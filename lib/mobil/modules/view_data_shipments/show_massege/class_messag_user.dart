import 'package:flutter/material.dart';
import 'card_anmtion_massge.dart';
import 'package:dashboard/main.dart';

class AppAlerts {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static void showSuccess({
    required String message,
    Duration duration = const Duration(seconds: 3),
    BuildContext? context,
  }) {
    _showAlert(
      message: message,
      type: AlertType.success,
      duration: duration,
      context: context,
    );
  }

  static void showError({
    required String message,
    Duration duration = const Duration(seconds: 4),
    BuildContext? context,
  }) {
    _showAlert(
      message: message,
      type: AlertType.error,
      duration: duration,
      context: context,
    );
  }

  static void showWarning({
    required String message,
    Duration duration = const Duration(seconds: 3),
    BuildContext? context,
  }) {
    _showAlert(
      message: message,
      type: AlertType.warning,
      duration: duration,
      context: context,
    );
  }

  static void _showAlert({
    required String message,
    required AlertType type,
    required Duration duration,
    BuildContext? context,
  }) {
    // تأخير التنفيذ حتى تصبح الشجرة جاهزة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // استخدام context من navigatorKey إذا كان context المقدم null
      final ctx = context ?? navigatorKey.currentContext;
      if (ctx == null) return;

      // التحقق مما إذا كان context صالحًا
      if (!ctx.mounted) return;

      final theme = Theme.of(ctx);
      Color backgroundColor;
      Color textColor;
      IconData icon;

      switch (type) {
        case AlertType.success:
          backgroundColor = Colors.green.shade600;
          textColor = Colors.white;
          icon = Icons.check_circle;
          break;
        case AlertType.error:
          backgroundColor = theme.colorScheme.error;
          textColor = theme.colorScheme.onError;
          icon = Icons.error;
          break;
        case AlertType.warning:
          backgroundColor = Colors.orange.shade600;
          textColor = Colors.white;
          icon = Icons.warning;
          break;
      }

      final overlay = Overlay.of(ctx);
      if (overlay == null) return;

      final overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          top: MediaQuery.of(context).viewInsets.top + 50,
          left: 20,
          right: 20,
          child: Material(
            color: Colors.transparent,
            child: AnimatedAlertCard(
              backgroundColor: backgroundColor,
              textColor: textColor,
              icon: icon,
              message: message,
              duration: duration,
            ),
          ),
        ),
      );

      overlay.insert(overlayEntry);
      Future.delayed(duration, () {
        if (overlayEntry.mounted) {
          overlayEntry.remove();
        }
      });
    });
  }
}

enum AlertType { success, error, warning }