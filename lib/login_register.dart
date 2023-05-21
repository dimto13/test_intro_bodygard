import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

final Logger _logger = Logger();

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anmeldung'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  email = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'E-Mail',
              ),
            ),
            const SizedBox(height: 20.0),
            TextField(
              onChanged: (value) {
                setState(() {
                  password = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Passwort',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                _logger.i('### Login done...');
              },
              child: const Text('Anmelden'),
            ),
          ],
        ),
      ),
    );
  }
}
