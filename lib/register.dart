import 'package:flutter/material.dart';
import 'main.dart';
import 'dart:convert';

class RegisterObject extends MessageObject {
  late String username;
  late String password;
  RegisterObject(this.username, this.password) : super('', '');

  @override
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}

class RegistrationPage extends StatelessWidget {
  final MyHomePageState hpState;
  const RegistrationPage({super.key, required this.hpState});

  @override
  Widget build(BuildContext context) {
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
              ),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
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
                String username = usernameController.text;
                String password = passwordController.text;
                String email = emailController.text;
                MessageObjectPackage registerMessagePack = MessageObjectPackage('/register');
                registerMessagePack.messages.add(RegisterObject(username, email));
                hpState.channel.sink.add(jsonEncode(registerMessagePack.toJson()));
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
