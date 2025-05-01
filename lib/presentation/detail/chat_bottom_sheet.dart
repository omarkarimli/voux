import 'package:flutter/material.dart';

import '../../utils/constants.dart';

class ChatBottomSheet extends StatefulWidget {

  const ChatBottomSheet({super.key});

  @override
  State<ChatBottomSheet> createState() => _ChatBottomSheetState();
}

class _ChatBottomSheetState extends State<ChatBottomSheet> {
  final DraggableScrollableController _sheetController = DraggableScrollableController();
  final TextEditingController _textController = TextEditingController();
  final List<String> _messages = [];

  bool _showInput = false;

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
    if (text.isNotEmpty) {
      setState(() {
        _messages.add(text);
        _textController.clear();
      });
    }
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
      initialChildSize: 0.15,
      minChildSize: 0.15,
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
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: Text(
                          'Chat',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),

                    // Messages list
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _messages
                            .map(
                              (msg) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withAlpha(25),
                                borderRadius: BorderRadius.circular(Constants.cornerRadiusLarge),
                              ),
                              child: Text(
                                msg,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ),
                        )
                            .toList(),
                      ),
                    ),

                    const SizedBox(height: 80), // Reserve space for input
                  ],
                ),
              ),

              // Animated input
              AnimatedPositioned(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeOut,
                bottom: _showInput ? MediaQuery.of(context).padding.bottom + 16 : -100,
                left: 16,
                right: 16,
                child: AnimatedOpacity(
                  duration: Duration(milliseconds: 300),
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
