/// تم إنشاء الملف بواسطة فاطمة اليامي
/// - تصميم شريط التنقل السفلي لواجهة الشركة.
/// - تفعيل الترجمة للعناصر داخل شريط التنقل باستخدام easy_localization.
/// - تم استخدام Builder لإعادة بناء الترجمة عند تغيير اللغة.
/// - مفاتيح الترجمة المستخدمة:
///   • nav_home        → الرئيسية
///   • nav_workers     → العمال
///   • nav_orders      → الطلبات
///   • nav_reviews     → التقييمات
///   • nav_account     → حسابي
library;

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class CompanyNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CompanyNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ نستخدم Builder لإعادة بناء الترجمة عند تغيير اللغة
    return Builder(
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -1),
              ),
            ],
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: const Color(0xFF4B827B),
            unselectedItemColor: Colors.grey,
            currentIndex: currentIndex,
            onTap: onTap,
            type: BottomNavigationBarType.fixed,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
            ),
         items: [
  BottomNavigationBarItem(
    icon: const Icon(Icons.home),
    label: tr('nav.nav_home'),
  ),
  BottomNavigationBarItem(
    icon: const Icon(Icons.group),
    label: tr('nav.nav_workers'),
  ),
  BottomNavigationBarItem(
    icon: const Icon(Icons.star_rate),
    label: tr('nav.nav_reviews'),
  ),
  BottomNavigationBarItem(
    icon: const Icon(Icons.settings),
    label: tr('nav.nav_account'),
  ),
],
  ),
        );
      },
    );
  }
}
