import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';

class SubscriptionPaymentModel {
  final String id;
  final String name;
  final Timestamp purchaseTime;
  final Timestamp endTime;

  SubscriptionPaymentModel({
    required this.id,
    required this.name,
    required this.purchaseTime,
    required this.endTime,
  });

  // Create a SubscriptionPaymentModel from a map (for Firestore data)
  factory SubscriptionPaymentModel.fromMap(Map<String, dynamic> data) {
    return SubscriptionPaymentModel(
      id: data[Constants.id] ?? '',
      name: data[Constants.name] ?? '',
      purchaseTime: data[Constants.purchaseTime] ?? Timestamp.now(),
      endTime: data[Constants.endTime] ?? Timestamp.now(),
    );
  }

  // Convert a SubscriptionPaymentModel to a map that can be saved in Firestore
  Map<String, dynamic> toMap() {
    return {
      Constants.id: id,
      Constants.name: name,
      Constants.purchaseTime: purchaseTime,
      Constants.endTime: endTime,
    };
  }
}
