/// تم اشناء الملف بواسطة فاطمة اليامي
/// - توحيد الازرار في واجهة الشركات بلون و خط معين
library;
import 'package:flutter/material.dart';

class CompanyButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final IconData? icon;
  final double radius;
  final Color textColor;
  final bool fullWidth;

  const CompanyButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = const Color.fromARGB(255, 75, 130, 123),
    this.icon,
    this.radius = 12.0,
    this.textColor = Colors.white,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonChild = Text(
      text,
      style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
    );

    final button = icon != null
        ? ElevatedButton.icon(
            icon: Icon(icon, size: 20, color: textColor),
            label: buttonChild,
            onPressed: onPressed,
            style: _buttonStyle(),
          )
        : ElevatedButton(
            onPressed: onPressed,
            style: _buttonStyle(),
            child: buttonChild,
          );

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    );
  }
}
