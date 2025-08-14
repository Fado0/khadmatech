/// ------------------------------
/// تم انشاء الصفحة بواسطة:  شهد العتيبي
/// - (النموذج الأ,لي للصفحه (الاسم،الايميل ، كلمة السر ،رقم الجوال))
///
///فاطمة اليامي :
///- توحيد الخلفية مثلا كلمة واجهة تسجيل الدخول + نسيت كلمة السر
///- اضافة بعض الحقول و التأكد من صحة كلمة المرور انها مستوفيه للشروط
///- اضافة حقل سياسة المنصة
//
/// أميرة الخالدي:
/// - ربط منطق التسجيل بـ Firebase Auth.
/// - إنشاء المستخدم وتوليد UID مخصص من مجموعة Counters.
/// - تخزين بيانات المستخدم في مجموعة Users.
/// ------------------------------
library;

import 'login_page.dart';
import '../common_pages/terms_page.dart';
import '../user/widgets/client_background.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _roleController = TextEditingController();

  String password = '';
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _acceptedTerms = false;
  bool _showTermsError = false;
  bool _loading = false;
  String? _error;

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

  bool isPasswordSecure(String password) {
    return password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[a-z]')) &&
        password.contains(RegExp(r'[0-9]')) &&
        password.contains(RegExp(r'[!@#\$&*~]')) &&
        password.length >= 8;
  }

  bool isEmailValid(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return false;
    if (email.endsWith('@eamana.gov.sa')) return false;
    return allowedDomains.contains(parts[1]);
  }

  bool isPhoneValid(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');
    return RegExp(r'^05\d{8}$').hasMatch(cleaned);
  }

  String _determineRole(String email) {
    if (email.endsWith('@company.com')) return 'شركة العمالة';
    return 'عميل';
  }

  Future<String> generateCustomUID(String role) async {
    final docKey = role == 'شركة العمالة' ? 'شركة العمالة' : 'عميل';
    final countersRef = FirebaseFirestore.instance
        .collection('Counters')
        .doc(docKey);

    return FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(countersRef);
      int last = snapshot.exists ? snapshot.get('last') as int : 0;
      int next = last + 1;
      transaction.update(countersRef, {'last': next});
      return next.toString();
    });
  }

  Future<void> _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (email.endsWith('@eamana.gov.sa')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'لا يمكن إنشاء حساب لموظف الأمانة من هنا',
            style: GoogleFonts.cairo(),
          ),
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    if (!_acceptedTerms) {
      setState(() => _showTermsError = true);
      return;
    }

    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final role = _determineRole(email);
      final customUID = await generateCustomUID(role);

      await FirebaseFirestore.instance.collection('Users').doc(customUID).set({
        'UID': customUID,
        'email': email,
        'name': name,
        'phone': phone,
        'role': role,
        'approved': role == 'عميل',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم التسجيل بنجاح', style: GoogleFonts.cairo())),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = e.message ?? 'حدث خطأ أثناء التسجيل';
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    _roleController.text = _determineRole(_emailController.text.trim());
    return Theme(
      data: ThemeData.light(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              const ClientBackground(),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Container(
                    width: 500,
                    decoration: BoxDecoration(
                      color: Colors.white,
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
                      children: [
                        _headerTabs(),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                _buildField(
                                  _nameController,
                                  'اسم المستخدم / الشركة',
                                  'مثال: فاطمة اليامي',
                                  Icons.person,
                                ),
                                _buildField(
                                  _emailController,
                                  'البريد الإلكتروني',
                                  'مثال: example@company.com',
                                  Icons.email,
                                  inputType: TextInputType.emailAddress,
                                  onChanged: (_) => setState(() {
                                    _roleController.text = _determineRole(
                                      _emailController.text.trim(),
                                    );
                                  }),
                                ),
                                _buildField(
                                  _phoneController,
                                  'رقم الجوال',
                                  'مثال: 0501234567',
                                  Icons.phone_android,
                                  inputType: TextInputType.phone,
                                ),
                                TextFormField(
                                  controller: _roleController,
                                  readOnly: true,
                                  style: GoogleFonts.cairo(),
                                  decoration: const InputDecoration(
                                    labelText:
                                        'نوع الحساب (يتم تحديده تلقائياً)',
                                    prefixIcon: Icon(Icons.badge),
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildPasswordFields(),
                                const SizedBox(height: 24),
                                _termsSection(),
                                if (_showTermsError)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      right: 12,
                                      bottom: 8,
                                    ),
                                    child: Text(
                                      'يجب الموافقة على الشروط والأحكام',
                                      style: GoogleFonts.cairo(
                                        color: Colors.red,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                _submitButton(),
                              ],
                            ),
                          ),
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

  Widget _headerTabs() {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            ),
            child: Text('تسجيل الدخول', style: GoogleFonts.cairo()),
          ),
        ),
        Expanded(
          child: Container(
            color: const Color(0xFFB2EFE6),
            padding: const EdgeInsets.all(12),
            child: Center(
              child: Text(
                'إنشاء حساب',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    String hint,
    IconData icon, {
    TextInputType inputType = TextInputType.text,
    void Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        onChanged: onChanged,
        style: GoogleFonts.cairo(),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
        ),
        validator: (value) {
          if (controller == _emailController && !isEmailValid(value ?? '')) {
            return 'البريد الإلكتروني غير مدعوم أو خاص بموظف الأمانة';
          }
          if (controller == _phoneController && !isPhoneValid(value ?? '')) {
            return 'رقم الجوال غير صحيح';
          }
          if (value == null || value.isEmpty) return 'هذا الحقل مطلوب';
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordFields() {
    return Column(
      children: [
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          onChanged: (value) => setState(() => password = value),
          style: GoogleFonts.cairo(),
          decoration: InputDecoration(
            labelText: 'كلمة المرور',
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'الرجاء إدخال كلمة المرور';
            }
            if (!isPasswordSecure(value)) {
              return 'كلمة المرور لا تحقق جميع الشروط';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        _buildPasswordRule('8 أحرف أو أكثر', password.length >= 8),
        _buildPasswordRule(
          'حرف كبير (A-Z)',
          password.contains(RegExp(r'[A-Z]')),
        ),
        _buildPasswordRule(
          'حرف صغير (a-z)',
          password.contains(RegExp(r'[a-z]')),
        ),
        _buildPasswordRule('رقم (0-9)', password.contains(RegExp(r'[0-9]'))),
        _buildPasswordRule(
          'رمز خاص (!@#...)',
          password.contains(RegExp(r'[!@#\$&*~]')),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirm,
          style: GoogleFonts.cairo(),
          decoration: InputDecoration(
            labelText: 'تأكيد كلمة المرور',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirm ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'الرجاء تأكيد كلمة المرور';
            }
            if (value != _passwordController.text) {
              return 'كلمتا المرور غير متطابقتين';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordRule(String text, bool isValid) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.cancel,
          color: isValid ? Colors.green : Colors.red,
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.cairo(
            fontSize: 14,
            color: isValid ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _termsSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _acceptedTerms,
          onChanged: (value) => setState(() {
            _acceptedTerms = value ?? false;
            if (_acceptedTerms) _showTermsError = false;
          }),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TermsPage()),
            ),
            child: Text(
              'بالنقر هنا، أوافق على سياسات المنصة',
              style: GoogleFonts.cairo(
                color: Colors.teal,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _submitButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
      child: ElevatedButton(
        onPressed: _loading ? null : _register,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          textStyle: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        child: _loading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text('تسجيل', style: GoogleFonts.cairo()),
      ),
    );
  }
}
