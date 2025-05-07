import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class ConfirmBottomSheet extends StatefulWidget {
  final Function function;
  final String title;

  const ConfirmBottomSheet({
    super.key,
    required this.function,
    required this.title
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
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 36,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 48.0), // space for close button
                child: Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleLarge,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              widget.function();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              elevation: 3,
              padding: EdgeInsets.symmetric(vertical: 12.0),
              backgroundColor: Theme.of(context).colorScheme.onSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Constants.cornerRadiusSmall),
              ),
            ),
            child: Text(
              "Confirm".tr(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
          )
        ],
      ),
    );
  }
}
