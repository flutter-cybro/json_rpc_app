import 'package:flutter/material.dart';

class FloatFieldWidget extends StatefulWidget {
  final String name;
  final double value;


  FloatFieldWidget({
    required this.name,
    required this.value,
  });

  @override
  _FloatFieldWidgetState createState() => _FloatFieldWidgetState();
}

class _FloatFieldWidgetState extends State<FloatFieldWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  void _onValueChanged(String newValue) {
    final double? parsedValue = double.tryParse(newValue);
    // if (parsedValue != null) {
    //
    // } else {
    //
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.name,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            onChanged: _onValueChanged,
          ),
        ],
      ),
    );
  }
}
