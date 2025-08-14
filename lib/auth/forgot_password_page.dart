/// ------------------------------
///  تم إنشاء الصفحة بواسطة: فاطمة اليامي:
/// - توحيد الخلفية في صفحة نسيت كلمة المرور
/// - التاكد من صحة الايميل 
///
/// أميرة الخالدي:
/// - ربط منطق الصفحة بـ Firebase Auth لإرسال رابط إعادة تعيين كلمة المرور.
/// - عرض رسائل نجاح أو خطأ بناءً على استجابة Firebase.
/// ------------------------------
library;

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../user/widgets/client_background.dart';
import '../../user/widgets/custom_button.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  final List<String> allowedDomains = [
    'gmail.com',
    'hotmail.com',
    'outlook.com',
    'icloud.com',
    'yahoo.com',
    'live.com',
    'msn.com',
    'mail.com',
    'aol.com',
    'protonmail.com',
    'zoho.com',
    'yandex.com',
    'gmx.com',
    'company.co',
    'eamana.gov.sa',
    'edu.sa',
    'kfupm.edu.sa',
    'iau.edu.sa',
    'moe.gov.sa',
    'gov.sa',
    'stc.com.sa',
    'mobily.com.sa',
    'zain.com.sa',
  ];

  bool _isEmailAllowed(String email) {
    if (!email.contains('@')) return false;
    final domain = email.split('@').last.toLowerCase();
    return allowedDomains.any((allowed) => domain.endsWith(allowed));
  }

  Future<void> _sendResetLink() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();

      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ تم إرسال رابط إعادة تعيين كلمة المرور'),
            backgroundColor: Colors.teal,
          ),
        );

        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'حدث خطأ أثناء إرسال الرابط';

        if (e.code == 'user-not-found') {
          errorMessage = 'هذا البريد غير مسجل في النظام';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'البريد الإلكتروني غير صالح';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ $errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            const ClientBackground(),
            SafeArea(
              child: Column(
                children: [
                  AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    centerTitle: true,
                    title: Text(
                      'نسيت كلمة المرور',
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: const Color(0xFF34558B),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 12),
                            Text(
                              'أدخل بريدك الإلكتروني لإرسال رابط إعادة تعيين كلمة المرور',
                              style: GoogleFonts.cairo(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: _emailController,
                              textAlign: TextAlign.right,
                              style: GoogleFonts.cairo(),
                              decoration: InputDecoration(
                                labelText: 'البريد الإلكتروني',
                                labelStyle: GoogleFonts.cairo(),
                                hintStyle: GoogleFonts.cairo(),
                                prefixIcon: const Icon(Icons.mail_outline),
                                border: const OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'الرجاء إدخال البريد الإلكتروني';
                                }
                                if (!value.contains('@')) {
                                  return 'صيغة البريد غير صحيحة';
                                }
                                if (!_isEmailAllowed(value)) {
                                  return 'البريد غير مسموح. يرجى استخدام بريد رسمي مثل Gmail أو Outlook أو نطاق مسموح';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            CustomButton(
                              text: 'إرسال رابط إعادة التعيين',
                              onPressed: _sendResetLink,
                              icon: Icons.send,
                            ),
                          ],
                        ),
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
