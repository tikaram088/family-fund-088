import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'monthly_saving_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  double totalSavings = 25000;

  final List<Map<String, dynamic>> _transactions = [
    {
      'month': 'भाद्र',
      'date': '२०८१/०५/१०',
      'amount': '१,०००',
      'penalty': '०',
      'status': 'समयमै बुझाइएको',
      'isLate': false,
    },
    {
      'month': 'साउन',
      'date': '२०८१/०४/१८',
      'amount': '१,०२०',
      'penalty': '२०',
      'status': '२% हर्जाना सहित',
      'isLate': true,
    },
    {
      'month': 'असार',
      'date': '२०८१/०३/०५',
      'amount': '१,०००',
      'penalty': '०',
      'status': 'समयमै बुझाइएको',
      'isLate': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildHomeTab(context),
      const MonthlySavingScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('पारिवारिक बचत कोष'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'लगआउट',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'ड्यासबोर्ड',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'मासिक बचत',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.teal,
                child: Icon(Icons.person, color: Colors.white, size: 28),
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'नमस्ते, राम शर्मा',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'सदस्य कोड: M-102',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade700, Colors.teal.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.shade200,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'कुल जमा बचत रकम',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    Icon(Icons.stars, color: Colors.amberAccent),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'रु ${totalSavings.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(color: Colors.white30, height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'चालू असोज महिनाको स्थिति:',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: const Text(
                        'बुझाउन बाँकी',
                        style: TextStyle(
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amber.shade300),
            ),
            child: const Row(
              children: [
                Icon(Icons.info, color: Colors.amber),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'नियम: हरेक महिनाको १५ गतेसम्म हर्जाना लाग्दैन। १६-२० गते (२%), २१-२५ गते (४%) र २६ गतेपछि (६%) हर्जाना लाग्नेछ।',
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 1;
                    });
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('बचत जम्मा'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'कारोबार विवरण (History)',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _transactions.length,
            itemBuilder: (context, index) {
              final tx = _transactions[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: tx['isLate']
                        ? Colors.orange.shade100
                        : Colors.teal.shade100,
                    child: Icon(
                      tx['isLate'] ? Icons.priority_high : Icons.check,
                      color: tx['isLate'] ? Colors.orange : Colors.teal,
                    ),
                  ),
                  title: Text(
                    '${tx['month']} महिनाको बचत',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${tx['date']} • ${tx['status']}'),
                  trailing: Text(
                    'रु ${tx['amount']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.teal,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
