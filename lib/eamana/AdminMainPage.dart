import 'package:flutter/material.dart';
import '../eamana/admin/eamana_dashboard.dart';
import '../eamana/admin/approved_workers_page.dart';
import '../eamana/admin/settings_page.dart';
import '../eamana/widget/admin_navbar.dart';

class AdminMainPage extends StatefulWidget {
  const AdminMainPage({super.key});

  @override
  State<AdminMainPage> createState() => _AdminMainPageState();
}

class _AdminMainPageState extends State<AdminMainPage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = const [
      EamanaDashboardPage(),
      ApprovedWorkersPage(),
      SettingsPage(),
    ];
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _pages[_selectedIndex]),
      bottomNavigationBar: AdminNavbar(
        selectedIndex: _selectedIndex,
        onTabSelected: _onTabSelected,
      ),
    );
  }
}
