// تم تصميم الخلفية بواسطة: فاطمة اليامي
// يشمل التصميم اختيار الألوان المناسبة حسب الثيم (فاتح/غامق)
// وتم اختيار موجتين علويتين وسفليتين تضفي طابعًا مرئيًا أنيقًا
//  إضافة شعار التطبيق بشكل شفاف في منتصف الشاشة

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ClientBackground extends StatelessWidget {
  const ClientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // ✅ خلفية بلون يعتمد على الثيم
        Container(
          color: isDark
              ? const Color(0xFF303030) // لون غامق في الوضع الليلي
              : const Color.fromARGB(255, 255, 245, 245), // لون فاتح
        ),

        // ✅ الموجة العلوية
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SvgPicture.asset(
            'assets/Waves/wave2.svg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: 150,
            color: isDark
                ? Colors.black26
                : null, // ← لو تبين تغيّرين لون الموجة حسب الثيم
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
              'assets/Waves/wave2.svg',
              fit: BoxFit.cover,
              width: double.infinity,
              height: 150,
              color: isDark ? Colors.black26 : null, // نفس هنا
            ),
          ),
        ),

        // ✅ شعار في منتصف الخلفية
        Align(
          alignment: Alignment.center,
          child: Opacity(
            opacity: 0.2,
            child: Image.asset(
              'assets/Pictures/logo.png',
              width: 180,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }
}
