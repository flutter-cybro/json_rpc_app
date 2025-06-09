import 'package:odoo_jsonrpc/src/odoo_client.dart';
import 'package:flutter/material.dart';


class ListActivityWidget extends StatelessWidget {
  final String fieldName;
  final List<dynamic> value;
  final String relationModel;
  final OdooClient client;
  final Future<List<Map<String, dynamic>>> _activitiesFuture;

  ListActivityWidget({
    Key? key,
    required this.fieldName,
    required this.value,
    required this.relationModel,
    required this.client,
  })  : _activitiesFuture = _fetchActivities(value, relationModel, client),
        super(key: key);

  static Future<List<Map<String, dynamic>>> _fetchActivities(
      List<dynamic> value, String relationModel, OdooClient client) async {
    if (value.isEmpty || relationModel.isEmpty) return [];
    try {
      final result = await client.callKw({
        'model': relationModel,
        'method': 'search_read',
        'args': [
          [['id', 'in', value]],
        ],
        'kwargs': {
          'fields': ['id', 'display_name', 'activity_type_id', 'summary', 'date_deadline'],
        },
      });
      return (result as List<dynamic>).cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Error fetching activities: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _activitiesFuture, // Use memoized future
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('');
        }

        final activities = snapshot.data!;
        return SizedBox(
          height: 76,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: activities.map((activity) {
                final displayName = activity['display_name'] ?? 'Unnamed';
                final activityType = activity['activity_type_id'] is List
                    ? activity['activity_type_id'][1]
                    : 'Unknown';
                final summary = activity['summary'] ?? '';
                final dueDate = activity['date_deadline'] ?? '';

                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Chip(
                    label: Text(
                      '$activityType: $summary${dueDate.isNotEmpty ? ' ($dueDate)' : ''}',
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                    backgroundColor: Colors.blue.shade100,
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}