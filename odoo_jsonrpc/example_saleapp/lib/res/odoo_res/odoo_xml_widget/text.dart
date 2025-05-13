import 'package:flutter/material.dart';

class TextXmlFieldWidget extends StatefulWidget {
  final String name; // Field name
  final String value; // Current value (text)
  final Function(String) onChanged; // Callback for value change

  const TextXmlFieldWidget({
    Key? key,
    required this.name,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  _TextXmlFieldWidgetState createState() => _TextXmlFieldWidgetState();
}

class _TextXmlFieldWidgetState extends State<TextXmlFieldWidget> {
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
              hintText: 'Enter text',
              // Optional: Add an icon or styling to differentiate from CharFieldWidget
              prefixIcon: Icon(
                Icons.text_fields,
                size: 16,
                color: Colors.grey,
              ),
            ),
            maxLines: 3, // Allow multiple lines to distinguish from single-line char fields
            keyboardType: TextInputType.multiline, // Multi-line input support
            onChanged: (newValue) {
              widget.onChanged(newValue);
            },
          ),
        ],
      ),
    );
  }
}