import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IntegerFieldWidget extends StatefulWidget {
  final String name;
  final int? value;
  final ValueChanged<int>? onChanged;
  final bool readonly;
  final Color? borderColor;
  final Color? buttonColor;
  final Color? textColor;
  final Color? fillColor;
  final int? minValue;
  final int? maxValue;
  final double? buttonSize;

  const IntegerFieldWidget({
    Key? key,
    required this.name,
    required this.value,
    this.onChanged,
    this.readonly = false,
    this.borderColor,
    this.buttonColor,
    this.textColor,
    this.fillColor,
    this.minValue,
    this.maxValue,
    this.buttonSize = 40.0,
  }) : super(key: key);

  @override
  _IntegerFieldWidgetState createState() => _IntegerFieldWidgetState();
}

class _IntegerFieldWidgetState extends State<IntegerFieldWidget> {
  late TextEditingController _controller;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value?.toString() ?? '0');
  }

  void _updateValue(String newValue) {
    if (widget.readonly) return;

    if (newValue.isEmpty) {
      setState(() => _hasError = true);
      return;
    }

    final intValue = int.tryParse(newValue);
    setState(() {
      _hasError = intValue == null;
    });

    if (intValue != null && _isWithinRange(intValue)) {
      _controller.text = newValue; // Keep the exact text entered
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
      widget.onChanged?.call(intValue);
    }
  }

  bool _isWithinRange(int value) {
    if (widget.minValue != null && value < widget.minValue!) return false;
    if (widget.maxValue != null && value > widget.maxValue!) return false;
    return true;
  }

  void _increment() {
    if (widget.readonly) return;
    int newValue = (int.tryParse(_controller.text) ?? 0) + 1;
    if (_isWithinRange(newValue)) {
      _controller.text = newValue.toString();
      setState(() => _hasError = false);
      widget.onChanged?.call(newValue);
      HapticFeedback.lightImpact();
    }
  }

  void _decrement() {
    if (widget.readonly) return;
    int newValue = (int.tryParse(_controller.text) ?? 0) - 1;
    if (_isWithinRange(newValue)) {
      _controller.text = newValue.toString();
      setState(() => _hasError = false);
      widget.onChanged?.call(newValue);
      HapticFeedback.lightImpact();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: widget.textColor ?? theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextFormField(
              controller: _controller,
              keyboardType: TextInputType.numberWithOptions(
                signed: widget.minValue != null && widget.minValue! < 0,
                decimal: false,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^-?\d*')),
                TextInputFormatter.withFunction((oldValue, newValue) {
                  // Prevent multiple negative signs
                  if (newValue.text == '-' ||
                      (newValue.text.startsWith('-') &&
                          newValue.text.substring(1).contains('-'))) {
                    return oldValue;
                  }
                  return newValue;
                }),
              ],
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: widget.textColor ?? theme.textTheme.bodyLarge?.color,
              ),
              enabled: !widget.readonly,
              decoration: InputDecoration(
                contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _hasError
                        ? theme.colorScheme.error
                        : widget.borderColor ?? theme.dividerColor,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: widget.borderColor ?? theme.primaryColor,
                    width: 1.5,
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: widget.borderColor ?? theme.dividerColor,
                    width: 1,
                  ),
                ),
                filled: true,
                fillColor: widget.fillColor ??
                    theme.inputDecorationTheme.fillColor ??
                    Colors.grey[100],
                prefixIcon: _buildArrowButton(
                  icon: Icons.remove,
                  onPressed: widget.readonly ? null : _decrement,
                  isIncrement: false,
                  tooltip: 'Decrement',
                ),
                suffixIcon: _buildArrowButton(
                  icon: Icons.add,
                  onPressed: widget.readonly ? null : _increment,
                  isIncrement: true,
                  tooltip: 'Increment',
                ),
                errorText: _hasError
                    ? 'Invalid number${widget.minValue != null || widget.maxValue != null ? " (Range: ${widget.minValue ?? '-∞'} - ${widget.maxValue ?? '∞'})" : ""}'
                    : null,
              ),
              onChanged: _updateValue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArrowButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required bool isIncrement,
    required String tooltip,
  }) {
    final theme = Theme.of(context);
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: widget.buttonSize,
          height: widget.buttonSize,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.buttonColor ?? theme.primaryColor.withOpacity(0.2),
                widget.buttonColor ?? theme.primaryColor.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: widget.buttonSize != null ? widget.buttonSize! * 0.5 : 20,
            color: onPressed == null
                ? theme.disabledColor
                : widget.buttonColor ?? theme.primaryColor,
          ),
        ),
      ),
    );
  }
}