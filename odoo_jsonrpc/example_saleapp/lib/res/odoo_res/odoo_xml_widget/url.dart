import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlFieldWidget extends StatefulWidget {
  final String name;
  final String value;
  final Function(String) onChanged;
  final bool readonly;
  final bool submitOnUnfocus; // Controls whether to submit when field loses focus

  const UrlFieldWidget({
    Key? key,
    required this.name,
    required this.value,
    required this.onChanged,
    this.readonly = false,
    this.submitOnUnfocus = true, // Default to submitting when unfocused
  }) : super(key: key);

  @override
  _UrlFieldWidgetState createState() => _UrlFieldWidgetState();
}

class _UrlFieldWidgetState extends State<UrlFieldWidget> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isFocused = false;
  String? _errorText;
  String _lastSubmittedValue = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.value == 'false' ? '' : widget.value,
    );
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
    _controller.addListener(_validateUrl);
    _lastSubmittedValue = widget.value;
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });

    if (!_focusNode.hasFocus &&
        !widget.readonly &&
        widget.submitOnUnfocus &&
        _errorText == null &&
        _controller.text != _lastSubmittedValue) {
      _submitToOdoo();
    }
  }

  void _validateUrl() {
    final value = _controller.text;
    setState(() {
      if (value.isNotEmpty &&
          !RegExp(r'^(https?:\/\/)?([\w-]+(\.[\w-]+)+)(\/[\w-]*)*\/?$').hasMatch(value)) {
        _errorText = 'Please enter a valid URL';
      } else {
        _errorText = null;
      }
    });
  }

  void _submitToOdoo() {
    if (_errorText == null && _controller.text != _lastSubmittedValue) {
      widget.onChanged(_controller.text);
      _lastSubmittedValue = _controller.text;
    }
  }

  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) return;

    String formattedUrl = url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      formattedUrl = 'https://$url';
    }

    try {
      final Uri uri = Uri.parse(formattedUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $formattedUrl')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid URL format')),
      );
    }
  }

  @override
  void didUpdateWidget(UrlFieldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = widget.value;
      _lastSubmittedValue = widget.value;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _controller.removeListener(_validateUrl);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            readOnly: widget.readonly,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _errorText != null ? Colors.red : Colors.transparent,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _errorText != null
                      ? Colors.red
                      : (isDarkMode ? Colors.grey[700]! : Colors.grey.shade300),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _errorText != null
                      ? Colors.red
                      : theme.primaryColor,
                  width: 2,
                ),
              ),
              prefixIcon: const Icon(
                FontAwesomeIcons.link,
                size: 16,
                color: Colors.grey,
              ),
              suffixIcon: _controller.text.isNotEmpty
                  ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isFocused && !widget.readonly)
                    IconButton(
                      icon: const Icon(Icons.check, size: 20),
                      color: _errorText == null
                          ? theme.primaryColor
                          : Colors.grey,
                      onPressed: _errorText == null
                          ? _submitToOdoo
                          : null,
                    ),
                  IconButton(
                    icon: const Icon(Icons.open_in_new, size: 18),
                    color: Colors.blue,
                    onPressed: widget.readonly || _errorText != null
                        ? null
                        : () => _launchUrl(_controller.text),
                  ),
                ],
              )
                  : null,
              hintText: 'Enter URL (e.g., https://example.com)',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
              ),
              filled: true,
              fillColor: widget.readonly
                  ? (isDarkMode ? Colors.grey[900]!.withOpacity(0.3) : Colors.grey.shade100)
                  : (isDarkMode ? Colors.grey[850]! : Colors.white),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 12,
              ),
              errorText: _errorText,
            ),
            keyboardType: TextInputType.url,
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
            onSubmitted: (_) => _submitToOdoo(),
          ),
        ],
      ),
    );
  }
}