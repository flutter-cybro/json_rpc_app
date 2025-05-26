import 'package:flutter/material.dart';

class CharFieldWidget extends StatefulWidget {
  final String name;
  final String value;
  final Function(String)? onChanged;
  final bool readonly;

  const CharFieldWidget({
    required this.name,
    required this.value,
    this.onChanged,
    this.readonly = false,
    Key? key,
  }) : super(key: key);

  @override
  _CharFieldWidgetState createState() => _CharFieldWidgetState();
}

class _CharFieldWidgetState extends State<CharFieldWidget> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange); // Add listener for focus changes
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && !widget.readonly) {
      // Only trigger onChanged when focus is lost and not readonly
      widget.onChanged?.call(_controller.text);
    }
  }

  @override
  void didUpdateWidget(CharFieldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange); // Clean up listener
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '${widget.name}:',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode, // Assign FocusNode
              enabled: !widget.readonly, // Disable input if readonly
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 1.5),
                ),
                disabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1),
                ),
              ),
              // Remove onChanged to avoid immediate updates
            ),
          ),
        ],
      ),
    );
  }
}