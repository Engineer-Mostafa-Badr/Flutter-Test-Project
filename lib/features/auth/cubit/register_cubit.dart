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

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// إظهار / إخفاء الباسورد
  void showHidePassword() {
    emit(state.copyWith(isShowPassword: !state.isShowPassword));
  }

  /// إرسال كود OTP عبر Firebase
  void sendPhoneOtp(String phone) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          final userCredential = await _auth.signInWithCredential(credential);
          bool isNewUser =
              userCredential.additionalUserInfo?.isNewUser ?? false;

          // حفظ البيانات محليًا
          await _saveUserLocally(userCredential.user!, isNewUser);

          emit(
            state.copyWith(
              isOtpVerified: true,
              isLoading: false,
              isNewUser: isNewUser,
            ),
          );
        },
        verificationFailed: (FirebaseAuthException e) {
          String message;
          if (e.code == 'invalid-phone-number') {
            message = "رقم الهاتف غير صالح";
          } else {
            message = e.message ?? "فشل التحقق من رقم الهاتف";
          }
          emit(state.copyWith(isLoading: false, errorMessage: message));
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
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: "حدث خطأ أثناء إرسال الرمز",
        ),
      );
    }
  }

  /// التحقق من كود OTP
  void verifyOtpCode(String smsCode) async {
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

      final userCredential = await _auth.signInWithCredential(credential);
      bool isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

      // حفظ البيانات محليًا
      await _saveUserLocally(userCredential.user!, isNewUser);

      emit(
        state.copyWith(
          isOtpVerified: true,
          isLoading: false,
          isNewUser: isNewUser,
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'invalid-verification-code') {
        message = "رمز التحقق غير صحيح";
      } else {
        message = e.message ?? "رمز التحقق غير صحيح";
      }
      emit(state.copyWith(isLoading: false, errorMessage: message));
    } catch (e) {
      emit(
        state.copyWith(isLoading: false, errorMessage: "رمز التحقق غير صحيح"),
      );
    }
  }

  /// حفظ بيانات المستخدم محليًا + حفظ التوكن
  Future<void> _saveUserLocally(User user, bool isNewUser) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('uid', user.uid);
    await prefs.setString('phoneNumber', user.phoneNumber ?? '');
    await prefs.setBool('isNewUser', isNewUser);
    // الحصول على الـ FCM Token وحفظه
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await prefs.setString('fcmToken', token);
      debugPrint("🎯 FCM Token generated and saved: $token");
    } else {
      debugPrint("⚠️ FCM Token is null, couldn't save it.");
    }
  }
}
