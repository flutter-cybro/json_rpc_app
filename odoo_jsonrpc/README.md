# Odoo RPC Client Library

Odoo JsonRPC Client Library for Dart.

## Features

- Create client Odoo Session.
- Authenticate via database name, login and password.
- Issue JSON-RPC requests to JSON controllers.
- Execute public methods via `CallKw`.
- Terminate session (logout).

## Usage

To use this plugin, add odoo_jsonrpc as a dependency in your pubspec.yaml file. For example:

```yaml
dependencies:
  odoo_jsonrpc: ^0.0.1
```

## Examples

Basic RPC-call

```dart
import 'dart:io';
import 'package:odoo_jsonrpc/odoo_jsonrpc.dart';

main() async {
  final client = OdooClient('https://my-db.odoo.com');
  try {
    await client.authenticate('my-db', 'admin', 'admin');
    final res = await client.call('/web/session/modules', []);
    print('Installed modules: \n' + res.toString());
  }  catch (e) {
    print(e);
  }
}
```

RPC-Calls for dbList out.

```dart
import 'dart:io';
import 'package:odoo_jsonrpc/odoo_jsonrpc.dart';

main() async {
  final client = OdooClient('https://my-db.odoo.com');
  final db = client.dbList();
  print(db);
  try {
    await client.authenticate('my-db', 'admin', 'admin');
  }  catch (e) {
    print(e);
  }
}
```



## Web platform notice

This package intentionally uses `http` package instead of `dart:io` so web platform could be supported.
However RPC calls via web client (dart js) that is hosted on separate domain will not work
due to CORS requests currently are not correctly handled by Odoo.
See [https://github.com/Shalbinmp/odoo_jsonrpc.git) for the details.

## Issues

Please file any issues, bugs or feature requests as an issue on our [GitHub](https://github.com/Shalbinmp/odoo_jsonrpc/issues) page.

## Want to contribute

If you would like to contribute to the plugin (e.g. by improving the documentation, solving a bug or adding a cool new feature), please send us your [pull request](https://github.com/Shalbinmp/odoo_jsonrpc/pulls).

## Author

Odoo RPC Client Library is developed by [SHALBIN MP](https://github.com/Shalbinmp).