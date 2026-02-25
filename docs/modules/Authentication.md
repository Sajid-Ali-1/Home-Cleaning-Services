# Authentication Module

## Overview
The Authentication module handles user registration, login, and authentication state management for the Home Cleaning Services app. It supports both Customer and Cleaner user types and integrates with Firebase Authentication.

## Implementation Details

### Key Files
- **Screens**: 
  - `lib/views/screens/auth/login_screen.dart`
  - `lib/views/screens/auth/signup_screen.dart`
  - `lib/views/screens/auth/forget_password.dart` (empty file)
- **Controller**: 
  - `lib/controllers/auth_controller.dart`
- **Services**: 
  - `lib/services/auth_services.dart`
- **Models**: 
  - `lib/models/user_model.dart`
- **Utils**: 
  - `lib/utils/app_validators.dart`

### Main Components

#### AuthController (`lib/controllers/auth_controller.dart`)
- Manages authentication state using GetX
- Listens to Firebase Auth state changes
- Handles sign up, sign in, and sign out operations
- Manages user data fetching and storage
- Supports user type selection (Customer/Cleaner)

**Key Methods:**
- `signUp()` - Handles user registration with email/password
- `signIn()` - Handles user login with email/password
- `signOut()` - Handles user logout
- `_handleAuthFlow()` - Manages auth state listener
- `_getUserData()` - Fetches user data from Firestore
- `_addUserData()` - Creates user data in Firestore

#### AuthServices (`lib/services/auth_services.dart`)
- Provides static methods for Firebase Authentication operations
- Handles email/password authentication
- Google Sign In initialized but not fully implemented

**Key Methods:**
- `signUp()` - Creates user account with email/password
- `signIn()` - Authenticates user with email/password
- `signOut()` - Signs out user from Firebase and Google

#### Login Screen (`lib/views/screens/auth/login_screen.dart`)
- Email and password input fields
- Form validation
- Google Sign In button (UI only)
- Navigation to Sign Up screen
- Loading state during authentication

#### Sign Up Screen (`lib/views/screens/auth/signup_screen.dart`)
- Full name, email, password, and confirm password fields
- User type selector (Customer/Cleaner)
- Form validation for all fields
- Google Sign In button (UI only)
- Navigation to Login screen

## Features Checklist

### Completed Features ✓
- [x] **Email/Password Sign Up**
  - User can create account with email and password
  - Full name is required during registration
  - User type (Customer/Cleaner) selection
  - Display name is updated in Firebase Auth
  - User data is saved to Firestore after signup
  
- [x] **Email/Password Sign In**
  - User can login with email and password
  - Form validation for email and password fields
  - Error handling with user-friendly messages
  
- [x] **Sign Out Functionality**
  - User can logout from the app
  - Firebase Auth sign out
  - Google Sign In sign out (initialized)
  - User data cleared from controller
  
- [x] **Auth State Listener**
  - Automatic navigation based on auth state
  - Redirects to Login if not authenticated
  - Redirects to NavPage if authenticated
  - User data is fetched automatically on login
  
- [x] **User Type Selection**
  - Customer/Cleaner selection during signup
  - UserType enum in UserModel
  - User type is saved to Firestore
  - UserTypeSelector widget implementation
  
- [x] **Form Validation**
  - Email validation using GetUtils
  - Password validation (minimum 6 characters)
  - Full name validation (minimum 3 characters)
  - Confirm password matching validation
  - All validators in `app_validators.dart`

### Pending Features
- [ ] **Google Sign In**
  - UI button exists in both Login and Sign Up screens
  - GoogleSignIn instance initialized in AuthServices
  - Actual Google Sign In functionality not implemented
  - Need to implement `signInWithGoogle()` method
  
- [ ] **Forget Password Screen**
  - File exists at `lib/views/screens/auth/forget_password.dart`
  - File is currently empty
  - Need to implement password reset functionality
  - Need to integrate with Firebase password reset

## File References

### Screens
- Login Screen: `lib/views/screens/auth/login_screen.dart`
- Sign Up Screen: `lib/views/screens/auth/signup_screen.dart`
- Forget Password: `lib/views/screens/auth/forget_password.dart` (empty)

### Controllers
- Auth Controller: `lib/controllers/auth_controller.dart`

### Services
- Auth Services: `lib/services/auth_services.dart`

### Models
- User Model: `lib/models/user_model.dart`

### Utilities
- App Validators: `lib/utils/app_validators.dart`

## Notes

1. **Auth Flow**: The app automatically handles auth state changes and redirects users accordingly. On app start, it checks Firebase Auth state and navigates to Login or NavPage.

2. **User Data Sync**: After successful authentication, user data is automatically fetched from Firestore. If user data doesn't exist, it's created automatically during signup.

3. **User Type**: The user type selection is stored in Firestore and can be used to differentiate between Customer and Cleaner experiences throughout the app.

4. **Onboarding**: There's commented code in AuthController for onboarding flow, but it's not currently implemented.

5. **Error Handling**: Authentication errors are displayed via GetX snackbar with error messages from Firebase.

6. **Loading States**: The AuthController manages loading states during authentication operations to provide user feedback.

## Related Modules
- **Profile Management**: Uses AuthController for logout functionality
- **Navigation**: Redirects based on auth state
- **Database Services**: Stores and retrieves user data

