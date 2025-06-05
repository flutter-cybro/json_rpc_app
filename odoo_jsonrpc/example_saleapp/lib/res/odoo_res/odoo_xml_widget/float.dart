import 'package:flutter/material.dart';

class FloatField extends StatefulWidget {
  const FloatField({
    super.key,
    this.label = 'Float field',
    this.readOnly = false, // Default to false
  });

  final String label; // Field name
  final bool readOnly; // Read-only flag

  @override
  State<FloatField> createState() => _FloatFieldState();
}

class _FloatFieldState extends State<FloatField> {
  final TextEditingController _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Float validation function
  String? _validateFloat(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a value';
    }

    // Check if the value can be parsed to a float
    final floatValue = double.tryParse(value);
    if (floatValue == null) {
      return 'Please enter a valid float';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.label, style: Theme.of(context).textTheme.titleSmall),
            TextFormField(
              controller: _controller,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              readOnly: widget.readOnly, // Apply readOnly property
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter a float value',
              ),
              validator: _validateFloat,
              onChanged: (value) {
                // Trigger validation on text change only if not readOnly
                if (!widget.readOnly) {
                  _formKey.currentState?.validate();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}