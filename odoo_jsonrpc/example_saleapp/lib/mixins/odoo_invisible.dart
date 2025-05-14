import 'dart:math' as math;
import 'dart:developer' as dev;

mixin InvisibleConditionMixin {
  Map<String, dynamic> get recordState;

  final _expressionCache = <String, bool>{};
  final _customOperators = <String, bool Function(String?, String)>{};

  void registerCustomOperator(
      String operator, bool Function(String?, String) evaluator) {
    _customOperators[operator] = evaluator;
  }

  void clearExpressionCache() {
    _expressionCache.clear();
  }

  bool parseInvisibleValue(dynamic value,
      {bool useCache = true, bool requireFieldExistence = false}) {
    dev.log('Parsing invisible value: $value', name: 'InvisibleConditionMixin');
    if (value == null) return false;

    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      final lowerValue = value.toLowerCase().trim();
      if (lowerValue == 'true' || lowerValue == '1') return true;
      if (lowerValue == 'false' || lowerValue == '0') return false;

      if (useCache && _expressionCache.containsKey(value)) {
        return _expressionCache[value]!;
      }

      final result =
      _evaluateInvisibleExpression(value, requireFieldExistence: requireFieldExistence);
      if (useCache) _expressionCache[value] = result;
      return result;
    }
    if (value is List) {
      return _evaluateDomainExpression(value, requireFieldExistence: requireFieldExistence);
    }

    dev.log('Unsupported value type: ${value.runtimeType}', name: 'InvisibleConditionMixin');
    return false;
  }

  bool _evaluateInvisibleExpression(String expression,
      {bool requireFieldExistence = false}) {
    // dev.log('Evaluating expression: $expression', name: 'InvisibleConditionMixin');

    String expr = expression
        .replaceAll(RegExp(r'\s*and\s*', caseSensitive: false), '&')
        .replaceAll(RegExp(r'\s*or\s*', caseSensitive: false), '|')
        .replaceAll(RegExp(r'\s+'), '');

    dev.log('Evaluating expression: $expression', name: 'InvisibleConditionMixin');

    if (expr.contains('in') || expr.contains('notin')) {
      final operator = expr.contains('notin') ? 'notin' : 'in';
      final parts = expr.split(operator);
      if (parts.length != 2) {
        dev.log('Invalid $operator expression: $expr', name: 'InvisibleConditionMixin');
        return false;
      }

      final fieldName = parts[0].trim();
      String listPart = parts[1].trim();

      if ((listPart.startsWith('[') && listPart.endsWith(']')) ||
          (listPart.startsWith('(') && listPart.endsWith(')'))) {
        listPart = listPart.substring(1, listPart.length - 1);
        final values = _splitListValues(listPart);
        final fieldValue = recordState[fieldName]?.toString();

        if (fieldValue == null) {
          dev.log('Field $fieldName is null', name: 'InvisibleConditionMixin');
          return requireFieldExistence ? false : operator == 'notin';
        }

        final isInList = values.contains(fieldValue);
        final result = operator == 'notin' ? !isInList : isInList;
        dev.log('$fieldName $operator $values: $result', name: 'InvisibleConditionMixin');
        return result;
      }
      dev.log('Invalid list delimiters in $operator expression: $expr',
          name: 'InvisibleConditionMixin');
      return false;
    }

    if (expr.startsWith('not') && expr.length > 3) {
      final fieldName = expr.substring(3).trim();
      final result = !_getFieldBoolValue(fieldName);
      dev.log('Evaluated not $fieldName: $result', name: 'InvisibleConditionMixin');
      return result;
    }

    const comparisonOperators = ['==', '!=', '<=', '>=', '<', '>', '='];
    String? foundOperator;
    for (var op in comparisonOperators) {
      if (expr.contains(op)) {
        foundOperator = op;
        break;
      }
    }

    if (foundOperator != null) {
      final parts = expr.split(foundOperator);
      if (parts.length != 2) {
        dev.log('Invalid $foundOperator expression: $expr', name: 'InvisibleConditionMixin');
        return false;
      }

      final fieldName = parts[0].trim();
      var expectedValue = parts[1].trim();

      if ((expectedValue.startsWith("'") && expectedValue.endsWith("'")) ||
          (expectedValue.startsWith('"') && expectedValue.endsWith('"'))) {
        expectedValue = expectedValue.substring(1, expectedValue.length - 1);
      }

      if (!recordState.containsKey(fieldName)) {
        dev.log('Field $fieldName not found', name: 'InvisibleConditionMixin');
        return requireFieldExistence ? false : foundOperator == '!=';
      }

      final fieldValue = recordState[fieldName]?.toString();
      final result =
      _compareValues(fieldValue, expectedValue, foundOperator, requireFieldExistence);
      dev.log('$fieldName $foundOperator $expectedValue = $result',
          name: 'InvisibleConditionMixin');
      return result;
    }

    if (expr.startsWith('group_')) {
      final result = _getFieldBoolValue(expr);
      dev.log('Evaluated group $expr: $result', name: 'InvisibleConditionMixin');
      return result;
    }

    if (expr.contains('.')) {
      final result = _evaluateNestedField(expr, requireFieldExistence: requireFieldExistence);
      dev.log('Evaluated nested field $expr: $result', name: 'InvisibleConditionMixin');
      return result;
    }

    if (RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]*$').hasMatch(expr)) {
      final result = _getFieldBoolValue(expr);
      dev.log('Evaluated field $expr: $result', name: 'InvisibleConditionMixin');
      return result;
    }

    if (expr.contains('&') || expr.contains('|')) {
      final result = _evaluateLogicalExpression(expr, requireFieldExistence: requireFieldExistence);
      dev.log('Evaluated logical expression $expr: $result', name: 'InvisibleConditionMixin');
      return result;
    }

    final result = _getFieldBoolValue(expr);
    dev.log('Evaluated default field $expr: $result', name: 'InvisibleConditionMixin');
    return result;
  }

  List<String> _splitListValues(String listPart) {
    final result = <String>[];
    final current = StringBuffer();
    bool inQuotes = false;
    String quoteChar = '';

    for (var i = 0; i < listPart.length; i++) {
      final char = listPart[i];

      if (char == '"' || char == "'") {
        if (inQuotes && char == quoteChar) {
          inQuotes = false;
          quoteChar = '';
        } else if (!inQuotes) {
          inQuotes = true;
          quoteChar = char;
        }
        current.write(char);
      } else if (char == ',' && !inQuotes) {
        var value = current.toString().trim();
        if (value.startsWith("'") && value.endsWith("'") ||
            value.startsWith('"') && value.endsWith('"')) {
          value = value.substring(1, value.length - 1);
        }
        if (value.isNotEmpty) result.add(value);
        current.clear();
      } else {
        current.write(char);
      }
    }

    final value = current.toString().trim();
    if (value.isNotEmpty) {
      if (value.startsWith("'") && value.endsWith("'") ||
          value.startsWith('"') && value.endsWith('"')) {
        result.add(value.substring(1, value.length - 1));
      } else {
        result.add(value);
      }
    }

    dev.log('Parsed list: $result', name: 'InvisibleConditionMixin');
    return result;
  }

  bool _evaluateDomainExpression(List<dynamic> domain, {bool requireFieldExistence = false}) {
    if (domain.isEmpty) {
      dev.log('Empty domain, returning true', name: 'InvisibleConditionMixin');
      return true;
    }

    if (domain[0] is String && ['&', '|', '!'].contains(domain[0])) {
      final operator = domain[0] as String;
      if (operator == '!') {
        if (domain.length != 2) {
          dev.log('Invalid ! domain: $domain', name: 'InvisibleConditionMixin');
          return false;
        }
        return !_evaluateDomainExpression(domain[1] as List<dynamic>,
            requireFieldExistence: requireFieldExistence);
      }

      final subDomains = domain.sublist(1);
      if (operator == '&') {
        for (var subDomain in subDomains) {
          if (!_evaluateDomainExpression(subDomain as List<dynamic>,
              requireFieldExistence: requireFieldExistence)) {
            return false;
          }
        }
        return true;
      } else if (operator == '|') {
        for (var subDomain in subDomains) {
          if (_evaluateDomainExpression(subDomain as List<dynamic>,
              requireFieldExistence: requireFieldExistence)) {
            return true;
          }
        }
        return false;
      }
    }

    if (domain.length == 3) {
      final fieldName = domain[0] as String;
      final operator = domain[1] as String;
      final expectedValue = domain[2];

      final fieldValue = fieldName.contains('.')
          ? _getNestedFieldValue(fieldName)
          : recordState[fieldName]?.toString();

      if (fieldValue == null && !recordState.containsKey(fieldName)) {
        dev.log('Field $fieldName not found', name: 'InvisibleConditionMixin');
        return requireFieldExistence ? false : (operator == '!=' || operator == 'not in');
      }

      if (operator == 'in' || operator == 'not in') {
        final values = expectedValue is List
            ? expectedValue.map((v) => v.toString()).toList()
            : [expectedValue.toString()];
        final isInList = values.contains(fieldValue);
        final result = operator == 'not in' ? !isInList : isInList;
        dev.log('$fieldName $operator $values: $result', name: 'InvisibleConditionMixin');
        return result;
      }

      if (operator == 'ilike' || operator == 'not ilike') {
        if (fieldValue == null) {
          return operator == 'not ilike';
        }
        final isLike =
        fieldValue.toLowerCase().contains(expectedValue.toString().toLowerCase());
        final result = operator == 'not ilike' ? !isLike : isLike;
        dev.log('$fieldName $operator $expectedValue: $result', name: 'InvisibleConditionMixin');
        return result;
      }

      final result = _compareValues(fieldValue, expectedValue.toString(), operator,
          requireFieldExistence);
      dev.log('$fieldName $operator $expectedValue: $result', name: 'InvisibleConditionMixin');
      return result;
    }

    dev.log('Invalid domain: $domain', name: 'InvisibleConditionMixin');
    return false;
  }

  bool _compareValues(String? fieldValue, String expectedValue, String operator,
      bool requireFieldExistence) {
    if (fieldValue == null) {
      return requireFieldExistence ? false : (operator == '!=' || operator == 'not in');
    }

    if (_customOperators.containsKey(operator)) {
      return _customOperators[operator]!(fieldValue, expectedValue);
    }

    final fieldNum = double.tryParse(fieldValue);
    final expectedNum = double.tryParse(expectedValue);

    if (fieldNum != null && expectedNum != null) {
      switch (operator) {
        case '==':
        case '=':
          return fieldNum == expectedNum;
        case '!=':
          return fieldNum != expectedNum;
        case '<':
          return fieldNum < expectedNum;
        case '>':
          return fieldNum > expectedNum;
        case '<=':
          return fieldNum <= expectedNum;
        case '>=':
          return fieldNum >= expectedNum;
        default:
          dev.log('Unsupported numerical operator: $operator', name: 'InvisibleConditionMixin');
          return false;
      }
    }

    switch (operator) {
      case '==':
      case '=':
        return fieldValue == expectedValue;
      case '!=':
        return fieldValue != expectedValue;
      default:
        dev.log('Unsupported string operator: $operator', name: 'InvisibleConditionMixin');
        return false;
    }
  }

  bool _evaluateLogicalExpression(String expr, {bool requireFieldExistence = false}) {
    if (expr.startsWith('(') && expr.endsWith(')')) {
      final innerExpr = expr.substring(1, expr.length - 1).trim();
      if (innerExpr.isNotEmpty) {
        return _evaluateInvisibleExpression(innerExpr,
            requireFieldExistence: requireFieldExistence);
      }
      return false;
    }

    if (expr.contains('|')) {
      final conditions = _splitOnOperator(expr, '|', respectParentheses: true);
      for (var condition in conditions) {
        if (_evaluateInvisibleExpression(condition,
            requireFieldExistence: requireFieldExistence)) {
          return true;
        }
      }
      return false;
    }

    if (expr.contains('&')) {
      final conditions = _splitOnOperator(expr, '&', respectParentheses: true);
      for (var condition in conditions) {
        if (!_evaluateInvisibleExpression(condition,
            requireFieldExistence: requireFieldExistence)) {
          return false;
        }
      }
      return true;
    }

    return _evaluateInvisibleExpression(expr, requireFieldExistence: requireFieldExistence);
  }

  List<String> _splitOnOperator(String expr, String operator,
      {bool respectParentheses = false}) {
    final result = <String>[];
    final current = StringBuffer();
    bool inQuotes = false;
    String quoteChar = '';
    int parenLevel = 0;

    for (var i = 0; i < expr.length; i++) {
      final char = expr[i];

      if (char == '"' || char == "'") {
        if (inQuotes && char == quoteChar) {
          inQuotes = false;
          quoteChar = '';
        } else if (!inQuotes) {
          inQuotes = true;
          quoteChar = char;
        }
      } else if (respectParentheses && char == '(' && !inQuotes) {
        parenLevel++;
      } else if (respectParentheses && char == ')' && !inQuotes) {
        parenLevel--;
      } else if (char == operator && !inQuotes && parenLevel == 0) {
        if (current.isNotEmpty) result.add(current.toString().trim());
        current.clear();
        continue;
      }

      current.write(char);
    }

    if (current.isNotEmpty) result.add(current.toString().trim());
    return result;
  }

  bool _getFieldBoolValue(String fieldName) {
    final value = fieldName.contains('.')
        ? _getNestedFieldValue(fieldName)
        : recordState[fieldName];

    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      final lowerValue = value.toLowerCase();
      return lowerValue == 'true' || lowerValue == '1';
    }
    return false;
  }

  dynamic _getNestedFieldValue(String fieldPath) {
    final parts = fieldPath.split('.');
    dynamic current = recordState;

    for (var part in parts) {
      if (current is Map<String, dynamic>) {
        current = current[part];
      } else if (current is List && int.tryParse(part) != null) {
        final index = int.parse(part);
        if (index >= 0 && index < current.length) {
          current = current[index];
        } else {
          return null;
        }
      } else {
        return null;
      }
    }

    return current;
  }

  bool _evaluateNestedField(String expr, {bool requireFieldExistence = false}) {
    const comparisonOperators = ['==', '!=', '='];
    String? foundOperator;
    for (var op in comparisonOperators) {
      if (expr.contains(op)) {
        foundOperator = op;
        break;
      }
    }

    if (foundOperator != null) {
      final parts = expr.split(foundOperator);
      if (parts.length != 2) {
        dev.log('Invalid nested field expression: $expr', name: 'InvisibleConditionMixin');
        return false;
      }

      final fieldPath = parts[0].trim();
      var expectedValue = parts[1].trim();

      if ((expectedValue.startsWith("'") && expectedValue.endsWith("'")) ||
          (expectedValue.startsWith('"') && expectedValue.endsWith('"'))) {
        expectedValue = expectedValue.substring(1, expectedValue.length - 1);
      }

      final fieldValue = _getNestedFieldValue(fieldPath)?.toString();
      if (fieldValue == null && requireFieldExistence) {
        dev.log('Nested field $fieldPath not found', name: 'InvisibleConditionMixin');
        return false;
      }
      return _compareValues(fieldValue, expectedValue, foundOperator, requireFieldExistence);
    }

    return _getFieldBoolValue(expr);
  }
}