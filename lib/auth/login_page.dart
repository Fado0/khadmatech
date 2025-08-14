/// ------------------------------
// تم انشاء الصفحة بواسطة : شهد العتيبي (النموذج الأ,لي للصفحة)
///
///فاطمة اليامي :
/// تصميم الواجهه و تنسيق العناصر في الصفحه | توحيد الخلفية
///
/// أميرة الخالدي:
/// - ربط منطق تسجيل الدخول بـ Firebase Auth.
/// - جلب بيانات المستخدم من Firestore بناءً على البريد الإلكتروني.
/// ------------------------------
library;

import 'uid_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'register_page.dart';
import 'forgot_password_page.dart';
import '../user/widgets/client_background.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _notFound = false;
  String _userRole = "";

  String getUserRole(String email) {
    if (!email.contains('@')) return '';
    String domain = email.split('@').last.toLowerCase();
    if (domain == "company.com") return "شركة";
    if (domain == "eamana.gov.sa") return "موظف الأمانة";
    return "عميل";
  }

  Future<void> _login() async {
    setState(() {
      _notFound = false;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      // تسجيل الدخول باستخدام Firebase Auth
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // جلب بيانات المستخدم من Firestore
      final query = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        setState(() => _notFound = true);
        return;
      }

      final doc = query.docs.first;
      final customUID = doc['UID'];
      final role = doc['role'] ?? '';

      Provider.of<UIDProvider>(context, listen: false).setUID(customUID);

      // التوجيه
      if (email.endsWith('@eamana.gov.sa') || role == 'مشرف الأمانة') {
        Navigator.pushReplacementNamed(context, '/admin_dashboard');
      } else if (email.endsWith('@company.com') || role == 'شركة') {
        Navigator.pushReplacementNamed(context, '/company_dashboard');
      } else {
        Navigator.pushReplacementNamed(
          context,
          '/home_page',
          arguments: {
            'userId': customUID,
            'userData': {'name': doc['name'] ?? '', 'email': email},
          },
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _notFound = true);
      debugPrint("Firebase Error: ${e.message}");
    }
  }

  @override
  void initState() {
    super.initState();
    _emailController.text = '';
    _passwordController.text = '';

    _emailController.addListener(() {
      setState(() {
        _userRole = getUserRole(_emailController.text);
      });
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light(), // ✅ يجبر الصفحة على البقاء بالوضع الفاتح
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              const ClientBackground(), // ✅ خلفية مضافة
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_outline, size: 60, color: Colors.teal),
                        const SizedBox(height: 20),
                        Text(
                          'تسجيل الدخول',
                          style: GoogleFonts.cairo(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_userRole.isNotEmpty)
                          Text(
                            'سيتم الدخول كـ $_userRole',
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              color: Colors.teal,
                            ),
                          ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _emailController,
                          textAlign: TextAlign.right,
                          style: GoogleFonts.cairo(),
                          decoration: InputDecoration(
                            labelText: 'البريد الإلكتروني',
                            labelStyle: GoogleFonts.cairo(),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          textAlign: TextAlign.right,
                          style: GoogleFonts.cairo(),
                          decoration: InputDecoration(
                            labelText: 'كلمة المرور',
                            labelStyle: GoogleFonts.cairo(),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        if (_notFound)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              'بيانات غير صحيحة. حاول مرة أخرى.',
                              style: GoogleFonts.cairo(color: Colors.red),
                            ),
                          ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _login,
                          icon: const Icon(Icons.login),
                          label: Text(
                            'تسجيل الدخول',
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            minimumSize: const Size.fromHeight(48),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RegisterPage(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.person_add),
                              label: Text(
                                'حساب جديد',
                                style: GoogleFonts.cairo(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ForgotPasswordPage(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.lock_reset),
                              label: Text(
                                'نسيت كلمة المرور؟',
                                style: GoogleFonts.cairo(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
