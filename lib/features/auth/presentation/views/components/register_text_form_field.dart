import 'package:flutter_text_project/core/custom_widget/app_text_form_field.dart';
import 'package:flutter_text_project/core/resources/app_color_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class RegisterTextFormField extends StatelessWidget {
  const RegisterTextFormField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIconPath,
    this.validate,
    this.keyboardType,
    this.color,
    this.labelText,
    this.suffix,
  });
  final TextEditingController controller;
  final String hintText;
  final String? labelText;
  final String prefixIconPath;
  final Widget? suffix;
  final String? Function(String?)? validate;
  final TextInputType? keyboardType;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return AppTextFormField(
      keyboardType: keyboardType,
      validate: validate,
      textEditingController: controller,
      hinText: hintText,
      labelText: labelText,
      colorHintText: color,
      suffix: suffix,
      prefix: SvgPicture.asset(
        prefixIconPath,
        fit: BoxFit.scaleDown,
        colorFilter: ColorFilter.mode(
          ColorManager.primaryColor,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}
