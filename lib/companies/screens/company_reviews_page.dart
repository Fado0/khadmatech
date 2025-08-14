/// ==============================
/// 🛠️ تم إنشاء الصفحة بواسطة الفريق التالي:
///فاطمة اليامي
///- التصميم الاولي للصفحة
///- توحيد الخلفية للصفحات
///- تصميم بطاقة حساب متوسط التقييم
///- تصميم بطاقات تقييم العملاء في الاسفل تظهر بعد تقييم العميل للموظف
///- دعم الترجمة في الصفحة
///
///  فاضله الهاجري:
/// - ربط الصفحة بقاعدة بيانات Firestore لجلب اسم الشركة والتقييمات المرتبطة بها.
/// - استخدام `FutureBuilder` لجلب اسم الشركة حسب UID الحالي.
/// - استخدام `StreamBuilder` لعرض التقييمات بشكل مباشر من قاعدة البيانات.
/// - حساب التقييم المتوسط بناءً على بيانات `user_rate`.
/// ==============================
library;
import '../../auth/uid_provider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../widgets/company_background.dart';

class CompanyReviewsPage extends StatelessWidget {
  const CompanyReviewsPage({super.key});

  Future<String?> _getCompanyName(String uid) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .get();
    return userDoc.data()?['name'];
  }

  @override
  Widget build(BuildContext context) {
    final uid = Provider.of<UIDProvider>(context).uid;

    return Stack(
      children: [
        const CompanyBackground(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text(
              'company_reviews.title'.tr(),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00695C),
              ),
            ),
            automaticallyImplyLeading: false,
          ),
          body: uid == null
              ? const Center(child: Text('لم يتم تسجيل الدخول'))
              : FutureBuilder<String?>(
                  future: _getCompanyName(uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data == null) {
                      return const Center(
                        child: Text('لم يتم العثور على اسم الشركة'),
                      );
                    }

                    final companyName = snapshot.data!;
                    final reviewsStream = FirebaseFirestore.instance
                        .collection('requests')
                        .where('working_company', isEqualTo: companyName)
                        .snapshots();

                    return StreamBuilder(
                      stream: reviewsStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Center(
                            child: Text('❌ حدث خطأ أثناء تحميل التقييمات'),
                          );
                        }

                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final reviews = snapshot.data!.docs
                            .where((doc) => doc.data().containsKey('user_rate'))
                            .toList();

                        if (reviews.isEmpty) {
                          return Center(
                            child: Text(
                              'company_reviews.no_reviews'.tr(),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        }

                        double averageRating =
                            reviews
                                .map((doc) => (doc['user_rate'] ?? 0) as num)
                                .fold(0.0, (a, b) => a + b) /
                            reviews.length;

                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'company_reviews.reviews_intro'.tr(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'company_reviews.average_rating'.tr(),
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          averageRating.toStringAsFixed(1),
                                          style: const TextStyle(
                                            fontSize: 34,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(
                                          Icons.star,
                                          color: Colors.orange,
                                          size: 30,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(
                                height: 30,
                                thickness: 1.2,
                                color: Color.fromARGB(80, 0, 0, 0),
                              ),
                              Expanded(
                                child: ListView.separated(
                                  itemCount: reviews.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 10),
                                  itemBuilder: (context, index) {
                                    final review = reviews[index];
                                    final rid = review.id;
                                    final wid = review['WID'] ?? 'غير معروف';

                                    return Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      elevation: 3,
                                      child: Padding(
                                        padding: const EdgeInsets.all(14),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.person,
                                                  color: Colors.grey[600],
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  review['customer_name'] ??
                                                      'مستخدم',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              children: List.generate(
                                                5,
                                                (i) => Icon(
                                                  Icons.star,
                                                  color: i < review['user_rate']
                                                      ? Colors.orange
                                                      : Colors.grey[300],
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              review['user_rate_description'] ??
                                                  '',
                                              style: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              '${'company_reviews.review_date'.tr()} ${review['date'] ?? 'غير متوفر'}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              '🆔 ${'company_reviews.request_id'.tr()}: $rid\n'
                                              '🧰 ${'company_reviews.worker_id'.tr()}: $wid',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
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
    );
  }
}
