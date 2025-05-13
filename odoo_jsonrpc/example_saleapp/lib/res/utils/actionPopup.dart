import 'package:flutter/material.dart';

class ActionPopupModal extends StatelessWidget {
  final String actionName;
  final String? connectedModelName;
  final dynamic viewId;
  final String xmlArchitecture;
  final Map<String, dynamic> wizard;
  final Map<String, dynamic> selectionsMap;

  const ActionPopupModal({
    super.key,
    required this.actionName,
    this.connectedModelName,
    this.viewId,
    required this.xmlArchitecture,
    required this.wizard,
    required this.selectionsMap,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(actionName),
      content: Text("Form View UI here (based on XML)"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text("Cancel"),
        ),
      ],
    );
  }
}
