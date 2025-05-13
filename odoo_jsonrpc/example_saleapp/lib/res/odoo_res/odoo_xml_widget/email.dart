import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // For email icon

class EmailFieldWidget extends StatefulWidget {
  final String name; // Field name
  final String value; // Current value (email address)
  final Function(String) onChanged; // Callback for value change

  const EmailFieldWidget({
    Key? key,
    required this.name,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  _EmailFieldWidgetState createState() => _EmailFieldWidgetState();
}

class _EmailFieldWidgetState extends State<EmailFieldWidget> {
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
                FontAwesomeIcons.envelope,
                size: 16, // Small icon
                color: Colors.grey, // Faded color
              ),
              hintText: '',
            ),
            keyboardType: TextInputType.emailAddress, // Email-specific keyboard
            onChanged: (newValue) {
              widget.onChanged(newValue);
            },
          ),
        ],
      ),
    );
  }
}