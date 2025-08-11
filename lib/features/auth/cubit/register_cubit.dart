import 'package:flutter_text_project/core/utils/validate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> with Validate {
  RegisterCubit()
    : super(
        RegisterState(
          nameController: TextEditingController(),
          emailController: TextEditingController(),
          phoneController: TextEditingController(),
          passwordController: TextEditingController(),
          keyForm: GlobalKey<FormState>(),
        ),
      );

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// يعكس حالة إظهار/إخفاء كلمة المرور
  void togglePasswordVisibility() {
    emit(state.copyWith(isShowPassword: !state.isShowPassword));
  }

  /// يرسل رمز التحقق OTP إلى رقم الهاتف عبر Firebase
  Future<void> sendPhoneOtp(String phoneNumber) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          final errorMsg = _mapFirebaseAuthErrorToMessage(e);
          emit(state.copyWith(isLoading: false, errorMessage: errorMsg));
        },
        codeSent: (String verificationId, int? resendToken) {
          emit(
            state.copyWith(
              verificationId: verificationId,
              resendToken: resendToken,
              isOtpSent: true,
              isLoading: false,
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          emit(state.copyWith(verificationId: verificationId));
        },
      );
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: "حدث خطأ أثناء إرسال الرمز",
        ),
      );
    }
  }

  /// يتحقق من كود OTP المُدخل ويرسل بيانات الدخول
  Future<void> verifyOtpCode(String smsCode) async {
    if (state.verificationId == null) {
      emit(state.copyWith(errorMessage: "لم يتم إرسال رمز التحقق بعد"));
      return;
    }

    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: state.verificationId!,
        smsCode: smsCode,
      );
      await _signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      final errorMsg = _mapFirebaseAuthErrorToMessage(e);
      emit(state.copyWith(isLoading: false, errorMessage: errorMsg));
    } catch (_) {
      emit(
        state.copyWith(isLoading: false, errorMessage: "رمز التحقق غير صحيح"),
      );
    }
  }

  /// يعالج تسجيل الدخول باستخدام بيانات الاعتماد ويخزن بيانات المستخدم محليًا
  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

    await _saveUserLocally(userCredential.user!, isNewUser);

    emit(
      state.copyWith(
        isOtpVerified: true,
        isLoading: false,
        isNewUser: isNewUser,
      ),
    );
  }

  /// يحفظ بيانات المستخدم محليًا مع حفظ FCM Token
  Future<void> _saveUserLocally(User user, bool isNewUser) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('uid', user.uid);
    await prefs.setString('phoneNumber', user.phoneNumber ?? '');
    await prefs.setBool('isNewUser', isNewUser);

    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      await prefs.setString('fcmToken', fcmToken);
      debugPrint("🎯 FCM Token generated and saved: $fcmToken");
    } else {
      debugPrint("⚠️ FCM Token is null, couldn't save it.");
    }
  }

  /// يحول أخطاء FirebaseAuth إلى رسائل مفهومة للمستخدم
  String _mapFirebaseAuthErrorToMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return "رقم الهاتف غير صالح";
      case 'invalid-verification-code':
        return "رمز التحقق غير صحيح";
      default:
        return e.message ?? "حدث خطأ أثناء التحقق";
    }
  }
}
