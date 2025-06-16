import 'package:flutter/material.dart';

class CharWithPlaceholderFieldWidget extends StatelessWidget {
  final String name;
  final String value;
  final String? hintText;
  final bool readOnly;
  final String viewType;

  const CharWithPlaceholderFieldWidget({
    Key? key,
    required this.name,
    required this.value,
    this.hintText,
    this.readOnly = true,
    this.viewType = 'tree',
  }) : super(key: key);

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      value.isEmpty ? hintText ?? 'Enter $name' : value,
      style: TextStyle(
        fontSize: 16.0,
        color: value.isEmpty ? Colors.grey.shade500 : Colors.black87,
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
    child: TextField(
      controller: _controller,
      focusNode: _focusNode,
      enabled: !widget.readonly,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      obscureText: widget.obscureText,
      keyboardType: widget.isEmailField
          ? TextInputType.emailAddress
          : widget.keyboardType,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: widget.readonly
            ? (isDarkMode ? Colors.white54 : Colors.black54)
            : (isDarkMode ? Colors.white : Colors.black),
      ),
      decoration: InputDecoration(
        hintText: widget.hintText ?? (widget.isEmailField ? 'Enter email address' : null),
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
          borderSide: BorderSide(
            color: _errorText != null
                ? Colors.red
                : Colors.transparent,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: _errorText != null
                ? Colors.red
                : (isDarkMode ? Colors.grey[700]! : Colors.grey[300]!),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: _errorText != null
                ? Colors.red
                : theme.primaryColor,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
            width: 1,
          ),
        ),
        suffixIcon: widget.readonly
            ? const Padding(
          padding: EdgeInsets.all(12.0),
          child: Icon(Icons.lock_outline, size: 18),
        )
            : widget.isEmailField
            ? const Padding(
          padding: EdgeInsets.all(12.0),
          child: Icon(Icons.email_outlined, size: 18),
        )
            : null,
        errorText: _errorText,
      ),
      onSubmitted: (value) {
        if (widget.isEmailField && _errorText == null) {
          widget.onChanged?.call(value);
        }
      },
    ),

  }
}