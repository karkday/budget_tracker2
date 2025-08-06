import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String msg = '';
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 30),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: "username"),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: "password"),
                obscureText: true,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  login();
                },
                child: const Text('Login'),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text('do not have an account? register'),
              ),
              const SizedBox(height: 20),
              Text(msg, style: TextStyle(color: Colors.red, fontSize: 20.0)),
            ],
          ),
        ),
      ),
    );
  }

  void login() async {
    String url = 'http://localhost/budget_api/login.php';

    final Map<String, String> queryParams = {
      "username": _usernameController.text.trim(),
      "password": _passwordController.text.trim(),
    };

    try {
      final response = await http.get(
        Uri.parse(url).replace(queryParameters: queryParams),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          final user = data['user'];
          final totalIncome = (data['total_income'] as num).toDouble();
          final totalExpense = (data['total_expense'] as num).toDouble();

          Navigator.pushReplacementNamed(
            context,
            '/home',
            arguments: {
              'userId': user['id'],
              'username': user['username'],
              'totalIncome': totalIncome,
              'totalExpenses': totalExpense,
            },
          );
        } else {
          setState(() {
            msg = data['message'] ?? 'Invalid username or password';
          });
        }
      } else {
        setState(() {
          msg = 'Server error: ${response.statusCode}';
        });
      }
    } catch (error) {
      setState(() {
        msg = 'Error: $error';
      });
    }
  }
}
