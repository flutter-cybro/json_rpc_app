import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IntegerFieldWidget extends StatefulWidget {
  final String name;
  final int value;
  final ValueChanged<int> onChanged;

  const IntegerFieldWidget({
    Key? key,
    required this.name,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  _IntegerFieldWidgetState createState() => _IntegerFieldWidgetState();
}

class _IntegerFieldWidgetState extends State<IntegerFieldWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
  }

  void _updateValue(String newValue) {
    final intValue = int.tryParse(newValue) ?? 0;
    widget.onChanged(intValue);
  }

  void _increment() {
    int newValue = (int.tryParse(_controller.text) ?? 0) + 1;
    _controller.text = newValue.toString();
    widget.onChanged(newValue);
  }

  void _decrement() {
    int newValue = (int.tryParse(_controller.text) ?? 0) - 1;
    _controller.text = newValue.toString();
    widget.onChanged(newValue);
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
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: _decrement,
              ),
              Expanded(
                child: TextFormField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  onChanged: _updateValue,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _increment,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
