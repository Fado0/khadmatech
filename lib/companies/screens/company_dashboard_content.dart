/// ==============================
/// 🛠️ تم إنشاء الصفحة بواسطة الفريق التالي:
/// 
///فاطمة اليامي: 
// -انشاء بطاقة عرض الطلبات تحتوي على عدد الطلبات كاملة 
// -وجود الحالة و عدد الطلبات عند كل حاله
/// دعم الترجمة في الصفحة
library;

///  فاضله الهاجري:
/// // - ربط الواجهة مع قاعدة بيانات Firestore.
/// - جلب اسم الشركة تلقائيًا من جدول `Users` باستخدام UID المسجل.
/// - تحميل الطلبات الخاصة بالشركة من مجموعة `requests`.
/// - دعم الفلترة حسب حالة الطلب باستخدام فلاتر أفقية.
/// - عرض تفاصيل الطلبات (ID، نوع العامل، الموقع، الوقت، العميل، وغيرها).
/// - إتاحة إمكانية تغيير حالة الطلب من الواجهة وتحديثها مباشرة في Firestore.
/// ==============================
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../../auth/uid_provider.dart';
import '../widgets/company_background.dart';
import '../widgets/orders_summary_pie_card.dart';

class CompanyDashboardContent extends StatefulWidget {
  const CompanyDashboardContent({super.key});

  @override
  State<CompanyDashboardContent> createState() => _CompanyDashboardContentState();
}

class _CompanyDashboardContentState extends State<CompanyDashboardContent> {
  String selectedStatusFilter = 'all';

  final Map<String, String> statusFilters = {
    'all': 'filters.all',
    'قيد الانتظار': 'company_dashboard.status_pending',
    'جاري العمل': 'company_dashboard.status_in_progress',
    'مكتمل': 'company_dashboard.status_completed',
    'مرفوض': 'company_dashboard.status_rejected',
    'تم الإلغاء': 'company_dashboard.status_cancelled',
  };

  Future<String?> _fetchCompanyName() async {
    final uid = Provider.of<UIDProvider>(context, listen: false).uid;
    if (uid == null) return null;

    final snapshot =
        await FirebaseFirestore.instance.collection('Users').doc(uid).get();
    if (snapshot.exists) {
      return snapshot.data()?['name'];
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> _fetchRequests(String companyName) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('requests')
        .where('working_company', isEqualTo: companyName)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Future<void> _updateRequestStatus(String docId, String newStatus) async {
    await FirebaseFirestore.instance
        .collection('requests')
        .doc(docId)
        .update({'status': newStatus});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const CompanyBackground(),
        SafeArea(
          child: FutureBuilder<String?>(
            future: _fetchCompanyName(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final companyName = snapshot.data;
              if (companyName == null) {
                return Center(child: Text(tr('company_dashboard.no_company')));
              }

              return FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchRequests(companyName),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final allRequests = snapshot.data ?? [];

                  final filteredRequests = selectedStatusFilter == 'all'
                      ? allRequests
                      : allRequests
                          .where((r) => r['status'] == selectedStatusFilter)
                          .toList();

                  return CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        pinned: true,
                        expandedHeight: 100,
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        flexibleSpace: LayoutBuilder(
                          builder: (context, constraints) {
                            bool isCollapsed = constraints.maxHeight <= kToolbarHeight + 20;

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/Pictures/logo.png',
                                    height: isCollapsed ? 30 : 50,
                                  ),
                                  const Spacer(),
                                  if (!isCollapsed)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          tr('company_dashboard.welcome'),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Theme.of(context).textTheme.bodyLarge?.color,
                                          ),
                                        ),
                                        Text(
                                          companyName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF00695C),
                                          ),
                                        ),
                                      ],
                                    ),
                                  const SizedBox(width: 12),
                                  IconButton(
                                    icon: const Icon(Icons.notifications, color: Colors.black87),
                                    onPressed: () {},
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.support_agent, color: Colors.black87),
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 10),
                              Text(
                                tr('company_dashboard.orders_overview'),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              OrdersSummaryPieCard(requests: allRequests),
                              const SizedBox(height: 20),
                              Text(
                                tr('company_dashboard.company_requests_note'),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 30),

  Text(
                                tr('company_dashboard.company_requests'),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              
                              SizedBox(
                                height: 48,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: statusFilters.length,
                                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                                  itemBuilder: (context, index) {
                                    final key = statusFilters.keys.elementAt(index);
                                    final isSelected = selectedStatusFilter == key;
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() => selectedStatusFilter = key);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: isSelected ? const Color(0xFF0097A7) : Colors.white,
                                          borderRadius: BorderRadius.circular(25),
                                        ),
                                        child: Text(
                                          tr(statusFilters[key]!),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isSelected ? Colors.white : const Color(0xFF2B4164),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),

                              const SizedBox(height: 16),

                          

                              ...filteredRequests.map((data) {
                                String currentStatus = data['status'] ?? '';

                                return StatefulBuilder(
                                  builder: (context, setState) {
                                    return Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('${tr('company_dashboard.order_id')}: ${data['RID']}'),
                                            Text('${tr('company_dashboard.worker_type')}: ${data['worker_type']}'),
                                            Text('${tr('company_dashboard.company')}: ${data['working_company']}'),
                                            Text('${tr('company_dashboard.location')}: ${data['location']}'),
                                            if (data['description'] != null && data['description'].toString().trim().isNotEmpty)
                                              Text('${tr('company_dashboard.description')}: ${data['description']}'),
                                            Text('${tr('company_dashboard.worker_id')}: ${data['WID']}'),
                                            Text('${tr('company_dashboard.client_id')}: ${data['UID']}'),
                                            if (data['date'] != null)
                                              Text('${tr('company_dashboard.date')}: ${data['date']}'),
                                            if (data['time'] != null)
                                              Text('${tr('company_dashboard.time')}: ${data['time']}'),
                                            const SizedBox(height: 10),
                                            Row(
                                              children: [
                                                Text('${tr('company_dashboard.status')}: '),
                                                currentStatus == 'تم الإلغاء'
                                                    ? Text(
                                                        currentStatus,
                                                        style: const TextStyle(
                                                          color: Colors.red,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      )
                                                    : DropdownButton<String>(
                                                        value: currentStatus,
                                                        onChanged: (newValue) async {
                                                          if (newValue != null) {
                                                            setState(() {
                                                              currentStatus = newValue;
                                                            });
                                                            await _updateRequestStatus(data['id'], newValue);
                                                          }
                                                        },
                                                        items: [
                                                          DropdownMenuItem(
                                                            value: 'قيد الانتظار',
                                                            child: Text(tr('company_dashboard.status_pending')),
                                                          ),
                                                          DropdownMenuItem(
                                                            value: 'جاري العمل',
                                                            child: Text(tr('company_dashboard.status_in_progress')),
                                                          ),
                                                          DropdownMenuItem(
                                                            value: 'مكتمل',
                                                            child: Text(tr('company_dashboard.status_completed')),
                                                          ),
                                                          DropdownMenuItem(
                                                            value: 'مرفوض',
                                                            child: Text(tr('company_dashboard.status_rejected')),
                                                          ),
                                                        ],
                                                      ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
