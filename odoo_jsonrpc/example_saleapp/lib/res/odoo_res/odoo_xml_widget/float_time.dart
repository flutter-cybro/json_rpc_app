import 'package:flutter/material.dart';
import 'dart:developer';

class FloatTimeFieldWidget extends StatefulWidget {
  final String name;
  final double value; // Expects double
  final Function(double)? onChanged; // Returns double
  final bool readOnly; // Read-only flag

  const FloatTimeFieldWidget({
    Key? key,
    required this.name,
    required this.value,
    this.onChanged,
    this.readOnly = false, // Default to false
  }) : super(key: key);

  @override
  State<FloatTimeFieldWidget> createState() => _FloatTimeFieldWidgetState();
}

class _FloatTimeFieldWidgetState extends State<FloatTimeFieldWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _floatToTime(widget.value));
    log("FloatTimeFieldWidget initState - Name: ${widget.name}, Value: ${widget.value}, Display: ${_controller.text}");
  }

  @override
  void didUpdateWidget(covariant FloatTimeFieldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      final newText = _floatToTime(widget.value);
      _controller.text = newText;
      log("FloatTimeFieldWidget didUpdateWidget - Name: ${widget.name}, New Value: ${widget.value}, Display: $newText");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _floatToTime(double value) {
    if (value.isNaN || value.isInfinite) return "0:00";
    final hours = value.floor();
    final minutes = ((value - hours) * 60).round();
    return "$hours:${minutes.toString().padLeft(2, '0')}";
  }

  double _timeToFloat(String time) {
    final parts = time.split(':');
    if (parts.length != 2) return 0.0;
    try {
      final hours = double.parse(parts[0]);
      final minutes = double.parse(parts[1]);
      return hours + (minutes / 60);
    } catch (e) {
      log("Error parsing time '$time' for ${widget.name}: $e");
      return 0.0;
    }
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
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0, right: 8.0),
              child: Text(
                '${widget.name}:',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.0,
                ),
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              readOnly: widget.readOnly, // Apply readOnly property
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
                hintText: 'HH:MM',
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              ),
              onChanged: (newValue) {
                if (!widget.readOnly && widget.onChanged != null) { // Only trigger if not readOnly
                  final floatValue = _timeToFloat(newValue);
                  widget.onChanged!(floatValue);
                  log("FloatTimeFieldWidget onChanged - Name: ${widget.name}, Input: $newValue, Float: $floatValue");
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}