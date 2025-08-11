// ignore_for_file: avoid_print

import 'package:flutter_text_project/core/resources/app_assets_manager.dart';
import 'package:flutter_text_project/core/route/routes_generator.dart';
import 'package:flutter_text_project/features/auth/cubit/register_cubit.dart';
import 'package:flutter_text_project/features/splash/views/splash_view.dart';
import 'package:flutter_text_project/core/services/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

// 📩 هندلر الرسائل في الخلفية
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("📩 رسالة في الخلفية: ${message.notification?.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // تفعيل استقبال الرسائل في الخلفية
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _token;

  @override
  void initState() {
    super.initState();
    _initFCM();
  }

  Future<void> _initFCM() async {
    // طلب الإذن
    NotificationSettings settings = await FirebaseMessaging.instance
        .requestPermission();
    print("🔔 حالة الإذن: ${settings.authorizationStatus}");

    // الحصول على التوكن
    _token = await FirebaseMessaging.instance.getToken();
    print("🎯 توكن الجهاز: $_token");

    // استقبال الرسائل أثناء فتح التطبيق
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("📨 رسالة جديدة: ${message.notification?.title}");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message.notification?.title ?? "بدون عنوان")),
        );
      }
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
