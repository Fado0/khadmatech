/// ==============================
/// 🛠️ تم إنشاء الصفحة بواسطة الفريق التالي:
///
/// فاطمة اليامي:
/// - عرض تفاصيل العامل بشكل منسق.
/// - تفعيل الترجمة باستخدام مكتبة `easy_localization`.
/// - استخدام مفاتيح من قسم `worker_details_page` مثل:
///   • `worker_details_title`, `job_title`, `nationality`, `id_number`, `location`,  
///     `phone`, `email`, `price_per_hour`, `sar`, `requests_count`, `rating`, `status`.
///
///  فاضله الهاجري:
/// - ربط الصفحة بقاعدة بيانات Firestore.
/// - جلب بيانات العامل من مجموعة `Workers` باستخدام `workerId`.
/// - تمرير البيانات للواجهة وعرضها بطريقة ديناميكية.
/// ==============================
library;

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/company_background.dart';
import 'package:easy_localization/easy_localization.dart';

class WorkerDetailsPage extends StatelessWidget {
  final String workerId;

  const WorkerDetailsPage({super.key, required this.workerId});

  Future<Map<String, dynamic>?> fetchWorkerData() async {
    final doc = await FirebaseFirestore.instance.collection('Workers').doc(workerId).get();
    return doc.exists ? doc.data() : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            const CompanyBackground(),
            SafeArea(
              child: FutureBuilder<Map<String, dynamic>?>(
                future: fetchWorkerData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data == null) {
                    return Center(child: Text(tr('worker_details_page.not_found')));
                  }

                  final worker = snapshot.data!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔙 زر الرجوع
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back_ios_new, size: 28),
                        ),
                      ),

                      // 🏷️ العنوان
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          tr('worker_details_page.worker_details_title'),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // 🪪 بطاقة المعلومات
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  worker['name'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // 🖼️ صورة العامل
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: worker['image'] != null
                                      ? Image.network(
                                          worker['image'],
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset(
                                          'assets/Pictures/worker_default.jpeg',
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                const SizedBox(height: 16),

                                _buildDetailRow(tr('worker_details_page.job_title'), worker['type'] ?? ''),
                                _buildDetailRow(tr('worker_details_page.nationality'), worker['nationality'] ?? ''),
                                _buildDetailRow(tr('worker_details_page.id_number'), worker['iqama'] ?? ''),
                                _buildDetailRow(tr('worker_details_page.location'), worker['location'] ?? ''),
                                _buildDetailRow(tr('worker_details_page.phone'), worker['phone'] ?? ''),
                                _buildDetailRow(tr('worker_details_page.email'), worker['email'] ?? ''),
                                _buildDetailRow(
                                  tr('worker_details_page.price_per_hour'),
                                  '${worker['charge_per_hour']} ${tr('worker_details_page.sar')}',
                                ),
                                _buildDetailRow(
                                  tr('worker_details_page.requests_count'),
                                  '${worker['number_of_requests_performed'] ?? 0}',
                                ),
                                const SizedBox(height: 8),
                                _buildRatingRow(worker['ratings']?.toDouble() ?? 0),
                                const SizedBox(height: 4),
                                _buildStatusRow(worker['approved'] ?? ''),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _buildRatingRow(double rating) {
    return Row(
      children: [
        Text('${tr('worker_details_page.rating')}:', style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Text(rating.toString()),
        const SizedBox(width: 4),
        const Icon(Icons.star, color: Colors.amber, size: 20),
      ],
    );
  }

Widget _buildStatusRow(bool status) {
  final translatedStatus = status
      ? tr('worker_details_page.status_accepted')   // ✅
      : tr('worker_details_page.status_pending');   // ⏳

  final statusColor = status ? Colors.green : Colors.deepOrange;
  final statusIcon = status ? Icons.check_circle : Icons.hourglass_bottom;

  return Row(
    children: [
      Text(
        '${tr('worker_details_page.status')}:',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      const SizedBox(width: 8),
      Text(translatedStatus, style: TextStyle(color: statusColor)),
      const SizedBox(width: 4),
      Icon(statusIcon, size: 18, color: statusColor),
    ],
  );
}

}
