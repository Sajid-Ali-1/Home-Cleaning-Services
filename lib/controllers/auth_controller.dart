import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:home_cleaning_app/models/user_model.dart';
import 'package:home_cleaning_app/models/provider_verification_model.dart';
import 'package:home_cleaning_app/services/auth_services.dart';
import 'package:home_cleaning_app/services/db_services.dart';
import 'package:home_cleaning_app/services/notification_service.dart';
import 'package:home_cleaning_app/services/provider_verification_service.dart';
import 'package:home_cleaning_app/views/screens/auth/login_screen.dart';
import 'package:home_cleaning_app/views/screens/nav_pages/nav_page.dart';
import 'package:home_cleaning_app/views/screens/provider_verification_screen.dart';
import 'package:home_cleaning_app/views/screens/verification_pending_screen.dart';
import 'package:home_cleaning_app/views/screens/verification_success_screen.dart';
import 'package:home_cleaning_app/views/screens/email_verification_pending_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  UserModel? userModel;
  ProviderVerification? providerVerification;
  String? fullName;
  String? _currentRouteName;

  void _navigateToRoute(String routeName, Widget Function() pageBuilder) {
    if (_currentRouteName == routeName) return;
    _currentRouteName = routeName;
    Get.offAll(pageBuilder(), routeName: routeName);
  }

  // listen to auth state changes in initialization
  @override
  void onInit() {
    super.onInit();
    _handleAuthFlow();
  }

  Future<void> _handleAuthFlow() async {
    // final prefs = await SharedPreferences.getInstance();
    // final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    // // 🌀 Show onboarding first if user hasn’t seen it
    // if (!hasSeenOnboarding) {
    //   Get.offAll(() => const OnboardingPage());
    //   return;
    // }

    // 🔥 Listen to Firebase Auth changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      // Get.to(() => EmailVerificationPendingScreen());
      // return;
      if (user == null) {
        _navigateToRoute('/login', () => LoginScreen());
      } else {
        // Reload user to get latest email verification status
        await user.reload();
        final currentUser = FirebaseAuth.instance.currentUser;

        await _getUserData();
        if (userModel == null) {
          await _addUserData();
        }
        await NotificationService.registerDeviceToken(user.uid);
        if (userModel != null) {
          if (currentUser != null && !currentUser.emailVerified) {
            _navigateToRoute(
              '/emailVerificationPending',
              () => const EmailVerificationPendingScreen(),
            );
            return;
          }

          if (userModel!.userType == UserType.cleaner) {
            providerVerification =
                await ProviderVerificationService.getVerification(user.uid);

            if (userModel!.isVerified == true) {
              _navigateToRoute('/nav', () => const NavPage());
              return;
            }

            if (providerVerification?.status ==
                ProviderVerificationStatus.pending) {
              _navigateToRoute(
                '/verificationPending',
                () => const VerificationPendingScreen(),
              );
              return;
            }

            _navigateToRoute(
              '/providerVerification',
              () => const ProviderVerificationScreen(),
            );
          } else {
            _navigateToRoute('/nav', () => const NavPage());
          }
        } else {
          signOut();
        }
      }
    });
  }

  Future<void> markOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
  }

  bool isLoading = false;

  UserType? userType; // Store user type for signup

  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
    required UserType userType,
  }) async {
    try {
      isLoading = true;
      update();
      this.fullName = fullName;
      this.userType = userType;
      await AuthServices.signUp(
        fullName: fullName,
        email: email,
        password: password,
      );
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      isLoading = true;
      update();
      User? user = await AuthServices.signIn(email: email, password: password);

      // Check email verification after sign in
      if (user != null && !user.emailVerified) {
        // Email verification will be handled by authStateChanges listener
        // which will navigate to EmailVerificationPendingScreen
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> signOut() async {
    try {
      // Remove FCM token before signing out
      final userId = userModel?.uid ?? FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        await NotificationService.unregisterDeviceToken(userId);
      }
      await AuthServices.signOut();
      userModel = null;
      update();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> _getUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        userModel = await DbServices.getUserData(user.uid);
        update();
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  /// Refresh user data and check verification status
  Future<void> refreshUserData() async {
    try {
      // Store previous verification status
      bool? wasVerified = userModel?.isVerified;

      await _getUserData();
      if (userModel?.uid != null) {
        providerVerification =
            await ProviderVerificationService.getVerification(userModel!.uid!);
      }
      if (userModel != null) {
        // Check if cleaner is now verified (transition from not verified to verified)
        if (userModel!.userType == UserType.cleaner &&
            userModel!.isVerified == true &&
            (wasVerified == null || wasVerified == false)) {
          // Show success screen if just verified
          _navigateToRoute(
            '/verificationSuccess',
            () => const VerificationSuccessScreen(),
          );
        } else if (userModel!.userType == UserType.cleaner) {
          if (providerVerification?.status ==
              ProviderVerificationStatus.rejected) {
            Get.snackbar(
              'Action needed',
              'Verification was rejected. Please resubmit documents.',
            );
            _navigateToRoute(
              '/providerVerification',
              () => const ProviderVerificationScreen(),
            );
          } else if (userModel!.isVerified == null ||
              userModel!.isVerified == false) {
            Get.snackbar('Info', 'Your account is still pending verification');
          }
        }
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> _addUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await DbServices.addUserData(
        UserModel(
          uid: user.uid,
          displayName: user.displayName ?? fullName ?? '',
          email: user.email ?? '',
          userType: userType,
        ),
      );
      await _getUserData();
    }
  }

  /// Check if email is verified and reload user data
  Future<void> checkEmailVerification() async {
    try {
      isLoading = true;
      update();

      // Reload user to get latest email verification status
      await AuthServices.reloadUser();

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && user.emailVerified) {
        // Email is verified, continue with normal auth flow
        // The authStateChanges listener will handle navigation
        await _getUserData();
        if (userModel != null) {
          if (userModel!.userType == UserType.cleaner) {
            providerVerification =
                await ProviderVerificationService.getVerification(user.uid);
            if (userModel!.isVerified == true) {
              _navigateToRoute('/nav', () => const NavPage());
            } else if (providerVerification?.status ==
                ProviderVerificationStatus.pending) {
              _navigateToRoute(
                '/verificationPending',
                () => const VerificationPendingScreen(),
              );
            } else {
              _navigateToRoute(
                '/providerVerification',
                () => const ProviderVerificationScreen(),
              );
            }
          } else {
            _navigateToRoute('/nav', () => const NavPage());
          }
        }
      } else {
        Get.snackbar(
          'Email Not Verified',
          'Please verify your email address before continuing.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading = false;
      update();
    }
  }

  /// Resend email verification
  Future<void> resendEmailVerification() async {
    try {
      isLoading = true;
      update();
      await AuthServices.sendEmailVerification();
    } catch (e) {
      throw Exception(e.toString());
    } finally {
      isLoading = false;
      update();
    }
  }
}
