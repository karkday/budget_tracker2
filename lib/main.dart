import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/add_expense_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_income_screen.dart';
import 'screens/transaction_screen.dart';
import 'screens/profile_screen.dart';
import 'dart:io';

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Budget Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),

      initialRoute: '/login',

      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          final args = settings.arguments as Map<String, dynamic>;

          return MaterialPageRoute(
            builder: (context) => const HomePage(),
            settings: RouteSettings(
              arguments: {
                'userId': args['userId'],
                'username': args['username'], // Pass username here
                'totalIncome': (args['totalIncome'] as num).toDouble(),
                'totalExpenses': (args['totalExpenses'] as num).toDouble(),
              },
            ),
          );
        }

        if (settings.name == '/login') {
          return MaterialPageRoute(builder: (context) => const LoginScreen());
        }

        if (settings.name == '/register') {
          return MaterialPageRoute(
            builder: (context) => const RegisterScreen(),
          );
        }
        if (settings.name == '/profile') {
          final userId = settings.arguments as int;

          return MaterialPageRoute(
            builder: (context) => ProfileScreen(),
            settings: RouteSettings(arguments: userId),
          );
        }
        if (settings.name == '/transactions') {
          final userId = settings.arguments as int;

          return MaterialPageRoute(
            builder: (context) => TransactionsScreen(),
            settings: RouteSettings(arguments: userId),
          );
        }

        return null; // For any unknown route
      },
      routes: {
        '/': (context) => const LoginScreen(),
        '/transactions': (context) => const TransactionsScreen(),
        '/add_income': (context) => const AddIncomeScreen(),
        '/add_expense': (context) => const AddExpenseScreen(),
      },
    );
  }
}
