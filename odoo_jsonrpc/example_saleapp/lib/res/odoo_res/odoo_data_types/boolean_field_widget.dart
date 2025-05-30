import 'dart:developer';

import 'package:flutter/material.dart';

class BooleanFieldWidget extends StatefulWidget {
  final String? label;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String viewType;
  final bool readOnly;

  const BooleanFieldWidget({
    super.key,
    this.label,
    required this.value,
    this.onChanged,
    required this.viewType,
    this.readOnly = false,
  });

  @override
  _BooleanFieldWidgetState createState() => _BooleanFieldWidgetState();
}

class _BooleanFieldWidgetState extends State<BooleanFieldWidget> {
  late bool _currentValue;

  @override
  void initState() {
    super.initState();
    log("BooleanFieldWidget  : ${widget.readOnly}");
    _currentValue = widget.value;
  }

  void _onChanged(bool? newValue) {
    if (newValue != null && !widget.readOnly) {
      setState(() {
        _currentValue = newValue;
      });
      widget.onChanged?.call(newValue);
    }
  }

  @override
  void didUpdateWidget(BooleanFieldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      setState(() {
        _currentValue = widget.value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.viewType == 'tree'
        ? _buildTreeView()
        : _buildFormView(context);
  }

  Widget _buildTreeView() {
    return Checkbox(
      value: _currentValue,
      onChanged: widget.readOnly ? null : _onChanged, // Disable if readOnly
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      activeColor: Theme.of(context).primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (widget.readOnly && states.contains(WidgetState.disabled)) {
          return Theme.of(context).disabledColor.withOpacity(0.5); // Gray out when disabled
        }
        return null; // Use default colors otherwise
      }),
    );
  }

  Widget _buildFormView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.label != null && widget.label!.isNotEmpty) ...[
                Expanded(
                  flex: 3,
                  child: Text(
                    widget.label!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: widget.readOnly
                          ? Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)
                          : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.9),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                const SizedBox(width: 12.0),
              ],
              Checkbox(
                value: _currentValue,
                onChanged: widget.readOnly ? null : _onChanged, // Disable if readOnly
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                activeColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
                fillColor: WidgetStateProperty.resolveWith((states) {
                  if (widget.readOnly && states.contains(WidgetState.disabled)) {
                    return Theme.of(context).disabledColor.withOpacity(0.5); // Gray out when disabled
                  }
                  return null; // Use default colors otherwise
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}