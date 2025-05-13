import 'dart:developer';

mixin VisibilityParser {
  bool parseInvisibleCondition(dynamic condition, Map<String, dynamic> data) {
    log("parseInvisibleCondition  :  $condition   $data");
    if (condition == null) return false;

    // Handle simple boolean condition
    if (condition is bool) return condition;

    // Handle integer condition (Odoo often uses 1/0 for true/false)
    if (condition is int) return condition == 1;

    // Handle string condition
    if (condition is String) {
      final lowerCondition = condition.toLowerCase().trim();
      // Check for boolean strings
      if (lowerCondition == 'true' || lowerCondition == '1') return true;
      if (lowerCondition == 'false' || lowerCondition == '0') return false;

      // Handle field references, including nested fields (e.g., "journal_id.type")
      if (lowerCondition.contains('.')) {
        dynamic current = data;
        for (var part in lowerCondition.split('.')) {
          if (current is Map<String, dynamic>) {
            current = current[part];
          } else if (current is List && current.isNotEmpty) {
            // For many2one fields, use the ID (first element)
            current = current[0];
          } else {
            return false;
          }
        }
        return current != null;
      }

      // Check if the field exists and is non-null
      return data.containsKey(lowerCondition) && data[lowerCondition] != null;
    }

    // Handle map condition (for preprocessed domain conditions)
    if (condition is Map<String, dynamic>) {
      final type = condition['type']?.toString().toLowerCase();
      final key = condition['key'] as String?;
      final value = condition['value'];

      if (key == null || type == null) return false;

      // Handle nested key references (e.g., "journal_id.type")
      dynamic dataValue = data;
      for (var part in key.split('.')) {
        if (dataValue is Map<String, dynamic>) {
          dataValue = dataValue[part];
        } else if (dataValue is List && dataValue.isNotEmpty) {
          dataValue = dataValue[0]; // For many2one fields
        } else {
          dataValue = null;
          break;
        }
      }

      switch (type) {
        case 'equals':
          return dataValue == value;
        case 'not_equals':
          return dataValue != value;
        case 'greater_than':
          return dataValue is num && value is num && dataValue > value;
        case 'less_than':
          return dataValue is num && value is num && dataValue < value;
        case 'greater_or_equal':
          return dataValue is num && value is num && dataValue >= value;
        case 'less_or_equal':
          return dataValue is num && value is num && dataValue <= value;
        case 'contains':
          return dataValue is String &&
              value is String &&
              dataValue.contains(value);
        case 'not_contains':
          return dataValue is String &&
              value is String &&
              !dataValue.contains(value);
        case 'in':
          return value is List && dataValue != null && value.contains(dataValue);
        case 'not_in':
          return value is List && dataValue != null && !value.contains(dataValue);
        case 'is_null':
          return dataValue == null;
        case 'is_not_null':
          return dataValue != null;
        default:
          return false;
      }
    }

    // Handle list of conditions (for AND/OR operations or Odoo domain syntax)
    if (condition is List && condition.isNotEmpty) {
      final operator = condition[0].toString().toLowerCase();
      if (operator == 'and') {
        return condition
            .skip(1)
            .every((c) => parseInvisibleCondition(c, data));
      } else if (operator == 'or') {
        return condition.skip(1).any((c) => parseInvisibleCondition(c, data));
      } else {
        // Handle Odoo domain syntax: [('field', 'operator', value)]
        return condition.every((c) {
          if (c is List && c.length == 3) {
            final field = c[0] as String;
            final op = c[1] as String;
            final value = c[2];

            // Convert Odoo operator to internal type
            String type;
            switch (op) {
              case '=':
                type = 'equals';
                break;
              case '!=':
                type = 'not_equals';
                break;
              case '>':
                type = 'greater_than';
                break;
              case '<':
                type = 'less_than';
                break;
              case '>=':
                type = 'greater_or_equal';
                break;
              case '<=':
                type = 'less_or_equal';
                break;
              case 'in':
                type = 'in';
                break;
              case 'not in':
                type = 'not_in';
                break;
              case 'ilike':
                type = 'contains';
                break;
              case 'not ilike':
                type = 'not_contains';
                break;
              default:
                return false;
            }

            return parseInvisibleCondition(
              {'type': type, 'key': field, 'value': value},
              data,
            );
          }
          return false;
        });
      }
    }

    return false;
  }
}