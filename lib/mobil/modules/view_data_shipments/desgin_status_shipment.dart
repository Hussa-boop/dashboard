import 'package:flutter/material.dart';

class ParcelStatusFormatter {
  // دالة للحصول على معلومات الحالة (لون، نص، أيقونة)
  static StatusInfo getStatusInfo(String status) {
    switch (status) {
      case 'تم الالغاء من المرسل':
        return StatusInfo(
          text: 'تم الإلغاء من المرسل',
          color: Colors.red[700]!,
          icon: Icons.cancel,
          backgroundColor: Colors.red[50]!,
            timelineColor:Colors.red.withOpacity(0.6)
        );
      case 'تم الرفض مع الدفع':
        return StatusInfo(
          text: 'تم الرفض مع الدفع',
          color: Colors.orange[800]!,
          icon: Icons.money_off,
          backgroundColor: Colors.orange[50]!,
          timelineColor: Colors.orange.withOpacity(0.6)
        );
      case 'تم الرفض مع سداد جزء':
        return StatusInfo(
          text: 'تم الرفض مع سداد جزء',
          color: Colors.deepOrange[700]!,
          icon: Icons.attach_money,
          backgroundColor: Colors.deepOrange[50]!,
          timelineColor: Colors.deepOrange.withOpacity(0.6)
        );
      case 'تم الرفض ولم يتم الدفع':
        return StatusInfo(
          text: 'تم الرفض - لم يتم الدفع',
          color: Colors.purple[800]!,
          icon: Icons.block,
          backgroundColor: Colors.purple[50]!,
          timelineColor: Colors.purple.withOpacity(0.6)
        );
      case 'تم التأجيل':
        return StatusInfo(
          text: 'تم التأجيل',
          color: Colors.blueGrey[700]!,
          icon: Icons.schedule,
          backgroundColor: Colors.blueGrey[50]!,
          timelineColor: Colors.blueGrey.withOpacity(0.6)
        );
      case 'في مكتب الشحن'||'في المستودع':
        return StatusInfo(
          text: 'في مكتب الشحن',
          color: Colors.blue[800]!,
          icon: Icons.local_shipping,
          backgroundColor: Colors.blue[50]!,
          timelineColor: Colors.blue.withOpacity(0.6)
        );
      case 'في مكتب التسليم':
        return StatusInfo(
          text: 'في مكتب التسليم',
          color: Colors.teal[700]!,
          icon: Icons.store,
          backgroundColor: Colors.teal[50]!,
          timelineColor: Colors.tealAccent.withOpacity(0.6)
        );
      case 'تم التسليم جزئياً':
        return StatusInfo(
          text: 'تم التسليم جزئياً',
          color: Colors.lightGreen[800]!,
          icon: Icons.delivery_dining,
          backgroundColor: Colors.lightGreen[50]!,
          timelineColor: Colors.lightGreen.withOpacity(0.6)
        );
      case 'يتم الشحن':
        return StatusInfo(
          text: 'يتم الشحن',
          color: Colors.indigo[700]!,
          icon: Icons.directions_car,
          backgroundColor: Colors.indigo[50]!,
           timelineColor:  Colors.greenAccent.withOpacity(0.6)
        );
      case 'مستلم'||'تم التسليم':
        return StatusInfo(
          text: 'مستلم بالكامل',
          color: Colors.green[800]!,
          icon: Icons.check_circle,
          backgroundColor: Colors.green[50]!,
           timelineColor:  Colors.green.withOpacity(0.6)
        );
      case 'مفقود':
        return StatusInfo(
          text: 'مفقود',
          color: Colors.deepPurple[800]!,
          icon: Icons.warning,
          backgroundColor: Colors.deepPurple[50]!,
          timelineColor: Colors.grey.withOpacity(0.6)
        );
      default:
        return StatusInfo(
          text: 'حالة غير معروفة',
          color: Colors.grey[700]!,
          icon: Icons.help,
          backgroundColor: Colors.grey[200]!,
          timelineColor: Colors.amber.withOpacity(0.6)
        );
    }
  }

  // ويدجت لعرض الحالة بشكل جميل
  static Widget buildStatusWidget(String status, {bool withIcon = true}) {
    final info = getStatusInfo(status);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: info.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: info.color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (withIcon) ...[
            Icon(info.icon, size: 18, color: info.color),
            SizedBox(width: 6),
          ],
          Text(
            info.text,
            style: TextStyle(
              color: info.color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ويدجت لعرض الحالة مع تفاصيل إضافية
  static Widget buildDetailedStatusWidget(String status) {
    final info = getStatusInfo(status);

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: info.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(info.icon, size: 24, color: info.color),
              SizedBox(width: 8),
              Text(
                'حالة الشحنة',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            info.text,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: info.color,
            ),
          ),
          SizedBox(height: 8),
          _buildStatusDescription(status),
        ],
      ),
    );
  }

  // وصف نصي لكل حالة
  static Widget _buildStatusDescription(String status) {
    String description;

    switch (status) {
      case 'تم الالغاء من المرسل':
        description = 'تم إلغاء الشحنة من قبل المرسل قبل بدء عملية الشحن';
        break;
      case 'تم الرفض مع الدفع':
        description = 'تم رفض الاستلام مع دفع كامل المبلغ للمرسل';
        break;
      case 'تم الرفض مع سداد جزء':
        description = 'تم رفض الاستلام مع سداد جزء من المبلغ للمرسل';
        break;
      case 'تم الرفض ولم يتم الدفع':
        description = 'تم رفض الاستلام ولم يتم دفع أي مبلغ للمرسل';
        break;
      case 'تم التأجيل':
        description = 'تم تأجيل عملية التسليم لوقت لاحق بناءً على طلب العميل';
        break;
      case 'في مكتب الشحن':
        description = 'الشحنة موجودة في مكتب الشحن وجاري تجهيزها للإرسال';
        break;
      case 'في مكتب التسليم':
        description = 'الشحنة وصلت إلى مكتب التسليم في منطقة المستلم';
        break;
      case 'تم التسليم جزئياً':
        description = 'تم تسليم جزء من الشحنة وسيتم تسليم الباقي لاحقاً';
        break;
      case 'يتم الشحن':
        description = 'الشحنة في طريقها إلى وجهتها النهائية';
        break;
      case 'مستلم':
        description = 'تم تسليم الشحنة بالكامل إلى المستلم';
        break;
      case 'مفقود':
        description = 'الشحنة مفقودة وجاري البحث عنها';
        break;
      default:
        description = 'حالة الشحنة غير معروفة أو غير محددة';
    }

    return Text(
      description,
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey[700],
      ),
    );
  }
}

// نموذج لحفظ معلومات الحالة
class StatusInfo {
  final String text;
  final Color color;
  final IconData icon;
  final Color backgroundColor;
  final Color timelineColor;

  StatusInfo( {
    required this.text,
    required this.color,
    required this.icon,
    required this.backgroundColor, required this.timelineColor,
  });
}