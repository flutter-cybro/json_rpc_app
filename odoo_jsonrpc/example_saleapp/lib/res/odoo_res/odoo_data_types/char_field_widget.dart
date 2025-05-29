import 'package:flutter/material.dart';

class CharFieldWidget extends StatefulWidget {
  final String name;
  final String value;
  final Function(String)? onChanged;
  final bool readonly;
  final String? hintText;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? maxLength;
  final bool obscureText;

  const CharFieldWidget({
    required this.name,
    required this.value,
    this.onChanged,
    this.readonly = false,
    this.hintText,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
    this.obscureText = false,
    Key? key,
  }) : super(key: key);

  @override
  _CharFieldWidgetState createState() => _CharFieldWidgetState();
}

class _CharFieldWidgetState extends State<CharFieldWidget> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });

    if (!_focusNode.hasFocus && !widget.readonly) {
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
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            widget.name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: _isFocused && !widget.readonly
                ? [
              BoxShadow(
                color: theme.primaryColor.withOpacity(0.2),
                blurRadius: 6,
                spreadRadius: 1,
              )
            ]
                : null,
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            enabled: !widget.readonly,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: widget.readonly
                  ? (isDarkMode ? Colors.white54 : Colors.black54)
                  : (isDarkMode ? Colors.white : Colors.black),
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: isDarkMode ? Colors.white38 : Colors.black38,
              ),
              filled: true,
              fillColor: widget.readonly
                  ? (isDarkMode
                  ? Colors.grey[900]!.withOpacity(0.3)
                  : Colors.grey[200]!.withOpacity(0.5))
                  : (isDarkMode
                  ? Colors.grey[850]!
                  : Colors.grey[50]!),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: isDarkMode
                      ? Colors.grey[700]!
                      : Colors.grey[300]!,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: theme.primaryColor,
                  width: 2,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: isDarkMode
                      ? Colors.grey[700]!
                      : Colors.grey[300]!,
                  width: 1,
                ),
              ),
              suffixIcon: widget.readonly
                  ? const Padding(
                padding: EdgeInsets.all(12.0),
                child: Icon(Icons.lock_outline, size: 18),
              )
                  : null,
            ),
          ),
        ),
        if (widget.maxLength != null) ...[
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${_controller.text.length}/${widget.maxLength}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDarkMode ? Colors.white54 : Colors.black54,
              ),
            ),
          ),
        ],
      ],
    );
  }
}