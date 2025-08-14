// تم انشاء الصفحة بواسطة : فاطمة اليامي
// -الخلفية الموحدة لواجهة الشركات 

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CompanyBackground extends StatelessWidget {
  const CompanyBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // ✅ لون الخلفية مخصص للشركات
        Container(
          color: isDark
              ? const Color(0xFF1E1E1E) // داكن في الوضع الليلي
              : const Color(0xFFE3F2FD), // أزرق فاتح للشركات
        ),

        // ✅ الموجة العلوية
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SvgPicture.asset(
            'assets/Waves/wave3.svg', // ← استبدليها إذا عندك موجة خاصة
            fit: BoxFit.cover,
            width: double.infinity,
            height: 150,
            color: isDark ? Colors.white24 : null,
          ),
        ),

        // ✅ الموجة السفلية (مقلوبة)
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Transform.rotate(
            angle: 3.1416,
            child: SvgPicture.asset(
              'assets/Waves/wave3.svg',
              fit: BoxFit.cover,
              width: double.infinity,
              height: 150,
              color: isDark ? Colors.white24 : null,
            ),
          ),
        ),
      ],
    );
  }
}
