/// /// ==============================
/// 🛠️ تم إنشاء الصفحة بواسطة الفريق التالي:
///
///  فاطمة اليامي:
/// - تصميم واجهة "حساب الشركة" الخاصة بلوحة التحكم.
/// - عرض بيانات الشركة: الاسم، البريد، رقم الجوال، التخصص بشكل منسق.
/// - إضافة قسم "المزيد" يحتوي على: تعديل البيانات، عن التطبيق، سياسة الخصوصية، الدعم الفني، تغيير اللغة، تبديل الوضع الليلي/النهاري، تسجيل الخروج.
/// - تفعيل الترجمة باستخدام مكتبة `easy_localization` وربطها مع قسم `company_profile`.
/// - الحفاظ على الهوية البصرية للخلفية باستخدام `CompanyBackground`.
///
///  فاضله الهاجري:
///  - ربط الصفحة مع قاعدة بيانات Firestore.
/// - إنشاء دالة `fetchCompanyData` لجلب بيانات الشركة (الاسم، البريد، رقم الجوال) باستخدام UID الحالي.
/// - تمرير البيانات وعرضها داخل واجهة `CompanyProfilePage`.
/// ==============================
library;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../widgets/company_background.dart';
import '../../auth/uid_provider.dart';
import '../../common_pages/terms_page.dart';
import '../../common_pages/about_app_page.dart';
import '../../user/screens/other/support_page.dart';
import '../../theme/theme_notifier.dart';
import 'edit_company_contact_page.dart';

class CompanyProfilePage extends StatelessWidget {
  const CompanyProfilePage({super.key});

  Future<Map<String, dynamic>?> _fetchCompanyData(BuildContext context) async {
    final uid = Provider.of<UIDProvider>(context, listen: false).uid;
    if (uid == null) return null;

    final doc = await FirebaseFirestore.instance.collection('Users').doc(uid).get();
    return doc.data();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            const CompanyBackground(),
            SafeArea(
              child: FutureBuilder<Map<String, dynamic>?>(
                future: _fetchCompanyData(context),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final data = snapshot.data;
                  if (data == null) {
                    return Center(child: Text('بيانات الشركة غير متوفرة'));
                  }

                  return _buildProfileContent(context, data);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, Map<String, dynamic> companyData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 5),
          Center(
            child: Text(
              tr('company_profile.company_account'),
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
              child: const Icon(Icons.business, size: 60, color: Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Column(
              children: [
                Text(
                  companyData['name'] ?? '—',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(companyData['email'] ?? '—', style: const TextStyle(color: Colors.grey)),
                Text(companyData['phone'] ?? '—', style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 30),
          const Divider(thickness: 1.2, color: Colors.grey),
          const SizedBox(height: 25),
          Text(
            tr('company_profile.more'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          _buildSectionCard(context, [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.teal),
              title: Text(
                tr('company_profile.edit_data'),
                style: const TextStyle(fontSize: 16),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditCompanyContactPage()),
                );
              },
            ),
            _divider(),
            _buildTile(context, Icons.info_outline, tr('company_profile.about_app'), const AboutAppPage(isCompanyView: true)),
            _divider(),
            _buildTile(context, Icons.privacy_tip, tr('company_profile.privacy_policy'), const TermsPage(isCompanyView: true)),
            _divider(),
            _buildTile(context, Icons.support_agent, tr('company_profile.support'), const SupportPage()),
            _divider(),
            ListTile(
              leading: const Icon(Icons.language, color: Colors.teal),
              title: Text(context.locale.languageCode == 'ar' ? 'English' : 'العربية'),
              onTap: () {
                final newLocale = context.locale.languageCode == 'ar' ? const Locale('en') : const Locale('ar');
                context.setLocale(newLocale);
              },
            ),
            _divider(),
            ListTile(
              leading: const Icon(Icons.brightness_6_outlined, color: Colors.teal),
              title: Text(
                context.watch<ThemeNotifier>().isDarkMode
                    ? tr('company_profile.light_mode')
                    : tr('company_profile.dark_mode'),
              ),
              onTap: () {
                context.read<ThemeNotifier>().toggleTheme();
              },
            ),
          ]),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout, color: Colors.white),
              label: Text(
                tr('company_profile.logout'),
                style: const TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                context.setLocale(const Locale('ar'));
                Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
              },
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, List<Widget> children) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Column(children: children),
    );
  }

  Widget _buildTile(BuildContext context, IconData icon, String title, Widget page) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      leading: Icon(icon, color: Colors.teal),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
    );
  }

  Widget _divider() {
    return const Divider(height: 1, thickness: 0.6);
  }
}
