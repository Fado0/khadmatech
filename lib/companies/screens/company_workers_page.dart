/// ==============================
/// 🛠️ تم إنشاء الصفحة بواسطة الفريق التالي:
///
///  فاضله الهاجري:
/// - ربط الصفحة بقاعدة بيانات Firestore.
/// - جلب اسم الشركة من جدول `Users` باستخدام UID الحالي.
/// - تحميل وعرض قائمة العمال المرتبطين بالشركة من مجموعة `Workers`.
/// - دعم حذف العامل من قاعدة البيانات مع تأكيد المستخدم.
/// - تمرير معرف العامل لصفحة التفاصيل `WorkerDetailsPage`.
///
/// فاطمة اليامي
///- (الاسم, الوظيفة، رقم الجوال) وضع بطاقات تحتوي على المعلومات المهمه للعميل
///- توحيد الخلفية لواجهات الشركات
///- زر اضافة عامل جديد
///- دعم الترجمة في الصفحة
/// ==============================
library;

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../widgets/company_background.dart';
import '../../auth/uid_provider.dart';
import 'worker_details_page.dart';
import 'dart:convert';

class CompanyWorkersPage extends StatefulWidget {
  const CompanyWorkersPage({super.key});

  @override
  State<CompanyWorkersPage> createState() => _CompanyWorkersPageState();
}

class _CompanyWorkersPageState extends State<CompanyWorkersPage> {
  Future<String?> _fetchCompanyName(BuildContext context) async {
    final uid = Provider.of<UIDProvider>(context, listen: false).uid;
    if (uid == null) return null;

    final snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .get();
    if (snapshot.exists) {
      return snapshot.data()?['name'];
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> _fetchCompanyWorkers(
    String companyName,
  ) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Workers')
        .where('working_company', isEqualTo: companyName)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const CompanyBackground(),
          SafeArea(
            child: FutureBuilder<String?>(
              future: _fetchCompanyName(context),
              builder: (context, companySnapshot) {
                if (companySnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final companyName = companySnapshot.data;
                if (companyName == null) {
                  return Center(
                    child: Text(tr('workers_page.company_not_found')),
                  );
                }

                return FutureBuilder<List<Map<String, dynamic>>>(
                  future: _fetchCompanyWorkers(companyName),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final workers = snapshot.data ?? [];

                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tr('workers_page.workers_title'),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: workers.isEmpty
                                ? Center(
                                    child: Text(tr('workers_page.no_workers')),
                                  )
                                : ListView.builder(
                                    itemCount: workers.length,
                                    itemBuilder: (context, index) {
                                      final worker = workers[index];
                                      final image = worker['image'];
                                      Widget imageWidget;

                                      if (image != null &&
                                          image.toString().startsWith(
                                            'data:image',
                                          )) {
                                        try {
                                          final base64Str = image
                                              .toString()
                                              .split(',')
                                              .last;
                                          final imageBytes = base64Decode(
                                            base64Str,
                                          );
                                          imageWidget = Image.memory(
                                            imageBytes,
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                          );
                                        } catch (e) {
                                          imageWidget = const Icon(
                                            Icons.person,
                                            size: 60,
                                            color: Colors.grey,
                                          );
                                        }
                                      } else {
                                        imageWidget = Image.network(
                                          image ??
                                              'https://via.placeholder.com/100',
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return const Icon(
                                                  Icons.person,
                                                  size: 60,
                                                  color: Colors.grey,
                                                );
                                              },
                                        );
                                      }

                                      return Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    WorkerDetailsPage(
                                                      workerId: worker['id'],
                                                    ),
                                              ),
                                            );
                                          },
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: imageWidget,
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        worker['name'] ?? '',
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        '${tr('workers_page.job_title')}: ${worker['type'] ?? ''}',
                                                      ),
                                                      Text(
                                                        '${tr('workers_page.phone_number')}: ${worker['phone'] ?? ''}',
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.close,
                                                    color: Colors.red,
                                                  ),
                                                  onPressed: () async {
                                                    final confirm = await showDialog<bool>(
                                                      context: context,
                                                      builder: (_) => AlertDialog(
                                                        title: Text(
                                                          tr(
                                                            'workers_page.confirm_delete_title',
                                                          ),
                                                        ),
                                                        content: Text(
                                                          tr(
                                                            'workers_page.confirm_delete_message',
                                                          ),
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                  context,
                                                                  false,
                                                                ),
                                                            child: Text(
                                                              tr(
                                                                'workers_page.cancel',
                                                              ),
                                                            ),
                                                          ),
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                  context,
                                                                  true,
                                                                ),
                                                            child: Text(
                                                              tr(
                                                                'workers_page.delete',
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );

                                                    if (confirm == true) {
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection('Workers')
                                                          .doc(worker['id'])
                                                          .delete();

                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            tr(
                                                              'workers_page.deleted_successfully',
                                                            ),
                                                          ),
                                                        ),
                                                      );

                                                      setState(
                                                        () {},
                                                      ); // لإعادة تحميل القائمة
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(context, '/add_worker');
                              },
                              icon: const Icon(Icons.add),
                              label: Text(tr('workers_page.add_worker')),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00695C),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
