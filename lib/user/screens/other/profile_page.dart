/// ==============================
/// 🛠️ تم إنشاء وتعديل الصفحة بواسطة الفريق التالي:
///
/// شهد العتيبي:
/// - انشاء الصفحة.
/// - إضافة صورة البروفايل.
/// - تسجيل الخروج ، الاعدادات ، عرض الاسم، البريد الإلكتروني، ورقم الجوال.
/// - تفعيل الوضع الداكن
///
/// زهراء آل طلاق:
/// - إضافة عناصر ما بعد البطاقة:  سياسة الخصوصية، الدعم الفني.
///
/// فاطمة اليامي:
/// - إعادة تصميم الصفحة بالكامل داخل بطاقة منسقة.
/// - إضافة زر تغيير اللغة.
/// - إضافة عناصر جديدة مثل: عن التطبيق، التقييم.
/// - تفعيل الترجمة لكامل عناصر الصفحة باستخدام easy_localization.
/// - اضافة زر تغيير الوضع الداكن
///
/// فاضله الهاجري:
/// - ربط الصفحة بقاعدة بيانات Firestore.
/// ==============================

library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../auth/uid_provider.dart';
import '../../../common_pages/terms_page.dart';
import '../../widgets/client_background.dart';
import 'edit_profile_page.dart';
import '../../../common_pages/about_app_page.dart';
import 'faq_page.dart';
import '../../../common_pages/rate_us_page.dart';
import 'support_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../../../theme/theme_notifier.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final uid = Provider.of<UIDProvider>(context, listen: false).uid;
      final snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .get();

      if (snapshot.exists) {
        setState(() {
          userData = snapshot.data();
          _loading = false;
        });
      } else {
        throw 'User not found';
      }
    } catch (e) {
      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء تحميل البيانات: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const ClientBackground(),
          SafeArea(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : userData == null
                ? Center(child: Text(tr('profile.load_error')))
                : _buildProfileContent(context),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context) {
    final uid = Provider.of<UIDProvider>(context, listen: false).uid;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 5),
          Center(
            child: Text(
              tr('profile.title'),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 52, 85, 139),
              ),
            ),
          ),
          const SizedBox(height: 25),
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.person, size: 60, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Column(
              children: [
                Text(
                  userData!['name'] ?? tr('profile.company_name'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  userData!['email'] ?? tr('profile.email'),
                  style: TextStyle(color: Colors.grey[600]),
                ),
                Text(
                  userData!['phone'] ?? tr('profile.phone'),
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          const Divider(thickness: 1.2, color: Colors.grey),
          const SizedBox(height: 25),
          Text(
            tr('profile.more'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          _buildSectionCard([
            _buildTile(
              icon: Icons.edit,
              title: tr('profile.edit_data'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfilePage(
                      name: userData!['name'] ?? '',
                      email: userData!['email'] ?? '',
                      phone: userData!['phone'] ?? '',
                      customUID: uid ?? '',
                    ),
                  ),
                );
              },
            ),
            _divider(),
            _buildTile(
              icon: Icons.info_outline,
              title: tr('profile.about_app'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const AboutAppPage(isCompanyView: false),
                ),
              ),
            ),
            _divider(),
            _buildTile(
              icon: Icons.privacy_tip,
              title: tr('profile.privacy_policy'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TermsPage(isCompanyView: false),
                ),
              ),
            ),
            _divider(),
            _buildTile(
              icon: Icons.support_agent,
              title: tr('profile.support'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SupportPage()),
              ),
            ),
            _divider(),
            _buildTile(
              icon: Icons.help_outline,
              title: tr('profile.faq'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FaqPage()),
              ),
            ),
            _divider(),
            _buildTile(
              icon: Icons.star_rate,
              title: tr('profile.rate_us'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RateUsPage()),
              ),
            ),
            _divider(),
            _buildTile(
              icon: Icons.language,
              title: context.locale.languageCode == 'ar'
                  ? 'English'
                  : 'العربية',
              onTap: () {
                final newLocale = context.locale.languageCode == 'ar'
                    ? const Locale('en')
                    : const Locale('ar');
                context.setLocale(newLocale);
              },
              showArrow: false,
            ),
            _divider(),
            _buildTile(
              icon: Icons.brightness_6_outlined,
              title: context.watch<ThemeNotifier>().isDarkMode
                  ? tr('profile.light_mode')
                  : tr('profile.dark_mode'),
              onTap: () => context.read<ThemeNotifier>().toggleTheme(),
              showArrow: false,
            ),
          ]),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout, color: Colors.white),
              label: Text(
                tr('profile.logout'),
                style: const TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                context.setLocale(const Locale('ar'));
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (_) => false,
                );
              },
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSectionCard(List<Widget> children) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Column(children: children),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = const Color.fromARGB(255, 67, 112, 176),
    bool showArrow = true,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: showArrow
          ? const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey)
          : null,
      onTap: onTap,
    );
  }

  Widget _divider() {
    return const Divider(height: 1, thickness: 0.6);
  }
}
