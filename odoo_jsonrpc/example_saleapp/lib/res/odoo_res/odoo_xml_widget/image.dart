import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageFieldWidget extends StatefulWidget {
  final String name; // Field label from FormView or TreeView
  final String value; // Initial Base64-encoded image string
  final Function(String)? onChanged; // Callback to update the value in FormView
  final bool isReadonly; // To disable editing if readonly
  final String viewType; // "tree" or "form" to determine display style

  const ImageFieldWidget({
    super.key,
    required this.name,
    required this.value,
    this.onChanged,
    this.isReadonly = false,
    this.viewType = 'form', // Default to "form" if not specified
  });

  @override
  _ImageFieldWidgetState createState() => _ImageFieldWidgetState();
}

class _ImageFieldWidgetState extends State<ImageFieldWidget> {
  final ImagePicker _picker = ImagePicker();
  String? _base64Image;

  @override
  void initState() {
    super.initState();
    _base64Image = widget.value.isNotEmpty ? widget.value : null;
  }

  @override
  void didUpdateWidget(ImageFieldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      setState(() {
        _base64Image = widget.value.isNotEmpty ? widget.value : null;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      final base64String = base64Encode(bytes);

      setState(() {
        _base64Image = base64String;
      });

      if (widget.onChanged != null) {
        widget.onChanged!(base64String);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Responsive dimensions based on viewType
    final screenWidth = MediaQuery.of(context).size.width;
    final imageSize = widget.viewType == 'tree' ? 60.0 : screenWidth * 0.4; // Small for tree, larger for form

    if (widget.viewType == 'tree') {
      // Tree view: Show only a small image, no label or edit button
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _base64Image != null && _base64Image!.isNotEmpty
              ? Image.memory(
            base64Decode(_base64Image!),
            fit: BoxFit.cover,
            width: imageSize,
            height: imageSize,
            errorBuilder: (context, error, stackTrace) =>
                _buildErrorPlaceholder(imageSize),
          )
              : _buildNoImagePlaceholder(imageSize),
        ),
      );
    } else {
      // Form view: Full layout with label, image, and edit button (if not readonly)
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label
            Text(
              '${widget.name}:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ) ??
                  const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 8),
            // Image Container
            Container(
              width: imageSize,
              height: imageSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _base64Image != null && _base64Image!.isNotEmpty
                        ? Image.memory(
                      base64Decode(_base64Image!),
                      fit: BoxFit.cover,
                      width: imageSize,
                      height: imageSize,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildErrorPlaceholder(imageSize),
                    )
                        : _buildNoImagePlaceholder(imageSize),
                  ),
                  if (!widget.isReadonly)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: FloatingActionButton(
                        mini: true,
                        backgroundColor: Theme.of(context).primaryColor,
                        onPressed: _pickImage,
                        child: const Icon(Icons.edit, size: 20),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildNoImagePlaceholder(double size) {
    return Container(
      width: size,
      height: size,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image,
            size: size * 0.3,
            color: Colors.grey[400],
          ),
          if (widget.viewType != 'tree') ...[
            const SizedBox(height: 8),
            Text(
              'No Image',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorPlaceholder(double size) {
    return Container(
      width: size,
      height: size,
      color: Colors.red[50],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: size * 0.3,
            color: Colors.red[400],
          ),
          if (widget.viewType != 'tree') ...[
            const SizedBox(height: 8),
            Text(
              'Invalid Image',
              style: TextStyle(
                color: Colors.red[600],
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}