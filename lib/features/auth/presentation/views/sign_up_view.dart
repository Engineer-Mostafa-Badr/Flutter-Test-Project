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
      create: (_) => RegisterCubit(),
      child: BlocBuilder<RegisterCubit, RegisterState>(
        builder: (context, state) {
          final cubit = context.watch<RegisterCubit>();

          Widget buildTextField({
            required String hintText,
            required String labelText,
            required TextEditingController controller,
            required String? Function(String?) validate,
            required String prefixIconPath,
            required TextInputType keyboardType,
            bool obscureText = false,
          }) {
            return RegisterTextFormField(
              validate: validate,
              controller: controller,
              hintText: hintText,
              labelText: labelText,
              color: ColorManager.grey,
              prefixIconPath: prefixIconPath,
              keyboardType: keyboardType,
            );
          }

          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Form(
                key: state.keyForm,
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  children: [
                    SizedBox(height: 15.h),

                    // Name
                    buildTextField(
                      hintText: "Full Name",
                      labelText: "Full Name",
                      controller: state.nameController,
                      validate: (name) =>
                          cubit.validateName(context: context, name: name),
                      prefixIconPath: AppAssetsManager.name,
                      keyboardType: TextInputType.name,
                    ),

                    // Email
                    buildTextField(
                      hintText: "Email",
                      labelText: "Email",
                      controller: state.emailController,
                      validate: (email) =>
                          cubit.validateEmail(context: context, email: email),
                      prefixIconPath: AppAssetsManager.email,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    // Phone
                    buildTextField(
                      hintText: "Phone Number",
                      labelText: "Phone Number",
                      controller: state.phoneController,
                      validate: (phone) =>
                          cubit.validatePhone(context: context, phone: phone),
                      prefixIconPath: AppAssetsManager.phone,
                      keyboardType: TextInputType.phone,
                    ),

                    // Password
                    buildTextField(
                      hintText: "Password",
                      labelText: "Password",
                      controller: state.passwordController,
                      validate: (password) => cubit.validatePassword(
                        context: context,
                        password: password,
                      ),
                      prefixIconPath: AppAssetsManager.password,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: !state.isShowPassword,
                    ),

                    SizedBox(height: 2.h),

                    // Show/Hide Password Toggle
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: cubit.togglePasswordVisibility,
                        child: AppText(
                          text: state.isShowPassword
                              ? "Hide Password"
                              : "Show Password",
                          textColor: ColorManager.black,
                          fontSize: 14.px,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    SizedBox(height: 3.h),

                    // Sign Up Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorManager.primaryColor,
                        minimumSize: Size(double.infinity, 6.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.w),
                        ),
                      ),
                      onPressed: () {
                        if (state.keyForm.currentState!.validate()) {
                          Navigator.pushNamed(
                            context,
                            PageRouteName.enterOTP,
                            arguments: {
                              'name': state.nameController.text,
                              'email': state.emailController.text,
                              'phone': state.phoneController.text,
                            },
                          );
                        }
                      },
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.px,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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
