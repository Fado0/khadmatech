/// ==============================
/// 🛠️ تم إنشاء الصفحة بواسطة الفريق التالي:
///
///  شهد العتيبي:
/// - إنشاء نموذج الحجز الأساسي.
/// - اضافة الوضع الداكن 
library;

///  فاطمة اليامي:
/// - إضافة منطق اختيار المدينة.
/// - ربط الأحياء حسب المدينة المختارة.
/// - التحقق من التواريخ المتاحة وتعطيل الأيام المحجوزة بالكامل.
/// - تفعيل الترجمة باستخدام `easy_localization`.
///
///  فاضله الهاجري:
/// - ربط الصفحة بقاعدة البيانات لحفظ بيانات الحجز.
/// - جلب الأوقات المحجوزة من Firebase للتاريخ المختار.
/// - تمرير بيانات الحجز إلى صفحة الدفع `PaymentPage`.
/// ==============================

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/client_background.dart';
import '../../widgets/custom_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'payment_page.dart';

class BookingPage extends StatefulWidget {
  final Map<String, dynamic> worker;
  final String userId;
  final Map<String, dynamic> userData;

  const BookingPage({
    super.key,
    required this.worker,
    required this.userId,
    required this.userData,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime? selectedDate;
  String? selectedCity;
  String? selectedDistrict;
  String? selectedTime;
  final _addressController = TextEditingController();
  final _detailsController = TextEditingController(); // ✅ Details field
  bool _submitted = false;

  Set<String> bookedTimes = {};
  final Set<String> _fullyBookedDays = {};

  final Map<String, List<String>> cityDistricts = {
    'الخبر': ['العزيزية', 'الثقبة', 'الراكة', 'الخبر الشمالية'],
    'الدمام': ['الريان', 'الشاطئ', 'البادية', 'النخيل'],
    'القطيف': ['سيهات', 'صفوى', 'العوامية', 'تاروت'],
  };

  final List<String> availableTimes = [
    '8:00 ص - 10:00 ص',
    '10:00 ص - 12:00 م',
    '2:00 م - 4:00 م',
    '4:00 م - 6:00 م',
    '8:00 م - 10:00 م',
    '10:00 م - 12:00 ص',
  ];

  String get formattedDate {
    if (selectedDate == null) return tr('booking.not_selected_date');
    return '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    fetchFullyBookedDays();
  }

  Future<void> fetchFullyBookedDays() async {
    final now = DateTime.now();
    final List<DateTime> next30Days = List.generate(
      30,
      (i) => now.add(Duration(days: i)),
    );

    for (var date in next30Days) {
      final isFull = await isDayFullyBooked(date);
      if (isFull) {
        final formatted =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        _fullyBookedDays.add(formatted);
      }
    }

    setState(() {});
  }

  Future<bool> isDayFullyBooked(DateTime date) async {
    final formatted =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    final query = await FirebaseFirestore.instance
        .collection('requests')
        .where(
          'WID',
          isEqualTo: widget.worker['customUID'] ?? widget.worker['id'],
        )
        .where('date', isEqualTo: formatted)
        .get();

    final booked = query.docs.map((doc) => doc['time'] as String).toSet();
    return booked.length >= availableTimes.length;
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
                    children: [
                      _buildHeader(),
                      _buildDropdowns(),
                      _buildAddressField(),
                      _buildDetailsField(), // ✅
                      _buildDatePicker(),
                      _buildTimePicker(),
                      if (_fullyBookedDays.length == 30)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            tr('booking.day_fully_booked'),
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      const SizedBox(height: 30),
                      CustomButton(
                        text: tr('booking.confirm'),
                        icon: Icons.check_circle,
                        onPressed: () {
                          setState(() => _submitted = true);

                          final validForm = _formKey.currentState!.validate();
                          final dateValid = selectedDate != null;
                          final timeValid = selectedTime != null;

                          if (validForm && dateValid && timeValid) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PaymentPage(
                                  worker: widget.worker,
                                  userId: widget.userId,
                                  userData: widget.userData,
                                  city: selectedCity!,
                                  district: selectedDistrict!,
                                  address: _addressController.text,
                                  date: formattedDate,
                                  time: selectedTime!,
                                  details: _detailsController.text.trim(), 
                                ),
                              ),
                            );
                          }
                        },
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          Text(
            tr('booking.title'),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF34558B),
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildDropdowns() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(tr('booking.select_city')),
        DropdownButtonFormField<String>(
          value: selectedCity,
          decoration: _inputDecoration(),
          hint: Text(tr('booking.select_city')),
          items: cityDistricts.keys
              .map((city) => DropdownMenuItem(value: city, child: Text(city)))
              .toList(),
          onChanged: (val) {
            setState(() {
              selectedCity = val;
              selectedDistrict = null;
            });
          },
          validator: (value) =>
              value == null ? tr('booking.validation_city') : null,
        ),
        const SizedBox(height: 16),
        _buildLabel(tr('booking.select_district')),
        DropdownButtonFormField<String>(
          value: selectedDistrict,
          decoration: _inputDecoration(),
          hint: Text(tr('booking.select_district')),
          items: selectedCity == null
              ? []
              : cityDistricts[selectedCity]!
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
          onChanged: (val) => setState(() => selectedDistrict = val),
          validator: (value) =>
              value == null ? tr('booking.validation_district') : null,
        ),
      ],
    );
  }

  Widget _buildAddressField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        _buildLabel(tr('booking.address')),
        TextFormField(
          controller: _addressController,
          decoration: _inputDecoration(hint: tr('booking.address_hint')),
          validator: (value) => value == null || value.isEmpty
              ? tr('booking.validation_address')
              : null,
        ),
      ],
    );
  }

  Widget _buildDetailsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        _buildLabel("details"), // ✅ add key "details" in ar.json
        TextFormField(
          controller: _detailsController,
          decoration: _inputDecoration(hint: tr("booking.details_hint")),
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        _buildLabel(tr('booking.select_date')),
        OutlinedButton.icon(
          icon: const Icon(Icons.calendar_today, color: Color(0xFF34558B)),
          label: Align(
            alignment: Alignment.centerRight,
            child: Text(
              formattedDate,
              style: const TextStyle(
                color: Color(0xFF34558B),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          onPressed: () async {
            final date = await showDatePicker(
              context: context,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 30)),
              initialDate: selectedDate ?? DateTime.now(),
              selectableDayPredicate: (day) {
                final formatted =
                    '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
                return !_fullyBookedDays.contains(formatted);
              },
            );

            if (date != null) {
              setState(() {
                selectedDate = date;
                selectedTime = null;
                bookedTimes.clear();
              });

              final formatted =
                  '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
              final query = await FirebaseFirestore.instance
                  .collection('requests')
                  .where(
                    'WID',
                    isEqualTo:
                        widget.worker['customUID'] ?? widget.worker['id'],
                  )
                  .where('date', isEqualTo: formatted)
                  .get();

              setState(() {
                bookedTimes = query.docs
                    .map((doc) => doc['time'] as String)
                    .toSet();
              });
            }
          },
        ),
        if (_submitted && selectedDate == null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                tr('booking.validation_date'),
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        _buildLabel(tr('booking.select_time')),
        DropdownButtonFormField<String>(
          value: selectedTime,
          decoration: _inputDecoration(hint: tr('booking.select_time')),
          items: availableTimes
              .where((time) => !bookedTimes.contains(time))
              .map((time) => DropdownMenuItem(value: time, child: Text(time)))
              .toList(),
          onChanged: (val) => setState(() => selectedTime = val),
          validator: (value) =>
              value == null ? tr('booking.validation_time') : null,
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
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
}
