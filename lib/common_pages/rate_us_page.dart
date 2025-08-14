/// تم إنشاء الصفحة بواسطة: فاطمة اليامي
/// - تصميم صفحة تقييم المستخدمين بنفس خلفية التطبيق.
/// - إنشاء عنوان مخصص (AppBar يدوي) يحتوي على زر الرجوع.
/// - إنشاء بطاقة تحتوي على شرح لأهمية التقييم وتشجيع المستخدم على التفاعل.
/// - تصميم زر "ابدأ التقييم" مع تنسيق مخصص.
/// - ربط الزر بنموذج Google Form لبدء التقييم باستخدام launchUrl.
/// - استخدام Scaffold + Stack + SafeArea + Scroll لتناسق الواجهة ودعم الأجهزة المختلفة.
///
library;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../user/widgets/client_background.dart';

class RateUsPage extends StatelessWidget {
  const RateUsPage({super.key});

  final String formUrl =
      'https://docs.google.com/forms/d/e/1FAIpQLScWIb_1hehE0p5CCug4H1lNwpiEcZ8IbO5RZgZhvNG_20jo6g/viewform';

  Future<void> _launchRatingForm(BuildContext context) async {
    final Uri url = Uri.parse(formUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تعذر فتح رابط التقييم')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            const ClientBackground(),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // عنوان الصفحة
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        const Text(
                          'قيّمنا',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF355689),
                          ),
                        ),
                        const Spacer(flex: 2),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // بطاقة التقييم
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'مشاركتك تهمنا!',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00695C),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'ساعدنا في تحسين تطبيق خدمتك من خلال تقييم تجربتك ومشاركة اقتراحاتك.',
                              style: TextStyle(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 25),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.star),
                              label: const Text(
                                'ابدأ التقييم',
                                style: TextStyle(fontSize: 16),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  72,
                                  95,
                                  123,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () => _launchRatingForm(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
