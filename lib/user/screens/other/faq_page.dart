/// ==============================
/// 🛠️ تم إنشاء الصفحة بواسطة: فاطمة اليامي
///
/// - تصميم صفحة "الأسئلة الشائعة" مع الحفاظ على الخلفية الموحدة للتطبيق.
/// - إضافة `AppBar` مخصص لعنوان الصفحة.
/// - عرض الأسئلة والإجابات باستخدام بطاقات منسقة (`Card`).
/// - استخدام `SingleChildScrollView` لتسهيل التصفح.
/// - تفعيل الترجمة باستخدام مكتبة `easy_localization`.
/// ==============================
library;

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:khadmatech/user/widgets/client_background.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            const ClientBackground(), // الخلفية الموحّدة

            SafeArea(
              child: Column(
                children: [
                  // AppBar مخصص
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios),
                          color: Colors.black87,
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        Text(
                          'faq.title'.tr(),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF355689),
                          ),
                        ),
                        const Spacer(flex: 2),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Column(
                        children: const [
                          _FaqCard(question: 'faq.q1', answer: 'faq.a1'),
                          _FaqCard(question: 'faq.q2', answer: 'faq.a2'),
                          _FaqCard(question: 'faq.q3', answer: 'faq.a3'),
                          _FaqCard(question: 'faq.q4', answer: 'faq.a4'),
                          _FaqCard(question: 'faq.q5', answer: 'faq.a5'),
                          SizedBox(height: 30),
                        ],
                      ),
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

// ✅ ويدجت البطاقة لكل سؤال وجواب
class _FaqCard extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqCard({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00695C),
              ),
            ),
            const SizedBox(height: 10),
            Text(answer.tr(), style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
