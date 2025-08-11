import 'package:flutter_text_project/features/auth/presentation/views/components/register_text_form_field.dart';
import 'package:flutter_text_project/core/custom_widget/app_text_manager.dart';
import 'package:flutter_text_project/features/auth/cubit/register_cubit.dart';
import 'package:flutter_text_project/core/resources/app_assets_manager.dart';
import 'package:flutter_text_project/core/resources/app_color_manager.dart';
import 'package:flutter_text_project/core/route/routes.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

class SignUpView extends StatelessWidget {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterCubit(),
      child: BlocBuilder<RegisterCubit, RegisterState>(
        builder: (context, regState) {
          final cubit = context.read<RegisterCubit>();
          return Form(
            key: regState.keyForm,
            child: Scaffold(
              backgroundColor: Colors.white,
              body: SafeArea(
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  children: [
                    SizedBox(height: 15.h),
                    RegisterTextFormField(
                      validate: (name) =>
                          cubit.validateName(context: context, name: name),
                      controller: regState.nameController,
                      hintText: "Full Name",
                      labelText: "Full Name",
                      color: ColorManager.grey,
                      prefixIconPath: AppAssetsManager.name,
                      keyboardType: TextInputType.name,
                    ),
                    RegisterTextFormField(
                      validate: (email) =>
                          cubit.validateEmail(context: context, email: email),
                      controller: regState.emailController,
                      hintText: "Email",
                      labelText: "Email",
                      color: ColorManager.grey,
                      prefixIconPath: AppAssetsManager.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    RegisterTextFormField(
                      validate: (phone) =>
                          cubit.validatePhone(context: context, phone: phone),
                      controller: regState.phoneController,
                      hintText: "Phone Number",
                      labelText: "Phone Number",
                      color: ColorManager.grey,
                      prefixIconPath: AppAssetsManager.phone,
                      keyboardType: TextInputType.phone,
                    ),
                    RegisterTextFormField(
                      validate: (password) => cubit.validatePassword(
                        context: context,
                        password: password,
                      ),
                      controller: regState.passwordController,
                      hintText: "Password",
                      labelText: "Password",
                      color: ColorManager.grey,
                      prefixIconPath: AppAssetsManager.password,
                      keyboardType: TextInputType.visiblePassword,
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            cubit.showHidePassword();
                          },
                          child: AppText(
                            text: regState.isShowPassword
                                ? "Show Password"
                                : "Hide Password",
                            textColor: ColorManager.black,
                            fontSize: 14.px,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3.h),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorManager.primaryColor,
                        minimumSize: Size(double.infinity, 6.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.w),
                        ),
                      ),
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.px,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onPressed: () {
                        if (regState.keyForm.currentState!.validate()) {
                          Navigator.pushNamed(
                            context,
                            PageRouteName.enterOTP,
                            arguments: {
                              'name': regState.nameController.text,
                              'email': regState.emailController.text,
                              'phone': regState.phoneController.text,
                            },
                          );
                        }
                      },
                    ),
                    SizedBox(height: 3.h),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
