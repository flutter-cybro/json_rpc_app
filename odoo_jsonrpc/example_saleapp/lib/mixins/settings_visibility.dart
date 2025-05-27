import 'dart:developer';

class SettingsInvisibleUtils {
  static bool parseSettingsInvisibleCondition(
      dynamic invisible,
      Map<String, dynamic> recordState,
      Map<String, dynamic> configSettingsValues,
      ) {
    log('Parsing invisible condition: $invisible');

    if (invisible == null) {
      log('Condition is null, returning false (visible)');
      return false;
    }
    if (invisible is bool) {
      log('Condition is boolean: $invisible');
      return invisible;
    }
    if (invisible is num) {
      bool result = invisible == 1;
      log('Condition is numeric: $invisible -> $result');
      return result;
    }

    if (invisible is String) {
      final trimmed = invisible.trim();
      bool isNegated = trimmed.startsWith('not ');
      String condition = isNegated ? trimmed.substring(4).trim() : trimmed;

      log('String condition: $condition, negated: $isNegated');
      log('recordState: $recordState');
      log('configSettingsValues: $configSettingsValues');

      if (recordState.containsKey(condition)) {
        final value = recordState[condition];
        bool boolValue = value is bool ? value : (value == 'true' || value == 1);
        log('Evaluated from recordState: $condition = $value -> $boolValue');
        return isNegated ? !boolValue : boolValue;
      } else if (configSettingsValues.containsKey(condition)) {
        final value = configSettingsValues[condition];
        bool boolValue = value is bool ? value : (value == 'true' || value == 1);
        log('Evaluated from configSettingsValues: $condition = $value -> $boolValue');
        return isNegated ? !boolValue : boolValue;
      }

      log('Condition "$condition" not found in recordState or configSettingsValues');
      return false;
    }

    if (invisible is List && invisible.isNotEmpty) {
      if (invisible[0] == 'not' && invisible.length == 2) {
        final fieldName = invisible[1] as String;
        log('List condition: not $fieldName');
        if (recordState.containsKey(fieldName)) {
          final value = recordState[fieldName];
          bool boolValue = value is bool ? value : (value == 'true' || value == 1);
          log('Evaluated from recordState: $fieldName = $value -> $boolValue');
          return !boolValue;
        } else if (configSettingsValues.containsKey(fieldName)) {
          final value = configSettingsValues[fieldName];
          bool boolValue = value is bool ? value : (value == 'true' || value == 1);
          log('Evaluated from configSettingsValues: $fieldName = $value -> $boolValue');
          return !boolValue;
        }
        log('Field "$fieldName" not found');
        return false;
      }
      log('Unsupported list condition: $invisible');
      return false;
    }

    log('Invalid condition type: $invisible');
    return false;
  }
}