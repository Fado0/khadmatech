/// ==============================
/// 🛠️ تم إنشاء الصفحة بواسطة الفريق التالي:
///
///  زهراء آل طلاق:
/// - تصميم أولي، عرض قائمة العمال لصفحة "مربيات الأطفال".
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
import '../../screens/other/worker_details_page.dart';
import '../other/MyBookingsPage.dart';
import '../other/profile_page.dart';

class BabysitterListPage extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> userData;

  const BabysitterListPage({
    super.key,
    required this.userId,
    required this.userData,
  });

  @override
  State<BabysitterListPage> createState() => _BabysitterListPageState();
}

class _BabysitterListPageState extends State<BabysitterListPage> {
  int _selectedIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Widget> get _pages => [
    _buildBabysitterContent(),
    MyBookingsPage(userId: widget.userId),
    ProfilePage(),
  ];

  Widget _buildBabysitterContent() {
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: theme.iconTheme.color,
                  size: 22,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              const Spacer(),
              Text(
                tr('babysitter.title'),
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

        // ✅ جلب البيانات من Firestore
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Workers')
                .where('type', isEqualTo: 'مربية أطفال')
                .where('approved', isEqualTo: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text(tr('babysitter.error')));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs;

              if (docs.isEmpty) {
                return Center(child: Text(tr('babysitter.empty')));
              }

              return ListView.builder(
                itemCount: docs.length,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
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
                      trailing: Icon(
                        Icons.baby_changing_station,
                        size: 36,
                        color: Color.fromARGB(255, 52, 85, 139),
                      ),
                      title: Text(
                        worker['name'] ?? tr('babysitter.no_name'),
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
                              '${tr('babysitter.service')}: ${worker['type']}',
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
                        final workerData =
                            docs[index].data() as Map<String, dynamic>;
                        final customUID =
                            workerData['customUID'] ?? docs[index].id;

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
