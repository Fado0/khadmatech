///
///شهد العتيبي:
/// - انشاء الصفحة.
/// - تصميم واجهة الدفع.
/// - إنشاء نموذج الدفع لحالتي: الدفع النقدي والدفع بالبطاقة.
/// - ربط زر "تأكيد الحجز" بصفحة النجاح `BookingSuccessPage`.
library;

/// فاطمة اليامي:
/// - تفعيل الترجمة باستخدام easy_localization.
/// - توحيد الخلفية للتناسب مع واجهات العميل 

/// 
/// فاضله الهاجري:
/// - ربط الصفحة بقاعدة بيانات Firestore.
/// - توليد معرف الحجز RID من جدول `Counters`.
/// - حفظ بيانات الحجز في مجموعة `requests`.
/// ==============================

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/client_background.dart';
import '../../widgets/custom_button.dart';
import 'successful.dart';
import 'package:easy_localization/easy_localization.dart';

class PaymentPage extends StatefulWidget {
  final Map<String, dynamic> worker;
  final String userId;
  final Map<String, dynamic> userData;
  final String city;
  final String district;
  final String address;
  final String date;
  final String time;
  final String details;


  const PaymentPage({
    super.key,
    required this.worker,
    required this.userId,
    required this.userData,
    required this.city,
    required this.district,
    required this.address,
    required this.date,
    required this.time,
    required this.details,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String _selectedMethod = 'cash';

  final _cardHolderController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _cvvController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  String? selectedMonth;
  String? selectedYear;

  final List<String> months = List.generate(12, (i) => (i + 1).toString().padLeft(2, '0'));
  final List<String> years = List.generate(10, (i) => (DateTime.now().year + i).toString());

  @override
  void dispose() {
    _cardHolderController.dispose();
    _cardNumberController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<String> generateNextRID() async {
    final counterRef = FirebaseFirestore.instance.collection('Counters').doc('requests');
    final doc = await counterRef.get();
    String current = doc.data()?['last'] ?? 'req00';
    int currentNum = int.parse(current.replaceAll('req', ''));
    String nextRID = 'req${(currentNum + 1).toString().padLeft(2, '0')}';
    await counterRef.update({'last': nextRID});
    return nextRID;
  }

  Future<void> submitBooking() async {
    final newRID = await generateNextRID();
    final fullLocation = '${widget.city} - ${widget.district} - ${widget.address}';

    await FirebaseFirestore.instance.collection('requests').doc(newRID).set({
      'RID': newRID,
      'UID': widget.userId,
      'customer_name': widget.userData['name'] ?? '',
      'customer_phone': widget.userData['phone'] ?? '',
      'WID': widget.worker['customUID'] ?? widget.worker['id'],
      'worker_name': widget.worker['name'],
      'worker_phone': widget.worker['phone'],
       'description': widget.details.trim(),
      'location': fullLocation,
      'status': 'قيد الانتظار',
      'worker_type': widget.worker['type'],
      'working_company': widget.worker['working_company'],
      'date': widget.date,
      'time': widget.time,
    });
  }

  void _handleSubmit() async {
    if (_selectedMethod == 'card') {
      if (_formKey.currentState!.validate()) {
        await submitBooking();
        _goToSuccess();
      }
    } else {
      await submitBooking();
      _goToSuccess();
    }
  }

  void _goToSuccess() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => BookingSuccessPage(
          userId: widget.userId,
          userData: widget.userData,
        ),
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
            const ClientBackground(),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 40),
                      _buildPaymentOptions(),
                      if (_selectedMethod == 'card') _buildCardForm(),
                      const SizedBox(height: 30),
                      CustomButton(
                        text: tr('payment.confirm_booking'),
                        icon: Icons.payment,
                        onPressed: _handleSubmit,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        const Spacer(),
        Text(
          tr('payment.title'),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF34558B)),
        ),
        const Spacer(flex: 2),
      ],
    );
  }

  Widget _buildPaymentOptions() {
    return Column(
      children: [
        RadioListTile<String>(
          title: Text(tr('payment.cash')),
          value: 'cash',
          groupValue: _selectedMethod,
          onChanged: (value) => setState(() => _selectedMethod = value!),
        ),
        RadioListTile<String>(
          title: Text(tr('payment.card')),
          value: 'card',
          groupValue: _selectedMethod,
          onChanged: (value) => setState(() => _selectedMethod = value!),
        ),
      ],
    );
  }

  Widget _buildCardForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        _buildLabel(tr('payment.card_name')),
        TextFormField(
          controller: _cardHolderController,
          decoration: _inputDecoration(),
          validator: (value) =>
              value == null || value.isEmpty ? tr('payment.validation_name') : null,
        ),
        const SizedBox(height: 16),
        _buildLabel(tr('payment.card_number')),
        TextFormField(
          controller: _cardNumberController,
          keyboardType: TextInputType.number,
          maxLength: 16,
          decoration: _inputDecoration(hint: tr('payment.card_number_hint')),
          validator: (value) {
            if (value == null || value.isEmpty) return tr('payment.validation_card');
            if (value.length != 16) return tr('payment.validation_card_length');
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildLabel(tr('payment.cvv')),
        TextFormField(
          controller: _cvvController,
          keyboardType: TextInputType.number,
          maxLength: 3,
          decoration: _inputDecoration(hint: tr('payment.cvv_hint')),
          validator: (value) =>
              value == null || value.length < 3 ? tr('payment.validation_cvv') : null,
        ),
        const SizedBox(height: 16),
        _buildLabel(tr('payment.expiry')),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: selectedMonth,
                hint: Text(tr('payment.month')),
                decoration: _inputDecoration(),
                items: months.map((month) => DropdownMenuItem(value: month, child: Text(month))).toList(),
                onChanged: (val) => setState(() => selectedMonth = val),
                validator: (value) => value == null ? tr('payment.validation_month') : null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: selectedYear,
                hint: Text(tr('payment.year')),
                decoration: _inputDecoration(),
                items: years.map((year) => DropdownMenuItem(value: year, child: Text(year))).toList(),
                onChanged: (val) => setState(() => selectedYear = val),
                validator: (value) => value == null ? tr('payment.validation_year') : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF34558B)),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }
}
