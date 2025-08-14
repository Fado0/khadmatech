///  تم إنشاء الملف بواسطة فاطمة اليامي
library;

/// - تعرض توزيع الطلبات في رسم بياني دائري (Pie Chart).
/// - تعتمد على مكتبة pie_chart لعرض البيانات بشكل دائري مع ألوان مخصصة.
/// - تستخدم الترجمة مع EasyLocalization لدعم اللغتين.
/// - يتم احتساب عدد الطلبات في كل حالة: قيد الانتظار، جاري العمل، مكتمل، مرفوض، تم الإلغاء.
/// - تظهر إجمالي عدد الطلبات مع شرح بياني لكل حالة.
/// ------------------------------


import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:pie_chart/pie_chart.dart';

class OrdersSummaryPieCard extends StatelessWidget {
  final List<Map<String, dynamic>> requests;

  const OrdersSummaryPieCard({super.key, required this.requests});

  @override
  Widget build(BuildContext context) {
    final int pending = requests.where((r) => r['status'] == 'قيد الانتظار').length;
    final int inProgress = requests.where((r) => r['status'] == 'جاري العمل').length;
    final int completed = requests.where((r) => r['status'] == 'مكتمل').length;
    final int rejected = requests.where((r) => r['status'] == 'مرفوض').length;
    final int cancelled = requests.where((r) => r['status'] == 'تم الإلغاء').length;

    final int total = pending + inProgress + completed + rejected + cancelled;

    if (total == 0) {
      return Text(tr('company_dashboard.no_requests_yet'));
    }

    final Map<String, double> dataMap = {
      'pending': pending.toDouble(),
      'in_progress': inProgress.toDouble(),
      'completed': completed.toDouble(),
      'rejected': rejected.toDouble(),
      'cancelled': cancelled.toDouble(),
    };

    final Map<String, Color> colorMap = {
      'pending': Colors.orange,
      'in_progress': Colors.blue,
      'completed': Colors.green,
      'rejected': Colors.grey,
      'cancelled': Colors.redAccent,
    };

    final Map<String, String> labelMap = {
      'pending': tr('company_dashboard.status_pending'),
      'in_progress': tr('company_dashboard.status_in_progress'),
      'completed': tr('company_dashboard.status_completed'),
      'rejected': tr('company_dashboard.status_rejected'),
      'cancelled': tr('company_dashboard.status_cancelled'),
    };

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              tr('company_dashboard.orders_distribution'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: PieChart(
                    dataMap: dataMap,
                    chartRadius: MediaQuery.of(context).size.width / 3.2,
                    colorList: colorMap.values.toList(),
                    chartType: ChartType.ring,
                    ringStrokeWidth: 16,
                    chartValuesOptions: const ChartValuesOptions(
                      showChartValues: false,
                    ),
                    legendOptions: const LegendOptions(showLegends: false),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: dataMap.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 6,
                              backgroundColor: colorMap[entry.key],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${labelMap[entry.key]} (${entry.value.toInt()})',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              tr('order_count', args: [total.toString()]),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}