import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:http_requests/http_requests.dart';
import 'package:flutter_multiselect/flutter_multiselect.dart';
import 'package:quickalert/quickalert.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:multiselect/multiselect.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Directory document = await getApplicationDocumentsDirectory();
  Hive.init(document.path);
  await Hive.initFlutter();
  await Hive.openBox<dynamic>("contacts1");
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Box<dynamic> contactsBox = Hive.box<dynamic>("contacts1");
  Map person = {};
  Map<String, dynamic> contact = {};
  List<Map<String, dynamic>> _contacts = [];
  List _selectedPhoneNumbers = [];
  String? message = '';
  String? valuechoose = '';
  String number = '';
  String name = '';
  int keyn = 2;
  String? dropdownvalue = '0113188590';
  final TextEditingController _messageController = TextEditingController();

  final TextEditingController newcontactname = TextEditingController();
  final TextEditingController newcontactnumber = TextEditingController();
  void success() {
    QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        text: "Message sent successfuly");
  }

  void fail() {
    QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: "Message sending failed");
  }

  void _sendMessage() async {
    message = _messageController.text;
    number = dropdownvalue.toString();

    _messageController.clear();

    String contact = _selectedPhoneNumbers.toString();
    String contac = contact.replaceAll('[', '');
    contac = contac.replaceAll(' ', '');
    contac = contac.replaceAll(']', '');
    print(contact);
    Response r = await HttpRequests.get(
        "http://api.mspace.co.ke/mspaceservice/wr/sms/sendtext/username=intern/password=intern/senderid=Mspace/recipient=$contac/message=$message");
    print(
        "http://api.mspace.co.ke/mspaceservice/wr/sms/sendtext/username=intern/password=intern/senderid=Mspace/recipient=$contac/message=$message");
    if (r.statusCode == 200) {
      success();
    } else {
      fail();
    }
    setState(() {
      print(_selectedPhoneNumbers);
      _selectedPhoneNumbers = [];
    });
  }

  void _refreshlist() {
    final data = contactsBox.keys.map<Map<String, dynamic>>((key) {
      final item = contactsBox.get(key);
      String cont = item['phone'];

      return {"key": key, "name": item['name'], "phone": cont};
    }).toList();

    setState(() {
      _contacts = data.reversed.toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshlist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send SMS via url'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 54, 200, 244),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 3,
                  // child: DropDownMultiSelect(
                  //   onChanged: (List<Map<String, dynamic>> selected) {
                  //     setState(() {
                  //       _selectedPhoneNumbers = selected[0]['name'];
                  //     });
                  //   },
                  //   options: (List<String> names) {
                  //    _contacts.map<DropdownMenuItem<String>>(
                  //        (Map<String, dynamic> contact))
                  //   },
                  //   selectedValues: _selectedPhoneNumbers,
                  // ),

                  //.....
                  child: MultiSelect(
                    autovalidateMode: AutovalidateMode.always,
                    initialValue: ['IN', 'US'],
                    titleText: 'Contacts',
                    maxLength: 20, // optional
                    validator: (dynamic value) {
                      return value == null
                          ? 'Please select one or more contact(s)'
                          : null;
                    },
                    errorText: 'Please select one or more contact(s)',
                    dataSource: _contacts,
                    textField: 'name',
                    valueField: 'phone',
                    filterable: true,
                    required: true,
                    onSaved: (value) {
                      print('The saved values are $value');
                      setState(() {
                        _selectedPhoneNumbers = value;
                      });
                    },
                    change: (value) {
                      setState(() {
                        _selectedPhoneNumbers = value;
                      });
                      print('The selected values are $value');
                    },
                    selectIcon: Icons.arrow_drop_down_circle,
                    saveButtonColor: Theme.of(context).primaryColor,
                    checkBoxColor: Theme.of(context).primaryColorDark,
                    cancelButtonColor: Theme.of(context).primaryColorLight,
                    responsiveDialogSize: Size(600, 800),
                  ),
                  //.....
                  // child: DropdownButton<String>(
                  //   value: dropdownvalue,
                  //   hint: const Text('Select a contact'),
                  //   onChanged: (String? newValue) {
                  //     setState(() {
                  //       dropdownvalue = newValue;
                  //     });
                  //   },
                  //   items: _contacts.map<DropdownMenuItem<String>>(
                  //       (Map<String, dynamic> contact) {
                  //     return DropdownMenuItem<String>(
                  //       value: contact['phone'],
                  //       child: Text(contact['name']),
                  //     );
                  //   }).toList(),
                  // ),
                ),
                Expanded(
                    flex: 2,
                    child: IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) {
                              return Dialog(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          0.0, 20.0, 0, 0),
                                      child: TextField(
                                        controller: newcontactname,
                                        keyboardType: TextInputType.name,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText: 'Enter Name here',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20.0),
                                    TextField(
                                      controller: newcontactnumber,
                                      keyboardType: TextInputType.phone,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        hintText: 'Enter Number here',
                                      ),
                                    ),
                                    const SizedBox(height: 20.0),
                                    FloatingActionButton(
                                      child: const Text('Add'),
                                      onPressed: () {
                                        final name = newcontactname.text;
                                        final contact = newcontactnumber.text;

                                        person = {
                                          'name': name,
                                          'phone': contact
                                        };
                                        contactsBox.put(keyn, person);
                                        print(person);
                                        setState(() {
                                          keyn = keyn += 1;
                                        });
                                        _refreshlist();

                                        newcontactname.clear();
                                        newcontactnumber.clear();
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        })),
              ],
            ),
          ),
          Expanded(
            flex: 9,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                const SizedBox(
                  height: 20.0,
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(30.0, 0.0, 0.0, 0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Expanded(
                        flex: 9,
                        child: TextField(
                          controller: _messageController,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter Message here ...',
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: IconButton(
                          onPressed: () {
                            _sendMessage();
                          },
                          icon: const Icon(Icons.send_sharp),
                          color: Colors.blueGrey[400],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
