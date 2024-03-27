import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import './login.dart';
import './register.dart';

void main() {
  runApp(const MyApp());
}

abstract class Server {
  static String scheme = 'http';
  static String host = 'localhost';
  static int port = 3000;

  static String websocketString = 'ws://f82e-213-172-91-122.ngrok-free.app';

  static Future<WebSocketChannel> webSocketConnect(
      String socketURiString) async {
    final channel = WebSocketChannel.connect(
      Uri.parse(websocketString),
    );
    return channel;
  }
}

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

void addAMessageBox2ViewList(
    MyHomePageState hPState, String text, String author) {
  hPState.messageBoxList.insert(0, Text('$author: $text'));
}

class MessageObject {
  late String messageText;
  late String messageAuthor;
  MessageObject(this.messageText, this.messageAuthor);
  Map<String, dynamic> toJson() {
    return {
      'text': messageText,
      'name': messageAuthor,
    };
  }
}

class MessageObjectPackage {
  List<MessageObject> messages = [];
  String path;
  MessageObjectPackage(this.path);
  Map<String, dynamic> toJson() {
    return {
      'messages': messages.map((message) => message.toJson()).toList(),
      'path': path,
    };
  }
}

class MyHomePageState extends State<MyHomePage> {
  List<Widget> messageBoxList = [];
  String myName = 'root';

  TextEditingController sendTextController = TextEditingController();
  FocusNode sendTextFocusNode = FocusNode();
  TextField sendText = const TextField();

  final ScrollController listViewScrollController = ScrollController();
  final ScrollPhysics listViewScrollPhysics = const BouncingScrollPhysics();

  late WebSocketChannel channel;
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      channel = await Server.webSocketConnect(Server.websocketString);
      channel.ready.then((value) {
        getAllMessages(channel);
      }).onError((error, stackTrace) async {
        print('Error occurred: $error; Trying to reconnect...');
      });
    });
  }

  void handleGetMessages(List<dynamic> messages, String path) {
    late MessageObject message;
    setState(() {
      for (int i = 0; i < messages.length; i++) {
        message = MessageObject(messages[i]['text'], messages[i]['name']);
        addAMessageBox2ViewList(
            this, message.messageText, message.messageAuthor);
      }
    });
  }

  void getAllMessages(channel) {
    listenTo(channel);
    MessageObjectPackage chatMessages = MessageObjectPackage('/getMessages');
    chatMessages.messages.add(MessageObject('', myName));
    channel.sink.add(jsonEncode(chatMessages.toJson()));
  }

  void listenTo(WebSocketChannel channel) {
    channel.stream.listen((messagesBodyString) {
      var messagesBody = jsonDecode(messagesBodyString);
      String path = messagesBody['path'];
      List<dynamic> messages = messagesBody['messages'];
      switch (path) {
        case '/getMessages':
          handleGetMessages(messages, path);
          break;
        case '/addMessage':
          print(messagesBody);
          setState(() {
            addAMessageBox2ViewList(
                this, messages[0]['text'], messages[0]['name']);
          });
          break;
        default:
      }
    }, onError: (error) async {
      print('Error occurred: $error');
    }, onDone: () async {
      print('WebSocket connection closed.');
    });
  }

  List<Widget> navigationList(context){
    return [
      ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginPage(hpState: this)),
          );
        },
        child: const Text('Login'),
      ),
      ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RegistrationPage(hpState: this,)),
          );
        },
        child: const Text('Register'),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
            children: navigationList(context),
          ),
          Expanded(
            child: ListView(
              controller: listViewScrollController,
              physics: listViewScrollPhysics,
              reverse: true,
              children: [...messageBoxList],
            ),
          ),
          // Input field at the bottom
          textField(this),
        ],
      ),
    );
  }
}

TextField textField(MyHomePageState hPState) {
  return TextField(
    controller: hPState.sendTextController,
    focusNode: hPState.sendTextFocusNode,
    onSubmitted: (value) {
      hPState.setState(() {
        MessageObjectPackage newMessage = MessageObjectPackage('/addMessage');
        newMessage.messages.add(MessageObject(value, hPState.myName));
        hPState.channel.sink.add(jsonEncode(newMessage.toJson()));
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

