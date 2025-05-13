import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // For phone icon

class PhoneFieldWidget extends StatefulWidget {
  final String name; // Field name
  final String value; // Current value (phone number)
  final Function(String) onChanged; // Callback for value change

  const PhoneFieldWidget({
    Key? key,
    required this.name,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  _PhoneFieldWidgetState createState() => _PhoneFieldWidgetState();
}

class _PhoneFieldWidgetState extends State<PhoneFieldWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.value == 'false' ? '' : widget.value,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              prefixIcon: Icon(
                FontAwesomeIcons.phone,
                size: 16, // Smaller icon size
                color: Colors.grey, // Faded color
              ),
              hintText: '',
            ),
            keyboardType: TextInputType.phone, // Phone-specific keyboard
            onChanged: (newValue) {
              widget.onChanged(newValue);
            },
          ),
        ],
      ),
    );
  }
}