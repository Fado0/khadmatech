///  تم إنشاء  صفحة "الشروط والأحكام" بواسطة: فاطمة اليامي
library;

/// - تدعم العرض الخاص بالشركات والعملاء حسب المتغير isCompanyView.
/// - تعرض نصوص الشروط والأحكام مع تصميم متوافق مع الوضع الليلي.
/// - تستخدم خلفية مخصصة للشركات أو العملاء عند الحاجة.
/// ------------------------------

import 'package:flutter/material.dart';
import '../user/widgets/client_background.dart';
import '../companies/widgets/company_background.dart'; // ← أضف هذا السطر

class TermsPage extends StatelessWidget {
  final bool? isCompanyView;

  const TermsPage({super.key, this.isCompanyView});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // ✅ الخلفية حسب نوع المستخدم أو سادة
            if (isCompanyView == true)
              const CompanyBackground()
            else if (isCompanyView == false)
              const ClientBackground()
            else
              Container(color: const Color(0xFFF5F6FA)),

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
                          color: isDark ? Colors.white : Colors.black87,
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        const Text(
                          'الشروط والأحكام',
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
                          Card(
                            color: isDark ? Colors.grey[850] : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'مرحبًا بك في منصتنا!',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF00695C),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'يرجى قراءة الشروط والأحكام التالية قبل إنشاء الحساب أو استخدام المنصة:',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildBullet(
                                    '1. يجب أن تكون جميع المعلومات المدخلة دقيقة وحديثة.',
                                    theme,
                                    isDark,
                                  ),
                                  _buildBullet(
                                    '2. يُمنع استخدام المنصة لأي نشاط غير قانوني أو مسيء.',
                                    theme,
                                    isDark,
                                  ),
                                  _buildBullet(
                                    '3. المستخدم مسؤول عن الحفاظ على سرية بيانات حسابه.',
                                    theme,
                                    isDark,
                                  ),
                                  _buildBullet(
                                    '4. يحق لإدارة المنصة تعديل الشروط والأحكام في أي وقت دون إشعار مسبق.',
                                    theme,
                                    isDark,
                                  ),
                                  _buildBullet(
                                    '5. يمنع مشاركة الحساب مع أطراف أخرى بدون إذن رسمي.',
                                    theme,
                                    isDark,
                                  ),
                                  _buildBullet(
                                    '6. تحتفظ المنصة بحق تعليق أو حذف الحسابات المخالفة.',
                                    theme,
                                    isDark,
                                  ),
                                  _buildBullet(
                                    '7. يجب احترام جميع المستخدمين وعدم الإساءة لهم داخل المنصة.',
                                    theme,
                                    isDark,
                                  ),
                                  _buildBullet(
                                    '8. بالاستمرار في استخدام المنصة، فأنت توافق ضمنيًا على هذه الشروط.',
                                    theme,
                                    isDark,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'في حال وجود أي استفسار أو شكوى، يرجى التواصل مع الدعم الفني.',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: isDark
                                          ? Colors.grey[300]
                                          : Colors.grey[700],
                                    ),
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

  Widget _buildBullet(String text, ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
    );
  }
}
