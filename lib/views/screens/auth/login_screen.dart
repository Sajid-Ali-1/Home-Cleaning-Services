import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:home_cleaning_app/controllers/auth_controller.dart';
import 'package:home_cleaning_app/utils/app_images.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';
import 'package:home_cleaning_app/utils/app_validators.dart';
import 'package:home_cleaning_app/views/screens/auth/signup_screen.dart';
import 'package:home_cleaning_app/views/widgets/custom_button.dart';
import 'package:home_cleaning_app/views/widgets/custom_text_form_field.dart';
import 'package:home_cleaning_app/views/widgets/divider_with_text.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.of(context).secondaryBackground,

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Sign in to your Account',
                      style: AppTheme.of(context).displayMedium,
                    ),
                    Text(
                      'Enter your info to login your account.',
                      style: AppTheme.of(context).labelSmall,
                    ),
                    SizedBox(height: 20.h),
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
                    SizedBox(height: 30.h),
                    GetBuilder<AuthController>(
                      init: Get.find<AuthController>(),
                      builder: (authController) {
                        return CustomButton(
                          buttonText: 'Login',
                          isLoading: authController.isLoading,
                          onTap: () {
                            if (_formKey.currentState!.validate()) {
                              authController.signIn(
                                email: emailController.text.trim(),
                                password: passwordController.text.trim(),
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
                          'Don\'t have an account? ',
                          style: AppTheme.of(context).labelSmall,
                        ),
                        GestureDetector(
                          onTap: () => Get.to(() => SignUpScreen()),
                          child: Text(
                            'Sign Up',
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
          ],
        ),
      ),
    );
  }
}
