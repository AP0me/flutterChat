import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

abstract class Server {
  static String scheme = 'http';
  static String host = 'localhost';
  static int port = 3000;
}
String myName = 'root';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Chat',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Chat App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({super.key, required this.title});
  @override
  State<MyHomePage> createState() => MyHomePageState();
}

void addAMessageBox2ViewList(MyHomePageState hPState, text, author) {
  hPState.messageBoxList.insert(0, Text(author + ': ' + text));
  print(hPState.messageBoxList);
}

dynamic postRequest(Uri uri, String text) async {
  http.Response messages = await http.post(uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "title": 'mytitle',
        "body": {
          "text": text,
          "user": myName,
        },
      }));
  return messages.body;
}

class MyHomePageState extends State<MyHomePage> {
  List<Widget> messageBoxList = [];
  late String myName;

  TextEditingController sendTextController = TextEditingController();
  FocusNode sendTextFocusNode = FocusNode();
  TextField sendText = const TextField();

  final ScrollController listViewScrollController = ScrollController();
  final ScrollPhysics listViewScrollPhysics = const BouncingScrollPhysics();

  @override
  void initState() {
    super.initState();
    var helloUri = Uri(
      scheme: Server.scheme,
      host: Server.host,
      port: Server.port,
      path: '/messages',
    );

    late String messageText, messageAuther;
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      postRequest(helloUri, '').then((messagesBodyString) {
        late var messagesBody = jsonDecode(messagesBodyString);
        setState(() {
          for (var i = 0; i < messagesBody.length; i++) {
            messageText = messagesBody[i]["text"] as String;
            messageAuther = messagesBody[i]["name"] as String;
            addAMessageBox2ViewList(this, messageText, messageAuther);
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                controller: listViewScrollController,
                physics: listViewScrollPhysics,
                reverse: true,
                children: [...messageBoxList],
              ),
            ),
            textField(this)
          ],
        ),
      ),
    );
  }
}

TextField textField(MyHomePageState hPState) {
  var helloUri = Uri(
    scheme: Server.scheme,
    host: Server.host,
    port: Server.port,
    path: '/add_message',
  );
  return TextField(
    controller: hPState.sendTextController,
    focusNode: hPState.sendTextFocusNode,
    onSubmitted: (value) {
      hPState.setState(() {
        postRequest(helloUri, value);
        addAMessageBox2ViewList(hPState, value, myName);
        hPState.sendTextController.clear();
        hPState.sendTextFocusNode.requestFocus();
      });
    },
    decoration: const InputDecoration(
      hintTextDirection: TextDirection.ltr,
      labelText: "Send message",
      hintText: "type...",
      fillColor: Color.fromARGB(255, 255, 255, 255),
    ),
  );
}
