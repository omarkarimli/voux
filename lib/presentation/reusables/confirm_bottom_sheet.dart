import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../di/locator.dart';
import '../../utils/extensions.dart';
import '../../models/clothing_item_model.dart';
import '../../models/optional_analysis_result_model.dart';
import '../../utils/constants.dart';
import 'more_bottom_sheet_view_model.dart';

class ConfirmBottomSheet extends StatefulWidget {
  final Function function;

  const ConfirmBottomSheet({
    super.key,
    required this.function
  });

  @override
  _ConfirmBottomSheetState createState() => _ConfirmBottomSheetState();
}

class _ConfirmBottomSheetState extends State<ConfirmBottomSheet> {
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
                Text("Are you sure?", style: Theme.of(context).textTheme.titleLarge),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close),
                )
              ]
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => widget.function,
            style: ElevatedButton.styleFrom(
              elevation: 3,
              padding: EdgeInsets.symmetric(vertical: 12.0),
              backgroundColor: Theme.of(context).colorScheme.onSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Constants.cornerRadiusSmall),
              ),
            ),
            child: Text("Confirm", style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.surface)),
          )
        ],
      ),
    );
  }
}
