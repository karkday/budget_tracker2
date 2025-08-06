import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  Future<void> _submitExpense(int userId) async {
    final url = Uri.parse('http://localhost/budget_api/add_expense.php');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId,
        "amount": double.tryParse(_amountController.text) ?? 0.0,
        "category": _categoryController.text,
        "note": _noteController.text,
        "date": selectedDate.toIso8601String().split('T').first,
      }),
    );

    final result = jsonDecode(response.body);
    if (result['status'] == 'success') {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${result['error']}')));
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final int userId = ModalRoute.of(context)!.settings.arguments as int;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(labelText: 'Note'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  "Date: ${selectedDate.toLocal().toString().split(' ')[0]}",
                ),
                const Spacer(),
                TextButton(
                  onPressed: _pickDate,
                  child: const Text('Select Date'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _submitExpense(userId),
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
