import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:flutter/material.dart';

class AppText extends StatelessWidget {
  const AppText({
    super.key,
    required this.text,
    this.textColor,
    this.fontSize,
    this.fontFamily,
    this.textAlign,
    this.latterSpace,
    this.fontWeight,
  });

  final String text;
  final Color? textColor;
  final FontWeight? fontWeight;
  final double? fontSize;
  final String? fontFamily;
  final TextAlign? textAlign;
  final double? latterSpace;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        color: textColor,
        fontFamily: fontFamily,
        fontWeight: fontWeight,
        letterSpacing: latterSpace,
        fontSize: fontSize?.sp ?? 16.sp,
      ),
    );
  }
}
