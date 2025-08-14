/// ==============================
/// 🛠️ تم إنشاء الصفحة بواسطة الفريق التالي:
///
///  فاطمة اليامي:
/// - تفعيل الترجمة باستخدام مكتبة `easy_localization`.
/// - استخدام المفاتيح داخل قسم "workers_page" لعرض:
///   • عنوان الصفحة: `workers_title`  
///   • الوظيفة: `job_title`  
///   • رقم الجوال: `phone_number`  
///   • زر "إضافة عامل جديد": `add_worker`
/// - تعديل جميع النصوص الثابتة إلى مفاتيح ترجمة.
/// - الحفاظ على التنسيق والتصميم السابق كما هو.
///
///  فاضله الهاجري:
/// - ربط الصفحة مع Firestore لجلب بيانات الشركة (الاسم، الإيميل، رقم الجوال).
/// - تعبئة الحقول تلقائيًا عند فتح الصفحة.
/// - السماح بتحديث الاسم ورقم الجوال فقط، مع الحفاظ على الإيميل كحقل غير قابل للتعديل.
/// - تنفيذ عملية الحفظ وتحديث البيانات في قاعدة البيانات.
/// ==============================
library;

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../widgets/company_background.dart';
import '../widgets/company_button.dart';
import '../../auth/uid_provider.dart';

class EditCompanyContactPage extends StatefulWidget {
  const EditCompanyContactPage({super.key});

  @override
  State<EditCompanyContactPage> createState() => _EditCompanyContactPageState();
}

class _EditCompanyContactPageState extends State<EditCompanyContactPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchCompanyData();
  }

  Future<void> _fetchCompanyData() async {
    try {
      final uid = Provider.of<UIDProvider>(context, listen: false).uid;
      final snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .get();

      final data = snapshot.data();
      if (data != null) {
        _nameController.text = data['name'] ?? '';
        _emailController.text = data['email'] ?? '';
        _phoneController.text = data['phone'] ?? '';
      }
    } catch (e) {
      print('Error fetching company data: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      final uid = Provider.of<UIDProvider>(context, listen: false).uid;

      await FirebaseFirestore.instance.collection('Users').doc(uid).update({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('changes_saved'.tr())));

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const CompanyBackground(),
          SafeArea(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios,
                                color: Colors.black,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const Spacer(),
                            Text(
                              tr('edit_data'),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00695C),
                              ),
                            ),
                            const Spacer(flex: 2),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // الاسم
                              TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  labelText: tr('company_name'),
                                  prefixIcon: const Icon(Icons.business),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'يرجى إدخال اسم الشركة';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              // الإيميل (ثابت)
                              TextFormField(
                                controller: _emailController,
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: tr('email'),
                                  prefixIcon: const Icon(Icons.email),
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // رقم الجوال
                              TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  labelText: tr('phone'),
                                  prefixIcon: const Icon(Icons.phone),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null ||
                                      value.length != 10 ||
                                      !value.startsWith('05')) {
                                    return 'invalid_phone'.tr();
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 30),

                              CompanyButton(
                                text: tr('save_changes'),
                                onPressed: _saveChanges,
                                fullWidth: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
