import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PhoneFieldWidget extends StatefulWidget {
  final String name;
  final String value;
  final Function(String) onChanged;
  final bool readonly;
  final bool submitOnUnfocus; // Controls whether to submit when field loses focus

  const PhoneFieldWidget({
    Key? key,
    required this.name,
    required this.value,
    required this.onChanged,
    this.readonly = false,
    this.submitOnUnfocus = true, // Default to submitting when unfocused
  }) : super(key: key);

  @override
  _PhoneFieldWidgetState createState() => _PhoneFieldWidgetState();
}

class _PhoneFieldWidgetState extends State<PhoneFieldWidget> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isFocused = false;
  String _lastSubmittedValue = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.value == 'false' ? '' : widget.value,
    );
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
    _lastSubmittedValue = widget.value;
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });

    if (!_focusNode.hasFocus &&
        !widget.readonly &&
        widget.submitOnUnfocus &&
        _controller.text != _lastSubmittedValue) {
      _submitToOdoo();
    }
  }

  void _submitToOdoo() {
    if (_controller.text != _lastSubmittedValue) {
      widget.onChanged(_controller.text);
      _lastSubmittedValue = _controller.text;
    }
  }

  @override
  void didUpdateWidget(PhoneFieldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = widget.value;
      _lastSubmittedValue = widget.value;
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
                  color: isDarkMode ? Colors.grey[700]! : Colors.grey.shade300,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDarkMode ? Colors.grey[700]! : Colors.grey.shade300,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.primaryColor,
                  width: 2,
                ),
              ),
              prefixIcon: const Icon(
                FontAwesomeIcons.phone,
                size: 16,
                color: Colors.grey,
              ),
              suffixIcon: _isFocused && !widget.readonly
                  ? IconButton(
                icon: const Icon(Icons.check, size: 20),
                color: theme.primaryColor,
                onPressed: _submitToOdoo,
              )
                  : null,
              hintText: 'Enter phone number',
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
            ),
            keyboardType: TextInputType.phone,
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