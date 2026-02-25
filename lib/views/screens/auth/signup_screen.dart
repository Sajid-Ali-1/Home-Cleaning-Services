import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:home_cleaning_app/controllers/auth_controller.dart';
import 'package:home_cleaning_app/models/user_model.dart';
import 'package:home_cleaning_app/utils/app_images.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';
import 'package:home_cleaning_app/utils/app_validators.dart';
import 'package:home_cleaning_app/views/screens/auth/login_screen.dart';
import 'package:home_cleaning_app/views/widgets/custom_button.dart';
import 'package:home_cleaning_app/views/widgets/custom_text_form_field.dart';
import 'package:home_cleaning_app/views/widgets/divider_with_text.dart';
import 'package:home_cleaning_app/views/widgets/user_type_selector.dart';

class SignUpScreen extends StatefulWidget {
  SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  UserType selectedUserType = UserType.customer;

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.of(context).secondaryBackground,

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 120.h),

                Text(
                  'Create an Account',
                  style: AppTheme.of(context).displayMedium,
                ),
                Text(
                  'Enter your info to sign up to your account.',
                  style: AppTheme.of(context).labelSmall,
                ),
                SizedBox(height: 20.h),
                // User Type Selection
                UserTypeSelector(
                  selectedUserType: selectedUserType,
                  onUserTypeChanged: (userType) {
                    setState(() {
                      selectedUserType = userType;
                    });
                  },
                  label: 'I want to sign up as:',
                ),
                SizedBox(height: 20.h),
                CustomTextFormField(
                  controller: fullNameController,
                  validator: AppValidators.validateFullName,
                  labelText: 'Full Name',
                  prefixIcon: Icons.person_outline,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                ),
                SizedBox(height: 12.h),
                CustomTextFormField(
                  controller: emailController,
                  validator: AppValidators.validateEmail,
                  labelText: 'Email Address',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 12.h),
                CustomTextFormField(
                  controller: passwordController,
                  validator: AppValidators.validatePassword,
                  labelText: 'Password',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                ),
                SizedBox(height: 12.h),
                CustomTextFormField(
                  controller: confirmPasswordController,
                  validator: (value) => AppValidators.validateConfirmPassword(
                    value,
                    passwordController.text,
                  ),
                  labelText: 'Confirm Password',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                ),
                SizedBox(height: 30.h),
                GetBuilder<AuthController>(
                  init: Get.find<AuthController>(),
                  builder: (authController) {
                    return CustomButton(
                      buttonText: 'Sign Up',
                      isLoading: authController.isLoading,
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          authController.signUp(
                            fullName: fullNameController.text,
                            email: emailController.text.trim(),
                            password: passwordController.text.trim(),
                            userType: selectedUserType,
                          );
                        }
                      },
                    );
                  },
                ),

                SizedBox(height: 30.h),
                // DividerWithText(text: 'Sign in with'),
                // SizedBox(height: 30.h),
                // CustomButton(
                //   buttonText: 'Sign In with Google',
                //   buttonColor: AppTheme.of(context).darkGray,
                //   style: AppTheme.of(context).bodyMedium,
                //   prefix: Image.asset(
                //     AppImages.google,
                //     height: 16.r,
                //     width: 16.r,
                //   ),
                // ),
                SizedBox(height: 30.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: AppTheme.of(context).labelSmall,
                    ),
                    GestureDetector(
                      onTap: () => Get.to(() => LoginScreen()),
                      child: Text(
                        'Login',
                        style: AppTheme.of(context).labelSmall.copyWith(
                          color: AppTheme.of(context).accent1,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
