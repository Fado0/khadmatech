/// ------------------------------
/// 🛠️ تم إنشاء الصفحة بواسطة الفريق التالي:
///
/// فاطمة اليامي:
/// - توحيد ألوان واجهات موظف الأمانة لتتماشى مع الهوية البصرية.
/// - إضافة التبويبات لعرض العمال المعلقين والمرفوضين.
/// - تحسين التصميم العام وتعديل العناصر البصرية.
/// - تفعيل الترجمة وتغيير اتجاه النصوص تلقائيًا حسب اللغة.
///
/// فاضله الهاجري:
/// - ربط الصفحة بقاعدة بيانات Firestore.
/// - جلب بيانات العمال وتصنيفهم كمعلقين أو مرفوضين.
/// - إنشاء الدوال الخاصة بالموافقة والرفض، وتحديث حالة العامل.
/// - تخزين سبب الرفض وإظهاره في الواجهة.
/// ------------------------------
library;

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import '../widget/emana_background.dart';

class EamanaDashboardPage extends StatefulWidget {
  const EamanaDashboardPage({super.key});

  @override
  State<EamanaDashboardPage> createState() => _EamanaDashboardPageState();
}

class _EamanaDashboardPageState extends State<EamanaDashboardPage> {
  final Color darkBlue = const Color(0xFF003049);

  Future<void> _approveWorker(String docId) async {
    await FirebaseFirestore.instance.collection('Workers').doc(docId).update({
      'approved': true,
      'rejection_reason': null,
    });
  }

  Future<void> _rejectWorker(BuildContext context, String docId) async {
    final reasonController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr('dashboard.rejection_reason')),
        content: TextField(
          controller: reasonController,
          decoration: InputDecoration(labelText: tr('dashboard.enter_reason')),
        ),
        actions: [
          TextButton(
            child: Text(tr('dashboard.cancel')),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text(tr('dashboard.reject')),
            onPressed: () {
              final reason = reasonController.text.trim();
              if (reason.isNotEmpty) Navigator.pop(context, reason);
            },
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await FirebaseFirestore.instance.collection('Workers').doc(docId).update({
        'approved': false,
        'rejection_reason': result,
      });
    }
  }

  Widget _buildWorkerCard(
    Map<String, dynamic> data,
    String docId,
    BuildContext context, {
    bool showActions = true,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: ListTile(
        title: Text(
          data['name'] ?? tr('admin_workers.no_name'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${tr('admin_workers.service')}: ${data['type'] ?? '—'}'),
            Text(
              '${tr('admin_workers.charge')}: ${data['charge_per_hour'] ?? '—'} ${tr('admin_workers.per_hour')}',
            ),
            Text('${tr('admin_workers.iqama')}: ${data['iqama'] ?? '—'}'),
            Text('${tr('admin_workers.phone')}: ${data['phone'] ?? '—'}'),
            if (data['rejection_reason'] != null)
              Text(
                '${tr('dashboard.reason')}: ${data['rejection_reason']}',
                style: const TextStyle(color: Colors.red),
              ),
          ],
        ),
        isThreeLine: true,
        trailing: showActions
            ? Wrap(
                spacing: 8,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () => _approveWorker(docId),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => _rejectWorker(context, docId),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  Widget _buildWorkerList({required bool showRejected}) {
    final workersRef = FirebaseFirestore.instance.collection('Workers');

    return StreamBuilder<QuerySnapshot>(
      stream: workersRef.where('approved', isEqualTo: false).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text(tr('dashboard.load_error')));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final filteredDocs = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final reason = data['rejection_reason'];
          return showRejected
              ? (reason != null && reason.toString().trim().isNotEmpty)
              : (reason == null || reason.toString().trim().isEmpty);
        }).toList();

        if (filteredDocs.isEmpty) {
          return Center(
            child: Text(
              showRejected
                  ? tr('dashboard.no_rejected')
                  : tr('dashboard.no_pending'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.only(top: 10, bottom: 30),
          children: filteredDocs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return _buildWorkerCard(
              data,
              doc.id,
              context,
              showActions: !showRejected,
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            const EmanaBackground(),
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.notifications,
                                color: Color(0xFF003049),
                              ),
                              onPressed: () {},
                            ),
                            Image.asset('assets/Pictures/logo.png', height: 50),
                          ],
                        ),
                      ),
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            tr('dashboard.title'),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF003049),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TabBar(
                    labelColor: darkBlue,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: darkBlue,
                    tabs: [
                      Tab(text: tr('dashboard.pending')),
                      Tab(text: tr('dashboard.rejected')),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildWorkerList(showRejected: false),
                        _buildWorkerList(showRejected: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
