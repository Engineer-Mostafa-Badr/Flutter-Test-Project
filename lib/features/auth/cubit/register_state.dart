part of 'register_cubit.dart';

class RegisterState extends Equatable {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final GlobalKey<FormState> keyForm;

  final bool isShowPassword;
  final bool isLoading;
  final bool isOtpSent;
  final bool isOtpVerified;
  final String? verificationId;
  final int? resendToken;
  final String? errorMessage;
  final String? nextRoute;
  final bool isNewUser;

  const RegisterState({
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    required this.keyForm,
    this.isShowPassword = false,
    this.isLoading = false,
    this.isOtpSent = false,
    this.isOtpVerified = false,
    this.verificationId,
    this.resendToken,
    this.errorMessage,
    this.nextRoute,
    this.isNewUser = false,
  });

  RegisterState copyWith({
    TextEditingController? nameController,
    TextEditingController? emailController,
    TextEditingController? phoneController,
    TextEditingController? passwordController,
    GlobalKey<FormState>? keyForm,
    bool? isShowPassword,
    bool? isLoading,
    bool? isOtpSent,
    bool? isOtpVerified,
    String? verificationId,
    int? resendToken,
    String? errorMessage,
    String? nextRoute,
    bool? isNewUser,
  }) {
    return RegisterState(
      nameController: nameController ?? this.nameController,
      emailController: emailController ?? this.emailController,
      phoneController: phoneController ?? this.phoneController,
      passwordController: passwordController ?? this.passwordController,
      keyForm: keyForm ?? this.keyForm,
      isShowPassword: isShowPassword ?? this.isShowPassword,
      isLoading: isLoading ?? this.isLoading,
      isOtpSent: isOtpSent ?? this.isOtpSent,
      isOtpVerified: isOtpVerified ?? this.isOtpVerified,
      verificationId: verificationId ?? this.verificationId,
      resendToken: resendToken ?? this.resendToken,
      errorMessage: errorMessage,
      nextRoute: nextRoute ?? nextRoute,
      isNewUser: isNewUser ?? this.isNewUser,
    );
  }

  @override
  List<Object?> get props => [
    nameController,
    emailController,
    phoneController,
    passwordController,
    keyForm,
    isShowPassword,
    isLoading,
    isOtpSent,
    isOtpVerified,
    verificationId,
    resendToken,
    errorMessage,
    nextRoute,
    isNewUser,
  ];
}
