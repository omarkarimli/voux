import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:voux/models/report_model.dart';
import 'package:voux/utils/extensions.dart';
import '../../utils/constants.dart';

class ReportBottomSheet extends StatefulWidget {
  const ReportBottomSheet({super.key});

  @override
  _ReportBottomSheetState createState() => _ReportBottomSheetState();
}

class _ReportBottomSheetState extends State<ReportBottomSheet> {
  TextEditingController reportController = TextEditingController();
  String? errorMessage;

  // Send report to Firestore
  Future<void> _sendReport(String reportText, {Function? onSuccess, Function? onError}) async {
    try {
      final user = FirebaseAuth.instance.currentUser; // Get current user
      final report = ReportModel(
        reportText: reportText,
        userId: user?.uid ?? Constants.unknown,
        timestamp: DateTime.now(),
      );

      // Add the report to Firestore
      await FirebaseFirestore.instance.collection(Constants.reports).add(report.toMap());

      // Call the onSuccess callback if it's provided
      if (onSuccess != null) {
        onSuccess();
      }

    } catch (e) {
      // Call the onError callback if it's provided
      if (onError != null) {
        onError(e);
      }
    } finally {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 18,
        right: 18,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 36,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Report Issue".tr(), style: Theme.of(context).textTheme.titleLarge),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close),
              )
            ]
          ),
          SizedBox(height: 24),
          TextField(
            controller: reportController,
            maxLength: Constants.maxReportLength,
            maxLines: Constants.maxReportLine,
            minLines: 1,
            decoration: InputDecoration(
              hintText: "Enter your report reason...".tr(),
              errorText: errorMessage,
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                  borderRadius: BorderRadius.circular(Constants.cornerRadiusSmall)
              ),
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              String reportText = reportController.text.trim();
              print("Report Text: '$reportText'");  // Debug: check the actual text

              setState(() {
                errorMessage = null; // Clear previous errors
              });

              if (reportText.isNotEmpty) {
                if (reportText.length < Constants.maxReportLength && reportText.length > Constants.minReportLength) {
                  _sendReport(
                    reportText,
                    onSuccess: () {
                      // Handle success
                      context.showCustomSnackBar(Constants.success, "Report submitted successfully".tr());
                    },
                    onError: (e) {
                      // Handle error
                      context.showCustomSnackBar(Constants.error, "Error sending report".tr());
                    },
                  );
                } else {
                  setState(() {
                    errorMessage = "Report should be less than ${Constants.maxReportLength} characters and more than ${Constants.minReportLength} characters";
                  });
                }
              } else {
                setState(() {
                  errorMessage = "Fill the field".tr();
                });
              }
            },
            style: ElevatedButton.styleFrom(
              elevation: 3,
              padding: EdgeInsets.symmetric(vertical: 12.0),
              backgroundColor: Theme.of(context).colorScheme.onSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Constants.cornerRadiusSmall),
              ),
            ),
            child: Text("Confirm".tr(), style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.surface)),
          )
        ],
      ),
    );
  }
}
