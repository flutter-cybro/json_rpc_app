import 'dart:developer';

import 'package:flutter/material.dart';

class Many2OneFieldWidget extends StatefulWidget {
  final String name;
  final dynamic value;
  final List<Map<String, dynamic>> options;
  final Function(dynamic) onValueChanged;
  final String viewType;
  final bool readonly;
  final String? hintText;

  const Many2OneFieldWidget({
    required this.name,
    required this.value,
    required this.options,
    required this.onValueChanged,
    super.key,
    this.viewType = 'form',
    this.readonly = false,
    this.hintText,
  });

  @override
  _Many2OneFieldWidgetState createState() => _Many2OneFieldWidgetState();
}

class _Many2OneFieldWidgetState extends State<Many2OneFieldWidget> {
  dynamic selectedValue;

  @override
  void initState() {
    super.initState();
    log("widget : ${widget.readonly}");
    _updateSelectedValue(widget.value);
  }

  @override
  void didUpdateWidget(Many2OneFieldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value || oldWidget.options != widget.options) {
      _updateSelectedValue(widget.value);
    }
  }

  void _updateSelectedValue(dynamic value) {
    final valueId = (value is List && value.isNotEmpty) ? value[0] : value;
    final existsInOptions = widget.options.any((option) => option['id'] == valueId);
    setState(() {
      selectedValue = existsInOptions ? valueId : null;
    });
  }

  String _getDisplayName(dynamic valueId) {
    if (valueId == null || widget.options.isEmpty) {
      return widget.hintText ?? 'Select an option';
    }

    for (var option in widget.options) {
      if (option['id'] == valueId) {
        return option['name']?.toString() ?? 'Unnamed';
      }
    }

    return widget.hintText ?? 'Select an option';
  }

  @override
  Widget build(BuildContext context) {
    final uniqueOptions = _removeDuplicateOptions(widget.options);
    final theme = Theme.of(context);

    if (widget.viewType == 'tree') {
      return _buildCompactView(theme, uniqueOptions);
    } else {
      return _buildFormView(theme, uniqueOptions);
    }
  }

  Widget _buildFormView(ThemeData theme, List<Map<String, dynamic>> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            widget.name,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: widget.readonly ? theme.disabledColor : theme.textTheme.bodyMedium?.color,
            ),
          ),
        ),
        widget.readonly
            ? Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.dividerColor.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Text(
            _getDisplayName(selectedValue),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: widget.readonly ? theme.disabledColor : theme.textTheme.bodyLarge?.color,
            ),
          ),
        )
            : DropdownButtonFormField<dynamic>(
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
            ),
            filled: true,
            fillColor: theme.colorScheme.surface,
          ),
          value: selectedValue,
          items: options
              .map((option) => DropdownMenuItem<dynamic>(
            value: option['id'],
            child: Text(
              option['name']?.toString() ?? 'Unnamed',
              style: theme.textTheme.bodyLarge,
            ),
          ))
              .toList(),
          onChanged: (newValue) {
            setState(() {
              selectedValue = newValue;
            });
            widget.onValueChanged(newValue);
          },
          isExpanded: true,
          hint: Text(
            widget.hintText ?? 'Select an option',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.hintColor,
            ),
          ),
          style: theme.textTheme.bodyLarge,
          icon: Icon(
            Icons.arrow_drop_down,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          dropdownColor: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
      ],
    );
  }

  Widget _buildCompactView(ThemeData theme, List<Map<String, dynamic>> options) {
    return widget.readonly
        ? Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Text(
        _getDisplayName(selectedValue),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: widget.readonly ? theme.disabledColor : theme.textTheme.bodyMedium?.color,
        ),
      ),
    )
        : DropdownButtonFormField<dynamic>(
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
      ),
      value: selectedValue,
      items: options
          .map((option) => DropdownMenuItem<dynamic>(
        value: option['id'],
        child: Text(
          option['name']?.toString() ?? 'Unnamed',
          style: theme.textTheme.bodyMedium,
        ),
      ))
          .toList(),
      onChanged: (newValue) {
        setState(() {
          selectedValue = newValue;
        });
        widget.onValueChanged(newValue);
      },
      isExpanded: true,
      hint: Text(
        widget.hintText ?? 'Select',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.hintColor,
        ),
      ),
      style: theme.textTheme.bodyMedium,
      icon: Icon(
        Icons.arrow_drop_down,
        color: theme.colorScheme.onSurface.withOpacity(0.6),
        size: 20,
      ),
      dropdownColor: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
    );
  }

  List<Map<String, dynamic>> _removeDuplicateOptions(List<Map<String, dynamic>> options) {
    final seenIds = <dynamic>{};
    return options.where((option) {
      final id = option['id'];
      if (id != null && !seenIds.contains(id)) {
        seenIds.add(id);
        return true;
      }
      return false;
    }).toList();
  }
}