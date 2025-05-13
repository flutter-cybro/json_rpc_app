import 'package:flutter/material.dart';

class MonetaryWidget extends StatelessWidget {
  final String name;
  final double value;
  final String currency;
  final ValueChanged<double>? onChanged;

  const MonetaryWidget({
    Key? key,
    required this.name,
    required this.value,
    this.currency = 'USD',
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: const TextStyle(fontSize: 16),
          ),
          onChanged != null
              ? SizedBox(
            width: 120,
            child: TextFormField(
              initialValue: value.toString(),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                suffixText: currency,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
              ),
              onChanged: (text) {
                final newValue = double.tryParse(text) ?? value;
                onChanged!(newValue);
              },
            ),
          )
              : Text(
            '$value $currency',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}