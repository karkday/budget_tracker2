import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int userId;
  late String username;
  double totalIncome = 0.0;
  double totalExpenses = 0.0;
  bool isLoading = true;
  String errorMessage = '';
  int _currentIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Extract userId and username from route arguments only once
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    userId = int.tryParse(args['userId'].toString()) ?? 0;
    username = args['username'] ?? 'User';

    _fetchSummaryData(); // Fetch data on page load
  }

  Future<void> _fetchSummaryData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final url = Uri.parse(
        'http://localhost/budget_api/get_summary.php?user_id=$userId',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            totalIncome = (data['income'] ?? 0).toDouble();
            totalExpenses = (data['expense'] ?? 0).toDouble();
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = data['message'] ?? 'Failed to load summary';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Server error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _navigateToAddIncome() async {
    final shouldRefresh = await Navigator.pushNamed(
      context,
      '/add_income',
      arguments: userId,
    );
    if (shouldRefresh == true) {
      await _fetchSummaryData(); // Refresh data after adding income
    }
  }

  Future<void> _navigateToAddExpense() async {
    final shouldRefresh = await Navigator.pushNamed(
      context,
      '/add_expense',
      arguments: userId,
    );
    if (shouldRefresh == true) {
      await _fetchSummaryData(); // Refresh data after adding expense
    }
  }

  @override
  Widget build(BuildContext context) {
    final double balance = totalIncome - totalExpenses;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Welcome, $username'),
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSummaryCard(totalIncome, totalExpenses, balance),
                  const SizedBox(height: 16),
                  _buildActionButtons(context),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.teal,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        currentIndex: _currentIndex, // <-- use state
        onTap: (index) {
          setState(() {
            _currentIndex = index; // <-- update state
          });
          switch (index) {
            case 0:
              // Already on home, do nothing or you can refresh
              break;
            case 1:
              Navigator.pushNamed(
                context,
                '/transactions',
                arguments: {'userId': userId},
              );
              break;
            case 2:
              Navigator.pushNamed(context, '/profile', arguments: userId);
              break;
            case 3:
              Navigator.pushNamed(context, '/tips');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb),
            label: 'Tips & Tricks',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    double totalIncome,
    double totalExpenses,
    double balance,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              ' Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _summaryItem('Income', totalIncome, Colors.green),
                _summaryItem('Expenses', totalExpenses, Colors.red),
                _summaryItem('Balance', balance, Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(String label, double value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(
          '${value.toStringAsFixed(2)} AED',
          style: TextStyle(color: color, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: _navigateToAddIncome,
          child: const Text('Add Income'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        ),
        ElevatedButton(
          onPressed: _navigateToAddExpense,
          child: const Text('Add Expense'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        ),
      ],
    );
  }
}
