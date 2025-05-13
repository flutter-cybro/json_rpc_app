import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MonetaryFieldWidget extends StatelessWidget {
  final String name;
  final dynamic value;
  final String currency;
  final ValueChanged<double> onChanged;

  const MonetaryFieldWidget({
    Key? key,
    required this.name,
    required this.value,
    required this.currency,
    required this.onChanged,
  }) : super(key: key);

  double _extractValue(dynamic value) {
    if (value is double) {
      return value;
    } else if (value is Map) {

      if (value.containsKey('amount_untaxed')) {
        return (value['amount_untaxed'] as num).toDouble();
      } else if (value.containsKey('amount_total')) {
        return (value['amount_total'] as num).toDouble();
      } else if (value.containsKey('formatted_amount_total')) {

        return double.tryParse(value['formatted_amount_total']
            .replaceAll(RegExp(r'[^\d.]'), '')) ??
            0.0;
      }
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    double numericValue = _extractValue(value);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          TextFormField(
            initialValue: numericValue.toString(),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  currency,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onChanged: (newValue) {
              double parsedValue = double.tryParse(newValue) ?? 0.0;
              onChanged(parsedValue);
            },
          ),
        ],
      ),
    );
  }
}
