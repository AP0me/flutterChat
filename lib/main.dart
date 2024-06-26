import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:crypt/crypt.dart';
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

  static String websocketString = 'ws://a897-213-172-91-122.ngrok-free.app';

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
  MessageObject(this.messageText);
  Map<String, dynamic> toJson() {
    return {
      'text': messageText,
    };
  }
}

class MessageObjectPackage {
  List<MessageObject> messages = [];
  String path;
  String messageAuthor;
  MessageObjectPackage(this.path, this.messageAuthor);
  Map<String, dynamic> toJson() {
    return {
      'messages': messages.map((message) => message.toJson()).toList(),
      'path': path,
      'messageAuthor': messageAuthor
    };
  }
}

class ChatMessage {
  late String messageText;
  late String author;
  ChatMessage(this.messageText, this.author);
  Map<String, dynamic> toJson() {
    return {'text': messageText, 'author': author};
  }
}

class MyHomePageState extends State<MyHomePage> {
  List<Widget> messageBoxList = [];
  String myName = 'guest';
  String sessionID = 'guest';
  late String client_salt;
  late String username;
  late String password;
  late LoginPage lpState;

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

  void handleGetMessages(List<dynamic> messages, String path, String author) {
    late ChatMessage message;
    setState(() {
      for (int i = 0; i < messages.length; i++) {
        message = ChatMessage(messages[i]['text'], messages[i]['name']);
        addAMessageBox2ViewList(this, message.messageText, message.author);
      }
    });
  }

  String passwordHasher(String password, String clientSalt) {
    return Crypt.sha256(password, salt: clientSalt, rounds: 20).hash.toString();
  }

  void getAllMessages(channel) {
    listenTo(channel);
    MessageObjectPackage chatMessages =
        MessageObjectPackage('/getMessages', myName);
    chatMessages.messages.add(MessageObject(''));
    channel.sink.add(jsonEncode(chatMessages.toJson()));
  }

  void listenTo(WebSocketChannel channel) {
    channel.stream.listen((messagesBodyString) {
      var messagesBody = jsonDecode(messagesBodyString);
      String path = messagesBody['path'];
      print(messagesBody);
      List<dynamic> messages = messagesBody['messages'];
      if (!(messages.length > 1)) {
        print("Message with length 0 was recieved");
        return;
      }
      switch (path) {
        case '/getMessages':
          handleGetMessages(messages, path, messagesBody['messageAuthor']);
          break;
        case '/addMessage':
          setState(() {
            addAMessageBox2ViewList(
                this, messages[0]['text'], messagesBody['messageAuthor']);
          });
          break;
        case '/askSalt':
          client_salt = messages[0]['client_salt'];
          lpState.login(password, username);
          break;
        case '/login':
          int count = messages[0]['count'];
          sessionID = messages[0]['session_id'];
          if (count == 1) {
            setState(() {
              myName = username;
            });
          }
          break;
        default:
      }
    }, onError: (error) async {
      print('Error occurred: $error');
    }, onDone: () async {
      print('WebSocket connection closed.');
    });
  }

  List<Widget> navigationList(context) {
    return [
      Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => LoginPage(hpState: this)),
              );
            },
            child: const Text('Login'),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RegistrationPage(
                            hpState: this,
                          )),
                );
              },
              child: const Text('Register'),
            ),
          ),
        ],
      ),
      Padding(
        padding: const EdgeInsets.only(
            left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
        child: Text("Profile: $myName"),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          textField(this),
        ],
      ),
    )));
  }
}

TextField textField(MyHomePageState hPState) {
  return TextField(
    controller: hPState.sendTextController,
    focusNode: hPState.sendTextFocusNode,
    onSubmitted: (value) {
      hPState.setState(() {
        MessageObjectPackage newMessage =
            MessageObjectPackage('/addMessage', hPState.myName);
        newMessage.messages.add(MessageObject(
            jsonEncode({"value": value, "sessionID": hPState.sessionID})));
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
