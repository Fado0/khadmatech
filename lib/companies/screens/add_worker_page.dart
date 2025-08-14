/// ==============================
/// 🛠️ تم إنشاء الصفحة بواسطة الفريق التالي:
/// 
///  فاطمة اليامي:
/// - تصميم واجهة "إضافة عامل جديد".
/// - استخدام خلفية مخصصة للشركات: `CompanyBackground`.
/// - إضافة نموذج يحتوي على الحقول: الاسم، البريد، رقم الإقامة، الموقع، رقم الجوال، نوع الخدمة، السعر بالساعة.
/// - دعم الترجمة باستخدام مكتبة `easy_localization` ضمن قسم `add_worker_page`.
/// - استخدام `Directionality` لتغيير اتجاه الصفحة بناءً على اللغة المختارة.
/// - عرض رسالة تأكيد (نجاح) بعد إضافة العامل.
///
///  فاضله الهاجري:
/// - ربط النموذج بقاعدة بيانات Firestore.
/// - توليد UID مخصص لكل عامل جديد باستخدام مجموعة `Counters`.
/// - جلب اسم الشركة تلقائيًا من جدول `Users` بناءً على UID المستخدم.
/// - حفظ بيانات العامل في مجموعة `Workers` مع الحقول: UID مخصص، اسم الشركة، عدد الطلبات، التقييم.
/// ==============================
library;

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../widgets/company_background.dart';
import '../../auth/uid_provider.dart';

class AddWorkerPage extends StatefulWidget {
  const AddWorkerPage({super.key});

  @override
  State<AddWorkerPage> createState() => _AddWorkerPageState();
}

class _AddWorkerPageState extends State<AddWorkerPage> {
  final _formKey = GlobalKey<FormState>();

  final Map<String, dynamic> _worker = {
    'name': '',
    'email': '',
    'iqama': '',
    'location': '',
    'phone': '',
    'type': '',
    'charge_per_hour': '',
  };

  Future<String> _generateCustomUID() async {
    final counterRef = FirebaseFirestore.instance
        .collection('Counters')
        .doc('عامل');
    final counterDoc = await counterRef.get();
    int last = counterDoc.data()?['last'] ?? 2002;
    int next = last + 1;
    await counterRef.set({'last': next});
    return next.toString();
  }

  Future<String> _getCompanyName() async {
    try {
      final uid = Provider.of<UIDProvider>(context, listen: false).uid;
      if (uid == null) return 'Unknown Company';

      final doc =
          await FirebaseFirestore.instance.collection('Users').doc(uid).get();

      final name = doc.data()?['name'];
      return name is String ? name : 'Unknown Company';
    } catch (e) {
      print('⚠️ Error fetching company name: $e');
      return 'Unknown Company';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final customUID = await _generateCustomUID();
    final companyName = await _getCompanyName();

    await FirebaseFirestore.instance.collection('Workers').doc(customUID).set({
      'approved': false,
      'name': _worker['name'],
      'email': _worker['email'],
      'iqama': _worker['iqama'],
      'location': _worker['location'],
      'phone': _worker['phone'],
      'type': _worker['type'],
      'charge_per_hour': _worker['charge_per_hour'],
      'customUID': customUID,
      'working_company': companyName,
      'number_of_requests_performed': 0,
      'ratings': 0.0,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${tr('add_worker_page.title')} ${tr('add_worker_page.success')}',
        ),
      ),
    );

    Navigator.pop(context);
  }

  Widget _buildField(String key, String fieldKey) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: tr('add_worker_page.$fieldKey'),
          border: const UnderlineInputBorder(),
        ),
        validator: (val) =>
            val == null || val.isEmpty ? '${tr('add_worker_page.please_enter')} ${tr('add_worker_page.$fieldKey')}' : null,
        onSaved: (val) => _worker[key] = val,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            const CompanyBackground(),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              tr('add_worker_page.title'),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildField('name', 'name'),
                        _buildField('email', 'email'),
                        _buildField('iqama', 'iqama_number'),
                        _buildField('location', 'location'),
                        _buildField('phone', 'phone_number'),
                        Padding(
  padding: const EdgeInsets.symmetric(vertical: 8),
  child: DropdownButtonFormField<String>(
    decoration: InputDecoration(
      labelText: tr('add_worker_page.service_type'),
      border: const UnderlineInputBorder(),
    ),
    value: _worker['type'].isNotEmpty ? _worker['type'] : null,
    items: [
      'سباك',
      'كهربائي',
      'مربية أطفال',
      'عاملة تنظيف',
      'نجار',
      'رش حشرات',
      'تنسيق حدائق',
      'صيانة مكيفات',
      'غسيل سيارات',
      'اصلاح سيارات',
      'رعاية كبار السن',
      'دهان',
    ].map((type) {
      return DropdownMenuItem<String>(
        value: type,
        child: Text(type),
      );
    }).toList(),
    validator: (value) =>
        value == null || value.isEmpty
            ? '${tr('add_worker_page.please_enter')} ${tr('add_worker_page.service_type')}'
            : null,
    onChanged: (value) {
      setState(() {
        _worker['type'] = value!;
      });
    },
    onSaved: (value) => _worker['type'] = value!,
  ),
),

                        _buildField('charge_per_hour', 'hourly_rate'),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00695C),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              tr('add_worker_page.add'),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
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
