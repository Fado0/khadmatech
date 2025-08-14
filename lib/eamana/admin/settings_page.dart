/// ------------------------------
/// 🛠️ تم إنشاء الصفحة بواسطة الفريق التالي:
///
/// فاطمة اليامي:
/// - إضافة الترجمة وتحويل اتجاه النصوص حسب اللغة المختارة.
/// - تنسيق التصميم العام للواجهة.
/// - توحيد الألوان والرموز المستخدمة.
///
/// فاضله الهاجري:
/// - ربط الصفحة بقاعدة بيانات Firestore.
/// - جلب بيانات المستخدم (الاسم، البريد، الجوال) باستخدام البريد من FirebaseAuth.
/// - معالجة الحالات الفارغة وإظهار بيانات المستخدم في البطاقة.
/// ------------------------------
library;

import '../admin/admin_edit_profile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import '../../auth/login_page.dart';
import '../widget/emana_background.dart';

import '../../common_pages/about_app_page.dart';
import '../../common_pages/terms_page.dart';
import '../../user/screens/other/support_page.dart';
import '../../theme/theme_notifier.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final currentUser = FirebaseAuth.instance.currentUser;
  bool isLoading = true;

  String name = '';
  String phone = '';
  String email = '';
  String role = 'موظف الأمانة';

  final int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (currentUser == null) return;
    final emailFromAuth = currentUser!.email ?? '';

    try {
      final doc = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: emailFromAuth)
          .limit(1)
          .get();

      if (doc.docs.isNotEmpty) {
        final data = doc.docs.first.data();
        setState(() {
          name = data['name'] ?? '—';
          phone = data['phone'] ?? '—';
          email = emailFromAuth;
          isLoading = false;
        });
      } else {
        setState(() {
          name = 'غير موجود';
          phone = 'غير موجود';
          email = emailFromAuth;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ خطأ في جلب البيانات: $e');
      setState(() => isLoading = false);
    }
  }

  void _copyToClipboard(String label, String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('📋 ${tr('admin_settings.copied')} $label')),
    );
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  Widget _divider() => const Divider(height: 1, thickness: 0.6);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Stack(
      children: [
        const EmanaBackground(),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Center(
                    child: Text(
                      tr('admin_nav.settings'),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00695C),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      child: const Icon(
                        Icons.business,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(email, style: const TextStyle(color: Colors.grey)),
                        Text(
                          '${tr('admin_settings.phone')}: $phone',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        Text(
                          '${tr('admin_settings.role')}: $role',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildSectionCard([
                    _buildTile(
                      Icons.edit,
                      tr('company_profile.edit_data'),
                      const AmanaEditPage(),
                    ),

                    _divider(),
                    _buildTile(
                      Icons.info_outline,
                      tr('company_profile.about_app'),
                      const AboutAppPage(isCompanyView: false),
                    ),
                    _divider(),
                    _buildTile(
                      Icons.privacy_tip,
                      tr('company_profile.privacy_policy'),
                      const TermsPage(isCompanyView: false),
                    ),
                    _divider(),
                    _buildTile(
                      Icons.support_agent,
                      tr('company_profile.support'),
                      const SupportPage(),
                    ),
                    _divider(),
                    ListTile(
                      leading: const Icon(
                        Icons.language,
                        color: Color(0xFF003049),
                      ),
                      title: Text(
                        context.locale.languageCode == 'ar'
                            ? 'English'
                            : 'العربية',
                      ),
                      onTap: () {
                        final newLocale = context.locale.languageCode == 'ar'
                            ? const Locale('en')
                            : const Locale('ar');
                        context.setLocale(newLocale);
                      },
                    ),
                    _divider(),
                    ListTile(
                      leading: const Icon(
                        Icons.brightness_6_outlined,
                        color: Color(0xFF003049),
                      ),
                      title: Text(
                        context.watch<ThemeNotifier>().isDarkMode
                            ? tr('company_profile.light_mode')
                            : tr('company_profile.dark_mode'),
                      ),
                      onTap: () {
                        context.read<ThemeNotifier>().toggleTheme();
                      },
                    ),
                    _divider(),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: Text(
                        tr('admin_settings.logout'),
                        style: const TextStyle(color: Colors.red),
                      ),
                      onTap: _signOut,
                    ),
                  ]),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTile(IconData icon, String title, Widget page) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      leading: Icon(icon, color: Color(0xFF003049)),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
    );
  }

  Widget _buildSectionCard(List<Widget> children) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Column(children: children),
    );
  }
}
