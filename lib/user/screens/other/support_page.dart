/// ==============================
/// 🛠️ تم إنشاء وتعديل الصفحة بواسطة الفريق التالي:
///شهدالعتيبي 
///- تفعيل الوضع الداكن 
/// فاطمة اليامي:
/// - تصميم صفحة الدعم الفني بنفس الخلفية.
/// - إنشاء عنوان الصفحة مع زر الرجوع.
/// - تصميم نموذج البلاغ.
/// - تنسيق البطاقات، الأزرار، والحقول.
/// - استخدام ScrollView لدعم التصفح السلس في مختلف الأجهزة.
///
/// زهراء آل طلاق:
/// - إضافة رابط التواصل عبر واتساب داخل بطاقة خاصة.
/// ==============================
library;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../widgets/client_background.dart';
import 'package:easy_localization/easy_localization.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  Future<void> _openWhatsApp() async {
    final phoneNumber = '966555229836'; // استبدلي برقم الدعم
    final Uri url = Uri.parse('https://wa.me/$phoneNumber');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(tr('support.whatsapp_error'))));
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(tr('support.success'))));
      _formKey.currentState!.reset();
      _nameController.clear();
      _phoneController.clear();
      _emailController.clear();
      _messageController.clear();
    }
  }

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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // ✅ العنوان وزر الرجوع
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          tr('support.title'),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 52, 85, 139),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),

                    // ✅ بطاقة واتساب
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      child: ListTile(
                        leading: const FaIcon(
                          FontAwesomeIcons.whatsapp,
                          color: Colors.green,
                        ),
                        title: Text(tr('support.whatsapp')),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey,
                        ),
                        onTap: _openWhatsApp,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ✅ نموذج البلاغ
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tr('support.report_title'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 15),
                              _buildTextField(
                                _nameController,
                                tr('support.name'),
                                TextInputType.name,
                              ),
                              const SizedBox(height: 12),
                              _buildTextField(
                                _phoneController,
                                tr('support.phone'),
                                TextInputType.phone,
                              ),
                              const SizedBox(height: 12),
                              _buildTextField(
                                _emailController,
                                tr('support.email'),
                                TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _messageController,
                                maxLines: 4,
                                decoration: InputDecoration(
                                  labelText: tr('support.message'),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return tr('support.validation_required');
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _submitForm,
                                  icon: const Icon(Icons.send),
                                  label: Text(tr('support.submit')),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(
                                      255,
                                      72,
                                      95,
                                      123,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
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
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    TextInputType type,
  ) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return tr('support.validation_required');
        }
        return null;
      },
    );
  }
}
