/// ==============================
/// 🛠️ تم إنشاء الصفحة بواسطة: فاطمة اليامي
///
/// - تصميم الواجهة الرئيسية للشركات.
/// - تضم شريط تنقل سفلي للتنقل بين: لوحة التحكم، العمال، التقييمات، الحساب.
/// - تعتمد على عرض الصفحة المناسبة حسب العنصر المحدد من القائمة.
/// ==============================
library;

import 'package:flutter/material.dart';
import '../widgets/company_navbar.dart';
import 'company_dashboard_content.dart';
import 'company_workers_page.dart';
import 'company_reviews_page.dart';
import 'company_profile_page.dart';

class CompanyMainPage extends StatefulWidget {
  const CompanyMainPage({super.key});

  @override
  State<CompanyMainPage> createState() => _CompanyMainPageState();
}

class _CompanyMainPageState extends State<CompanyMainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    CompanyDashboardContent(),
    CompanyWorkersPage(),
    CompanyReviewsPage(),
    CompanyProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F3),
      body: _pages[_selectedIndex],
      bottomNavigationBar: CompanyNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
