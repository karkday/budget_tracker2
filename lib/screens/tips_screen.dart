import 'package:flutter/material.dart';

class TipsAndTricksScreen extends StatelessWidget {
  const TipsAndTricksScreen({super.key});

  final List<String> tips = const [
    "Track every expense to know where your money goes.",
    "Set a monthly budget and stick to it.",
    "Prioritize saving at least 10% of your income.",
    "Avoid impulse purchases by waiting 24 hours.",
    "Use cash for daily spending to control expenses.",
    "Review your budget weekly and adjust as needed.",
    "Cut unnecessary subscriptions and memberships.",
    "Plan meals to save money on groceries.",
    "Set financial goals to stay motivated.",
    "Keep an emergency fund for unexpected expenses.",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tips & Tricks'),
        backgroundColor: Colors.teal,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: tips.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.lightbulb_outline, color: Colors.orange),
            title: Text(
              tips[index],
              style: const TextStyle(fontSize: 16),
            ),
          );
        },
      ),
    );
  }
}
