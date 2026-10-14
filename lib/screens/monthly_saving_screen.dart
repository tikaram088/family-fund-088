import 'package:flutter/material.dart';
import 'voucher_screen.dart';

class MonthlySavingScreen extends StatefulWidget {
  const MonthlySavingScreen({super.key});

  @override
  State<MonthlySavingScreen> createState() => _MonthlySavingScreenState();
}

class _MonthlySavingScreenState extends State<MonthlySavingScreen> {
  final _amountController = TextEditingController();
  int _penaltyPercentage = 0;

  void _calculatePenalty(String dayText) {
    int day = int.tryParse(dayText) ?? 0;
    setState(() {
      if (day > 25) {
        _penaltyPercentage = 6;
      } else if (day > 20) {
        _penaltyPercentage = 4;
      } else if (day > 15) {
        _penaltyPercentage = 2;
      } else {
        _penaltyPercentage = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('मासिक बचत जम्मा'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'बचत रकम (रु)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'आजको गते (१ - ३०)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
              ),
              onChanged: _calculatePenalty,
            ),
            const SizedBox(height: 16),
            if (_penaltyPercentage > 0)
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.red.shade50,
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.red),
                    const SizedBox(width: 10),
                    Text(
                      'हर्जाना: $_penaltyPercentage% थपिनेछ।',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const VoucherScreen(),
                    ),
                  );
                },
                child: const Text('भोउचर हेर्नुहोस् / बुझाउनुहोस्'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
