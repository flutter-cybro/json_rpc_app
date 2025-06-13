import 'package:flutter/material.dart';
import 'package:odoo_jsonrpc/odoo_jsonrpc.dart';

class One2ManyWidget extends StatefulWidget {
  final String fieldName;
  final String model;
  final List<dynamic> records;
  final Map<String, dynamic>? fieldsInfo;
  final OdooClient? client;

  const One2ManyWidget({
    super.key,
    required this.fieldName,
    required this.model,
    required this.records,
    this.fieldsInfo,
    this.client,
  });

  @override
  _One2ManyWidgetState createState() => _One2ManyWidgetState();
}

class _One2ManyWidgetState extends State<One2ManyWidget> {
  List<Map<String, dynamic>> relatedRecords = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRelatedRecords();
  }

  Future<void> _fetchRelatedRecords() async {
    if (widget.client == null || widget.records.isEmpty) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final recordIds = widget.records.whereType<int>().toList();
      if (recordIds.isEmpty) {
        setState(() => isLoading = false);
        return;
      }

      final response = await widget.client!.callKw({
        'model': widget.model,
        'method': 'search_read',
        'args': [
          [['id', 'in', recordIds]],
          ['id', 'name'], // Fetch only necessary fields
        ],
        'kwargs': {'context': {}},
      });

      setState(() {
        relatedRecords = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch records: $e')),
        );
      }
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme),
          const Divider(height: 1),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
            onRefresh: _fetchRelatedRecords,
            child: relatedRecords.isEmpty
                ? const Center(child: Text('No records found'))
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: relatedRecords.length,
              itemBuilder: (context, index) {
                final record = relatedRecords[index];
                return _buildRecordTile(theme, record, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.fieldName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          IconButton(
            icon: Icon(Icons.add, color: theme.colorScheme.primary),
            onPressed: _showAddRecordDialog,
            tooltip: 'Add new record',
          ),
        ],
      ),
    );
  }

  Widget _buildRecordTile(ThemeData theme, Map<String, dynamic> record, int index) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 300),
      child: ListTileTheme(
        data: ListTileThemeData(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          tileColor: index.isEven ? theme.colorScheme.surfaceContainerLow : null,
        ),
        child: ListTile(
          title: Text(
            record['name']?.toString() ?? 'Unnamed Record',
            style: theme.textTheme.bodyLarge,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            'ID: ${record['id']}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: theme.colorScheme.primary),
                onPressed: () => _showEditRecordDialog(record),
                tooltip: 'Edit record',
              ),
              IconButton(
                icon: Icon(Icons.delete, color: theme.colorScheme.error),
                onPressed: () => _deleteRecord(record['id']),
                tooltip: 'Delete record',
              ),
            ],
          ),
          onTap: () => _showRecordDetails(record),
        ),
      ),
    );
  }

  void _showAddRecordDialog() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Add New Record', style: theme.textTheme.titleLarge),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  value!.isEmpty ? 'Name is required' : null,
                  textInputAction: TextInputAction.done,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    await widget.client?.callKw({
                      'model': widget.model,
                      'method': 'create',
                      'args': [
                        {'name': nameController.text}
                      ],
                      'kwargs': {},
                    });
                    Navigator.pop(context);
                    _fetchRelatedRecords();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to add record: $e')),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    ).whenComplete(() => nameController.dispose());
  }

  void _showEditRecordDialog(Map<String, dynamic> record) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: record['name']?.toString());

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Edit Record', style: theme.textTheme.titleLarge),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  value!.isEmpty ? 'Name is required' : null,
                  textInputAction: TextInputAction.done,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    await widget.client?.callKw({
                      'model': widget.model,
                      'method': 'write',
                      'args': [
                        [record['id']],
                        {'name': nameController.text}
                      ],
                      'kwargs': {},
                    });
                    Navigator.pop(context);
                    _fetchRelatedRecords();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update record: $e')),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    ).whenComplete(() => nameController.dispose());
  }

  Future<void> _deleteRecord(int recordId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => isLoading = true);
              try {
                await widget.client?.callKw({
                  'model': widget.model,
                  'method': 'unlink',
                  'args': [[recordId]],
                  'kwargs': {},
                });
                _fetchRelatedRecords();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Record deleted successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete record: $e')),
                  );
                }
                setState(() => isLoading = false);
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showRecordDetails(Map<String, dynamic> record) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Record Details', style: theme.textTheme.titleLarge),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: record.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    '${entry.key}: ${entry.value}',
                    style: theme.textTheme.bodyMedium,
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}