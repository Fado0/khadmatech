/// ==============================
/// 🛠️ تم إنشاء الصفحة بواسطة الفريق التالي:
/// 
/// شهد العتيبي 
/// - اضافة الوضع الداكن 
/// 
/// تم انشاء الصفحة بواسطة فاطمة اليامي :
/// - تحتوي على (الصورة ، اسم العامل، الوظيفة، اسم الشركة، المدينة، الحي، العنوان ، التاريخ، الوقت، الهاتف)
///- التاكد من تشغيل الوضع اداكن في البطاقات و النصوص
///  فاضله الهاجري:
/// - ربط الصفحة بقاعدة البيانات.
/// - جلب بيانات الحجز والعامل ومعالجتها للعرض.
/// ==============================
library;
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../widgets/client_background.dart';

class BookingDetailsPage extends StatelessWidget {
  final Map<String, dynamic> booking;
  final Map<String, dynamic> workerData;

  const BookingDetailsPage({
    super.key,
    required this.booking,
    required this.workerData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final textStyleLabel = theme.textTheme.bodyLarge?.copyWith(
      fontWeight: FontWeight.bold,
      fontSize: 16,
      color: theme.brightness == Brightness.dark
          ? Colors.white
          : const Color(0xFF2B4164),
    );

    final textStyleValue = theme.textTheme.bodyLarge?.copyWith(fontSize: 16);

    // تقسيم العنوان لاستخراج المدينة والحي
    String city = '—';
    String district = '—';
    String address = booking['location'] ?? '—';
    final parts = address.split('-');
    if (parts.length >= 3) {
      city = parts[0].trim();
      district = parts[1].trim();
      address = parts.sublist(2).join('-').trim();
    }

    return Directionality(
      textDirection: Directionality.of(context),
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
                    automaticallyImplyLeading: false, // إلغاء السهم التلقائي
                    leading: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Color(0xFF34558B),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    title: Text(
                      tr('booking_details.title'),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: theme.brightness == Brightness.dark
                            ? Colors.white
                            : const Color(0xFF34558B),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const CircleAvatar(
                            radius: 55,
                            backgroundImage: AssetImage(
                              'assets/Pictures/worker_default.jpeg',
                            ),
                          ),

                          const SizedBox(height: 20),
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            color: theme.cardColor,
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDetail(
                                    tr('booking_details.worker_name'),
                                    workerData['name'] ?? '—',
                                    textStyleLabel!,
                                    textStyleValue!,
                                  ),
                                  _buildDetail(
                                    tr('booking_details.worker_type'),
                                    booking['worker_type'] ??
                                        tr('booking_details.unknown'),
                                    textStyleLabel,
                                    textStyleValue,
                                  ),
                                  _buildDetail(
                                    tr('booking_details.company'),
                                    booking['working_company'] ??
                                        tr('booking_details.unknown'),
                                    textStyleLabel,
                                    textStyleValue,
                                  ),
                                  const Divider(),
                                  _buildDetail(
                                    tr('booking_details.city'),
                                    city,
                                    textStyleLabel,
                                    textStyleValue,
                                  ),
                                  _buildDetail(
                                    tr('booking_details.district'),
                                    district,
                                    textStyleLabel,
                                    textStyleValue,
                                  ),
                                  _buildDetail(
                                    tr('booking_details.address'),
                                    address,
                                    textStyleLabel,
                                    textStyleValue,
                                  ),
                                  const Divider(),
                                  _buildDetail(
                                    tr('booking_details.date'),
                                    booking['date'] ?? '—',
                                    textStyleLabel,
                                    textStyleValue,
                                  ),
                                  _buildDetail(
                                    tr('booking_details.time'),
                                    booking['time'] ?? '—',
                                    textStyleLabel,
                                    textStyleValue,
                                  ),
                                  const Divider(),
                                  _buildDetail(
                                    tr('booking_details.phone'),
                                    workerData['phone'] ??
                                        tr('booking_details.not_available'),
                                    textStyleLabel,
                                    textStyleValue,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildDetail(
    String label,
    String value,
    TextStyle labelStyle,
    TextStyle valueStyle,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: labelStyle),
          Expanded(child: Text(value, style: valueStyle)),
        ],
      ),
    );
  }
}
