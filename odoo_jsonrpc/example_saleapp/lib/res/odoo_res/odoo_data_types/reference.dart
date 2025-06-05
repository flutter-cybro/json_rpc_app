import 'package:flutter/material.dart';

import '../../../controller/odooclient_manager_controller.dart';

class ReferenceFieldWidget extends StatelessWidget {
  final String value;
  final VoidCallback? onTap;
  final OdooClientController odooClientController; // Add Odoo client dependency

  const ReferenceFieldWidget({
    super.key,
    required this.value,
    this.onTap,
    required this.odooClientController, // Require Odoo client
  });

  Future<String> _fetchReferenceName(String model, int id) async {
    try {
      final result = await odooClientController.client.callKw({
        'model': model,
        'method': 'search_read',
        'args': [
          [['id', '=', id]],
        ],
        'kwargs': {
          'fields': ['name', 'display_name'],
          'limit': 1,
        },
      });

      if (result is List && result.isNotEmpty) {
        final record = result[0] as Map<String, dynamic>;
        return record['display_name'] ?? record['name'] ?? 'Unnamed';
      }
      return 'Unnamed';
    } catch (e) {
      // Handle errors gracefully
      return 'Error: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Parse the reference value (e.g., "sale.order,72")
    final parts = value.split(',');
    if (parts.length != 2) {
      return Text(
        'Invalid Reference',
        style: TextStyle(
          fontSize: 16.0,
          color: Colors.red,
        ),
        overflow: TextOverflow.ellipsis,
      );
    }

    final model = parts[0];
    final id = int.tryParse(parts[1]) ?? 0;

    return FutureBuilder<String>(
      future: _fetchReferenceName(model, id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text(
            'Error: ${snapshot.error}',
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.red,
            ),
            overflow: TextOverflow.ellipsis,
          );
        }
        final displayName = snapshot.data ?? 'Unnamed';

        return GestureDetector(
          onTap: onTap,
          child: Text(
            displayName,
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }
}