import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:flutter/material.dart';

class AppNotifier {
  static final AppNotifier _instance = AppNotifier._internal();

  factory AppNotifier() => _instance;

  AppNotifier._internal();

  // ✅ إظهار رسالة نجاح
  void showSuccess(BuildContext context, String message) {
    _showSnackbar(context, message, Colors.green, Icons.check_circle);
  }

  // ❌ إظهار رسالة خطأ
  void showError(BuildContext context, String message) {
    _showSnackbar(context, message, Colors.red, Icons.error);
  }

  // ℹ️ إظهار معلومات أو تنبيه
  void showInfo(BuildContext context, String message) {
    _showSnackbar(context, message, Colors.blue, Icons.info);
  }

  // ⏳ إظهار التحميل باستخدام EasyLoading
  void showLoading({String message = "Loading, please wait..."}) {
    EasyLoading.show(status: message, maskType: EasyLoadingMaskType.black);
  }

  void hideLoading() {
    EasyLoading.dismiss();
  }

  // ⚙️ تهيئة إعدادات EasyLoading
  static void configLoading() {
    EasyLoading.instance
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle
      ..loadingStyle = EasyLoadingStyle.dark
      ..indicatorSize = 45.0
      ..radius = 10.0
      ..maskType = EasyLoadingMaskType.black
      ..backgroundColor = Colors.white
      ..indicatorColor = const Color(0xFF5D9CEC)
      ..textColor = Colors.white
      ..userInteractions = false
      ..dismissOnTap = false;
  }

  // 🎯 Snackbar داخلي عام
  void _showSnackbar(
    BuildContext context,
    String message,
    Color backgroundColor,
    IconData icon,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 27.px),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontFamily: "Lato",
                  fontSize: 16.px,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.w)),
      ),
    );
  }
}
