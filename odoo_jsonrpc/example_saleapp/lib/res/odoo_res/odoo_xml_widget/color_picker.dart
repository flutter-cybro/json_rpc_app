import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

final Map<int, Color> colorMap = {
  1: Color(0xFF777777), // medium gray
  2: Color(0xFFF06050), // red
  3: Color(0xFFF4A460), // orange
  4: Color(0xFFF7CD1F), // yellow
  5: Color(0xFF6CC1ED), // light blue
  6: Color(0xFF814968), // purple
  7: Color(0xFFEB7E7F), // pink
  8: Color(0xFF2C8397), // blue-green
  9: Color(0xFF475577), // dark blue
  10: Color(0xFFD6145F), // dark red
  11: Color(0xFF30C381), // green
  12: Color(0xFF9365B8), // purple
};

class ColorPickerWidget extends StatefulWidget {
  final int initialColorValue;
  final String viewType;
  final bool readonly; // Controls interactivity and UI
  final ValueChanged<int>? onChanged;

  const ColorPickerWidget({
    super.key,
    required this.initialColorValue,
    required this.viewType,
    this.readonly = false, // Default to non-readonly
    this.onChanged,
  });

  @override
  State<ColorPickerWidget> createState() => _ColorPickerWidgetState();
}

class _ColorPickerWidgetState extends State<ColorPickerWidget> {
  late int selectedColorValue;

  @override
  void initState() {
    super.initState();
    _updateSelectedColor(widget.initialColorValue);
  }

  @override
  void didUpdateWidget(covariant ColorPickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialColorValue != widget.initialColorValue) {
      _updateSelectedColor(widget.initialColorValue);
    }
  }

  void _updateSelectedColor(int newValue) {
    setState(() {
      selectedColorValue = colorMap.containsKey(newValue)
          ? newValue
          : colorMap.keys.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    Color color = colorMap[selectedColorValue] ?? Colors.grey;

    // Visual adjustments for readonly state
    final effectiveOpacity = widget.readonly ? 0.6 : 1.0;

    switch (widget.viewType.toLowerCase()) {
      case 'tree':
        return Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color.withOpacity(effectiveOpacity),
              border: widget.readonly
                  ? Border.all(color: Colors.black26, width: 0.5)
                  : null,
            ),
            margin: const EdgeInsets.symmetric(vertical: 4.0),
          ),
        );
      case 'form':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(effectiveOpacity),
                  border: widget.readonly
                      ? Border.all(color: Colors.black26, width: 0.5)
                      : Border.all(color: Colors.black54, width: 1.0),
                ),
                margin: const EdgeInsets.only(right: 16.0),
              ),
              Expanded(
                child: DropdownButton<int>(
                  value: selectedColorValue,
                  items: colorMap.keys.map((int key) {
                    return DropdownMenuItem<int>(
                      value: key,
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: colorMap[key]!.withOpacity(effectiveOpacity),
                              border: widget.readonly
                                  ? Border.all(color: Colors.black26, width: 0.5)
                                  : null,
                            ),
                            margin: const EdgeInsets.only(right: 8.0),
                          ),
                          Text(
                            'Color #$key',
                            style: TextStyle(
                              color: Colors.black.withOpacity(effectiveOpacity),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: widget.readonly
                      ? null
                      : (int? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedColorValue = newValue;
                        widget.onChanged?.call(newValue);
                      });
                    }
                  },
                  isExpanded: true,
                  disabledHint: Text(
                    'Color #$selectedColorValue',
                    style: TextStyle(
                      color: Colors.black.withOpacity(effectiveOpacity),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      default:
        return Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color.withOpacity(effectiveOpacity),
              border: widget.readonly
                  ? Border.all(color: Colors.black26, width: 0.5)
                  : null,
            ),
            margin: const EdgeInsets.symmetric(vertical: 4.0),
          ),
        );
    }
  }
}