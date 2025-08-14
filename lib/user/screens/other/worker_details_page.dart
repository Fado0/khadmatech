/// ==============================
///  تم إنشاء وتعديل الصفحة بواسطة الفريق التالي:
/// 
/// شهد العتيبي : 
/// - انشاء الصفحة الاولية لل
/// - البطاقة تحتوي على (الصورة ، الاسم، نوع الخدمة، الجنسية ، الاجر بالساعة، عدد الطلبات، الشركة )
/// - بطاقة التقييم (تحتوي عل النجوم و متوسط التقييم للعامل)
/// - زر احجز الان
/// - تفعيل الوضع الداكن 
///
/// فاطمة اليامي:
/// - تصميم صفحة تفاصيل العامل.
/// - تنسيق الواجهة العامة، البطاقات، والأزرار.
/// - عرض معلومات العامل بطريقة منسقة.
/// - تصميم مكون تقييم النجوم.
/// - التاكد من تشغيل الوضع الداكن في البطاقات و النصوص
///
/// فاضلة الهاجري:
/// - ربط الصفحة بقاعدة بيانات Firestore.
/// - جلب بيانات العامل من مجموعة Workers.
/// - تمرير البيانات إلى صفحة BookingPage.
/// ==============================
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../widgets/client_background.dart';
import '../other/booking_page.dart';
import '../../widgets/custom_button.dart';

class WorkerDetailsPage extends StatelessWidget {
  final String userId;
  final Map<String, dynamic> userData;
  final String workerId;

  const WorkerDetailsPage({
    super.key,
    required this.workerId,
    required this.userId,
    required this.userData,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            const ClientBackground(),
            SafeArea(
              child: FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('Workers')
                    .doc(workerId)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(tr('worker_details.error_loading')),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return Center(child: Text(tr('worker_details.not_found')));
                  }

                  final worker = snapshot.data!.data() as Map<String, dynamic>;
                  final String imageUrl =
                      worker['imageUrl'] ??
                      'https://via.placeholder.com/150.png?text=صورة+العامل';

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.black,
                              size: 22,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(height: 10),
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(imageUrl),
                          backgroundColor: Colors.grey[300],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          worker['name'] ?? tr('worker_details.unknown'),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 25),
                        _buildCard(
                          children: [
                            _infoRow(
                              tr('worker_details.service_type'),
                              worker['type'] ?? tr('worker_details.unknown'),
                            ),
                            _infoRow(
                              tr('worker_details.nationality'),
                              worker['nationality'] ??
                                  tr('worker_details.unknown'),
                            ),
                            _infoRow(
                              tr('worker_details.hourly_rate'),
                              '${worker['charge_per_hour'] ?? tr('worker_details.unknown')} ${tr('worker_details.currency')}',
                            ),
                            _infoRow(
                              tr('worker_details.requests_done'),
                              '${worker['number_of_requests_performed'] ?? 0} ${tr('worker_details.requests')}',
                            ),
                            _infoRow(
                              tr('worker_details.company'),
                              worker['working_company'] ??
                                  tr('worker_details.unknown'),
                            ),
                          ],
                        ),
                        _buildCard(
                          children: [
                            Text(
                              tr('worker_details.rating'),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: List.generate(5, (i) {
                                return Icon(
                                  i < (worker['ratings'] ?? 0).round()
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                );
                              }),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${tr('worker_details.average_rating')}: ${(worker['ratings'] ?? 0).toStringAsFixed(1)}/5',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            text: tr('worker_details.book_now'),
                            icon: Icons.calendar_today,
                            onPressed: () async {
                              final userSnapshot = await FirebaseFirestore
                                  .instance
                                  .collection('Users')
                                  .doc(userId)
                                  .get();

                              final updatedUserData = userSnapshot.data() ?? {};

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BookingPage(
                                    worker: worker,
                                    userId: userId,
                                    userData: updatedUserData,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }
}
