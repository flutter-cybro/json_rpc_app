import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImageUrlFieldWidget extends StatefulWidget {
  final String value;

  const ImageUrlFieldWidget({
    super.key,
    required this.value,
  });

  @override
  State<ImageUrlFieldWidget> createState() => _ImageUrlFieldWidgetState();
}

class _ImageUrlFieldWidgetState extends State<ImageUrlFieldWidget> {
  String? _baseUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBaseUrl();
  }

  Future<void> _loadBaseUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _baseUrl = prefs.getString('url');
        _isLoading = false;
      });
    } catch (e) {
      log('Error loading base URL: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    log('ImageUrlFieldWidget value: "${widget.value}"');

    // Handle loading state
    if (_isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    // Handle false or empty values
    if (widget.value.isEmpty || widget.value == 'false') {
      return const Text('No Image', style: TextStyle(fontSize: 16));
    }

    // Check if base URL is available
    if (_baseUrl == null || _baseUrl!.isEmpty) {
      return const Text('Server not configured', style: TextStyle(fontSize: 16));
    }

    // Construct full URL if relative
    String fullUrl = widget.value;
    if (!widget.value.startsWith('http')) {
      fullUrl = '$_baseUrl${widget.value}';
    }

    // Basic URL validation
    final uri = Uri.tryParse(fullUrl);
    if (uri == null || !uri.isAbsolute) {
      return const Text('Invalid URL', style: TextStyle(fontSize: 16));
    }

    return Image.network(
      fullUrl,
      width: 100,
      height: 100,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        log('Failed to load image from $fullUrl - $error');
        return const Text('Load Failed', style: TextStyle(fontSize: 16));
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      },
    );
  }
}