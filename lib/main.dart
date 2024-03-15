import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({super.key, required this.title});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Widget> messageBoxList = [];

  final gKey = GlobalKey();

  TextEditingController sendTextController = TextEditingController();
  FocusNode sendTextFocusNode = FocusNode();
  TextField sendText = const TextField();

  final ScrollController listViewScrollController = ScrollController();
  final ScrollPhysics listViewScrollPhysics = const BouncingScrollPhysics();

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
                children: [...messageBoxList],
              ),
            ),
            TextField(
              controller: sendTextController,
              focusNode: sendTextFocusNode,
              onSubmitted: (value) {
                setState(() {
                  if (messageBoxList.isNotEmpty) {
                    Text oldLastMesaageBox = messageBoxList
                        .removeAt(messageBoxList.length - 1) as Text;
                    messageBoxList.add(Text(oldLastMesaageBox.data as String));
                  }

                  messageBoxList.add(Text(key: gKey, value));
                  sendTextController.clear();
                  sendTextFocusNode.requestFocus();
                });
                setState(() {
                  double lastMessageBoxHeight = 0;
                  if (messageBoxList.length > 1) {
                    lastMessageBoxHeight =
                        gKey.currentContext?.size?.height as double;
                  }
                  if(listViewScrollController.position.maxScrollExtent>0){
                    listViewScrollController.animateTo(
                      listViewScrollController.position.maxScrollExtent +
                      lastMessageBoxHeight,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });
              },
              decoration: const InputDecoration(
                hintTextDirection: TextDirection.ltr,
                labelText: "Send message",
                hintText: "type...",
                fillColor: Color.fromARGB(255, 255, 255, 255),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
