# Profile Management Module

## Overview
The Profile Management module handles user profile information, settings, and account management. It provides a settings screen with account options, notifications preferences, and logout functionality.

## Implementation Details

### Key Files
- **Screens**: 
  - `lib/views/screens/nav_pages/profile_screen.dart`
- **Controller**: 
  - `lib/controllers/auth_controller.dart`
- **Models**: 
  - `lib/models/user_model.dart`
- **Services**: 
  - `lib/services/db_services.dart`
- **Widgets**: 
  - `lib/views/widgets/custom_list_tile.dart`

### Main Components

#### ProfileScreen (`lib/views/screens/nav_pages/profile_screen.dart`)
- Displays settings section
- Shows list of settings options
- Handles user logout
- Accessible from bottom navigation bar (Profile tab)

**Key Features:**
- Settings title display
- Account settings option (placeholder)
- Notifications settings option (placeholder)
- Logout functionality

#### CustomListTile (`lib/views/widgets/custom_list_tile.dart`)
- Reusable widget for settings list items
- Displays icon, title, and navigation arrow
- Handles tap events
- Styled with app theme

#### UserModel (`lib/models/user_model.dart`)
- Defines user data structure
- Includes: uid, email, displayName, profilePic, phoneNumber, userType
- Firestore serialization/deserialization

#### DbServices (`lib/services/db_services.dart`)
- Handles user data CRUD operations
- Firestore integration for user data

**Key Methods:**
- `addUserData()` - Creates or updates user data in Firestore
- `getUserData()` - Retrieves user data from Firestore

## Features Checklist

### Completed Features ✓
- [x] **Profile Screen UI**
  - Settings screen layout
  - Settings title display
  - List tiles for settings options
  - Responsive design using ScreenUtil
  
- [x] **Logout Functionality**
  - Logout option in settings
  - Integrates with AuthController
  - Signs out from Firebase
  - Redirects to Login screen after logout
  
- [x] **Settings Navigation**
  - Account settings tile (UI only)
  - Notifications settings tile (UI only)
  - Navigation arrows on list tiles
  - Tap handlers on tiles
  
- [x] **User Data Storage and Retrieval**
  - User data saved to Firestore
  - User data retrieved on app start
  - UserModel serialization/deserialization
  - User data synced with Firebase Auth

### Pending Features
- [ ] **Account Settings Details**
  - Account settings screen not implemented
  - Need to create account settings screen
  - Should allow editing: display name, email, phone number
  - Should display user type (Customer/Cleaner)
  
- [ ] **Notifications Settings Functionality**
  - Notifications settings screen not implemented
  - Need to create notifications preferences screen
  - Should allow managing notification preferences
  - Should integrate with device notifications
  
- [ ] **Profile Picture Upload**
  - Profile picture field exists in UserModel
  - No profile picture upload functionality
  - Need to implement image picker
  - Need to implement image upload to Firebase Storage
  - Need to display profile picture in profile screen
  
- [ ] **Profile Editing**
  - No profile editing functionality
  - Need to implement profile update screen
  - Should allow updating user information
  - Should update Firestore data

## File References

### Screens
- Profile Screen: `lib/views/screens/nav_pages/profile_screen.dart`

### Controllers
- Auth Controller: `lib/controllers/auth_controller.dart` (for logout)

### Models
- User Model: `lib/models/user_model.dart`

### Services
- Database Services: `lib/services/db_services.dart`

### Widgets
- Custom List Tile: `lib/views/widgets/custom_list_tile.dart`

## Current Implementation Details

### Profile Screen Structure
```dart
- Settings title
- Account list tile (tap handler not implemented)
- Notifications list tile (tap handler not implemented)
- Logout list tile (functional - calls AuthController.signOut())
```

### User Data Structure
The UserModel includes:
- `uid` - Firebase user ID
- `email` - User email address
- `displayName` - User's full name
- `profilePic` - URL to profile picture (not currently used)
- `phoneNumber` - User's phone number (not currently used)
- `userType` - Customer or Cleaner enum

### Logout Flow
1. User taps "Log out" in Profile screen
2. Calls `AuthController.signOut()`
3. Signs out from Firebase Auth
4. Signs out from Google Sign In (if initialized)
5. Clears user data from controller
6. Auth state listener redirects to Login screen

## Notes

1. **Settings Tiles**: The Account and Notifications list tiles are currently placeholders. They display UI but don't navigate to any screens.

2. **User Data**: User data is automatically fetched when authenticated, but there's no UI to display user information on the profile screen yet.

3. **Profile Picture**: The UserModel includes a profilePic field, but there's no implementation for uploading or displaying profile pictures.

4. **Phone Number**: The UserModel includes a phoneNumber field, but there's no UI or functionality to set or display it.

5. **Access Location**: Profile screen is accessible as the 5th tab in the bottom navigation bar (index 4).

6. **Integration**: Profile screen uses AuthController for logout functionality but doesn't currently display user information from UserModel.

## Error Handling

**Error Handling**: Database errors are handled with try-catch blocks and thrown as exceptions, with user feedback through AuthController's error handling.

## Related Modules
- **Authentication**: Uses AuthController for logout functionality
- **Navigation**: Part of bottom navigation system
- **Database Services**: User data storage and retrieval

