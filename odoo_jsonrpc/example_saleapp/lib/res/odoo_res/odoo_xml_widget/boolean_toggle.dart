import 'package:flutter/material.dart';

class BooleanToggleFieldWidget extends StatefulWidget {
  final String name;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool readonly;

  const BooleanToggleFieldWidget({
    required this.name,
    required this.value,
    this.onChanged,
    this.readonly = false,
  });

  @override
  _BooleanToggleFieldWidgetState createState() => _BooleanToggleFieldWidgetState();
}

class _BooleanToggleFieldWidgetState extends State<BooleanToggleFieldWidget> {
  late bool _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
  }

  @override
  void didUpdateWidget(BooleanToggleFieldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      setState(() {
        _currentValue = widget.value;
      });
    }
  }

  void _onChanged(bool newValue) {
    setState(() {
      _currentValue = newValue;
    });
    if (widget.onChanged != null) {
      widget.onChanged!(newValue);
    }
    print('New value for ${widget.name}: $newValue');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SwitchListTile(
            value: _currentValue,
            onChanged: widget.readonly ? null : _onChanged,
            title: Text('Toggle ${widget.name}'),
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }
}