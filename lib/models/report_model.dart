import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';

class ReportModel {
  final String reportText;
  final String userId;
  final DateTime timestamp;

  ReportModel({
    required this.reportText,
    required this.userId,
    required this.timestamp,
  });

  // Convert ReportModel to Firestore format
  Map<String, dynamic> toMap() {
    return {
      Constants.reportText: reportText,
      Constants.userId: userId,
      Constants.timestamp: timestamp,
    };
  }

  // Convert Firestore format to ReportModel
  factory ReportModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReportModel(
      reportText: data[Constants.reportText],
      userId: data[Constants.userId],
      timestamp: (data[Constants.timestamp] as Timestamp).toDate(),
    );
  }
}
