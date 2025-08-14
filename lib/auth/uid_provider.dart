/// ------------------------------
/// 🛠️ تم إنشاء الصفحة بواسطة الفريق التالي:
///
/// فاضله الهاجري:
/// - إنشاء منطق UID لحفظ وتتبع معرف المستخدم عبر جميع الصفحات.
/// ------------------------------
library;

import 'package:flutter/material.dart';

class UIDProvider with ChangeNotifier {
  String? _uid;

  String? get uid => _uid;

  void setUID(String uid) {
    _uid = uid;
    notifyListeners();
  }

  void clearUID() {
    _uid = null;
    notifyListeners();
  }
}
