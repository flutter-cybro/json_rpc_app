import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:odoo_jsonrpc/odoo_jsonrpc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml2json/xml2json.dart';
import 'package:xml/xml.dart';

import '../odoo_res/odoo_xml_widget/datetime_selector.dart';
import '../odoo_res/odoo_xml_widget/float.dart';
import '../odoo_res/odoo_xml_widget/integer.dart';
import '../odoo_res/odoo_xml_widget/many2one.dart';
import '../odoo_res/odoo_xml_widget/monetory.dart';
import '../odoo_res/odoo_xml_widget/one2many.dart';


class FormViewPage extends StatefulWidget {
  final Map<String, dynamic> record;
  final List<String> fieldNames;
  final List<String> requiredFieldNames;
  final Map<String, dynamic>? viewsData;
  final List<dynamic>? fieldsData;
  final List<dynamic>? allFieldNames;
  final List<dynamic>? allRequiredFieldNames;
  final String mainView;
  final String recordName;
  const FormViewPage({
    super.key,
    required this.record,
    required this.fieldNames,
    required this.requiredFieldNames,
    required this.fieldsData,
    required this.viewsData,
    required this.mainView,
    required this.allFieldNames,
    required this.allRequiredFieldNames,
    required this.recordName,
  });

  @override
  _FormViewPageState createState() => _FormViewPageState();
}

class _FormViewPageState extends State<FormViewPage> {
  OdooClient? client;
  List<Map<String, dynamic>> records = [];
  List<String> fieldNames = [];
  List<String> requiredFieldNames = [];
  bool isDataFetched = false;
  Map<String, TextEditingController> controllers = {};
  List<Map<String, dynamic>> buttons = [];

  String status = " ";
  Map<String, Map<String, dynamic>> fieldDetails = {};

  @override
  void initState() {
    super.initState();
    fieldNames = widget.fieldNames;
    requiredFieldNames = widget.requiredFieldNames;
    _processFieldDetails();
    _initializeOdooClient();
    _initializeControllers();
  }

  void _processFieldDetails() {
    if (widget.fieldsData != null) {
      for (var field in widget.fieldsData!) {
        if (field is Map<String, dynamic>) {
          fieldDetails[field['name'].toString()] = field;
        }
      }
    }
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
    _fetchDataIfNeeded();
  }

  void _initializeControllers() {
    for (String fieldName in widget.fieldNames) {
      final fieldValue = widget.record[fieldName];
      final fieldText = (fieldValue is List && fieldValue.length > 1)
          ? fieldValue[1].toString()
          : fieldValue?.toString() ?? 'N/A';
      controllers[fieldName] = TextEditingController(text: fieldText);
    }
  }

  void _fetchDataIfNeeded() {
    if (widget.viewsData != null &&
        widget.viewsData!.containsKey('views') &&
        widget.viewsData?['views'].containsKey(widget.mainView)) {
      final viewDetails = widget.viewsData?['views'][widget.mainView];
      final modelName = viewDetails['model'];
      final xmlString = viewDetails['arch'];
      final fieldDetails = widget.fieldsData;
      for (var individualFieldDetails in fieldDetails!) {
      }

      if (xmlString != null) {
        final jsonDataString = convertXmlToJson(xmlString);
        final Map<String, dynamic> jsonData = jsonDecode(jsonDataString);

        String? viewOfXml;

        if (widget.mainView == 'list') {
          viewOfXml = 'tree';
        } else if (widget.mainView == 'kanban') {
          viewOfXml = 'kanban';
        } else if (widget.mainView == 'form') {
          viewOfXml = 'form';
        }



        if (viewOfXml != null && jsonData.containsKey(widget.mainView)) {
          final fields = jsonData[widget.mainView]['field'] as List<dynamic>;
          final List<String> fieldNames =
              fields.map((field) => field['name'].toString()).toList();


          if (viewOfXml == 'tree' || viewOfXml == 'kanban') {
            _fetchModelData(modelName, fieldNames);
          } else {

          }
        } else {

        }
      } else {

      }
    } else {

    }
  }

  String convertXmlToJson(String xml) {
    final Xml2Json xml2json = Xml2Json();
    xml2json.parse(xml);
    return xml2json.toGData();
  }

  Future<void> _fetchModelData(
      String modelName, List<String> fieldNames) async {
    try {

      final response = await client?.callKw({
        'model': modelName,
        'method': 'search_read',
        'args': [
          [
            ['id', '=', widget.record['id']]
          ],
          []
        ],
        'kwargs': {},
      });



      if (response != null && response.isNotEmpty) {
        setState(() {
          records = List<Map<String, dynamic>>.from(response);
          isDataFetched = true;

          _extractButtonsAndStatus();
        });
      } else {

      }
    } catch (e) {

    }
  }

  void _extractButtonsAndStatus() {


    if (widget.viewsData != null && widget.viewsData!['views'] != null) {
      final viewDetails = widget.viewsData?['views']['form'];
      final xmlString = viewDetails['arch'];

      if (xmlString != null) {
        final document = XmlDocument.parse(xmlString);
        final buttonsInView = document.findAllElements('button');


        for (var button in buttonsInView) {

          final name = button.getAttribute('name');
          final string = button.getAttribute('string');
          final type = button.getAttribute('type');
          final invisible = button.getAttribute('invisible');

          bool isVisible = true;

          if (invisible == "1") {
            isVisible = false;
          } else if (invisible == null) {
            isVisible = false;
          } else if (invisible != null) {
            if (invisible.contains("!=") &&
                invisible.indexOf("!=") == invisible.lastIndexOf("!=")) {

              List<String> parts = invisible.split("!=");


              String firstElement = parts[0].trim();
              String secondElement =
                  parts[1].replaceAll("'", "").trim();



              print('records: $records');

              if (records.isNotEmpty) {
                records[0].forEach((key, value) {
                  if (key == '$firstElement') {

                    if (firstElement == key) {
                      if (secondElement == value) {
                        isVisible = true;
                      } else {
                        isVisible = false;
                      }
                    }
                  }
                });
              }
            }

            else if (invisible.contains("==") &&
                invisible.indexOf("==") == invisible.lastIndexOf("==")) {
              print('44444444');
              List<String> parts = invisible.split("==");


              String firstElement = parts[0].trim();
              String secondElement =
                  parts[1].replaceAll("'", "").trim();



              print(records);

              if (records.isNotEmpty) {
                records[0].forEach((key, value) {
                  if (key == '$firstElement') {

                    if (firstElement == key) {
                      if (secondElement == value) {
                        isVisible = false;
                      } else {
                        isVisible = true;
                      }
                    }
                  }
                });
              }
            } else if (invisible.startsWith("not") &&
                !RegExp(r"\b(or|and)\b").hasMatch(invisible) &&
                RegExp(r"\bnot\b").allMatches(invisible).length == 1) {
              String element = invisible.replaceFirst("not", "").trim();
              if (records.isNotEmpty) {
                records[0].forEach((key, value) {
                  if (key == '$element') {

                    if (element == key) {
                      if (value == true) {
                        isVisible = true;
                      } else {
                        isVisible = false;
                      }
                    }
                  }
                });
              }
            } else if (invisible.contains("not in") &&
                !RegExp(r"\b(or|and)\b").hasMatch(invisible) &&
                RegExp(r"\bnot\b").allMatches(invisible).length == 1) {

              List<String> elements = [];
              List<String> parts = invisible.split("not in");
              String firstElement = parts[0].trim();
              String secondElement = parts[1].replaceAll("'", "").trim();

              int startIndex = secondElement.indexOf('(');
              int endIndex = secondElement.indexOf(')');

              String elementsString =
                  secondElement.substring(startIndex + 1, endIndex);

              elements = elementsString.split(', ');


              for (var ele in elements) {

                if (records.isNotEmpty) {
                  records[0].forEach((key, value) {
                    if (key == '$firstElement') {

                      if (firstElement == key) {
                        if (ele == value) {
                          isVisible = true;
                        } else {
                          isVisible = false;
                        }
                      }
                    }
                  });
                }
              }
            } else if (invisible.contains("not") &&
                invisible.contains("or") &&
                !RegExp(r"\b(and)\b").hasMatch(invisible) &&
                RegExp(r"\bnot\b").allMatches(invisible).length == 1) {


              List<String> conditions = invisible.split("or");

              for (String condition in conditions) {
                condition = condition.trim();

                if (condition.startsWith("not ")) {
                  String element = condition.replaceAll("not ", "").trim();


                  if (records.isNotEmpty) {
                    records[0].forEach((key, value) {
                      if (key == element &&
                          value != null &&
                          value.toString() == 'false') {

                        isVisible = true;
                      } else {
                        isVisible = false;
                      }
                    });
                  }
                } else if (condition.contains(" in ")) {

                  List<String> inParts = condition.split(" in ");
                  String firstElement = inParts[0].trim();
                  String secondElement = inParts[1].trim();


                  secondElement =
                      secondElement.replaceAll(RegExp(r"[\[\]']"), "").trim();
                  List<String> elements = secondElement.split(', ');



                  if (records.isNotEmpty) {
                    records[0].forEach((key, value) {
                      if (key == firstElement && elements.contains(value)) {

                        isVisible = true;
                      } else {
                        isVisible = false;
                      }
                    });
                  }
                }
              }
            }


          }



          if (isVisible && string != null) {
            buttons.add({
              'name': name ?? '',
              'string': string ?? '',
              'type': type ?? '',
            });
          }
        }


        final header = document.findAllElements('header').isNotEmpty
            ? document.findAllElements('header').first
            : null;
        if (header != null) {
          final statusElement = header.findElements('field').firstWhere(
              (field) => field.getAttribute('name') == 'status',
              orElse: () =>
                  XmlElement(XmlName(''))); // Provide a fallback element
          if (statusElement.getAttribute('string') != null) {
            status = statusElement.getAttribute('string') ?? "Draft";
          }
        }


        if (records.isNotEmpty) {

        } else {

        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recordName,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Color(0xFF7D3C98),
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Colors.white),

          onPressed: () {

            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    status,
                    style: const TextStyle(fontSize: 18, color: Colors.blue),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (buttons.isNotEmpty)
                Wrap(
                  spacing: 10.0,
                  children: buttons.map((button) {
                    return ElevatedButton(
                      onPressed: () {

                      },
                      child: Text(button['string'] ?? 'Action'),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.allFieldNames?.length,
                itemBuilder: (context, index) {
                  final fieldName = widget.allFieldNames?[index];
                  final fieldNames = widget.allRequiredFieldNames?[index];

                  if (fieldName == 'partner_shipping_id') {

                  }

                  final controller = controllers[fieldName];
                  final fieldInfo = fieldDetails[fieldName] ?? {};
                  final isMany2One = fieldInfo['ttype'] == 'many2one';
                  final isDateTime = fieldInfo['ttype'] == 'datetime';
                  final isDate = fieldInfo['ttype'] == 'date';
                  final isMonetory = fieldInfo['ttype'] == 'monetary';
                  final isFloat = fieldInfo['ttype'] == 'float';
                  final isInteger = fieldInfo['ttype'] == 'integer';
                  final isChar = fieldInfo['ttype'] == 'char';
                  final isText = fieldInfo['ttype'] == 'text';
                  final isOne2many = fieldInfo['ttype'] == 'one2many';

                  final relationModel =
                      fieldInfo['relation'];
                  final selectionData = fieldInfo['selection'];




                  bool isPartnerIdField = fieldName == 'partner_id';
                  bool isCompanyIdField = fieldName == 'company_id';

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fieldInfo['field_description']?.toString() ??
                              fieldName,

                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors
                                .grey,
                          ),
                        ),
                        const SizedBox(height: 8),


                        if (isPartnerIdField)
                          Many2one(
                            fieldName: fieldName,
                            modelName:
                                'res.partner',
                          ),
                        if (isCompanyIdField)
                          Many2one(
                            fieldName: fieldName,
                            modelName:
                                'res.company',
                          ),


                        if (isMany2One &&
                            relationModel != null &&
                            !isPartnerIdField &&
                            !isCompanyIdField)
                          Many2one(
                            fieldName: fieldName,
                            modelName: relationModel
                                .toString(),
                          ),
                        if (isDateTime) DateTimeSelectorWidget(),
                        if (isDate) DateTimeSelectorWidget(),
                        if (isMonetory)
                          MonetaryField(
                            label: '',
                          ),
                        if (isFloat) FloatField(),
                        if (isInteger) IntegerInput(),
                        if (isChar || isText)
                          TextField(
                            controller: controller,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 5.0),
                            ),
                            onChanged: (value) {
                              setState(() {
                                widget.record[fieldName] = value;
                              });
                            },
                          ),

                        // Handle One2Many field
                        if (isOne2many && fieldInfo['relation'] != null)
                          One2ManyWidget(
                            fieldName:
                                fieldInfo['field_description']?.toString() ??
                                    fieldName,
                            model: fieldInfo['relation'],
                            records: widget.record[fieldName] ?? [],
                            fieldsInfo: fieldInfo,
                            client: client,
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
