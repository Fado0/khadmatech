/// ------------------------------
/// تم انشاء الصفحة بواسطة فاطمة اليامي
/// - وضع شعار المشروع م حركة بسيطة عند الفتح
/// - وضع شعار الامانة اسفل الشاشة 
/// - وضع خلفية فيها ايقونات في زاوية الصفحه  
///// ------------------------------
library;

import 'package:flutter/material.dart';
import 'dart:async';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _rotationAnimation = Tween<double>(
      begin: -0.02,
      end: 0.02,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // بداية ظهور Fade-In بعد 300 ملي ثانية
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() => _opacity = 1.0);
    });

    // بعد 7 ثواني ينتقل لتسجيل الدخول
    Timer(const Duration(seconds: 7), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F3),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // الخلفية
          Image.asset('assets/Pictures/background2.png', fit: BoxFit.cover),

          // شعار التطبيق في المنتصف
          Center(
            child: AnimatedOpacity(
              opacity: _opacity,
              duration: const Duration(seconds: 2),
              child: AnimatedBuilder(
                animation: _rotationAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationAnimation.value,
                    child: Image.asset(
                      'assets/Pictures/logo.png', // شعار خدمتك
                      width: 350,
                    ),
                  );
                },
              ),
            ),
          ),

          // شعار الأمانة مثبت في الأسفل
          Positioned(
            bottom: 0, // ← تم تغييرها من 30 إلى 0
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/Pictures/emanaLogo.png', // شعار الأمانة
                width: 200,
                height: 180,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
