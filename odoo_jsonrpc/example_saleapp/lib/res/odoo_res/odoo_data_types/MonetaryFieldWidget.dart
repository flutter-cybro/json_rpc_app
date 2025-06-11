import 'package:flutter/material.dart';

class MonetaryFieldWidget extends StatelessWidget {
  final String name;
  final double value;
  final Future<String> currencySymbolFuture; // Dynamic currency symbol
  final bool isReadonly;
  final String viewType;

  const MonetaryFieldWidget({
    Key? key,
    required this.name,
    required this.value,
    required this.currencySymbolFuture,
    this.isReadonly = true,
    this.viewType = 'tree',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: currencySymbolFuture,
      builder: (context, snapshot) {
        String displaySymbol = '';
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }
        if (snapshot.hasData) {
          displaySymbol = snapshot.data!;
        } else {
          displaySymbol = ''; // Fallback: no symbol if fetch fails
        }

        // Format the monetary value with 2 decimal places
        String formattedValue = value.toStringAsFixed(2);
        return Text(
          '$displaySymbol$formattedValue',
          style: TextStyle(
            fontSize: viewType == 'tree' ? 16.0 : 18.0,
            color: Colors.black87,
            fontWeight: viewType == 'form' ? FontWeight.w500 : FontWeight.normal,
          ),
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }
}