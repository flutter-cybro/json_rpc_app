import 'package:odoo_jsonrpc/odoo_jsonrpc.dart';

void main() async {
  // Create an Odoo client
  var client = OdooClient('http://10.0.20.77:8018/');


  var session = await client.authenticate('odoo18', '1', '1');
  print('Session: $session');


  // var profile = await client.fetchUserProfile();
  // print('profile : $profile');
  // Example: List databases
  var db = await client.dbList();
  print('Databases: $db');

  // var reset = await client.resetPassword('rabbit1gaming@gmail.com');
  // print('reset : $reset');

  // var pass = await client.changePassword('1');
  // print('pass : $pass');

  // Example: List installed modules
  // var modules = await client.module();
  // print('Modules: $modules');

  List<dynamic> app = await client.fetchInstalledApplications();
  print('Modules: $app');

  // Example: Create a new record
  // var createResult = await client.create('your.model', {'name': 'New Record'});
  // print('Create Result: $createResult');
  //
  // var user = await client.fetchUserProfile();
  // print(user);
  // // Example: Read records
  // var readResult = await client.readAll('res.users',['name']);
  // print('Read Result: $readResult');
  //
  // // Example: Update records
  // var updateResult = await client.update('your.model', {'name': 'Updated Record'}, [1]);
  // print('Update Result: $updateResult');
  //
  // // Example: Delete a record
  // var deleteResult = await client.delete('your.model', 1);
  // print('Delete Result: $deleteResult');
}
