import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:voux/presentation/reusables/confirm_bottom_sheet.dart';
import '../../utils/constants.dart';

class ChatBottomSheet extends StatefulWidget {
  const ChatBottomSheet({super.key});

  @override
  State<ChatBottomSheet> createState() => _ChatBottomSheetState();
}

class _ChatBottomSheetState extends State<ChatBottomSheet> {
  final DraggableScrollableController _sheetController = DraggableScrollableController();
  final TextEditingController _textController = TextEditingController();
  final List<_ChatMessage> _messages = [];

  bool _showInput = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _sheetController.addListener(_onSizeChanged);
  }

  void _onSizeChanged() {
    final isExpanded = _sheetController.size > 0.2;
    if (_showInput != isExpanded) {
      setState(() => _showInput = isExpanded);
    }
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isNotEmpty && !_isLoading) {
      setState(() {
        _messages.add(_ChatMessage(text: text, isUser: true));
        _isLoading = true;
        _textController.clear();
      });

      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _messages.add(_ChatMessage(text: "Here's a suggestion from Voux!", isUser: false));
          _isLoading = false;
        });
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
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: 0.125,
      minChildSize: 0.125,
      maxChildSize: 0.85,
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
                              right: 0,
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
                                icon: Icon(Icons.delete_sweep_rounded),
                              ),
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
                          ..._messages.map((msg) {
                            final alignment = msg.isUser ? Alignment.centerRight : Alignment.centerLeft;
                            final color = msg.isUser
                                ? Theme.of(context).colorScheme.primary.withAlpha(75)
                                : Theme.of(context).colorScheme.secondary.withAlpha(25);
                            final textColor = Theme.of(context).colorScheme.onSurface;

                            return Align(
                              alignment: alignment,
                              child: Container(
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
                                child: Text(
                                  msg.text,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor),
                                ),
                              ),
                            );
                          }),
                          if (_isLoading)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    Image.asset(
                                      "assets/images/app_icon.png",
                                      width: 54,
                                      height: 54,
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
                  child: Container(
                    padding: const EdgeInsets.only(left: 16, right: 4),
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
                            controller: _textController,
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
                            onPressed: _sendMessage,
                            icon: Icon(Icons.arrow_upward_rounded, color: Theme.of(context).colorScheme.surface),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Simple message model
class _ChatMessage {
  final String text;
  final bool isUser;

  _ChatMessage({required this.text, required this.isUser});
}
