import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EmailFieldWidget extends StatefulWidget {
  final String name;
  final String value;
  final Function(String) onChanged;
  final bool readonly;
  final bool submitOnUnfocus; // New parameter to control when to submit

  const EmailFieldWidget({
    Key? key,
    required this.name,
    required this.value,
    required this.onChanged,
    this.readonly = false,
    this.submitOnUnfocus = true, // Default to submitting when unfocused
  }) : super(key: key);

  @override
  _EmailFieldWidgetState createState() => _EmailFieldWidgetState();
}

class _EmailFieldWidgetState extends State<EmailFieldWidget> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isFocused = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.value == 'false' ? '' : widget.value,
    );
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
    _controller.addListener(_validateEmail);
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });

    // Submit when losing focus if enabled and valid
    if (!_focusNode.hasFocus &&
        !widget.readonly &&
        widget.submitOnUnfocus &&
        _errorText == null) {
      _submitToOdoo();
    }
  }

  void _validateEmail() {
    final value = _controller.text;
    setState(() {
      if (value.isNotEmpty &&
          !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
        _errorText = 'Please enter a valid email address';
      } else {
        _errorText = null;
      }
    });
  }

  void _submitToOdoo() {
    if (_errorText == null && _controller.text != widget.value) {
      widget.onChanged(_controller.text);
    }
  }

  @override
  void didUpdateWidget(EmailFieldWidget oldWidget) {
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            readOnly: widget.readonly,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _errorText != null
                      ? Colors.red
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _errorText != null
                      ? Colors.red
                      : (isDarkMode ? Colors.grey[700]! : Colors.grey.shade300),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _errorText != null
                      ? Colors.red
                      : theme.primaryColor,
                  width: 2,
                ),
              ),
              prefixIcon: const Icon(
                FontAwesomeIcons.envelope,
                size: 16,
                color: Colors.grey,
              ),
              hintText: 'Enter email address',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
              ),
              filled: true,
              fillColor: widget.readonly
                  ? (isDarkMode ? Colors.grey[900]!.withOpacity(0.3) : Colors.grey.shade100)
                  : (isDarkMode ? Colors.grey[850]! : Colors.white),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 12,
              ),
              errorText: _errorText,
              suffixIcon: _isFocused && !widget.readonly
                  ? IconButton(
                icon: const Icon(Icons.check_circle_outline, size: 20),
                color: _errorText == null
                    ? theme.primaryColor
                    : Colors.grey,
                onPressed: _errorText == null
                    ? _submitToOdoo
                    : null,
              )
                  : null,
            ),
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
            onSubmitted: (_) => _submitToOdoo(),
          ),
        ],
      ),
    );
  }
}