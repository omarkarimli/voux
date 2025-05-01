import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../utils/extensions.dart';
import '../../models/clothing_item_model.dart';
import '../reusables/confirm_bottom_sheet.dart';
import '../../di/locator.dart';
import '../../utils/constants.dart';

class ChatBottomSheet extends StatefulWidget {
  final List<ClothingItemModel> clothingItems;
  
  const ChatBottomSheet({
    super.key,
    required this.clothingItems
  });

  @override
  State<ChatBottomSheet> createState() => _ChatBottomSheetState();
}

class _ChatBottomSheetState extends State<ChatBottomSheet> {
  final DraggableScrollableController _sheetController = DraggableScrollableController();
  final TextEditingController _textController = TextEditingController();
  final List<_ChatMessage> _messages = [];

  bool _showInput = false;
  bool _isLoading = false;
  bool _shouldCancel = false;
  bool _isMinimized = true;
  bool _showItemList = false;

  @override
  void initState() {
    super.initState();
    _sheetController.addListener(_onSizeChanged);

    _textController.addListener(() {
      // Trigger rebuild when the text changes
      setState(() {});
    });

    String initialMessage = "${widget.clothingItems.map((item) => item.name).join(', ')} how much price is each? and give alternatives, write compactly";
    _sendMessage(initialMessage);
  }

  void _onSizeChanged() {
    final isExpanded = _sheetController.size > 0.2;
    final isMinimized = (_sheetController.size - 0.125).abs() < 0.01;

    if (_showInput != isExpanded || _isMinimized != isMinimized) {
      setState(() {
        _showInput = isExpanded;
        _isMinimized = isMinimized;
      });
    }
  }

  void _sendMessage(String t) {
    if (t.isNotEmpty && !_isLoading && t.length <= 512) {
      setState(() {
        _messages.add(_ChatMessage(text: t, isUser: true));
        _isLoading = true;
        _textController.clear();
      });

      think(t).then((responseText) {
        setState(() {
          _messages.add(_ChatMessage(text: responseText, isUser: false));
          _isLoading = false;
        });
      }).catchError((error) {
        // Handle any error that might occur when calling think()
        setState(() {
          _messages.add(_ChatMessage(text: "Error occurred", isUser: false));
          _isLoading = false;
        });
      });
    }
  }

  Future<String> think(String t) async {
    _shouldCancel = false; // reset cancel flag when starting

    try {
      final content = [
        Content.multi([TextPart(t)])
      ];

      final response = await locator<GenerativeModel>().generateContent(content);

      // Check cancellation before using result
      if (_shouldCancel) return "Cancelled by user";

      return response.text ?? "Error occurred";
    } catch (e) {
      if (kDebugMode) {
        print("❌ Chat Error: $e");
      }
      return "Error occurred";
    }
  }

  void stopThinking() {
    if (_isLoading) {
      setState(() {
        _shouldCancel = true;
        _isLoading = false;
      });
    }
  }

  void _clearMessages() {
    setState(() {
      _messages.clear();
    });
  }

  @override
  void dispose() {
    _sheetController.removeListener(_onSizeChanged);
    _sheetController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double minChildSize = 0.125;
    double maxChildSize = 0.85;
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: minChildSize,
      minChildSize: minChildSize,
      maxChildSize: maxChildSize,
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
                                  if (_messages.isNotEmpty && !_isLoading) {
                                    showModalBottomSheet(
                                      context: context,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                                      ),
                                      builder: (context) {
                                        return ConfirmBottomSheet(function: _clearMessages);
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
                                  _sheetController.animateTo(
                                    _isMinimized ? maxChildSize : minChildSize, // Toggle size
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeOut,
                                  );
                                },
                                icon: Icon(
                                  _isMinimized
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
                          if (_messages.isEmpty)
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
                            ..._messages.map((msg) {
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
                          SizedBox(height: _messages.isNotEmpty ? 42 : 0),
                          if (_isLoading)
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
                bottom: _showInput ? MediaQuery.of(context).padding.bottom + 16 : -100,
                left: 16,
                right: 16,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _showInput ? 1 : 0,
                  child: Column(
                    children: [
                      if (_showItemList) ...[
                        Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(Constants.cornerRadiusMedium),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.onSurface.withAlpha(50),
                                width: 2,
                              ),
                            ),
                            child: ListView.builder(
                              clipBehavior: Constants.clipBehaviour,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shrinkWrap: true,
                              itemCount: widget.clothingItems.length,
                              itemBuilder: (context, index) {
                                final item = widget.clothingItems[index];
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _textController.text = "${item.name} price and alternatives?";
                                          _showItemList = false;
                                        });
                                      },
                                      child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Text(item.name, style: Theme.of(context).textTheme.titleMedium),
                                              if (item.brand != Constants.unknown)
                                                Text(item.brand),
                                            ],
                                          )
                                      ),
                                    ),
                                    // Divider between list items
                                    if (index < widget.clothingItems.length - 1)
                                      Divider(
                                          color: Theme.of(context).colorScheme.onSurface.withAlpha(50),
                                          thickness: 2,
                                          height: 20
                                      ),
                                  ],
                                );
                              },
                            )
                        ),
                        const SizedBox(height: 16)
                      ],
                      Container(
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
                                controller: _textController,
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
                                  if (_isLoading) {
                                    stopThinking();
                                  } else {
                                    if (_textController.text.isNotEmpty) {
                                      _sendMessage(_textController.text);  // Send text message
                                    } else {
                                      setState(() {
                                        _showItemList = !_showItemList;  // Toggle list display
                                      });
                                    }
                                  }
                                },
                                icon: _buildIcon(),
                              ),
                            ),
                          ],
                        )
                      )
                    ],
                  )
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIcon() {
    Widget icon;

    if (_isLoading) {
      icon = Icon(Icons.stop_rounded, key: ValueKey('stop'), color: Theme.of(context).colorScheme.surface);
    } else {
      if (_textController.text.isNotEmpty) {
        icon = Icon(Icons.arrow_upward_rounded, key: ValueKey('arrow'), color: Theme.of(context).colorScheme.surface);
      } else {
        if (_showItemList) {
          icon = Icon(Icons.close_rounded, key: ValueKey('close'), color: Theme.of(context).colorScheme.surface);
        } else {
          icon = Image.asset(
            'assets/images/stack.png',
            key: ValueKey('stack'),
            width: 22,
            height: 22,
            color: Theme.of(context).colorScheme.surface,
          );
        }
      }
    }

    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => RotationTransition(
        turns: animation,
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: icon,
    );
  }

}

// Simple message model
class _ChatMessage {
  final String text;
  final bool isUser;

  _ChatMessage({required this.text, required this.isUser});
}
