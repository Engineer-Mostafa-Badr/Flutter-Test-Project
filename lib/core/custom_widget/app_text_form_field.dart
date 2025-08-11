import 'package:responsive_sizer/responsive_sizer.dart';
import '../resources/app_color_manager.dart';
import 'package:flutter/material.dart';

class AppTextFormField extends StatelessWidget {
  const AppTextFormField({
    super.key,
    required this.textEditingController,
    this.colorHintText,
    this.hinText,
    this.labelText,
    this.isFill = true,
    this.validate,
    this.suffix,
    this.prefix,
    this.horizentalPadding,
    this.verticalPadding,
    this.isShowContent = false,
    this.keyboardType,
    this.colorLableText,
  });

  final TextEditingController textEditingController;
  final Color? colorHintText;
  final Color? colorLableText;
  final String? hinText;
  final String? labelText;
  final bool isFill;
  final String? Function(String? text)? validate;
  final Widget? suffix;
  final Widget? prefix;
  final double? horizentalPadding;
  final double? verticalPadding;
  final bool isShowContent;
  final TextInputType? keyboardType;

  InputBorder border({
    bool isErrorBorder = false,
    required BuildContext context,
  }) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(3.w),
    borderSide: BorderSide(
      color: isErrorBorder ? ColorManager.red : ColorManager.white,
    ),
  );
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizentalPadding ?? 1.w,
        vertical: verticalPadding ?? 1.h,
      ),
      child: TextFormField(
        keyboardType: keyboardType,
        controller: textEditingController,
        validator: validate,
        obscureText: isShowContent,
        decoration: InputDecoration(
          prefixIcon: prefix,
          suffixIcon: suffix,
          hintText: hinText,
          hintStyle: TextStyle(
            color: colorHintText ?? ColorManager.greyLabelText,
            fontSize: 14.px,
            fontWeight: FontWeight.w400,
            fontFamily: "Lato",
          ),
          labelText: labelText,
          labelStyle: TextStyle(color: colorLableText ?? ColorManager.grey),
          filled: isFill,
          errorMaxLines: 2,
          fillColor: ColorManager.greyTextFormField,
          enabledBorder: border(context: context),
          focusedBorder: border(context: context),
          border: border(context: context),
          errorBorder: border(isErrorBorder: true, context: context),
          contentPadding: EdgeInsets.symmetric(
            vertical: 3.5.h,
            horizontal: 5.w,
          ),
        ),
      ),
    );
  }
}
