import 'package:flutter/material.dart';

class TextFieldWidget extends StatefulWidget {
  final String name;
  final String value;
  final ValueChanged<String> onChanged;
  final bool readOnly; // Read-only flag

  const TextFieldWidget({
    Key? key,
    required this.name,
    required this.value,
    required this.onChanged,
    this.readOnly = false, // Default to false
  }) : super(key: key);

  @override
  _TextFieldWidgetState createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        widget.name,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        widget.value.isNotEmpty ? widget.value : "Tap to enter text...",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.grey),
      ),
      trailing: widget.readOnly ? null : const Icon(Icons.edit, color: Colors.blue), // Hide edit icon if readOnly
      onTap: widget.readOnly ? null : () => _openTextEditor(context), // Disable tap if readOnly
    );
  }

  void _openTextEditor(BuildContext context) {
    if (widget.readOnly) return; // Prevent opening bottom sheet if readOnly
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _controller,
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                readOnly: widget.readOnly, // Apply readOnly to TextField
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter text...",
                ),
              ),
              const SizedBox(height: 10),
              if (!widget.readOnly) // Show Save button only if not readOnly
                ElevatedButton(
                  onPressed: () {
                    widget.onChanged(_controller.text);
                    Navigator.pop(context);
                  },
                  child: const Text("Save"),
                ),
            ],
          ),
        );
      },
    );
  }
}