import 'dart:convert';
import 'package:flutter/material.dart';
import './main.dart';

class LoginPage extends StatelessWidget {
  final MyHomePageState hpState;
  const LoginPage({super.key, required this.hpState});

  void login(String password, String username) {
    String passwordHash = hpState.passwordHasher(
      password,
      hpState.client_salt,
    );
    MessageObjectPackage login = MessageObjectPackage('/login', hpState.myName);
    login.messages.add(MessageObject(
        jsonEncode({"username": username, "password": passwordHash})));
    print(passwordHash);
    hpState.channel.sink.add(jsonEncode(login.toJson()));
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    hpState.lpState = this;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Add your login fields and button here
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
              ),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () {
                hpState.username = usernameController.text;
                hpState.password = passwordController.text;
                MessageObjectPackage askSalt =
                    MessageObjectPackage('/askSalt', hpState.myName);
                askSalt.messages.add(MessageObject(hpState.username));
                hpState.channel.sink.add((jsonEncode(askSalt.toJson())));
                // login(password, username); this is called on main.dart
                // as result of hpState.channel.sink.add(jsonEncode(askSalt.toJson()));
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
