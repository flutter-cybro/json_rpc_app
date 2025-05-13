import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // For URL icon
import 'package:url_launcher/url_launcher.dart'; // For launching URLs

class UrlFieldWidget extends StatefulWidget {
  final String name; // Field name
  final String value; // Current value (URL)
  final Function(String) onChanged; // Callback for value change

  const UrlFieldWidget({
    Key? key,
    required this.name,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  _UrlFieldWidgetState createState() => _UrlFieldWidgetState();
}

class _UrlFieldWidgetState extends State<UrlFieldWidget> {
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

  // Launch URL in browser
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
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
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(
                FontAwesomeIcons.link,
                size: 16, // Small icon
                color: Colors.grey, // Faded color
              ),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(
                  Icons.open_in_new,
                  size: 18,
                  color: Colors.blue,
                ),
                onPressed: () => _launchUrl(_controller.text),
              )
                  : null,
              hintText: '',
            ),
            keyboardType: TextInputType.url, // URL-specific keyboard
            onChanged: (newValue) {
              setState(() {}); // Update suffixIcon visibility
              widget.onChanged(newValue);
            },
          ),
        ],
      ),
    );
  }
}