import 'package:flutter/material.dart';
import 'package:odoo_jsonrpc/odoo_jsonrpc.dart';

class One2ManyWidget extends StatefulWidget {
  final String fieldName;
  final String model;
  final List<dynamic> records;
  final Map<String, dynamic>? fieldsInfo;
  final OdooClient? client;

  const One2ManyWidget({
    Key? key,
    required this.fieldName,
    required this.model,
    required this.records,
    this.fieldsInfo,
    this.client,
  }) : super(key: key);

  @override
  _One2ManyWidgetState createState() => _One2ManyWidgetState();
}

class _One2ManyWidgetState extends State<One2ManyWidget> {
  List<Map<String, dynamic>> relatedRecords = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    print('xxxxxxxxxx');
    // print(widget.fieldName);
    // print(widget.model);
    print(widget.records);
    // print(widget.fieldsInfo);
    print(widget.client);

    _fetchRelatedRecords();
  }

  Future<void> _fetchRelatedRecords() async {
    if (widget.client == null || widget.records.isEmpty) {
      setState(() {
        isLoading = false;
      });
      return;
    }
    print('vvvvvvvvvbbbbb');



    try {


      List<int> recordIds = widget.records
          .where((record) => record is int)
          .map((record) => record as int)
          .toList();

      if (recordIds.isEmpty) {
        setState(() {
          isLoading = false;
        });
        return;
      }
      print('dddddhhhhhh');
      print(widget.model);


      // Fetch the related records
      final response = await widget.client?.callKw({
        'model': widget.model,
        'method': 'search_read',
        'args': [
          [['id', 'in', recordIds]],
          [], // You can specify which fields to fetch here
        ],
        'kwargs': {
          'context': {},
        },
      });
      print('ffffllll');
      print(response.body);

      if (response != null) {
        setState(() {
          relatedRecords = List<Map<String, dynamic>>.from(response);
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching related records: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.fieldName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    // Implement add new record functionality
                    _showAddRecordDialog();
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: relatedRecords.length,
            itemBuilder: (context, index) {
              final record = relatedRecords[index];
              return ListTile(
                title: Text(record['name']?.toString() ?? 'Unnamed Record'),
                subtitle: Text('ID: ${record['id']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // Implement edit functionality
                        _showEditRecordDialog(record);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        // Implement delete functionality
                        _deleteRecord(record['id']);
                      },
                    ),
                  ],
                ),
                onTap: () {
                  // Implement view record details functionality
                  _showRecordDetails(record);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _showAddRecordDialog() {
    // Implement dialog to add new record
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Record'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Add form fields based on the model's fields
                const TextField(
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                // Add more fields as needed
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                // Implement save functionality
                Navigator.of(context).pop();
                // Refresh the records after adding
                _fetchRelatedRecords();
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditRecordDialog(Map<String, dynamic> record) {
    // Implement dialog to edit existing record
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Record'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Name'),
                  controller: TextEditingController(text: record['name']?.toString()),
                ),
                // Add more fields as needed
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                // Implement save functionality
                Navigator.of(context).pop();
                // Refresh the records after editing
                _fetchRelatedRecords();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteRecord(int recordId) async {
    // Implement delete functionality
    try {
      await widget.client?.callKw({
        'model': widget.model,
        'method': 'unlink',
        'args': [[recordId]],
        'kwargs': {},
      });

      // Refresh the records after deletion
      _fetchRelatedRecords();
    } catch (e) {
      print('Error deleting record: $e');
    }
  }

  void _showRecordDetails(Map<String, dynamic> record) {
    // Implement showing record details
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Record Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: record.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text('${entry.key}: ${entry.value}'),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}