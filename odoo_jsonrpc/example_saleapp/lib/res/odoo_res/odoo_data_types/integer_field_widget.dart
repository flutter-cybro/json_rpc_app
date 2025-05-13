import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// class IntegerFieldWidget extends StatefulWidget {
//   final String name;
//   final int? value;
//   final ValueChanged<int> onChanged;
//   final bool readonly; // Add readonly parameter
//
//   const IntegerFieldWidget({
//     Key? key,
//     required this.name,
//     required this.value,
//     required this.onChanged,
//     this.readonly = false, // Default to false
//   }) : super(key: key);
//
//   @override
//   _IntegerFieldWidgetState createState() => _IntegerFieldWidgetState();
// }
//
// class _IntegerFieldWidgetState extends State<IntegerFieldWidget> {
//   late TextEditingController _controller;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = TextEditingController(text: widget.value?.toString() ?? '0');
//   }
//
//   void _updateValue(String newValue) {
//     final intValue = int.tryParse(newValue) ?? 0;
//     _controller.text = intValue.toString();
//     widget.onChanged(intValue);
//   }
//
//   void _increment() {
//     int newValue = (int.tryParse(_controller.text) ?? 0) + 1;
//     _controller.text = newValue.toString();
//     widget.onChanged(newValue);
//   }
//
//   void _decrement() {
//     int newValue = (int.tryParse(_controller.text) ?? 0) - 1;
//     _controller.text = newValue.toString();
//     widget.onChanged(newValue);
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             widget.name,
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 5),
//           TextFormField(
//             controller: _controller,
//             keyboardType: TextInputType.number,
//             inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//             textAlign: TextAlign.center,
//             style: const TextStyle(fontSize: 16),
//             decoration: InputDecoration(
//               contentPadding: const EdgeInsets.symmetric(vertical: 15),
//               border: const OutlineInputBorder(),
//               enabledBorder: const OutlineInputBorder(
//                 borderSide: BorderSide(color: Colors.grey, width: 1),
//               ),
//               focusedBorder: const OutlineInputBorder(
//                 borderSide: BorderSide(color: Colors.blue, width: 1.5),
//               ),
//               prefixIcon: _buildArrowButton(
//                 icon: Icons.arrow_drop_down,
//                 onPressed: _decrement,
//               ),
//               suffixIcon: _buildArrowButton(
//                 icon: Icons.arrow_drop_up,
//                 onPressed: _increment,
//               ),
//             ),
//             onChanged: _updateValue,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildArrowButton({
//     required IconData icon,
//     required VoidCallback onPressed,
//   }) {
//     return IconButton(
//       icon: Icon(
//         icon,
//         size: 24,
//         color: Colors.grey[600],
//       ),
//       onPressed: onPressed,
//       padding: EdgeInsets.zero,
//       constraints: const BoxConstraints(),
//     );
//   }
// }

class IntegerFieldWidget extends StatefulWidget {
  final String name;
  final int? value;
  final ValueChanged<int>? onChanged; // Make nullable
  final bool readonly; // Add readonly parameter

  const IntegerFieldWidget({
    Key? key,
    required this.name,
    required this.value,
    this.onChanged,
    this.readonly = false, // Default to false
  }) : super(key: key);

  @override
  _IntegerFieldWidgetState createState() => _IntegerFieldWidgetState();
}

class _IntegerFieldWidgetState extends State<IntegerFieldWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value?.toString() ?? '0');
  }

  void _updateValue(String newValue) {
    if (widget.readonly) return; // Skip  Skip update if readonly
    final intValue = int.tryParse(newValue) ?? 0;
    _controller.text = intValue.toString();
    widget.onChanged?.call(intValue);
  }

  void _increment() {
    if (widget.readonly) return; // Skip increment if readonly
    int newValue = (int.tryParse(_controller.text) ?? 0) + 1;
    _controller.text = newValue.toString();
    widget.onChanged?.call(newValue);
  }

  void _decrement() {
    if (widget.readonly) return; // Skip decrement if readonly
    int newValue = (int.tryParse(_controller.text) ?? 0) - 1;
    _controller.text = newValue.toString();
    widget.onChanged?.call(newValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: _controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
            enabled: !widget.readonly, // Disable input if readonly
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
              border: const OutlineInputBorder(),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 1),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue, width: 1.5),
              ),
              disabledBorder: const OutlineInputBorder( // Add disabled border
                borderSide: BorderSide(color: Colors.grey, width: 1),
              ),
              prefixIcon: _buildArrowButton(
                icon: Icons.arrow_drop_down,
                onPressed: widget.readonly ? null : _decrement,
              ),
              suffixIcon: _buildArrowButton(
                icon: Icons.arrow_drop_up,
                onPressed: widget.readonly ? null : _increment,
              ),
            ),
            onChanged: _updateValue,
          ),
        ],
      ),
    );
  }

  Widget _buildArrowButton({
    required IconData icon,
    required VoidCallback? onPressed, // Make nullable
  }) {
    return IconButton(
      icon: Icon(
        icon,
        size: 24,
        color: Colors.grey[600],
      ),
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }
}