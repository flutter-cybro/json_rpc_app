import 'dart:convert';
import 'package:flutter/material.dart';

class TaxTotalsFieldWidget extends StatelessWidget {
  final String name;
  final dynamic value;

  const TaxTotalsFieldWidget({
    Key? key,
    required this.name,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Parse the binary data if it's a string (assuming it's base64 encoded JSON)
    Map<String, dynamic> taxData = {};
    try {
      if (value is String && value.isNotEmpty) {
        final decodedBytes = base64Decode(value);
        final decodedString = utf8.decode(decodedBytes);
        taxData = jsonDecode(decodedString) as Map<String, dynamic>;
      } else if (value is Map<String, dynamic>) {
        taxData = value;
      }
    } catch (e) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          '$name: Error parsing tax totals data',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    // Extract relevant monetary values
    final subtotals = taxData['subtotals'] as List<dynamic>? ?? [];
    final totalAmount = taxData['total_amount']?.toString() ?? '0.0';
    final taxAmount = taxData['tax_amount']?.toString() ?? '0.0';
    final baseAmount = taxData['base_amount']?.toString() ?? '0.0';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: 8),
              if (subtotals.isNotEmpty)
                ...subtotals.map((subtotal) {
                  final subtotalMap = subtotal as Map<String, dynamic>;
                  return _buildMonetaryRow(
                    subtotalMap['name']?.toString() ?? 'Unnamed',
                    subtotalMap['base_amount']?.toString() ?? '0.0',
                  );
                }).toList(),
              const Divider(),
              _buildMonetaryRow('Tax Amount', taxAmount),
              _buildMonetaryRow('Base Amount', baseAmount),
              _buildMonetaryRow('Total Amount', totalAmount, isTotal: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonetaryRow(String label, String amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 14.0 : 12.0,
            ),
          ),
          Text(
            '\$$amount', // Assuming currency is USD; adjust as needed
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 14.0 : 12.0,
            ),
          ),
        ],
      ),
    );
  }
}