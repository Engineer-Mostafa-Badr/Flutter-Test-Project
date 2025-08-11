import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_text_project/core/custom_widget/text_span_manager.dart';
import 'package:flutter_text_project/core/custom_widget/app_text_manager.dart';
import 'package:flutter_text_project/core/resources/app_assets_manager.dart';
import 'package:flutter_text_project/core/resources/app_color_manager.dart';
import 'package:flutter_text_project/core/route/routes.dart';
import 'package:flutter_text_project/features/auth/cubit/register_cubit.dart';

class EnterOTPView extends StatefulWidget {
  const EnterOTPView({
    super.key,
    required this.email,
    required this.phone,
    required this.name,
  });

  final String name;
  final String email;
  final String phone;

  @override
  State<EnterOTPView> createState() => _EnterOTPViewState();
}

class _EnterOTPViewState extends State<EnterOTPView> {
  static const int otpLength = 6;

  final List<TextEditingController> _controllers = List.generate(
    otpLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    otpLength,
    (_) => FocusNode(),
  );

  bool _showSuccessBox = false;
  int _secondsRemaining = 30;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    context.read<RegisterCubit>().sendPhoneOtp(widget.phone);
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  // --------- OTP Logic ---------
  void _startCountdown() {
    _secondsRemaining = 30;
    _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining == 0) {
          _canResend = true;
          timer.cancel();
        } else {
          _secondsRemaining--;
        }
      });
    });
  }

  void _checkOTP() {
    final allFilled = _controllers.every(
      (controller) => controller.text.isNotEmpty,
    );
    if (!allFilled) return;

    final code = _controllers.map((e) => e.text).join();
    context.read<RegisterCubit>().verifyOtpCode(code);
  }

  void _onResendOTP() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes.first.requestFocus();
    _startCountdown();
    context.read<RegisterCubit>().sendPhoneOtp(widget.phone);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("خطأ"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("موافق"),
          ),
        ],
      ),
    );
  }

  // --------- UI ---------
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegisterCubit, RegisterState>(
      listener: (context, state) async {
        if (state.isOtpVerified) {
          FocusScope.of(context).unfocus();

          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('name', widget.name);
          await prefs.setString('email', widget.email);
          await prefs.setString('phone', widget.phone);

          setState(() {
            _showSuccessBox = true;
          });
        }

        if (state.errorMessage != null) {
          _showErrorDialog(state.errorMessage!);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: ColorManager.white,
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              _buildOTPForm(),
              if (_showSuccessBox) _buildSuccessBox(),
              if (state.isLoading)
                const Center(
                  child: CircularProgressIndicator(
                    color: ColorManager.primaryColor,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOTPForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 7.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 5.h),
          TextSpanManager(
            textAlign: TextAlign.start,
            textOne: "Enter the ",
            fontSizeTextOne: 25.px,
            fontWeightTextOne: FontWeight.w400,
            colorTextOne: ColorManager.primaryColor,
            latterSpaceTextOne: 0.5,
            textTwo: "Verification Code",
            fontSizeTextTwo: 25.px,
            fontWeightTextTwo: FontWeight.w900,
            colorTextTwo: ColorManager.black,
            latterSpaceTextTwo: 0.5,
          ),
          SizedBox(height: 3.h),
          AppText(
            textColor: ColorManager.black,
            fontWeight: FontWeight.w600,
            fontSize: 14.px,
            text: "Enter the 6 digit code that we just sent to",
          ),
          AppText(
            textColor: ColorManager.primaryColor,
            fontWeight: FontWeight.w700,
            fontSize: 16.px,
            text: widget.phone,
          ),
          SizedBox(height: 12.h),
          _buildOTPFields(),
          SizedBox(height: 30.h),
          _buildTimer(),
          SizedBox(height: 3.h),
          _buildResendText(),
        ],
      ),
    );
  }

  Widget _buildOTPFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(otpLength, (index) {
        return SizedBox(
          width: 12.w,
          height: 10.h,
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            maxLength: 1,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              fontSize: 24,
              color: ColorManager.primaryColor,
            ),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: ColorManager.greyTextFormField,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(3.w),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(2.w),
                borderSide: const BorderSide(color: ColorManager.black),
              ),
            ),
            onChanged: (value) {
              if (value.isNotEmpty && index < otpLength - 1) {
                _focusNodes[index + 1].requestFocus();
              } else if (value.isEmpty && index > 0) {
                _focusNodes[index - 1].requestFocus();
              }
              if (index == otpLength - 1 && value.isNotEmpty) {
                _checkOTP();
              }
            },
          ),
        );
      }),
    );
  }

  Widget _buildTimer() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7.w),
        child: Container(
          height: 6.h,
          width: 30.w,
          color: ColorManager.greyTextFormField,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                AppAssetsManager.timer,
                fit: BoxFit.scaleDown,
                width: 2.w,
                height: 3.5.h,
              ),
              AppText(
                text: _canResend
                    ? "Resend OTP"
                    : '00:${_secondsRemaining.toString().padLeft(2, '0')}',
                fontFamily: 'Mantserrat',
                fontSize: 14.px,
                fontWeight: FontWeight.w500,
                textColor: ColorManager.primaryColor,
                latterSpace: .5,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResendText() {
    return Center(
      child: GestureDetector(
        onTap: _canResend ? _onResendOTP : null,
        child: TextSpanManager(
          textAlign: TextAlign.start,
          textOne: "Didn’t receive the OTP? Resend OTP",
          fontSizeTextOne: 12.px,
          fontWeightTextOne: FontWeight.w400,
          colorTextOne: ColorManager.grey2,
          latterSpaceTextOne: 0.5,
          fontSizeTextTwo: 12.px,
          fontWeightTextTwo: FontWeight.w700,
          colorTextTwo: _canResend ? ColorManager.black : ColorManager.grey2,
          latterSpaceTextTwo: 0.5,
        ),
      ),
    );
  }

  Widget _buildSuccessBox() {
    return Stack(
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          // ignore: deprecated_member_use
          child: Container(color: ColorManager.black.withOpacity(0.5)),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
            height: 63.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: ColorManager.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(14.w)),
            ),
            child: Column(
              children: [
                Container(
                  width: 15.w,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3C4460),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: 4.h),
                SvgPicture.asset(
                  AppAssetsManager.alertSuccess,
                  width: 5.w,
                  height: 20.h,
                ),
                SizedBox(height: 2.h),
                TextSpanManager(
                  textAlign: TextAlign.start,
                  textOne: "Account ",
                  fontSizeTextOne: 25.px,
                  fontWeightTextOne: FontWeight.w500,
                  colorTextOne: ColorManager.black,
                  latterSpaceTextOne: 0.5,
                  textTwo: "successfully",
                  fontSizeTextTwo: 25.px,
                  fontWeightTextTwo: FontWeight.w600,
                  colorTextTwo: ColorManager.primaryColor,
                  latterSpaceTextTwo: 0.5,
                ),
                AppText(
                  text: "created",
                  fontWeight: FontWeight.w400,
                  fontSize: 25.px,
                ),
                SizedBox(height: 3.h),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorManager.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.w),
                    ),
                    minimumSize: Size(80.w, 6.h),
                  ),
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      PageRouteName.home,
                      (route) => false,
                    );
                  },
                  child: Text(
                    "Finish",
                    style: TextStyle(
                      color: ColorManager.white,
                      fontSize: 18.px,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
