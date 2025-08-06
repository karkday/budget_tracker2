import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String msg = '';

  Future<void> register() async {
    String url =
        'http://localhost/budget_api/register.php'; // Change IP if needed

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'username': _usernameController.text,
          'password': _passwordController.text,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          final user = data['user'];
          final totalIncome = data['totalIncome'];
          final totalExpenses = data['totalExpenses'];

          setState(() {
            msg = 'Registration successful!';
          });

          // Navigate to home screen with actual user data
          Future.delayed(const Duration(seconds: 1), () {
            Navigator.pushReplacementNamed(
              context,
              '/home',
              arguments: {
                'username': user['username'],
                'totalIncome': totalIncome,
                'totalExpenses': totalExpenses,
              },
            );
          });
        } else {
          setState(() {
            msg = data['message'];
          });
        }
      } else {
        setState(() {
          msg = 'Server error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        msg = 'Error: $e';
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: register, child: const Text('Register')),
            const SizedBox(height: 20),
            Text(
              msg,
              style: TextStyle(
                color: msg.contains('success') ? Colors.green : Colors.red,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: const Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}
