import 'package:flutter/material.dart';

class NotificationWidgets {
  // Вспомогательные виджеты для уведомлений
  static Widget notificationTile({
    required String title,
    required String body,
    required DateTime timestamp,
    VoidCallback? onTap,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(body),
      trailing: Text(
        '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      onTap: onTap,
    );
  }
}
