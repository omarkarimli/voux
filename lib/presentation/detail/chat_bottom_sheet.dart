import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../reusables/confirm_bottom_sheet.dart';
import '../../models/clothing_item_model.dart';
import '../../utils/extensions.dart';
import '../../utils/constants.dart';
import 'chat_bottom_sheet_view_model.dart';

class ChatBottomSheetWrapper extends StatelessWidget {
  final List<ClothingItemModel> clothingItems;

  const ChatBottomSheetWrapper({super.key, required this.clothingItems});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatViewModel(clothingItems: clothingItems),
      child: ChatBottomSheet(clothingItems: clothingItems), // This is your UI
    );
  }
}

class ChatBottomSheet extends StatelessWidget {
  final List<ClothingItemModel> clothingItems;

  const ChatBottomSheet({
    super.key,
    required this.clothingItems,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ChatViewModel>();

    return DraggableScrollableSheet(
      controller: viewModel.sheetController,
      initialChildSize: viewModel.minChildSize,
      minChildSize: viewModel.minChildSize,
      maxChildSize: viewModel.maxChildSize,
      builder: (context, scrollController) {
        return Container(
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
          child: Stack(
            children: [
              SingleChildScrollView(
                controller: scrollController,
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

                    // Heading
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
                                icon: Icon(
                                    Icons.clear_all_rounded
                                ),
                              ),
                            ),
                            Positioned(
                                right: 8,
                                top: 0,
                                bottom: 0,
                                child: IconButton(
                                  onPressed: () {
                                    viewModel.sheetController.animateTo(
                                      viewModel.isMinimized ? viewModel.maxChildSize : viewModel.minChildSize, // Toggle size
                                      duration: const Duration(milliseconds: 400),
                                      curve: Curves.easeOut,
                                    );
                                  },
                                  icon: Icon(
                                    viewModel.isMinimized
                                        ? Icons.keyboard_arrow_up_rounded // Maximize icon
                                        : Icons.keyboard_arrow_down_rounded, // Minimize icon
                                  ),
                                )
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Messages
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 16
                      ),
                      child: Column(
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
                                    if (!msg.isUser) // Display image if message is not from the user
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8), // Space between image and container
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
                                            children: msg.text.toStyledTextSpans(Theme.of(context).textTheme.bodyMedium!.copyWith(color: textColor)),
                                          ),
                                        )
                                    ),
                                  ],
                                ),
                              );
                            }),
                          SizedBox(height: viewModel.messages.isNotEmpty ? 42 : 0),
                          if (viewModel.isLoading)
                            Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
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
                                      )
                                    ],
                                  ),
                                )
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 80), // Space for input
                  ],
                ),
              ),

              // Input field
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                bottom: viewModel.showInput ? MediaQuery.of(context).padding.bottom + 16 : -100,
                left: 16,
                right: 16,
                child: Container(
                    padding: const EdgeInsets.only(left: 18, right: 8, bottom: 2, top: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(Constants.cornerRadiusLarge),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.onSurface.withAlpha(50),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            controller: viewModel.textController,
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
                                  showItemPicker(context, viewModel, clothingItems);
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
    );
  }

  Widget buildIcon(BuildContext context, ChatViewModel viewModel) {
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
  void showItemPicker(BuildContext context, ChatViewModel viewModel, List<ClothingItemModel> clothingItems) {
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