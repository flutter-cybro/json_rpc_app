import 'dart:developer';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:odoo_jsonrpc/odoo_jsonrpc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml2json/xml2json.dart';
import 'package:intl/intl.dart';
import '../../res/constants/app_colors.dart';
import 'form_view_page.dart';


class ViewDetailsWidget extends StatefulWidget {
  final String mainView;
  final Map<String, dynamic>? viewsData;
  final List<dynamic>? fieldsData;
  final List<dynamic>? allFieldNames;
  final List<dynamic>? allRequiredFieldNames;

  const ViewDetailsWidget(
      {super.key,
      required this.mainView,
      required this.viewsData,
      required this.allFieldNames,
      required this.allRequiredFieldNames,
      required this.fieldsData});

  @override
  State<ViewDetailsWidget> createState() => _ViewDetailsWidgetState();
}

class _ViewDetailsWidgetState extends State<ViewDetailsWidget> {
  OdooClient? client;
  List<Map<String, dynamic>> records = [];
  List<String> fieldNames = [];
  List<String> requiredFieldNames = [];

  bool isDataFetched = false;

  @override
  void initState() {
    super.initState();
    _initializeOdooClient();
  }


  String convertXmlToJson(String xml) {
    final Xml2Json xml2json = Xml2Json();
    xml2json.parse(xml);
    return xml2json.toGData();
  }


  Future<void> _initializeOdooClient() async {
    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString('url') ?? '';
    final db = prefs.getString('selectedDatabase') ?? '';
    final sessionId = prefs.getString('sessionId') ?? '';

    if (url.isEmpty || db.isEmpty || sessionId.isEmpty) {
      throw Exception('URL, database, or session details not set');
    }

    final session = OdooSession(
      id: sessionId,
      userId: prefs.getInt('userId') ?? 0,
      partnerId: prefs.getInt('partnerId') ?? 0,
      userLogin: prefs.getString('userLogin') ?? '',
      userName: prefs.getString('userName') ?? '',
      userLang: prefs.getString('userLang') ?? '',
      isSystem: prefs.getBool('isSystem') ?? false,
      dbName: db,
      serverVersion: prefs.getString('serverVersion') ?? '',
      userTz: '',
    );

    client = OdooClient(url, session);
    log('Odoo client initialized with URL: $url');


    _fetchDataIfNeeded();
  }




  Future<void> _fetchModelData(
      String modelName, List<String> fieldNames) async {
    try {


      final fieldDefsResponse = await client?.callKw({
        'model': modelName,
        'method': 'fields_get',
        'args': [],
        'kwargs': {},
      });

      List<String> requiredFields = [];

      if (fieldDefsResponse != null) {
        for (var fieldName in fieldDefsResponse.keys) {
          final fieldDef = fieldDefsResponse[fieldName];
          if (fieldDef != null && fieldDef['required'] == true) {
            requiredFields.add(fieldName);
          }
        }
      }


      final response = await client?.callKw({
        'model': modelName,
        'method': 'search_read',
        'args': [[], fieldNames],
        'kwargs': {},
      });

      if (response != null && response.isNotEmpty) {
        setState(() {
          records = List<Map<String, dynamic>>.from(response);

          isDataFetched = true;
          this.fieldNames = fieldNames;
          this.requiredFieldNames =
              requiredFields;

        });
      } else {

      }
    } catch (e) {

    }
  }


  void _fetchDataIfNeeded() {
    if (widget.viewsData != null &&
        widget.viewsData!.containsKey('views') &&
        widget.viewsData?['views'].containsKey(widget.mainView)) {
      final viewDetails = widget.viewsData?['views'][widget.mainView];
      final modelName = viewDetails['model'];
      final xmlString = viewDetails['arch'];


      if (xmlString != null) {
        final jsonDataString = convertXmlToJson(xmlString);
        final Map<String, dynamic> jsonData = jsonDecode(jsonDataString);

        String? viewOfXml;

        if (widget.mainView == 'list') {
          viewOfXml = 'tree';
        // } else if (widget.mainView == 'kanban') {
        //   viewOfXml = 'kanban';
        } else if (widget.mainView == 'form') {
          viewOfXml = 'form';
        }



        if (viewOfXml != null &&
            jsonData.containsKey(widget.mainView) &&
            viewOfXml == 'tree') {
          final fields = jsonData[widget.mainView]['field'] as List<dynamic>;
          final List<String> fieldNames =
              fields.map((field) => field['name'].toString()).toList();
          final List<String> requiredFieldNames =
              fields.map((field) => field['name'].toString()).toList();
          _fetchModelData(modelName, fieldNames);
          _fetchModelData(modelName, requiredFieldNames);
        } else if (viewOfXml != null && viewOfXml == 'form') {

        // } else if (viewOfXml != null && viewOfXml == 'kanban') {
        //   final fields = jsonData[viewOfXml]['field'] as List<dynamic>;
        //   final List<String> fieldNames =
        //       fields.map((field) => field['name'].toString()).toList();
        //   _fetchModelData(modelName, fieldNames);
        //   final List<String> requiredFieldNames =
        //       fields.map((field) => field['name'].toString()).toList();
        //   _fetchModelData(modelName, requiredFieldNames);

        } else {

        }
      } else {

      }
    } else {

    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.viewsData == null ||
        !widget.viewsData!.containsKey('views') ||
        !widget.viewsData?['views'].containsKey(widget.mainView)) {
      return const Text('No valid view data available');
    }
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (records.isNotEmpty && fieldNames.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    final String? iconPath = record['icon'];
                    final String? fullIconUrl =
                        iconPath != null && iconPath.isNotEmpty
                            ? 'http://10.42.0.1:8017$iconPath'
                            : null;

                    return Column(
                      children: [
                        ListTile(
                          title: Row(
                            children: [
                              if (fullIconUrl != null)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Image.network(
                                    fullIconUrl,
                                    width: 24,
                                    height: 24,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(Icons.error, color: Colors.red);
                                    },
                                  ),
                                ),
                              Expanded(
                                child: Text(
                                  record['name'] ??
                                      record[fieldNames[2]]?.toString() ??
                                      'No name',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              if (record['state'] != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    '${record['state']}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (record['summary'] != null)
                                Padding(
                                  padding: const EdgeInsets.only(left: 24.0),
                                  child: Text(
                                    '${record['summary']}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              if (record['create_date'] != null)
                                Text(
                                  DateFormat('yyyy-MM-dd').format(
                                    DateTime.parse(record['create_date']),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              if (record['partner_id'] is Map)
                                Text(
                                  '${record['partner_id']['name']}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              if (record['amount_total'] != null)
                                Text(
                                  '${record['amount_total']}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: GREEN_COLOR,
                                  ),
                                ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FormViewPage(
                                  record: record,
                                  fieldNames: fieldNames,
                                  requiredFieldNames: requiredFieldNames,
                                  viewsData: widget.viewsData,
                                  fieldsData: widget.fieldsData,
                                  allFieldNames: widget.allFieldNames,
                                  allRequiredFieldNames: widget.allRequiredFieldNames,
                                  mainView: widget.mainView,
                                  recordName: record['name'], // Pass the name here
                                ),
                              ),
                            );
                          },
                        ),
                        const Divider(),
                      ],
                    );
                  },
                )
              else if (!isDataFetched)
                const Center(child: CircularProgressIndicator())
              else
                const Text('No data found or data is empty'),
            ],
          ),
        ),
      ),
    );
  }
}
