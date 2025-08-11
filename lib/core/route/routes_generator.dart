import 'package:flutter_text_project/features/auth/presentation/views/enter_otp_view.dart';
import 'package:flutter_text_project/features/auth/presentation/views/sign_up_view.dart';
import 'package:flutter_text_project/features/home/presentation/views/home_view.dart';
import 'package:flutter_text_project/core/route/routes.dart';
import 'package:flutter/material.dart';

class RoutesGenerator {
  static Route<dynamic> onGenerateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case PageRouteName.signUp:
        return MaterialPageRoute(
          builder: (context) => const SignUpView(),
          settings: settings,
        );
      case PageRouteName.enterOTP:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) => EnterOTPView(
            name: args?['name'] ?? '',
            email: args?['email'] ?? '',
            phone: args?['phone'] ?? '',
          ),
          settings: settings,
        );
      case PageRouteName.home:
        return MaterialPageRoute(
          builder: (context) => const HomeView(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (context) => const SignUpView(),
          settings: settings,
        );
    }
  }
}
