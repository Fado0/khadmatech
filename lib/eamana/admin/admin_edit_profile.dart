/// ------------------------------
/// 🛠️ تم إنشاء الصفحة بواسطة الفريق التالي:
///
/// فاضله الهاجري:
/// - ربط الصفحة بقاعدة بيانات Firestore.
/// - جلب بيانات الشركة من مجموعة Users بناءً على UID.
/// - تحديث بيانات الاسم ورقم الجوال عند الحفظ.
/// - إنشاء الدوال المسؤولة عن التعامل مع البيانات (_fetchCompanyData, _saveChanges).
///
/// فاطمة اليامي:
/// - إضافة الترجمة لجميع العناصر باستخدام easy_localization.
/// - ضبط اتجاه الخطوط والعناصر بعد تغيير اللغة.
/// ------------------------------
library;

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../widget/emana_background.dart';
import '../../auth/uid_provider.dart';

class AmanaEditPage extends StatefulWidget {
  const AmanaEditPage({super.key});

  @override
  State<AmanaEditPage> createState() => _AmanaEditPageState();
}

class _AmanaEditPageState extends State<AmanaEditPage> {
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
          const EmanaBackground(),
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
                              tr('edit_company_contact_page.edit_data'),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF003049),
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
                              TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  labelText: tr('edit_profile.name'),
                                  prefixIcon: const Icon(
                                    Icons.business,
                                    color: Color(0xFF003049),
                                  ),
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
                              TextFormField(
                                controller: _emailController,
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: tr(
                                    'edit_company_contact_page.email',
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.email,
                                    color: Color(0xFF003049),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  labelText: tr(
                                    'edit_company_contact_page.phone',
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.phone,
                                    color: Color(0xFF003049),
                                  ),
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
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _saveChanges,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF003049),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    tr('edit_profile.save'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
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
          ),
        ],
      ),
    );
  }
}
