import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/detail/chat_bottom_sheet_view_model.dart';
import '../reusables/confirm_bottom_sheet.dart';
import '../../models/clothing_item_model.dart';
import '../../utils/extensions.dart';
import '../../utils/constants.dart';

class ChatBottomSheet extends StatefulWidget {
  final List<ClothingItemModel> clothingItems;

  const ChatBottomSheet({
    super.key,
    required this.clothingItems,
  });

  @override
  _ChatBottomSheetState createState() => _ChatBottomSheetState();
}

class _ChatBottomSheetState extends State<ChatBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatBottomSheetViewModel(clothingItems: widget.clothingItems)..initialize(),
      child: Consumer<ChatBottomSheetViewModel>(
        builder: (context, viewModel, child) {
          return Container(
            height: 512,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(Constants.cornerRadiusLarge)),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(50),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onSurface.withAlpha(50),
                        borderRadius: BorderRadius.circular(Constants.cornerRadiusLarge),
                      ),
                    ),
                  ),
                ),

                // Chat title
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            'Chat',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 8,
                          top: 0,
                          bottom: 0,
                          child: IconButton(
                            onPressed: () {
                              if (viewModel.messages.isNotEmpty && !viewModel.isLoading) {
                                showModalBottomSheet(
                                  context: context,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                                  ),
                                  builder: (context) {
                                    return ConfirmBottomSheet(function: viewModel.clearMessages);
                                  },
                                );
                              }
                            },
                            icon: Icon(Icons.clear_all_rounded, semanticLabel: 'Clear messages'),
                          ),
                        ),
                        Positioned(
                            right: 8,
                            top: 0,
                            bottom: 0,
                            child: IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(Icons.close_rounded, semanticLabel: 'Close chat'),
                            )
                        ),
                      ],
                    ),
                  ),
                ),

                // Messages
                Expanded(
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                        child: SingleChildScrollView(
                          reverse: true, // To show the latest message at the bottom
                          controller: viewModel.scrollController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (viewModel.messages.isEmpty)
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 24),
                                    child: Text(
                                      "No messages yet. Start the conversation!",
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurface.withAlpha(75),
                                      ),
                                    ),
                                  ),
                                )
                              else
                                ...viewModel.messages.map((msg) {
                                  final alignment = msg.isUser ? Alignment.centerRight : Alignment.centerLeft;
                                  final color = msg.isUser
                                      ? Theme.of(context).colorScheme.primary.withAlpha(70)
                                      : Theme.of(context).colorScheme.secondary.withAlpha(15);
                                  final textColor = Theme.of(context).colorScheme.onSurface;

                                  return Align(
                                    alignment: alignment,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (!msg.isUser)
                                          Padding(
                                            padding: const EdgeInsets.only(right: 8),
                                            child: Image.asset(
                                              Theme.of(context).brightness == Brightness.dark
                                                  ? 'assets/images/logo_dark.png'
                                                  : 'assets/images/logo_light.png',
                                              width: 36,
                                              height: 36,
                                            ),
                                          ),
                                        Container(
                                          margin: const EdgeInsets.symmetric(vertical: 6),
                                          padding: const EdgeInsets.all(12),
                                          constraints: const BoxConstraints(maxWidth: 280),
                                          decoration: BoxDecoration(
                                            color: color,
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: const Radius.circular(12),
                                              bottomRight: const Radius.circular(12),
                                              topRight: msg.isUser ? const Radius.circular(0) : const Radius.circular(12),
                                              topLeft: msg.isUser ? const Radius.circular(12) : const Radius.circular(0),
                                            ),
                                          ),
                                          child: SelectableText.rich(
                                            TextSpan(
                                              children: msg.text.toStyledTextSpans(
                                                Theme.of(context).textTheme.bodyMedium!.copyWith(color: textColor),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              if (viewModel.isLoading)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Image.asset(
                                          Theme.of(context).brightness == Brightness.dark
                                              ? 'assets/images/logo_dark.png'
                                              : 'assets/images/logo_light.png',
                                          width: 36,
                                          height: 36,
                                        ),
                                        const SizedBox(width: 8),
                                        CupertinoActivityIndicator(
                                          radius: 12.0,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                              if (viewModel.messages.isNotEmpty)
                                const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),

                      // Scroll Down Button
                      if (!viewModel.isAtBottom)
                        Positioned(
                          bottom: 16,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: ElevatedButton(
                              onPressed: () {
                                viewModel.scrollController.animateTo(
                                  viewModel.scrollController.position.minScrollExtent,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(12),
                                backgroundColor: Theme.of(context).colorScheme.primary,
                              ),
                              child: Icon(Icons.arrow_downward, color: Theme.of(context).colorScheme.surface),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Input
                Padding(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: MediaQuery.of(context).padding.bottom + 12,
                    top: 8
                  ),
                  child: Container(
                      padding: const EdgeInsets.only(left: 16, right: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(Constants.cornerRadiusMedium),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.onSurface.withAlpha(50),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: viewModel.textController,
                              maxLength: 512,
                              maxLines: null,
                              decoration: const InputDecoration(
                                hintText: "Ask Voux",
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.onSurface,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                if (viewModel.isLoading) {
                                  viewModel.stopThinking();
                                } else {
                                  if (viewModel.textController.text.isNotEmpty) {
                                    viewModel.sendMessage(viewModel.textController.text);  // Send text message
                                  } else {
                                    showItemPicker(context, viewModel, widget.clothingItems);
                                  }
                                }
                              },
                              icon: buildIcon(context, viewModel),
                            ),
                          ),
                        ],
                      )
                  )
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildIcon(BuildContext context, ChatBottomSheetViewModel viewModel) {
    Widget icon;

    if (viewModel.isLoading) {
      icon = Icon(
          Icons.stop_rounded,
          key: ValueKey('stop'),
          color: Theme.of(context).colorScheme.surface
      );
    } else {
      if (viewModel.textController.text.isNotEmpty) {
        icon = Icon(
            key: ValueKey('arrow'),
            Icons.arrow_upward_rounded,
            color: Theme.of(context).colorScheme.surface
        );
      } else {
        icon = Icon(
            CupertinoIcons.square_stack_3d_up,
            key: ValueKey('stack'),
            color: Theme.of(context).colorScheme.surface
        );
      }
    }

    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => RotationTransition(
        turns: Tween<double>(begin: 0.75, end: 1.0).animate(animation),
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: icon,
    );
  }

  // Show language selection sheet
  void showItemPicker(BuildContext context, ChatBottomSheetViewModel viewModel, List<ClothingItemModel> clothingItems) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        int selectedIndex = 0;

        return Padding(
          padding: EdgeInsets.only(
            left: 18,
            right: 18,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 96,
                child: CupertinoPicker(
                  itemExtent: 40.0,
                  scrollController: FixedExtentScrollController(initialItem: selectedIndex),
                  onSelectedItemChanged: (int index) {
                    selectedIndex = index;
                  },
                  children: clothingItems.map((item) {
                    return Center(child: Text(item.name.truncateWithEllipsis(22), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.normal), overflow: TextOverflow.ellipsis, maxLines: 1));
                  }).toList(),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  viewModel.setControllerText("${clothingItems[selectedIndex].name} price and alternatives?");

                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  elevation: 3,
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  backgroundColor: Theme.of(context).colorScheme.onSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text("Select", style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.surface)),
              ),
            ],
          ),
        );
      },
    );
  }
}
