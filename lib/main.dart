import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/scheduler.dart';

void main() {
  runApp(const MyApp());
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

class ScrollHomePageListView {
  void scroll(MyHomePageState hPState) {
    double lastMessageBoxHeight = 0;
    if (hPState.messageBoxList.length > 1) {
      if (hPState.gKey.currentContext?.size?.height is double) {
        lastMessageBoxHeight =
            hPState.gKey.currentContext?.size?.height as double;
      } else {
        throw ErrorDescription("Scroll's max extent is not correct");
      }
    }
    if (hPState.listViewScrollController.position.maxScrollExtent > 0) {
      hPState.listViewScrollController.animateTo(
        hPState.listViewScrollController.position.maxScrollExtent +
            lastMessageBoxHeight,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
}

void addAMessageBox2ViewList(MyHomePageState hPState, value) {
  if (hPState.messageBoxList.isNotEmpty) {
    Text oldLastMesaageBox = hPState.messageBoxList
        .removeAt(hPState.messageBoxList.length - 1) as Text;
    hPState.messageBoxList.add(Text(oldLastMesaageBox.data as String));
  }
  hPState.messageBoxList.add(Text(value, key: hPState.gKey));
}

TextField textField(MyHomePageState hPState) {
  return TextField(
    controller: hPState.sendTextController,
    focusNode: hPState.sendTextFocusNode,
    onSubmitted: (value) {
      //TODO: understand how sleeps stops both setState and print();
      hPState.setState(() {
        addAMessageBox2ViewList(hPState, value);
        hPState.sendTextController.clear();
        hPState.sendTextFocusNode.requestFocus();
        ScrollHomePageListView().scroll(hPState);
      });
      sleep(Durations.extralong4);
      print(hPState.listViewScrollController.position.maxScrollExtent);
    },
    decoration: const InputDecoration(
      hintTextDirection: TextDirection.ltr,
      labelText: "Send message",
      hintText: "type...",
      fillColor: Color.fromARGB(255, 255, 255, 255),
    ),
  );
}

class MyHomePageState extends State<MyHomePage> {
  List<Widget> messageBoxList = [];

  final gKey = GlobalKey();

  TextEditingController sendTextController = TextEditingController();
  FocusNode sendTextFocusNode = FocusNode();
  TextField sendText = const TextField();

  final ScrollController listViewScrollController = ScrollController();
  final ScrollPhysics listViewScrollPhysics = const BouncingScrollPhysics();

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < 80; i++) {
      addAMessageBox2ViewList(this, "init_value$i");
    }
    SchedulerBinding.instance.addPostFrameCallback((_) {
      listViewScrollController.jumpTo(
        listViewScrollController.position.maxScrollExtent,
      );
      print(listViewScrollController.position.maxScrollExtent);
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
