// شهد العتيبي 
///- بطاقات الحجز تحتوي على معلومات العميل المختصره (الاسم ، نوع الخدمة ، الموقع، رقم الجوال، الحالة )
library;

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // ← للتفعيل

class WorkerCard extends StatelessWidget {
  final Map<String, dynamic> worker;
  final VoidCallback onTap;

  const WorkerCard({super.key, required this.worker, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: const CircleAvatar(
          backgroundColor: Color(0xFF36596A),
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(
          worker['name'] ?? tr('worker_card.no_name'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${tr('worker_card.service')}: ${worker['type'] ?? tr('worker_card.unspecified')}',
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Row(
              children: List.generate(5, (i) {
                return Icon(
                  i < (worker['rating'] ?? 0).round()
                      ? Icons.star
                      : Icons.star_border,
                  color: Colors.amber,
                  size: 18,
                );
              }),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
