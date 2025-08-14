// فاطمة اليامي 
// - انشاء الخلفية الموحدة لموظف الامانة 

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EmanaBackground extends StatelessWidget {
  const EmanaBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ✅ خلفية بلون موحد (تقدر تغير اللون)
        Container(
          color: const Color.fromARGB(
            255,
            240,
            250,
            255,
          ), // لون فاتح خاص بموظف الأمانة
        ),

        // ✅ الموجة العلوية
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SvgPicture.asset(
            'assets/Waves/wave1.svg', // ← نفس مسار الموجة
            fit: BoxFit.cover,
            width: double.infinity,
            height: 150,
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
              'assets/Waves/wave1.svg',
              fit: BoxFit.cover,
              width: double.infinity,
              height: 150,
            ),
          ),
        ),

        // ✅ الشعار (بشفافية وسط الصفحة)
        Align(
          alignment: Alignment.center,
          child: Opacity(
            opacity: 0.15, // ← شفافية مناسبة
            child: Image.asset(
              'assets/Pictures/logo.png', // ← غيره لو عندك شعار مختلف
              width: 250,
              height: 250,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }
}
