import 'package:flutter/material.dart';

mixin Validate {
  String? validateEmail({
    required String? email,
    required BuildContext context,
  }) {
    RegExp emailRegex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    );

    if (email?.isEmpty ?? true) {
      return "Email cannot be empty";
    } else if (!emailRegex.hasMatch(email!)) {
      return "Please enter a valid email address";
    }
    return null;
  }

  String? validatePassword({
    required String? password,
    required BuildContext context,
  }) {
    RegExp passwordRegExp = RegExp(r'^.{6,}$');
    if (password?.isEmpty ?? true) {
      return "Password cannot be empty";
    } else if (!passwordRegExp.hasMatch(password!)) {
      return "Password must be at least 6 characters long";
    }
    return null;
  }

  String? validateName({required String? name, required BuildContext context}) {
    if (name?.isEmpty ?? true) {
      return "Full name cannot be empty";
    } else if (name!.length < 3) {
      return "Please enter a valid full name";
    }
    return null;
  }

  String? validatePhone({
    required String? phone,
    required BuildContext context,
  }) {
    if (phone?.isEmpty ?? true) {
      return "Phone number cannot be empty";
    } else if (!RegExp(r'^\+?\d+$').hasMatch(phone!)) {
      return "Please enter a valid phone number";
    }
    return null;
  }
}
