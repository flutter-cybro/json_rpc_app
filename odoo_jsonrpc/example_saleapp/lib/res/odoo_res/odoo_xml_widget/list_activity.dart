import 'dart:developer';
import 'package:flutter/material.dart';

class ListActivityWidget extends StatefulWidget {
  final String fieldName;
  final List<dynamic> value; // The one2many field value (e.g., list of IDs)
  final String relationModel; // The related model (e.g., 'mail.activity')
  final dynamic client; // Odoo client for RPC calls

  const ListActivityWidget({
    Key? key,
    required this.fieldName,
    required this.value,
    required this.relationModel,
    required this.client,
  }) : super(key: key);

  @override
  _ListActivityWidgetState createState() => _ListActivityWidgetState();
}

class _ListActivityWidgetState extends State<ListActivityWidget> {
  List<Map<String, dynamic>> relatedRecords = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchRelatedRecords();
  }

  Future<void> _fetchRelatedRecords() async {
    if (widget.value.isEmpty) {
      setState(() {
        isLoading = false;
        relatedRecords = [];
      });
      return;
    }

    try {
      final response = await widget.client.callKw({
        'model': widget.relationModel,
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': [['id', 'in', widget.value]],
          'fields': ['display_name', 'activity_type_id', 'date_deadline'],
        },
      });

      if (response is List<dynamic>) {
        setState(() {
          relatedRecords = response.map((record) => Map<String, dynamic>.from(record)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error loading activities: $e';
      });
      log('Error fetching related records for ${widget.fieldName}: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (errorMessage != null) {
      return Text(
        errorMessage!,
        style: const TextStyle(color: Colors.red, fontSize: 12),
        overflow: TextOverflow.ellipsis,
      );
    }

    if (relatedRecords.isEmpty) {
      return const Text(
        '',
        style: TextStyle(fontSize: 14, color: Colors.grey),
        overflow: TextOverflow.ellipsis,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: relatedRecords.map((record) {
        final displayName = record['display_name'] ?? '';
        final activityType = record['activity_type_id'] is List
            ? record['activity_type_id'][1]
            : 'Unknown';
        final deadline = record['date_deadline'] ?? '';
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          // child: Text(
          //   '$activityType: $displayName ($deadline)',
          //   style: const TextStyle(fontSize: 14),
          //   overflow: TextOverflow.ellipsis,
          // ),
          child: Text(
            '$activityType',
            style: const TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
    );
  }
}