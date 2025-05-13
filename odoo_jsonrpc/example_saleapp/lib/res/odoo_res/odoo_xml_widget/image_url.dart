import 'dart:developer';
import 'package:flutter/material.dart';

class ImageUrlFieldWidget extends StatelessWidget {
  final String value; // e.g., "/base/static/img/country_flags/us.png" or "false"
  final String baseUrl; // Your Odoo server's base URL

  const ImageUrlFieldWidget({
    super.key,
    required this.value,
    this.baseUrl = 'http://10.0.20.68:8018', // Replace with your Odoo server URL
  });

  @override
  Widget build(BuildContext context) {
    log('ImageUrlFieldWidget value: "$value"'); // Debug log

    // Handle false or empty values
    if (value.isEmpty || value == 'false') {
      log('ImageUrlFieldWidget: Empty or false value');
      return const Text('No Image', style: TextStyle(fontSize: 16));
    }

    // Construct full URL if relative
    String fullUrl = value;
    if (!value.startsWith('http')) {
      fullUrl = '$baseUrl$value';
    }
    log('ImageUrlFieldWidget full URL: "$fullUrl"');

    // Basic URL validation
    if (!Uri.tryParse(fullUrl)!.isAbsolute) {
      log('ImageUrlFieldWidget: Invalid URL format: $fullUrl');
      return const Text('Invalid URL', style: TextStyle(fontSize: 16));
    }

    return Image.network(
      fullUrl,
      width: 20,
      height: 20,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        log('ImageUrlFieldWidget: Failed to load image from $fullUrl - $error');
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