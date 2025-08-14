/// ==============================
/// 🛠️ تم إنشاء الصفحة بواسطة الفريق التالي:
///
///  فاضله الهاجري:
/// - ربط الصفحة بقاعدة بيانات Firestore لتحديث حالة الحجز.
/// - حفظ سبب الإلغاء داخل الحجز.
/// - عرض تفاصيل الحجز (العميل، العامل، الشركة، التاريخ، الوقت).
/// ==============================
library;


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../widgets/client_background.dart';
import '../../widgets/custom_button.dart';

class CancelBookingPage extends StatefulWidget {
  final String clientName;
  final String workerName;
  final String companyName;
  final String date;
  final String time;
  final String requestId;

  const CancelBookingPage({
    super.key,
    required this.clientName,
    required this.workerName,
    required this.companyName,
    required this.date,
    required this.time,
    required this.requestId,
  });

  @override
  State<CancelBookingPage> createState() => _CancelBookingPageState();
}

class _CancelBookingPageState extends State<CancelBookingPage> {
  String? selectedReason;
  bool isLoading = false;

  final List<String> reasons = [
    'cancel_reason.change_mind',
    'cancel_reason.found_better',
    'cancel_reason.price_issue',
    'cancel_reason.other',
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        body: Stack(
          children: [
            const ClientBackground(),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            tr('bookings.cancelRequest'),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildInfoCard(tr('bookings.clientName'), widget.clientName),
                      _buildInfoCard(tr('bookings.workerName'), widget.workerName),
                      _buildInfoCard(tr('bookings.companyName'), widget.companyName),
                      _buildInfoCard(tr('bookings.date'), widget.date),
                      _buildInfoCard(tr('bookings.time'), widget.time),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          tr('bookings.cancelReason'),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        value: selectedReason,
                        hint: Text(tr('bookings.selectReason')),
                        items: reasons.map((key) {
                          return DropdownMenuItem(
                            value: key,
                            child: Text(tr(key)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedReason = value;
                          });
                        },
                        validator: (value) => value == null
                            ? tr('bookings.reasonRequired')
                            : null,
                      ),
                      const SizedBox(height: 24),
                      isLoading
                          ? const CircularProgressIndicator()
                          : CustomButton(
                              text: tr('bookings.confirmCancel'),
                              onPressed: _handleCancel,
                              color: Colors.red[600]!,
                              icon: Icons.cancel,
                            ),
                      const SizedBox(height: 12),
                      CustomButton(
                        text: tr('bookings.back'),
                        onPressed: () => Navigator.pop(context),
                        color: Colors.grey[600]!,
                        icon: Icons.arrow_back,
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

  Future<void> _handleCancel() async {
    if (selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('bookings.reasonRequired'))),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(widget.requestId)
          .update({
        'status': 'تم الإلغاء',
        'cancel_reason': tr(selectedReason!),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('bookings.cancelSuccess')))
      );

      Navigator.pop(context); // الرجوع بعد الإلغاء
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('bookings.error'))),
      );
    }
  }

  Widget _buildInfoCard(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text('$title: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
