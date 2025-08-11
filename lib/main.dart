import 'package:flutter/material.dart';
import 'package:flutter_text_project/core/custom_widget/my_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_text_project/core/services/firebase_messaging_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final firebaseService = FirebaseMessagingService();
  await firebaseService.init();

  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn, firebaseService: firebaseService));
}
