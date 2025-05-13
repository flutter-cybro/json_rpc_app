import 'package:flutter/material.dart';

class IntegerInput extends StatefulWidget {
  final String label; // Field name
  final String? modelName; // Optional model name

  const IntegerInput({
    Key? key,
    this.label = 'Integer field', // Default label
    this.modelName, // Optional model name
  }) : super(key: key);

  @override
  State<IntegerInput> createState() => _IntegerInputState();
}

class _IntegerInputState extends State<IntegerInput> {
  final TextEditingController _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Integer validation function
  String? _validateInteger(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a value';
    }

    // Check if the value can be parsed to an integer
    final intValue = int.tryParse(value);
    if (intValue == null) {
      return 'Please enter a valid integer';
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
            if (widget.modelName != null) // Show modelName if not null
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Model: ${widget.modelName}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter an integer value',
              ),
              validator: _validateInteger,
              onChanged: (value) {
                // Trigger validation on text change
                _formKey.currentState?.validate();
              },
            ),
          ],
        ),
      ),
    );
  }
}
