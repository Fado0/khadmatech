import 'package:flutter/material.dart';
import 'home_page.dart';
import 'MyBookingsPage.dart';
import 'profile_page.dart';
import '../../widgets/navbar.dart';

class UserMainPage extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> userData;
  final int
  initialIndex; // ⭐️ لتحديد الصفحة المبدئية (0: الرئيسية، 1: الحجوزات، 2: حسابي)

  const UserMainPage({
    super.key,
    required this.userId,
    required this.userData,
    this.initialIndex = 0,
  });

  @override
  State<UserMainPage> createState() => _UserMainPageState();
}

class _UserMainPageState extends State<UserMainPage> {
  late int _selectedIndex;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;

    _pages = [
      HomePage(userId: widget.userId, userData: widget.userData),
      MyBookingsPage(userId: widget.userId),
      ProfilePage(),
    ];
  }

  void _onTabSelected(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: MyNavbar(
        selectedIndex: _selectedIndex,
        onTabSelected: _onTabSelected,
      ),
    );
  }
}
