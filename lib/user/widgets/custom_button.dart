// تم انشاء الملف بواسطة فاطمة اليامي 
// توحيد لون الازرار و النصوص في الازرار بتنسق يتناسب مع الخلفية


import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final IconData? icon;
  final double radius;
  final Color textColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = const Color.fromARGB(255, 72, 95, 123), // ← اللون المخصص
    this.icon,
    this.radius = 12.0,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: icon != null
          ? Icon(icon, size: 20, color: textColor)
          : const SizedBox.shrink(),
      label: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      onPressed: onPressed,
    );
  }
}
