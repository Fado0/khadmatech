//تم انشاء الملف بواسطة :شهد العتيبي
// - قارئ للصفحات لمساعدة كبار السن 


import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:easy_localization/easy_localization.dart'; // ← ضروري

class TTSSpeakerIcon extends StatefulWidget {
  final String text; // النص اللي راح يُقرأ
  final Color? color;
  final double? size;

  const TTSSpeakerIcon({super.key, required this.text, this.color, this.size});

  @override
  State<TTSSpeakerIcon> createState() => _TTSSpeakerIconState();
}

class _TTSSpeakerIconState extends State<TTSSpeakerIcon> {
  final FlutterTts flutterTts = FlutterTts();

  Future<void> _speak() async {
    final currentLocale = context.locale.languageCode;

    // 🔄 اختيار اللغة بناءً على اللغة الحالية
    if (currentLocale == 'ar') {
      await flutterTts.setLanguage("ar-SA"); // ← العربية السعودية
    } else {
      await flutterTts.setLanguage("en-US"); // ← الإنجليزية الأمريكية
    }

    await flutterTts.setPitch(1.0); // نغمة الصوت
    await flutterTts.setSpeechRate(0.6); // سرعة النطق
    await flutterTts.speak(widget.text); // النطق
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.volume_up),
      color: widget.color ?? Colors.green,
      iconSize: widget.size ?? 24,
      onPressed: _speak,
      tooltip: 'تشغيل القراءة الصوتية',
    );
  }
}
