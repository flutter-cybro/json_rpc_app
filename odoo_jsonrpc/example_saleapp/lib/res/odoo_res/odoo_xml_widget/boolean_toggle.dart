import 'package:flutter/material.dart';

class BooleanToggleFieldWidget extends StatefulWidget {
  final String name;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool readonly;
  final String viewType;

  const BooleanToggleFieldWidget({
    required this.name,
    required this.value,
    this.onChanged,
    this.readonly = false,
    this.viewType = 'form'
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
    // return InkWell(
    //   onTap: readonly ? null : onTap, // Disable tap if readonly
    //   borderRadius: BorderRadius.circular(12.0), // Rounded ripple effect
    //   child: Padding(
    //     padding: const EdgeInsets.all(4.0), // Small padding for tap area
    //     child: Icon(
    //       isFavorite ? Icons.star : Icons.star_border,
    //       color: iconColor,
    //       size: 24.0,
    //     ),
    //   ),
    // );
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