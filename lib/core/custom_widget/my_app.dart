import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_text_project/features/auth/cubit/register_cubit.dart';
import 'package:flutter_text_project/features/splash/views/splash_view.dart';
import 'package:flutter_text_project/core/resources/app_assets_manager.dart';
import 'package:flutter_text_project/core/route/routes_generator.dart';
import 'package:flutter_text_project/core/services/firebase_messaging_service.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class MyApp extends StatefulWidget {
  final bool isLoggedIn;
  final FirebaseMessagingService firebaseService;

  const MyApp({
    super.key,
    required this.isLoggedIn,
    required this.firebaseService,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _setupFirebaseMessaging();
  }

  Future<void> _setupFirebaseMessaging() async {
    widget.firebaseService.listenToMessages((RemoteMessage message) async {
      // ignore: avoid_print
      print("📨 رسالة جديدة: ${message.notification?.title}");

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("lastMessage", message.notification?.title ?? "");

      await widget.firebaseService.showNotification(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return BlocProvider<RegisterCubit>(
          create: (_) => RegisterCubit(),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: const SplashScreen(svgAssetPath: AppAssetsManager.mohamed),
            onGenerateRoute: RoutesGenerator.onGenerateRoutes,
            title: 'Flutter Demo',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            ),
          ),
        );
      },
    );
  }
}
