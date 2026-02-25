import 'package:cloud_firestore/cloud_firestore.dart';

enum UserType {
  customer,
  cleaner;

  // Convert enum to string for Firestore
  String toJson() => name;

  // Convert string to enum from Firestore
  static UserType? fromJson(String? value) {
    if (value == null) return UserType.customer;
    try {
      return UserType.values.firstWhere((e) => e.name == value);
    } catch (e) {
      return null;
    }
  }
}

class UserModel {
  String? uid;
  String? email;
  String? displayName;
  String? profilePic;
  String? phoneNumber;
  UserType? userType;
  bool? isVerified;
  String? stripeConnectAccountId;
  bool? stripeConnectOnboardingComplete;

  UserModel({
    this.uid,
    this.email,
    this.displayName,
    this.profilePic,
    this.phoneNumber,
    this.userType,
    this.isVerified,
    this.stripeConnectAccountId,
    this.stripeConnectOnboardingComplete,
  });

  // receiving data from server
  factory UserModel.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> docData = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: docData['email'],
      displayName: docData['displayName'],
      profilePic: docData['profilePic'],
      phoneNumber: docData['phoneNumber'],
      userType: UserType.fromJson(docData['userType'] as String?),
      isVerified: docData['isVerified'] as bool? ?? false,
      stripeConnectAccountId: docData['stripeConnectAccountId'] as String?,
      stripeConnectOnboardingComplete: docData['stripeConnectOnboardingComplete'] as bool? ?? false,
    );
  }

  // sending data to server
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'profilePic': profilePic,
      'phoneNumber': phoneNumber,
      'userType': userType?.toJson(),
      'isVerified': isVerified ?? false,
      'stripeConnectAccountId': stripeConnectAccountId,
      'stripeConnectOnboardingComplete': stripeConnectOnboardingComplete ?? false,
    };
  }
}
