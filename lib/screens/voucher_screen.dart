import 'package:flutter/material.dart';

class VoucherScreen extends StatefulWidget {
  const VoucherScreen({super.key});

  @override
  State<VoucherScreen> mekeState() => _VoucherScreenState();
}

class _VoucherScreenState extends State<VoucherScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String _selectedPaymentType = 'मासिक बचत';
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  String? _selectedMember = 'कमला चौहान';

  final List<String> _paymentTypes = [
    'मासिक बचत',
    'अतिरिक्त बचत',
    'ऋण भुक्तानी',
    'बीमा शुल्क',
    'दान / चन्दा',
  ];

  final List<String> _membersList = [
    'कमला चौहान',
    'हरि कुमार चौहान',
    'बाल कुमार चौहान',
    'चन्द्र बहादुर चौहान',
    'टिकाराम चौहान',
    'उदय चौहान',
  ];

  void _submitVoucher() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 8),
              Text('भौचर दाखिला भयो!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            'सदस्य: $_selectedMember\nप्रकार: $_selectedPaymentType\nरकम: रु ${_amountController.text}\n\nतपाईंको भौचर सफलपूर्वक पेश भएको छ।',
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0E5C79)),
              onPressed: () {
                Navigator.pop(ctx);
                _amountController.clear();
                _remarksController.clear();
              },
              child: const Text('ठीक छ', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBF4F8),
      appBar: AppBar(
        title: const Text('बचत / भुक्तानी भौचर', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.deepOrange.shade800,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F3A5D),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'पारिवारिक बचत कोष',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'अनलाइन भौचर सङ्कलन प्रणाली',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Form Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Member Select
                    const Text('सदस्यको नाम', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F3A5D))),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _selectedMember,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      items: _membersList.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                      onChanged: (val) => setState(() => _selectedMember = val),
                    ),
                    const SizedBox(height: 16),

                    // Payment Type Select
                    const Text('भुक्तानीको प्रकार', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F3A5D))),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _selectedPaymentType,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      items: _paymentTypes.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                      onChanged: (val) => setState(() => _selectedPaymentType = val!),
                    ),
                    const SizedBox(height: 16),

                    // Amount Input
                    const Text('रकम (रु मा)', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F3A5D))),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'उदाहरण: १०००',
                        prefixIcon: const Icon(Icons.attach_money, color: Color(0xFF0E5C79)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'कृपया रकम राख्नुहोस्!';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Remarks Input
                    const Text('कैफियत / विवरण (Remarks)', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F3A5D))),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _remarksController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'थप विवरण लेख्नुहोस् (ऐच्छिक)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0E5C79),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _submitVoucher,
                        child: const Text('भौचर बुझाउनुहोस्', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
