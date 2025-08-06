import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  List<dynamic> transactions = [];
  bool isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final userId = args['userId'];

    fetchTransactions(userId);
  }

  Future<void> fetchTransactions(int userId) async {
    final url = Uri.parse(
      'http://localhost/budget_api/transactions.php?user_id=$userId',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Transactions count: ${transactions.length}');

        if (data['status'] == 'success') {
          setState(() {
            transactions = data['transactions'];
            isLoading = false;
            
          });
        } else {
          showError(data['error'] ?? 'Failed to load transactions');
        }
      } else {
        showError('Server error: ${response.statusCode}');
      }
    } catch (e) {
      showError('Error: $e');
    }
  }

  void showError(String message) {
    setState(() {
      isLoading = false;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Transactions')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : transactions.isEmpty
          ? const Center(child: Text('No transactions found.'))
          : ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final t = transactions[index];
                return ListTile(
                  title: Text('${t['type'].toUpperCase()} - \$${t['amount']}'),
                  subtitle: Text('${t['category']} | ${t['note']}'),
                  trailing: Text(t['date']),
                );
              },
            ),
    );
  }
}
