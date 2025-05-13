import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MonetaryField extends StatefulWidget {
  final String label;
  final String currency;
  final double? initialAmount;
  final TextEditingController? controller;
  final void Function(String)? onChanged;

  const MonetaryField({
    Key? key,
    required this.label,
    this.currency = '₹',
    this.initialAmount,
    this.controller,
    this.onChanged,
  }) : super(key: key);

  @override
  _MonetaryFieldState createState() => _MonetaryFieldState();
}

class _MonetaryFieldState extends State<MonetaryField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(
      text: widget.initialAmount?.toStringAsFixed(2) ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 300;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).cardColor,
          ),
          child: isWide ? _buildWideLayout() : _buildNarrowLayout(),
        );
      },
    );
  }

  Widget _buildWideLayout() {
    return Row(
      children: [
        Text(
          widget.label,
          style: TextStyle(fontSize: 14, color: Theme.of(context).hintColor),
        ),
        const SizedBox(width: 16),
        Expanded(child: _buildInputField()),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(fontSize: 14, color: Theme.of(context).hintColor),
        ),
        const SizedBox(height: 8),
        _buildInputField(),
      ],
    );
  }

  Widget _buildInputField() {
    return Row(
      children: [
        Text(
          widget.currency,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: '0.00',
              hintStyle: TextStyle(color: Theme.of(context).hintColor),
            ),
            onChanged: widget.onChanged,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }
}