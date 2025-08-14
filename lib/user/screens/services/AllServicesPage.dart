/// ==============================
/// 🛠️ تم إنشاء الصفحة بواسطة الفريق التالي:
///
///  زهراء آل طلاق:
/// - تصميم أولي، عرض قائمة العمال لصفحة "كل الخدمات".
///
///  فاطمة اليامي:
/// - تحسين التناسق البصري، الألوان، والخلفية الموحدة.
/// - تفعيل الترجمة باستخدام مكتبة `easy_localization`.
///
///  أميرة الخالدي:
/// - ربط البيانات مع قاعدة بيانات Firebase (Firestore).
///
///  شهد العتيبي:
/// - تفعيل الوضع الليلي/النهاري (Dark/Light Mode).
/// ==============================
library;


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../widgets/client_background.dart';
import '../../widgets/navbar.dart';
import '../other/MyBookingsPage.dart';
import '../other/profile_page.dart';
import '../other/worker_details_page.dart';

class AllServicesPage extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> userData;

  const AllServicesPage({
    super.key,
    required this.userId,
    required this.userData,
  });

  @override
  State<AllServicesPage> createState() => _AllServicesPageState();
}

class _AllServicesPageState extends State<AllServicesPage> {
  int _selectedIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Widget> get _pages => [
        _buildServiceList(),
        MyBookingsPage(userId: widget.userId),
        ProfilePage(),
      ];

  Widget _buildServiceList() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // ✅ العنوان
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: isDark ? Colors.white : Colors.black,
                  size: 22,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              const Spacer(),
              Text(
                tr('all_services.title'),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleLarge?.color,
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),

        // ✅ جلب البيانات
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Workers')
                .where('approved', isEqualTo: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text(tr('all_services.error')));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs;

              if (docs.isEmpty) {
                return Center(child: Text(tr('all_services.empty')));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final worker = doc.data() as Map<String, dynamic>;

                  return Card(
                    color: theme.cardColor,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      trailing: const Icon(
                        Icons.home_repair_service_outlined,
                        size: 36,
                        color: Color.fromARGB(255, 52, 85, 139)
                      ),
                      title: Text(
                        worker['name'] ?? 'بدون اسم',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${tr('worker_card.service')}: ${worker['type'] ?? tr('worker_card.unspecified')}',
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.textTheme.bodySmall?.color,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: List.generate(5, (i) {
                                return Icon(
                                  i < (worker['ratings'] ?? 0).round()
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 18,
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        final customUID = worker['customUID'] ?? doc.id;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WorkerDetailsPage(
                              workerId: customUID,
                              userId: widget.userId,
                              userData: widget.userData,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            const ClientBackground(),
            SafeArea(child: _pages[_selectedIndex]),
          ],
        ),
        bottomNavigationBar: MyNavbar(
          selectedIndex: _selectedIndex,
          onTabSelected: _onTabSelected,
        ),
      ),
    );
  }
}
