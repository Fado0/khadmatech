//  فاطمة اليامي
/// اضافة الترجمة وتحول اتجاه الخطوط بعد الترجمة
library;


import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class AdminNavbar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;

  const AdminNavbar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onTabSelected,
      selectedItemColor:  Color(0xFF003049), // لون موحّد للأمانة
      unselectedItemColor: Colors.grey,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: tr('admin_nav.requests'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.check_circle),
          label: tr('admin_nav.approved_workers'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.settings),
          label: tr('admin_nav.settings'),
        ),
      ],
    );
  }
}
