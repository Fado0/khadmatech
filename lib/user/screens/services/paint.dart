/// ==============================
/// 🛠️ تم إنشاء الصفحة بواسطة الفريق التالي:
///
///  زهراء آل طلاق:
/// - تصميم أولي، عرض قائمة العمال لصفحة " الدهان".
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


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../widgets/client_background.dart';
import '../../widgets/navbar.dart';
import '../../screens/other/worker_details_page.dart';
import '../other/MyBookingsPage.dart';
import '../other/profile_page.dart';

class Painter extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> userData;

  const Painter({super.key, required this.userId, required this.userData});

  @override
  State<Painter> createState() => _PainterState();
}

class _PainterState extends State<Painter> {
  int _selectedIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Widget> get _pages => [
    _buildPainterContent(),
    MyBookingsPage(userId: widget.userId),
    ProfilePage(),
  ];

  Widget _buildPainterContent() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? Colors.grey[900] : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white70 : Colors.grey;
    const iconColor = Color.fromARGB(255, 52, 85, 139);

    return Column(
      children: [
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
                tr('filters.painting'),
                style:  TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Workers')
                .where('type', isEqualTo: 'دهان')
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
                itemCount: docs.length,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                itemBuilder: (context, index) {
                  final worker = docs[index].data() as Map<String, dynamic>;

                  return Card(
                    color: cardColor,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      trailing: const Icon(
                        Icons.format_paint,
                        size: 36,
                        color: iconColor,
                      ),
                      title: Text(
                        worker['name'] ?? tr('electricity.no_name'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${tr('electricity.service')}: ${worker['type']}',
                              style: TextStyle(
                                fontSize: 13,
                                color: subtitleColor,
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
