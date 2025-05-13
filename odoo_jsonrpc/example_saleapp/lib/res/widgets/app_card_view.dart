import 'package:flutter/material.dart';
import 'package:odoo_jsonrpc/odoo_jsonrpc.dart';

import '../../pages/submenu_listview.dart';



class AppCard extends StatelessWidget {
  final dynamic module;


  AppCard({super.key, required this.module,

  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubmenuListview(
              // module: module,
              // client: null,
              moduleName: module.display_name,
              moduleId: module.id, // Pass client here
            ),
          ),
        );
      },
      child: Card(
        elevation: 5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (module.iconBytes != null)
              Image.memory(
                module.iconBytes!,
                height: screenSize.height * 0.08,
                width: screenSize.width * 0.2,
              ),
            const SizedBox(height: 10),
            Text(
              module.display_name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
