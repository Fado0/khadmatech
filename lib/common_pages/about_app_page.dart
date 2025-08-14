// تم إنشاء هذه الصفحة بواسطة: فاطمة اليامي
// صفحة "عن التطبيق" تعرض معلومات تعريفية عن تطبيق خدمتك، مع تصميم متناسق يستخدم الخلفية الموحدة حسب نوع المستخدم

import 'package:flutter/material.dart';
import '../user/widgets/client_background.dart';
import '/companies/widgets/company_background.dart';

class AboutAppPage extends StatelessWidget {
  final bool? isCompanyView;

  const AboutAppPage({super.key, this.isCompanyView = false});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            (isCompanyView ?? false)
                ? const CompanyBackground()
                : const ClientBackground(),

            SafeArea(
              child: Column(
                children: [
                  // ✅ AppBar مخصص
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
                        const Text(
                          'عن التطبيق',
                          style: TextStyle(
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),

                          // ✅ المحتوى داخل بطاقة
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'تطبيق خدمتك',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF00695C),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'يهدف تطبيق "خدمتك" إلى تسهيل الوصول إلى الخدمات المنزلية والبلدية من خلال منصة موثوقة وسهلة الاستخدام. '
                                    'يمكنك حجز الخدمات، متابعة الطلبات، التواصل مع مقدمي الخدمة، وكل ذلك من خلال تجربة سلسة ومريحة.',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(height: 15),
                                  Text(
                                    'نحن ملتزمون بتقديم تجربة استخدام عالية الجودة تضمن رضا العملاء وراحة المستخدم.',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),
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
