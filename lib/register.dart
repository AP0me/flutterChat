import 'dart:math';

import 'package:flutter/material.dart';
import 'package:crypt/crypt.dart';
import 'main.dart';
import 'dart:convert';

class UserObject extends MessageObject {
  late String username;
  late String email;
  late String password;
  late String client_salt;
  UserObject(this.username, this.email, this.password, this.client_salt) : super('');

  @override
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email':    email,
      'password': password,
      'client_salt': client_salt,
    };
  }
}

class RegistrationPage extends StatelessWidget {
  final MyHomePageState hpState;
  const RegistrationPage({super.key, required this.hpState});

  String generateSalt([int length = 16]) {
    final Random random = Random.secure();
    final List<int> values = List<int>.generate(length, (i) => random.nextInt(256));
    return base64Url.encode(values);
  }

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
                String salt = generateSalt(16);
                password = hpState.passwordHasher(password, salt);
                MessageObjectPackage registerMessagePack = MessageObjectPackage('/register', hpState.myName);
                registerMessagePack.messages.add(UserObject(username, email, password, salt));
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
