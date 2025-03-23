import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';
import 'subscription_payment_model.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final Timestamp createdAt;
  final String currentSubscriptionStatus;
  final int analysisLimit;
  final int currentAnalysisCount;
  final List<SubscriptionPaymentModel> subscriptions;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.createdAt,
    required this.currentSubscriptionStatus,
    required this.analysisLimit,
    required this.currentAnalysisCount,
    required this.subscriptions,
  });

  // Create a UserModel from Firestore data
  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    return UserModel(
      uid: data[Constants.uid] ?? '',
      name: data[Constants.name] ?? '',
      email: data[Constants.email] ?? '',
      createdAt: data[Constants.createdAt] ?? Timestamp.now(),
      currentSubscriptionStatus: data[Constants.currentSubscriptionStatus] ?? '',
      analysisLimit: data[Constants.analysisLimit] ?? 0,
      currentAnalysisCount: data[Constants.currentAnalysisCount] ?? 0,
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
      Constants.createdAt: createdAt,
      Constants.currentSubscriptionStatus: currentSubscriptionStatus,
      Constants.analysisLimit: analysisLimit,
      Constants.currentAnalysisCount: currentAnalysisCount,
      Constants.subscriptions: subscriptions.map((sub) => sub.toMap()).toList(),
    };
  }
}
