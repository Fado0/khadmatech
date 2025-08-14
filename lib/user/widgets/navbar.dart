/// تم تصميم شريط التنقل السفلي بواسطة: زهراء آل طلاق
/// - بناء الهيكل العام لشريط التنقل وتحديد الأيقونات.
///
/// تم تعديل الألوان والتنسيق بواسطة: فاطمة اليامي
/// - تحديد ألوان العناصر المحددة وغير المحددة.
/// - تفعيل الترجمة باستخدام easy_localization وتنسيق المسارات.
library;

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class MyNavbar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;

  const MyNavbar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onTabSelected,
      selectedItemColor: const Color.fromARGB(255, 74, 105, 155),
      unselectedItemColor: Colors.grey,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: tr('navbar.home'), // ← استخدم مسار واضح للترجمة
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.calendar_today),
          label: tr('navbar.bookings'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person),
          label: tr('navbar.profile'),
        ),
      ],
    );
  }
}
