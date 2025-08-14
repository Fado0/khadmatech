/// ==============================
/// 🛠️ تم إنشاء وتعديل الصفحة بواسطة الفريق التالي:
///
///شهد العتيبي :
///-  انشاء الصفحة النوذج الاولي للصفحة
///- تفعيل  الوضع الداكن للتطبيق
///- اضافة الفلتر(قيد الانتظار، جاري العمل، مكتمل، ملغي، مرفوض ) في اعلى الصفحة
///- بطاقات الحجز تحتوي على معلومات العميل المختصره (الاسم ، نوع الخدمة ، الموقع، رقم الجوال، الحالة )
///
///  فاطمة اليامي:
/// - تصميم واجهة عرض الحجوزات.
/// - تصميم الفلاتر وتنسيق الحالات.
/// - تخصيص الألوان والأيقونات لكل حالة.
/// - ربط التنقل إلى صفحة تفاصيل الحجز `BookingDetailsPage`.
/// - ربط زر "إلغاء" بصفحة `CancelBookingPage`.
///
///  فاضله الهاجري:
/// - ربط الصفحة بقاعدة بيانات Firestore.
/// - جلب بيانات الحجوزات من مجموعة `requests` للمستخدم الحالي.
/// - تصفية الحجوزات حسب الحالة المختارة.
/// - جلب بيانات العامل لكل حجز من مجموعة `Workers`.
/// - تمرير بيانات الحجز والعامل إلى صفحة التفاصيل.
/// - تمرير بيانات الحجز إلى صفحة الإلغاء.
/// ==============================
library;

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../widgets/client_background.dart';
import '../../widgets/custom_button.dart';
import 'booking_details_page.dart';
import 'cancel_booking_page.dart';

class MyBookingsPage extends StatefulWidget {
  final String userId;

  const MyBookingsPage({super.key, required this.userId});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  String selectedFilter = 'all';

  // 🟡 خريطة ربط الحالات العربية بمفاتيح الترجمة
  final Map<String, String> statusMapping = {
    'قيد الانتظار': 'pending',
    'جاري العمل': 'inProgress',
    'مكتمل': 'completed',
    'تم الإلغاء': 'cancelled',
    'مرفوض': 'rejected',
  };

  final List<String> filterKeys = [
    'all',
    'pending',
    'inProgress',
    'completed',
    'rejected',
    'cancelled',
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
              child: Column(
                children: [
                  AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    centerTitle: true,
                    title: Text(
                      tr('bookings.title'),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF34558B),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFilterChips(),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('requests')
                            .where('UID', isEqualTo: widget.userId)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(child: Text(tr('bookings.error')));
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final docs = snapshot.data!.docs;
                          final allBookings = docs.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            data['RID'] = doc.id;
                            return data;
                          }).toList();

                          final filteredBookings = selectedFilter == 'all'
                              ? allBookings
                              : allBookings
                                    .where(
                                      (b) =>
                                          statusMapping[b['status']] ==
                                          selectedFilter,
                                    )
                                    .toList();

                          if (filteredBookings.isEmpty) {
                            return Center(
                              child: Text(tr('bookings.noBookings')),
                            );
                          }

                          return ListView.builder(
                            itemCount: filteredBookings.length,
                            itemBuilder: (context, index) {
                              return _buildBookingCard(filteredBookings[index]);
                            },
                          );
                        },
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

  Widget _buildFilterChips() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: filterKeys.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filterKeys[index];
          final isSelected = selectedFilter == filter;
          return GestureDetector(
            onTap: () => setState(() => selectedFilter = filter),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0097A7) : Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                tr('bookings.$filter'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : const Color(0xFF2B4164),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('Workers')
          .doc(booking['WID'])
          .get(),
      builder: (context, snapshot) {
        final workerData = snapshot.data?.data() as Map<String, dynamic>?;

        final rawStatus = booking['status'] ?? 'غير معروف';
        final statusKey = 'bookings.${statusMapping[rawStatus] ?? 'unknown'}';

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BookingDetailsPage(
                  booking: booking,
                  workerData: workerData ?? {},
                ),
              ),
            );
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workerData?['name'] ?? tr('bookings.notAvailable'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('${tr('bookings.location')}: ${booking['location']}'),
                  Text('${tr('bookings.type')}: ${booking['worker_type']}'),
                  Text(
                    '${tr('bookings.workerPhone')}: ${workerData?['phone'] ?? tr('bookings.notAvailable')}',
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${tr('bookings.status')}: ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Icon(
                        _getStatusIcon(rawStatus),
                        color: _getStatusColor(rawStatus),
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        tr(statusKey),
                        style: TextStyle(
                          color: _getStatusColor(rawStatus),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (rawStatus == 'مرفوض')
                    Text(
                      '${tr('bookings.rejectReason')}: ${booking['reject_reason'] ?? tr('bookings.notAvailable')}',
                    ),
               if (rawStatus == 'مكتمل') ...[
  const SizedBox(height: 10),

  if (booking['user_rate'] == null) // لم يتم التقييم بعد
    CustomButton(
      text: tr('bookings.rateWorker'),
      icon: Icons.star,
      color: Colors.amber[700]!,
      onPressed: () {
        _showRatingDialog(booking['RID']);
      },
    )
  else ...[ // عرض التقييم السابق
    Row(
      children: List.generate(5, (index) {
        return Icon(
          index < (booking['user_rate'] as num).toInt()
              ? Icons.star
              : Icons.star_border,
          color: Colors.amber,
          size: 20,
        );
      }),
    ),
    if ((booking['user_rate_description'] ?? '').toString().isNotEmpty)
      Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
          booking['user_rate_description'],
          style: const TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.black87,
          ),
        ),
      ),
    Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Text(
        tr('bookings.alreadyRated'),
        style: TextStyle(
          color: Colors.grey[700],
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ],
],

                  if (rawStatus == 'قيد الانتظار') ...[
                    const SizedBox(height: 10),
                    CustomButton(
                      text: tr('bookings.cancelRequest'),
                      icon: Icons.cancel,
                      color: Colors.red,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CancelBookingPage(
                              clientName: booking['customer_name'] ?? '',
                              workerName: workerData?['name'] ?? '',
                              companyName: booking['working_company'] ?? '',
                              date: booking['date'] ?? '',
                              time: booking['time'] ?? '',
                              requestId: booking['RID'],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

void _showRatingDialog(String requestId) {
  double selectedRating = 0;
  final TextEditingController descriptionController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(tr('bookings.ratingTitle')),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < selectedRating
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 32,
                      ),
                      onPressed: () {
                        setState(() {
                          selectedRating = index + 1.0;
                        });
                      },
                    );
                  }),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: tr('bookings.ratingDescriptionHint'),
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr('bookings.cancel')),
          ),
         ElevatedButton(
  onPressed: () async {
    await FirebaseFirestore.instance
        .collection('requests')
        .doc(requestId)
        .update({
      'user_rate': selectedRating,
      'user_rate_description': descriptionController.text.trim(),
    });

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(tr('bookings.ratingSuccess'))),
    );
    setState(() {}); // تحديث الشاشة
  },
  child: Text(tr('bookings.submit')),
),
 ],
      );
    },
  );
}


  Color _getStatusColor(String status) {
    switch (status) {
      case 'مكتمل':
        return Colors.green;
      case 'قيد الانتظار':
        return Colors.orange;
      case 'جاري العمل':
        return Colors.blue;
      case 'مرفوض':
        return Colors.grey;
      case 'تم الإلغاء':
        return Colors.red;
      default:
        return Colors.black54;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'مكتمل':
        return Icons.check_circle;
      case 'قيد الانتظار':
        return Icons.hourglass_bottom;
      case 'جاري العمل':
        return Icons.build_circle;
      case 'مرفوض':
        return Icons.highlight_off;
      case 'تم الإلغاء':
        return Icons.cancel;
      default:
        return Icons.info_outline;
    }
  }
}
