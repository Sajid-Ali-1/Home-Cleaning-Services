import 'package:get/get.dart';

class AppValidators {

  static String? validateFullName(String? value) { 
    if (value == null || value.isEmpty) {
      return 'Please enter your full name';
    }
    if (value.length < 3) {
      return 'Full name must be at least 3 characters long';
    }
    return null;
  } 

  static String? validateEmail(String? value) { 
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    // Simple email regex
    if(GetUtils.isEmail(value) == false) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? validatePassword(String? value) { 
    value = value?.trim();
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String? password) { 
    value = value?.trim();
    password = password?.trim();
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? validateNotEmpty(String? value, String fieldName) { 
    if (value == null || value.isEmpty) {
      return 'Please enter your $fieldName';
    }
    return null;
  }

}