/// تم إنشاء الصفحة بواسطة: فاطمة اليامي
/// - تعرض إشعارات الطلبات مع حالتها.
/// - تم تفعيل الترجمة باستخدام easy_localization.
library;

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> notifications = [
      {'title': 'طلب: تركيب مكيف', 'status': 'جديد'},
      {'title': 'طلب: تنظيف شقة', 'status': 'تم التنفيذ'},
    ];

    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        appBar: AppBar(
          title: Text('notifications'.tr()), // ✅ ترجمة العنوان
          backgroundColor: const Color(0xFF00695C),
        ),
        body: ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final item = notifications[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.notifications),
                title: Text(item['title']!), // ❌ بدون ترجمة
                subtitle: Text(
                  '${'order_status'.tr()}: ${item['status']}',
                ), // ✅ ترجمة العنوان فقط
              ),
            );
          },
        ),
      ),
    );
  }
}
