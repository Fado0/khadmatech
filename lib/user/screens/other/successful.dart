/// ==============================
/// 🛠️ تم إنشاء وتعديل الصفحة بواسطة الفريق التالي:
/// شهد العتيبي: 
/// تفعيل الوضع الداكن 
///
/// زهراء آل طلاق:
/// - تصميم صفحة نجاح الحجز بالكامل.
/// - تنسيق الرسائل، الأيقونات، الأزرار، والتنقل.
///
/// فاطمة اليامي:
/// - إضافة زر "عرض حجوزاتي" أسفل الرسالة.
/// - توحيد الخلفية مع هوية العميل.
/// - توحيد الألوان والخطوط لتتماشى مع باقي الواجهة.
/// - تفعيل الترجمة للواجهة باستخدام easy_localization.
/// - وضع المحتوى داخل بطاقة لزيادة وضوح الرسالة.
/// ==============================
library;

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../widgets/client_background.dart';
import '../other/UserMainPage.dart';

class BookingSuccessPage extends StatelessWidget {
  final String userId;
  final Map<String, dynamic> userData;

  const BookingSuccessPage({
    super.key,
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
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: Colors.white.withOpacity(0.95),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 40,
                        horizontal: 24,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 100,
                            color: Colors.green[700],
                          ),
                          const SizedBox(height: 30),
                          Text(
                            tr('booking_success.title'),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF36596A),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            tr('booking_success.subtitle'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 40),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => UserMainPage(
                                          userId: userId,
                                          userData: userData,
                                          initialIndex: 0,
                                        ),
                                      ),
                                      (route) => false,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF36596A),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    tr('booking_success.home'),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => UserMainPage(
                                          userId: userId,
                                          userData: userData,
                                          initialIndex: 1,
                                        ),
                                      ),
                                      (route) => false,
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: Color(0xFF36596A),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    tr('booking_success.view_bookings'),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Color(0xFF36596A),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
