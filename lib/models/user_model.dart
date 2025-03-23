import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';
import 'subscription_payment_model.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String currentSubscriptionStatus;
  final Timestamp createdAt;
  final List<SubscriptionPaymentModel> subscriptions;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.currentSubscriptionStatus,
    required this.createdAt,
    required this.subscriptions,
  });

  // Create a UserModel from Firestore data
  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    return UserModel(
      uid: data[Constants.uid] ?? '',
      name: data[Constants.name] ?? '',
      email: data[Constants.email] ?? '',
      currentSubscriptionStatus: data[Constants.currentSubscriptionStatus] ?? '',
      createdAt: data[Constants.createdAt] ?? Timestamp.now(),
      subscriptions: (data[Constants.subscriptions] as List<dynamic>? ?? [])
          .map((subscription) => SubscriptionPaymentModel.fromMap(subscription))
          .toList(),
    );
  }

  // Convert a UserModel to a map that can be saved in Firestore
  Map<String, dynamic> toMap() {
    return {
      Constants.uid: uid,
      Constants.name: name,
      Constants.email: email,
      Constants.currentSubscriptionStatus: currentSubscriptionStatus,
      Constants.createdAt: createdAt,
      Constants.subscriptions: subscriptions.map((sub) => sub.toMap()).toList(),
    };
  }
}
