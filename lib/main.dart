import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nepali_utils/nepali_utils.dart';
// Firebase packages can be initialized in main if needed:
// import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(); // Firebase प्रयोग गर्नुपर्दा यो अनकमेन्ट गर्नुहोला

  // नेपाली भाषा र क्यालेन्डर सेट गरिएको
  NepaliUtils().language = Language.nepali;
  runApp(const FamilySavingFundApp());
}

class FamilySavingFundApp extends StatelessWidget {
  const FamilySavingFundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'पारिवारिक बचत कोष',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFEBF4F8),
      ),
      home: const LoginScreen(),
    );
  }
}

// ---------------- ACCURATE REAL NEPALI BS & ENGLISH AD DATE HELPER ----------------
class DateHelper {
  static const List<String> adMonthsShort = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  static const List<String> adDaysShort = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
  ];

  static String getRunningFormattedDate() {
    DateTime now = DateTime.now();
    NepaliDateTime nepaliNow = NepaliDateTime.fromDateTime(now);

    // nepali_utils प्रयोग गरी वास्तविक र शुद्ध वि.सं. मिति
    String bsYearStr = nepaliNow.format('yyyy');
    String bsMonthStr = nepaliNow.format('MMMM');
    String bsDayStr = nepaliNow.format('dd');
    String bsDayName = nepaliNow.format('EEEE');

    String dayNameAd = adDaysShort[now.weekday - 1];
    String monthNameAd = adMonthsShort[now.month - 1];
    String adYearStr = now.year.toString();

    return "$bsYearStr-$bsMonthStr-$bsDayStr-$bsDayName\n${dayNameAd.toLowerCase()}-${monthNameAd.toLowerCase()}-$adYearStr";
  }
}

// ---------------- MODELS ----------------
class FamilyMemberDetail {
  String name;
  String relation;
  FamilyMemberDetail({required this.name, required this.relation});
}

class TransactionRecord {
  final String memberId;
  final String memberName;
  final String type; 
  final String details;
  final double amount;
  final double insuranceAmt;
  final double personalAmt;
  final String date;

  TransactionRecord({
    required this.memberId,
    required this.memberName,
    required this.type,
    required this.details,
    required this.amount,
    required this.insuranceAmt,
    required this.personalAmt,
    required this.date,
  });
}

List<TransactionRecord> globalTransactionHistory = [];

class LoanRequest {
  final String loanId;
  final Member member;
  final double amount;
  final String purpose;
  final String collateralDetails;
  final String guarantor1Id;
  final String guarantor2Id;
  Set<String> approvedMemberIds = {}; 
  String status; 

  LoanRequest({
    required this.loanId,
    required this.member,
    required this.amount,
    required this.purpose,
    required this.collateralDetails,
    required this.guarantor1Id,
    required this.guarantor2Id,
    this.status = 'Pending',
  });
}

List<LoanRequest> globalLoanRequests = [];

class Member {
  final String id;
  String password;
  String name;
  String phone;
  String address;
  String email;
  final String accountNumber;
  String bgPhotoPath;
  String profilePhotoPath;
  double personalSavings;
  double totalInsurance; 
  double totalLoan;
  double loanInterestRate; 
  int paidMonthsCount; 
  String joinedDate;
  bool isActive;
  
  Map<int, double> monthPaidPersonal = {}; 
  Map<int, bool> monthInsurancePaid = {};   
  
  List<FamilyMemberDetail> familyMembers = [];
  List<String> notifications = [];

  String notificationBannerText = '';
  bool isBannerGreen = true;
  bool hasPendingSubmission = false; 

  final String role; 
  bool isFrozen;

  Member({
    required this.id,
    required this.password,
    required this.name,
    required this.phone,
    required this.address,
    this.email = '',
    required this.accountNumber,
    required this.bgPhotoPath,
    required this.profilePhotoPath,
    this.personalSavings = 0.00,
    this.totalInsurance = 0.00,
    this.totalLoan = 0.00,
    this.loanInterestRate = 12.0, 
    this.paidMonthsCount = 0,
    this.joinedDate = '२०८३ कार्तिक ०१',
    this.isActive = true,
    required this.role,
    this.isFrozen = false,
  });
}

double totalFundSavings = 0.00; 
double emergencyReserve = 20000.00; 
double totalInsuranceFund = 0.00; 

final List<String> fundMonthsList = [
  'कार्तिक २०८३',
  'मंसिर २०८३',
  'पुष २०८३',
  'माघ २०८३',
  'फागुन २०८३',
  'चैत्र २०८३',
  'बैशाख २०८४',
  'जेठ २०८४',
  'असार २०८४',
  'श्रावण २०८४',
  'भाद्र २०८४',
  'असोज २०८४',
];

class ChatMessage {
  final String senderName;
  final String senderId;
  final String message;
  final String time;

  ChatMessage({required this.senderName, required this.senderId, required this.message, required this.time});
}

List<ChatMessage> globalChatMessages = [
  ChatMessage(senderName: 'टिकाराम चौहान (Admin)', senderId: 'ADM001', message: 'नमस्ते सबै परिवारलाई, हाम्रो कोष एपमा स्वागत छ।', time: '10:00 AM'),
];

class PaymentSubmission {
  final Member member;
  final String paymentType; 
  final int monthsCount;
  final String monthsText;
  double totalAmount;
  double fineAmount;
  double insuranceAmt;
  double personalAmt;
  final String voucherFileName;
  final XFile? voucherFileX; 
  int monthIndexTarget;

  PaymentSubmission({
    required this.member,
    required this.paymentType,
    required this.monthsCount,
    required this.monthsText,
    required this.totalAmount,
    required this.fineAmount,
    required this.insuranceAmt,
    required this.personalAmt,
    required this.voucherFileName,
    this.voucherFileX,
    required this.monthIndexTarget,
  });
}

List<PaymentSubmission> pendingPaymentApprovals = [];
List<Map<String, String>> pendingDelayRequests = [];

final List<Member> sampleMembers = [
  Member(id: 'MEM001', password: '123', name: 'कमला देउजा', phone: '9827786124', address: 'बिर्तामोड, झापा', email: 'kamala@gmail.com', accountNumber: '0630225858400011', bgPhotoPath: 'assets/images/user1_bg.jpg', profilePhotoPath: 'assets/images/user1_profile.jpg', role: 'member'),
  Member(id: 'MEM002', password: '123', name: 'हरि कुमार चौहान', phone: '9816336916', address: 'राम्धुनी, सुनसरी', email: 'hari@gmail.com', accountNumber: '0630225858400012', bgPhotoPath: 'assets/images/user2_bg.jpg', profilePhotoPath: 'assets/images/user2_profile.jpg', role: 'member'),
  Member(id: 'MEM003', password: '123', name: 'बाल कुमार चौहान', phone: '9812309084', address: 'इटहरी, सुनसरी', email: 'balkumar@gmail.com', accountNumber: '0630225858400013', bgPhotoPath: 'assets/images/user3_bg.jpg', profilePhotoPath: 'assets/images/user3_profile.jpg', role: 'member'),
  Member(id: 'MEM004', password: '123', name: 'चन्द्र बहादुर चौहान', phone: '9842898623', address: 'इटहरी, सुनसरी', email: 'chandra@gmail.com', accountNumber: '0630225858400014', bgPhotoPath: 'assets/images/user4_bg.jpg', profilePhotoPath: 'assets/images/User4_profile.png', role: 'member'),
  Member(id: 'ADM001', password: '123', name: 'टिकाराम चौहान', phone: '9818402375', address: 'इटहरी, सुनसरी', email: 'tikaram@gmail.com', accountNumber: '0630225858400015', bgPhotoPath: 'assets/images/user5_bg.jpg', profilePhotoPath: 'assets/images/user5_profile.jpg', role: 'admin'),
  Member(id: 'MEM005', password: '123', name: 'उदय चौहान', phone: '9862034240', address: 'राम्धुनी, सुनसरी', email: 'uday@gmail.com', accountNumber: '0630225858400018', bgPhotoPath: 'assets/images/user6_bg.jpg', profilePhotoPath: 'assets/images/user6_profile.png', role: 'member'),
];

Widget buildGlobalAvatar(String photoPath, double radius) {
  return CircleAvatar(
    radius: radius,
    backgroundColor: Colors.grey.shade300,
    backgroundImage: AssetImage(photoPath),
    onBackgroundImageError: (e, s) {},
  );
}

void copyToClipboard(BuildContext ctx, String text, String label) {
  Clipboard.setData(ClipboardData(text: text));
  ScaffoldMessenger.of(ctx).showSnackBar(
    SnackBar(content: Text('$label ($text) क्लिपबोर्डमा कपी भयो!'), duration: const Duration(milliseconds: 1200)),
  );
}

Widget buildVoucherPreview(XFile? file, {double height = 140}) {
  if (file == null) return const SizedBox.shrink();

  return Container(
    height: height,
    width: double.infinity,
    decoration: BoxDecoration(
      border: Border.all(color: Colors.teal),
      borderRadius: BorderRadius.circular(8),
    ),
    child: kIsWeb
        ? Image.network(file.path, fit: BoxFit.cover)
        : Image.file(File(file.path), fit: BoxFit.cover),
  );
}

// ---------------- LOGIN SCREEN ----------------
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String _errorMessage = '';

  void _handleLogin() {
    String enteredId = _userIdController.text.trim();
    String enteredPass = _passwordController.text.trim();
    setState(() => _errorMessage = '');

    if (enteredId.isEmpty || enteredPass.isEmpty) {
      setState(() => _errorMessage = 'कृपया मोबाईल नम्बर / सदस्यता नम्बर र पासवर्ड राख्नुहोस्!');
      return;
    }

    try {
      Member foundUser = sampleMembers.firstWhere(
        (m) => (m.id.toLowerCase() == enteredId.toLowerCase() || m.phone == enteredId) && m.password == enteredPass,
      );

      if (foundUser.isFrozen) {
        setState(() => _errorMessage = 'तपाईंको खाता निष्क्रिय (Frozen) गरिएको छ। प्रशासकलाई सम्पर्क गर्नुहोस्।');
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainContainerScreen(user: foundUser)),
      );
    } catch (e) {
      setState(() => _errorMessage = 'गलत सदस्यता नम्बर/मोबाईल नम्बर वा पासवर्ड!');
    }
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('पासवर्ड बिर्सिनुभयो?'),
        content: const Text('सुरक्षाको कारणले पासवर्ड रिसेट गर्न प्रशासक (Admin) सँग सम्पर्क गर्नुहोस्।\n\nसम्पर्क फोन: ९८१८४०२३७५'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ठीक छ')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFEBF4F8),
      body: SingleChildScrollView(
        child: SizedBox(
          height: mediaQuery.size.height,
          child: Column(
            children: [
              SizedBox(
                height: mediaQuery.size.height * 0.42,
                width: double.infinity,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.60,
                        child: Image.asset('assets/images/login_bg.jpg', fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: const Color(0xFF0F3A5D))),
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withOpacity(0.0), const Color(0xFFEBF4F8).withOpacity(0.80)],
                            stops: const [0.0, 0.6, 1.0],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10, left: 0, right: 0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset('assets/images/logo.png', height: 70, errorBuilder: (c, e, s) => const Icon(Icons.home_work, color: Color(0xFF0F3A5D), size: 60)),
                          const SizedBox(height: 6),
                          const Text('पारिवारिक बचत कोष', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F3A5D))),
                          const Text('संगै बचत सुरक्षित भविष्य (स्थापना २०८३ कार्तिक)', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0E5C79))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_errorMessage.isNotEmpty) ...[
                        Text(_errorMessage, style: const TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                      ],
                      Container(
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.92), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)),
                        child: TextField(
                          controller: _userIdController,
                          decoration: const InputDecoration(
                            hintText: 'मोबाईल नम्बर / सदस्यता नम्बर', hintStyle: TextStyle(fontSize: 13),
                            prefixIcon: Icon(Icons.person, color: Color(0xFF0F3A5D), size: 20),
                            border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.92), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: 'पासवर्ड', hintStyle: const TextStyle(fontSize: 13),
                            prefixIcon: const Icon(Icons.lock, color: Color(0xFF0F3A5D), size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey, size: 20),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _showForgotPasswordDialog,
                          child: const Text('पासवर्ड बिर्सिनुभयो?', style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity, height: 46,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0E5C79), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                          onPressed: _handleLogin,
                          child: const Text('लगइन', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- MAIN CONTAINER SCREEN ----------------
class MainContainerScreen extends StatefulWidget {
  final Member user;
  const MainContainerScreen({super.key, required this.user});

  @override
  State<MainContainerScreen> createState() => _MainContainerScreenState();
}

class _MainContainerScreenState extends State<MainContainerScreen> {
  int _currentNavIndex = 0;
  bool _isAdminMode = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    if (widget.user.role == 'admin') _isAdminMode = true;
  }

  void _toggleDashboardMode() {
    if (widget.user.role != 'admin') return;
    setState(() {
      _isAdminMode = !_isAdminMode;
      _currentNavIndex = 0;
    });
  }

  void _handleLogout() {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
  }

  void _showNotificationsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.notifications, color: Colors.deepOrange),
            SizedBox(width: 8),
            Text('सूचनाहरू (Notifications)'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: widget.user.notifications.isEmpty
              ? const Text('कुनै नयाँ सूचना छैन।')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.user.notifications.length,
                  itemBuilder: (c, i) => ListTile(
                    leading: const Icon(Icons.info, color: Colors.teal),
                    title: Text(widget.user.notifications[i], style: const TextStyle(fontSize: 12)),
                  ),
                ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('बन्द गर्नुहोस्')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> memberPages = [
      MemberDashboardView(user: widget.user),
      LoanManagementView(user: widget.user),
      InsuranceFundView(user: widget.user),
      FamilyChatView(user: widget.user),
      HistoryView(user: widget.user),
    ];

    List<Widget> adminPages = [
      AdminDashboardView(user: widget.user),
      AdminPaymentScreen(user: widget.user),
      AdminInsuranceView(user: widget.user),
      AdminMembersManagementView(user: widget.user),
      HistoryView(user: widget.user),
    ];

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFEBF4F8),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.deepOrange),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildGlobalAvatar(widget.user.profilePhotoPath, 28),
                  const SizedBox(height: 8),
                  Text(widget.user.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('ID: ${widget.user.id} | ${widget.user.address}', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ),
            ListTile(leading: const Icon(Icons.calendar_month), title: const Text('मासिक बचत भुक्तानी'), onTap: () { Navigator.pop(context); setState(() => _currentNavIndex = 0); }),
            ListTile(leading: const Icon(Icons.handshake), title: const Text('ऋण व्यवस्थापन'), onTap: () { Navigator.pop(context); setState(() => _currentNavIndex = 1); }),
            ListTile(leading: const Icon(Icons.shield), title: const Text('बीमा कोष'), onTap: () { Navigator.pop(context); setState(() => _currentNavIndex = 2); }),
            ListTile(leading: const Icon(Icons.receipt_long), title: const Text('कारोबार इतिहास'), onTap: () { Navigator.pop(context); setState(() => _currentNavIndex = 4); }),
            
            if (widget.user.role == 'admin') ...[
              const Divider(),
              ListTile(
                leading: const Icon(Icons.edit_note, color: Colors.deepOrange),
                title: const Text('सम्पादन (Edit Ledger)', style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (c) => AdminLedgerEditScreen(user: widget.user)));
                },
              ),
            ],
            const Divider(),
            ListTile(leading: const Icon(Icons.logout, color: Colors.red), title: const Text('लगआउट', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)), onTap: _handleLogout),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              color: Colors.deepOrange,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(_currentNavIndex != 0 ? Icons.arrow_back : Icons.menu, color: Colors.white, size: 24),
                    onPressed: () {
                      if (_currentNavIndex != 0) {
                        setState(() => _currentNavIndex = 0);
                      } else {
                        _scaffoldKey.currentState?.openDrawer();
                      }
                    },
                  ),
                  Image.asset('assets/images/logo.png', height: 32, errorBuilder: (c, e, s) => const Icon(Icons.home_work, color: Colors.white, size: 28)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _isAdminMode ? 'पारिवारिक बचत कोष (Admin)' : 'पारिवारिक बचत कोष',
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.white, size: 24),
                    onPressed: _showNotificationsDialog,
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              color: const Color(0xFF0F3A5D),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: const Row(
                children: [
                  Icon(Icons.campaign, color: Colors.yellowAccent, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'सूचना: हरेक महिनाको १ गतेदेखि ९ गतेसम्म नियमित बचत दाखिल गरौँ!',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _isAdminMode ? adminPages[_currentNavIndex] : memberPages[_currentNavIndex]),
          ],
        ),
      ),
      floatingActionButton: widget.user.role == 'admin'
          ? FloatingActionButton(
              onPressed: _toggleDashboardMode,
              backgroundColor: _isAdminMode ? Colors.deepOrange : const Color(0xFF0E5C79),
              child: const Icon(Icons.swap_horiz, color: Colors.white, size: 28),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        color: Colors.white,
        child: _isAdminMode ? _buildAdminNav() : _buildMemberNav(),
      ),
    );
  }

  Widget _buildMemberNav() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _navItem(Icons.home, 'Home', 0),
        _navItem(Icons.handshake, 'ऋण', 1),
        _navItem(Icons.shield, 'बीमा', 2),
        _navItem(Icons.chat, 'च्याट', 3),
        _navItem(Icons.receipt_long, 'इतिहास', 4),
      ],
    );
  }

  Widget _buildAdminNav() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _navItem(Icons.dashboard, 'Home', 0),
        _navItem(Icons.payment, 'भुक्तानी', 1), 
        _navItem(Icons.shield, 'बीमा', 2),
        _navItem(Icons.group, 'सदस्यहरू', 3),
        _navItem(Icons.receipt_long, 'इतिहास', 4),
      ],
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    bool isSelected = _currentNavIndex == index;
    return Expanded(
      child: MaterialButton(
        padding: EdgeInsets.zero,
        onPressed: () => setState(() => _currentNavIndex = index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? Colors.deepOrange : Colors.grey, size: 22),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.deepOrange : Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// ---------------- MEMBER DASHBOARD VIEW & ATM PROFILE SCREEN ----------------
class MemberDashboardView extends StatefulWidget {
  final Member user;
  const MemberDashboardView({super.key, required this.user});

  @override
  State<MemberDashboardView> createState() => _MemberDashboardViewState();
}

class _MemberDashboardViewState extends State<MemberDashboardView> {
  bool _showSavings = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.user.notificationBannerText.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.user.isBannerGreen ? Colors.green.shade100 : Colors.red.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: widget.user.isBannerGreen ? Colors.green.shade700 : Colors.red.shade700),
              ),
              child: Row(
                children: [
                  Icon(widget.user.isBannerGreen ? Icons.check_circle : Icons.error, color: widget.user.isBannerGreen ? Colors.green.shade800 : Colors.red.shade800),
                  const SizedBox(width: 8),
                  Expanded(child: Text(widget.user.notificationBannerText, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: widget.user.isBannerGreen ? Colors.green.shade900 : Colors.red.shade900))),
                  IconButton(icon: const Icon(Icons.close, size: 16), onPressed: () => setState(() => widget.user.notificationBannerText = '')),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (c) => MemberProfileSettingsScreen(user: widget.user)));
            },
            child: Container(
              height: 205, width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(colors: [Color(0xFF0F3A5D), Color(0xFF0E5C79)]),
                image: DecorationImage(
                  image: AssetImage(widget.user.bgPhotoPath),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.40), BlendMode.darken),
                  onError: (exception, stackTrace) {},
                ),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('A/C No. ${widget.user.accountNumber}', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                        Text(
                          DateHelper.getRunningFormattedDate(),
                          textAlign: TextAlign.right,
                          style: const TextStyle(color: Colors.yellowAccent, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(children: [
                      buildGlobalAvatar(widget.user.profilePhotoPath, 22),
                      const SizedBox(width: 10),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(widget.user.name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(widget.user.address, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                      ])),
                      const Icon(Icons.touch_app, color: Colors.white70, size: 18),
                    ]),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('कुल व्यक्तिगत बचत', style: TextStyle(color: Colors.white70, fontSize: 11)),
                        Row(children: [
                          Text(_showSavings ? 'रु ${widget.user.personalSavings.toStringAsFixed(2)}' : 'रु ••••••••', style: const TextStyle(color: Colors.greenAccent, fontSize: 15, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 6),
                          GestureDetector(onTap: () => setState(() => _showSavings = !_showSavings), child: Icon(_showSavings ? Icons.visibility : Icons.visibility_off, color: Colors.white70, size: 16)),
                        ]),
                      ]),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        const Text('कुल ऋण', style: TextStyle(color: Colors.white70, fontSize: 11)),
                        Text('रु ${widget.user.totalLoan.toStringAsFixed(2)}', style: const TextStyle(color: Colors.orangeAccent, fontSize: 15, fontWeight: FontWeight.bold)),
                      ]),
                    ]),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(color: const Color(0xFFE2F0D9), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.teal.shade300)),
            child: Row(
              children: [
                const Icon(Icons.savings, color: Colors.teal, size: 36),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('जम्मा कोषको बचत (Total Fund Pool)', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 12)),
                      Text('रु ${totalFundSavings.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF0F3A5D), fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          const Text('सेवाहरू', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F3A5D))),
          const SizedBox(height: 10),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.35,
            children: [
              InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => MonthlySavingsMenuScreen(user: widget.user))), child: _serviceCard('मासिक बचत\nभुक्तानी', Icons.calendar_month)),
              InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => AdditionalSavingsScreen(user: widget.user))), child: _serviceCard('अतिरिक्त बचत\nभुक्तानी', Icons.savings)),
              InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => DonateSavingsScreen(user: widget.user))), child: _serviceCard('Donate\nगर्नुहोस्', Icons.volunteer_activism)),
              InkWell(onTap: () => _showMembersList(), child: _serviceCard('सदस्यहरू', Icons.group)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _serviceCard(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(backgroundColor: const Color(0xFFD6E9F5), child: Icon(icon, color: const Color(0xFF0E5C79))),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F3A5D))),
        ],
      ),
    );
  }

  void _showMembersList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16), height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('कोषका सदस्यहरू', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F3A5D))),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: sampleMembers.length,
                itemBuilder: (c, i) => ListTile(
                  leading: buildGlobalAvatar(sampleMembers[i].profilePhotoPath, 20),
                  title: Text(sampleMembers[i].name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('ID: ${sampleMembers[i].id} | मो.नं.: ${sampleMembers[i].phone}'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- MEMBER PROFILE & SETTINGS SCREEN ----------------
class MemberProfileSettingsScreen extends StatefulWidget {
  final Member user;
  const MemberProfileSettingsScreen({super.key, required this.user});

  @override
  State<MemberProfileSettingsScreen> createState() => _MemberProfileSettingsScreenState();
}

class _MemberProfileSettingsScreenState extends State<MemberProfileSettingsScreen> {
  late TextEditingController nameCtrl;
  late TextEditingController addressCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController emailCtrl;

  final TextEditingController oldPassCtrl = TextEditingController();
  final TextEditingController newPassCtrl = TextEditingController();
  final TextEditingController confirmPassCtrl = TextEditingController();

  String passError = '';

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.user.name);
    addressCtrl = TextEditingController(text: widget.user.address);
    phoneCtrl = TextEditingController(text: widget.user.phone);
    emailCtrl = TextEditingController(text: widget.user.email);
  }

  void _updateProfileInfo() {
    setState(() {
      widget.user.name = nameCtrl.text.trim();
      widget.user.address = addressCtrl.text.trim();
      widget.user.phone = phoneCtrl.text.trim();
      widget.user.email = emailCtrl.text.trim();
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('तपाईंको विवरण सफलतापूर्वक अपडेट भयो!'), backgroundColor: Colors.teal));
  }

  void _addFamilyMemberField() {
    setState(() {
      widget.user.familyMembers.add(FamilyMemberDetail(name: '', relation: ''));
    });
  }

  void _changePassword() {
    setState(() => passError = '');
    if (oldPassCtrl.text != widget.user.password) {
      setState(() => passError = 'पुरानो पासवर्ड मिलेन!');
      return;
    }
    if (newPassCtrl.text.length < 3) {
      setState(() => passError = 'नयाँ पासवर्ड कम्तिमा ३ अंकको हुनुपर्छ!');
      return;
    }
    if (newPassCtrl.text != confirmPassCtrl.text) {
      setState(() => passError = 'नयाँ र कन्फर्म पासवर्ड मिलेन!');
      return;
    }

    setState(() {
      widget.user.password = newPassCtrl.text;
    });

    oldPassCtrl.clear();
    newPassCtrl.clear();
    confirmPassCtrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('पासवर्ड सफलतापुर्वक बदलियो!'), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('सदस्य विवरण तथा सेटिङ्स'), backgroundColor: Colors.deepOrange),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        buildGlobalAvatar(widget.user.profilePhotoPath, 28),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.user.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F3A5D))),
                            Text('सदस्यता नं: ${widget.user.id}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            Text('सदस्य बनेको मिति: ${widget.user.joinedDate}', style: const TextStyle(fontSize: 11, color: Colors.teal)),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(4)),
                              child: const Text('Status: Active', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text('१. Update your Information', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F3A5D))),
            const Divider(),
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'नाम (Name)', border: OutlineInputBorder(), isDense: true)),
            const SizedBox(height: 10),
            TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'ठेगाना (Address)', border: OutlineInputBorder(), isDense: true)),
            const SizedBox(height: 10),
            TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'मोबाईल नम्बर (Phone)', border: OutlineInputBorder(), isDense: true)),
            const SizedBox(height: 10),
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'ईमेल (Email)', border: OutlineInputBorder(), isDense: true)),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0E5C79)),
              onPressed: _updateProfileInfo,
              child: const Text('विवरण सेभ गर्नुहोस्', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),

            const Text('२. Family Detail (परिवार विवरण)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F3A5D))),
            const Divider(),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.user.familyMembers.length,
              itemBuilder: (ctx, idx) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: widget.user.familyMembers[idx].name,
                          decoration: const InputDecoration(labelText: 'सदस्यको नाम', border: OutlineInputBorder(), isDense: true),
                          onChanged: (v) => widget.user.familyMembers[idx].name = v,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          initialValue: widget.user.familyMembers[idx].relation,
                          decoration: const InputDecoration(labelText: 'नाता (Relation)', border: OutlineInputBorder(), isDense: true),
                          onChanged: (v) => widget.user.familyMembers[idx].relation = v,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () => setState(() => widget.user.familyMembers.removeAt(idx)),
                      ),
                    ],
                  ),
                );
              },
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.add, color: Colors.deepOrange),
              label: const Text('+ परिवार सदस्य थप्नुहोस्', style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold)),
              onPressed: _addFamilyMemberField,
            ),
            const SizedBox(height: 20),

            const Text('३. पासवर्ड बदल्नुहोस् (Change Password)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F3A5D))),
            const Divider(),
            if (passError.isNotEmpty) ...[
              Text(passError, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 11)),
              const SizedBox(height: 8),
            ],
            TextField(controller: oldPassCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'पुरानो पासवर्ड', border: OutlineInputBorder(), isDense: true)),
            const SizedBox(height: 10),
            TextField(controller: newPassCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'नयाँ पासवर्ड', border: OutlineInputBorder(), isDense: true)),
            const SizedBox(height: 10),
            TextField(controller: confirmPassCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'कन्फर्म पासवर्ड', border: OutlineInputBorder(), isDense: true)),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
              onPressed: _changePassword,
              child: const Text('पासवर्ड चेन्ज गर्नुहोस्', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildBankDetailChips(BuildContext context) {
  return Column(
    children: [
      Row(
        children: [
          Expanded(
            child: ActionChip(
              avatar: const Icon(Icons.copy, size: 14, color: Colors.deepOrange),
              label: const Text('बैंक नाम कपी', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              onPressed: () => copyToClipboard(context, 'नबिल बैंक', 'बैंक नाम'),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: ActionChip(
              avatar: const Icon(Icons.copy, size: 14, color: Colors.deepOrange),
              label: const Text('खाता नम्बर कपी', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              onPressed: () => copyToClipboard(context, '09810017511662', 'खाता नम्बर'),
            ),
          ),
        ],
      ),
      const SizedBox(height: 4),
      SizedBox(
        width: double.infinity,
        child: ActionChip(
          avatar: const Icon(Icons.copy, size: 14, color: Colors.deepOrange),
          label: const Text('खातावालाको नाम कपी', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          onPressed: () => copyToClipboard(context, 'TIKA RAM CHUHAN', 'खातावालाको नाम'),
        ),
      ),
    ],
  );
}

// ---------------- ADDITIONAL & DONATE SCREENS ----------------
class AdditionalSavingsScreen extends StatefulWidget {
  final Member user;
  const AdditionalSavingsScreen({super.key, required this.user});

  @override
  State<AdditionalSavingsScreen> createState() => _AdditionalSavingsScreenState();
}

class _AdditionalSavingsScreenState extends State<AdditionalSavingsScreen> {
  final TextEditingController amountCtrl = TextEditingController();
  XFile? uploadedVoucher;
  bool isChecked = false;

  Future<void> _pickVoucher() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => uploadedVoucher = image);
  }

  @override
  Widget build(BuildContext context) {
    double amt = double.tryParse(amountCtrl.text.trim()) ?? 0;
    return Scaffold(
      appBar: AppBar(title: const Text('अतिरिक्त बचत भुक्तानी'), backgroundColor: Colors.deepOrange),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('अतिरिक्त बचत रकम (बीमामा जम्मा हुँदैन):', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(controller: amountCtrl, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'रकम राख्नुहोस्'), onChanged: (v) => setState(() {})),
            const SizedBox(height: 16),
            buildBankDetailChips(context),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade800),
              onPressed: _pickVoucher,
              icon: const Icon(Icons.photo_library, color: Colors.white),
              label: Text(uploadedVoucher != null ? 'भौचर रोजियो ✓' : 'भौचर Upload गर्नुहोस्', style: const TextStyle(color: Colors.white)),
            ),
            
            if (uploadedVoucher != null) ...[
              const SizedBox(height: 8),
              buildVoucherPreview(uploadedVoucher),
              Text('फाइल: ${uploadedVoucher!.name}', style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)),
            ],
            const SizedBox(height: 12),
            Row(children: [
              Checkbox(value: isChecked, onChanged: (v) => setState(() => isChecked = v ?? false)),
              const Expanded(child: Text('बैंक खातामा रकम जम्मा गरेको सत्य हो।', style: TextStyle(fontSize: 11))),
            ]),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
                onPressed: (amt > 0 && uploadedVoucher != null && isChecked)
                    ? () {
                        pendingPaymentApprovals.add(PaymentSubmission(
                          member: widget.user, paymentType: 'Additional', monthsCount: 0, monthsText: 'अतिरिक्त बचत',
                          totalAmount: amt, fineAmount: 0, insuranceAmt: 0, personalAmt: amt,
                          voucherFileName: uploadedVoucher!.name, voucherFileX: uploadedVoucher, monthIndexTarget: 0,
                        ));
                        widget.user.hasPendingSubmission = true;
                        widget.user.notifications.insert(0, 'अतिरिक्त बचत रु $amt भुक्तानी पेस गरियो।');
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('अतिरिक्त बचत पेस गरियो।'), backgroundColor: Colors.green));
                      }
                    : null,
                child: const Text('पेस गर्नुहोस्', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DonateSavingsScreen extends StatefulWidget {
  final Member user;
  const DonateSavingsScreen({super.key, required this.user});

  @override
  State<DonateSavingsScreen> createState() => _DonateSavingsScreenState();
}

class _DonateSavingsScreenState extends State<DonateSavingsScreen> {
  final TextEditingController amountCtrl = TextEditingController();
  XFile? uploadedVoucher;
  bool isChecked = false;

  Future<void> _pickVoucher() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => uploadedVoucher = image);
  }

  @override
  Widget build(BuildContext context) {
    double amt = double.tryParse(amountCtrl.text.trim()) ?? 0;
    return Scaffold(
      appBar: AppBar(title: const Text('कोषमा दान गर्नुहोस् (Donate)'), backgroundColor: Colors.deepOrange),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('दान गर्ने रकम:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(controller: amountCtrl, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'दान रकम'), onChanged: (v) => setState(() {})),
            const SizedBox(height: 16),
            buildBankDetailChips(context),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade800),
              onPressed: _pickVoucher,
              icon: const Icon(Icons.photo_library, color: Colors.white),
              label: Text(uploadedVoucher != null ? 'भौचर रोजियो ✓' : 'भौचर Upload गर्नुहोस्', style: const TextStyle(color: Colors.white)),
            ),
            if (uploadedVoucher != null) ...[
              const SizedBox(height: 8),
              buildVoucherPreview(uploadedVoucher),
              Text('फाइल: ${uploadedVoucher!.name}', style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)),
            ],
            const SizedBox(height: 12),
            Row(children: [
              Checkbox(value: isChecked, onChanged: (v) => setState(() => isChecked = v ?? false)),
              const Expanded(child: Text('म बुझ्छु यो दान हो।', style: TextStyle(fontSize: 11))),
            ]),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
                onPressed: (amt > 0 && uploadedVoucher != null && isChecked)
                    ? () {
                        pendingPaymentApprovals.add(PaymentSubmission(
                          member: widget.user, paymentType: 'Donate', monthsCount: 0, monthsText: 'कोष दान',
                          totalAmount: amt, fineAmount: 0, insuranceAmt: amt * 0.5, personalAmt: 0,
                          voucherFileName: uploadedVoucher!.name, voucherFileX: uploadedVoucher, monthIndexTarget: 0,
                        ));
                        widget.user.hasPendingSubmission = true;
                        widget.user.notifications.insert(0, 'दान रकम रु $amt भुक्तानी पेस गरियो।');
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('दान भुक्तानी पेस गरियो।'), backgroundColor: Colors.green));
                      }
                    : null,
                child: const Text('दान पेस गर्नुहोस्', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- MONTHLY SAVINGS MENU ----------------
class MonthlySavingsMenuScreen extends StatelessWidget {
  final Member user;
  const MonthlySavingsMenuScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    int currentDay = DateTime.now().day;
    bool isDelayNoticeEnabled = (currentDay >= 1 && currentDay <= 9);

    return Scaffold(
      appBar: AppBar(title: const Text('मासिक बचत भुक्तानी मेनु'), backgroundColor: Colors.deepOrange, iconTheme: const IconThemeData(color: Colors.white)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (user.hasPendingSubmission) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.orange.shade800)),
                child: const Text('⚠️ तपाईंको भुक्तानी पेस भईसकेको छ, एडमिनको निर्णय कुर्नुहोला!', style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              const SizedBox(height: 16),
            ],
            _menuCard(context, '१. पूर्ण बचत भुक्तानी', 'बाँकी महिनाहरूको एकमुष्ठ भुक्तानी', Icons.payments, Colors.teal, true, () {
              if (user.hasPendingSubmission) return;
              Navigator.push(context, MaterialPageRoute(builder: (c) => FullSavingsScreen(user: user)));
            }),
            const SizedBox(height: 12),
            _menuCard(context, '२. आंशिक बचत भुक्तानी', 'चालु/बाँकी महिनाको आंशिक दाखिला', Icons.account_balance_wallet, Colors.orange, true, () {
              if (user.hasPendingSubmission) return;
              Navigator.push(context, MaterialPageRoute(builder: (c) => PartialSavingsScreen(user: user)));
            }),
            const SizedBox(height: 12),

            _menuCard(
              context, 
              '३. बचत भुक्तानी ढिलाइ जानकारी', 
              isDelayNoticeEnabled ? '१ गते देखि ९ गते सम्म मात्र पाइने (Active)' : '१० गते पछि यो मेनु बन्द हुन्छ (Disabled)', 
              Icons.assignment_late, 
              isDelayNoticeEnabled ? Colors.red : Colors.grey, 
              isDelayNoticeEnabled, 
              () {
                if (isDelayNoticeEnabled) {
                  Navigator.push(context, MaterialPageRoute(builder: (c) => DelayNoticeScreen(user: user)));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('भुक्तानी ढिलाइ जानकारी १ गतेदेखि ९ गतेसम्म मात्र दिन पाइन्छ!'), backgroundColor: Colors.red));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuCard(BuildContext context, String title, String subtitle, IconData icon, Color color, bool isEnabled, VoidCallback onTap) {
    return InkWell(
      onTap: isEnabled ? onTap : null,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.45,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14), border: Border.all(color: color, width: 1.5)),
          child: Row(
            children: [
              CircleAvatar(backgroundColor: color, child: Icon(icon, color: Colors.white)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
                Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.black54)),
              ])),
              Icon(Icons.chevron_right, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

class DelayNoticeScreen extends StatefulWidget {
  final Member user;
  const DelayNoticeScreen({super.key, required this.user});

  @override
  State<DelayNoticeScreen> createState() => _DelayNoticeScreenState();
}

class _DelayNoticeScreenState extends State<DelayNoticeScreen> {
  final TextEditingController reasonCtrl = TextEditingController();
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('बचत भुक्तानी ढिलाइ जानकारी'), backgroundColor: Colors.deepOrange),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ढिलाइ हुनुको कारण लेख्नुहोस्:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(controller: reasonCtrl, maxLines: 4, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'कारण खुलाउनुहोस्...')),
            Row(
              children: [
                Checkbox(value: isChecked, onChanged: (v) => setState(() => isChecked = v ?? false)),
                const Expanded(child: Text('म कोषको नियम मान्न तयार छु।', style: TextStyle(fontSize: 11))),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity, height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
                onPressed: isChecked && reasonCtrl.text.isNotEmpty
                    ? () {
                        pendingDelayRequests.add({'user': widget.user.name, 'id': widget.user.id, 'reason': reasonCtrl.text});
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ढिलाइ निवेदन पठाइयो।'), backgroundColor: Colors.teal));
                      }
                    : null,
                child: const Text('जानकारी पेस गर्नुहोस्', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- FULL & PARTIAL SAVINGS SCREENS ----------------
class FullSavingsScreen extends StatefulWidget {
  final Member user;
  const FullSavingsScreen({super.key, required this.user});

  @override
  State<FullSavingsScreen> createState() => _FullSavingsScreenState();
}

class _FullSavingsScreenState extends State<FullSavingsScreen> {
  int selectedMonthsCount = 1;
  XFile? uploadedVoucher;
  bool isChecked = false;

  Future<void> _pickVoucher() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => uploadedVoucher = image);
  }

  @override
  Widget build(BuildContext context) {
    int startIdx = widget.user.paidMonthsCount.clamp(0, 11);
    int maxRemaining = (12 - startIdx).clamp(1, 12);

    double alreadyPaidCurrentMonthPersonal = widget.user.monthPaidPersonal[startIdx] ?? 0.0;
    bool insuranceAlreadyPaid = widget.user.monthInsurancePaid[startIdx] ?? false;

    double currentMonthDue = 2200.0 - (insuranceAlreadyPaid ? 200.0 : 0.0) - alreadyPaidCurrentMonthPersonal;
    if (currentMonthDue < 0) currentMonthDue = 0;

    double totalAmt = currentMonthDue + ((selectedMonthsCount - 1) * 2200.0);

    int endIdx = (startIdx + selectedMonthsCount - 1).clamp(0, 11);
    
    String startM = fundMonthsList[startIdx].split(' ')[0];
    String endM = fundMonthsList[endIdx].split(' ')[0];
    String autoMonthsText = selectedMonthsCount == 1 ? fundMonthsList[startIdx] : '$startM देखि $endM सम्म';

    return Scaffold(
      appBar: AppBar(title: const Text('पूर्ण बचत भुक्तानी'), backgroundColor: Colors.deepOrange),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.teal)),
              child: Text('भुक्तानी हुन बाँकी महिना: ${fundMonthsList[startIdx]}\nयस महिनाको बाँकी रकम (Due): रु ${currentMonthDue.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: Color(0xFF0F3A5D), fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            const Text('कति महिनाको भुक्तानी गर्ने हो छान्नुस:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            DropdownButton<int>(
              isExpanded: true,
              value: selectedMonthsCount,
              items: List.generate(maxRemaining, (i) => i + 1).map((val) {
                double calcAmt = currentMonthDue + ((val - 1) * 2200.0);
                int tmpEnd = (startIdx + val - 1).clamp(0, 11);
                String tmpStartM = fundMonthsList[startIdx].split(' ')[0];
                String tmpEndM = fundMonthsList[tmpEnd].split(' ')[0];
                String rangeStr = val == 1 ? fundMonthsList[startIdx] : '$tmpStartM देखि $tmpEndM सम्म';

                return DropdownMenuItem(value: val, child: Text('$val महिना ($rangeStr - रु $calcAmt)'));
              }).toList(),
              onChanged: (val) => setState(() => selectedMonthsCount = val ?? 1),
            ),
            const SizedBox(height: 12),
            Text('छानिएको अवधि: $autoMonthsText', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
            const SizedBox(height: 12),
            buildBankDetailChips(context),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade800),
              onPressed: _pickVoucher,
              icon: const Icon(Icons.photo_library, color: Colors.white),
              label: Text(uploadedVoucher != null ? 'भौचर रोजियो ✓' : 'भौचर Upload गर्नुहोस्', style: const TextStyle(color: Colors.white)),
            ),
            
            if (uploadedVoucher != null) ...[
              const SizedBox(height: 8),
              buildVoucherPreview(uploadedVoucher),
              Text('फाइल: ${uploadedVoucher!.name}', style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)),
            ],

            const SizedBox(height: 12),
            Row(children: [
              Checkbox(value: isChecked, onChanged: (v) => setState(() => isChecked = v ?? false)),
              const Expanded(child: Text('बैंक खातामा रकम जम्मा गरेको सत्य हो।', style: TextStyle(fontSize: 11))),
            ]),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
                onPressed: (uploadedVoucher != null && isChecked)
                    ? () {
                        double totalIns = insuranceAlreadyPaid ? 0.0 : 200.0;
                        totalIns += (selectedMonthsCount - 1) * 200.0;
                        double totalPers = totalAmt - totalIns;

                        pendingPaymentApprovals.add(PaymentSubmission(
                          member: widget.user, paymentType: 'Full', monthsCount: selectedMonthsCount, monthsText: autoMonthsText,
                          totalAmount: totalAmt, fineAmount: 0, insuranceAmt: totalIns, personalAmt: totalPers,
                          voucherFileName: uploadedVoucher!.name, voucherFileX: uploadedVoucher, monthIndexTarget: startIdx,
                        ));
                        widget.user.hasPendingSubmission = true;
                        widget.user.notifications.insert(0, 'पूर्ण बचत ($autoMonthsText) रु $totalAmt भुक्तानी पेस गरियो।');
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('पूर्ण बचत भुक्तानी पेस गरियो।'), backgroundColor: Colors.green));
                      }
                    : null,
                child: const Text('भुक्तानी पेस गर्नुहोस्', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PartialSavingsScreen extends StatefulWidget {
  final Member user;
  const PartialSavingsScreen({super.key, required this.user});

  @override
  State<PartialSavingsScreen> createState() => _PartialSavingsScreenState();
}

class _PartialSavingsScreenState extends State<PartialSavingsScreen> {
  final TextEditingController amountCtrl = TextEditingController();
  XFile? uploadedVoucher;
  bool isChecked = false;

  Future<void> _pickVoucher() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => uploadedVoucher = image);
  }

  @override
  Widget build(BuildContext context) {
    int startIdx = widget.user.paidMonthsCount.clamp(0, 11);
    String monthName = fundMonthsList[startIdx];
    double alreadyPaid = widget.user.monthPaidPersonal[startIdx] ?? 0.0;
    bool insPaid = widget.user.monthInsurancePaid[startIdx] ?? false;

    double currentDue = 2200.0 - (insPaid ? 200.0 : 0.0) - alreadyPaid;
    double minLim = insPaid ? 50.0 : 200.0;
    double entered = double.tryParse(amountCtrl.text.trim()) ?? 0;

    bool isValidAmount = (entered >= minLim && entered <= currentDue);

    return Scaffold(
      appBar: AppBar(title: const Text('आंशिक बचत भुक्तानी'), backgroundColor: Colors.deepOrange),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('भुक्तानी महिना: $monthName', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
            Text('यस महिनाको बाँकी रकम (Due): रु ${currentDue.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F3A5D))),
            const SizedBox(height: 12),
            TextField(
              controller: amountCtrl, keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: 'रु ${minLim.toStringAsFixed(0)} देखि रु ${currentDue.toStringAsFixed(0)} सम्म मात्र',
                errorText: (amountCtrl.text.isNotEmpty && !isValidAmount) ? 'कृपया रु ${minLim.toStringAsFixed(0)} देखि रु ${currentDue.toStringAsFixed(0)} सम्म मात्र राख्नुहोस्!' : null,
              ),
              onChanged: (v) => setState(() {}),
            ),
            const SizedBox(height: 12),
            buildBankDetailChips(context),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade800),
              onPressed: _pickVoucher,
              icon: const Icon(Icons.photo_library, color: Colors.white),
              label: Text(uploadedVoucher != null ? 'भौचर रोजियो ✓' : 'भौचर Upload गर्नुहोस्', style: const TextStyle(color: Colors.white)),
            ),
            if (uploadedVoucher != null) ...[
              const SizedBox(height: 8),
              buildVoucherPreview(uploadedVoucher),
              Text('फाइल: ${uploadedVoucher!.name}', style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)),
            ],
            const SizedBox(height: 12),
            Row(children: [
              Checkbox(value: isChecked, onChanged: (v) => setState(() => isChecked = v ?? false)),
              const Expanded(child: Text('बैंक खातामा रकम जम्मा गरेको सत्य हो।', style: TextStyle(fontSize: 11))),
            ]),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
                onPressed: (uploadedVoucher != null && isChecked && isValidAmount)
                    ? () {
                        double insurancePart = insPaid ? 0.0 : 200.0;
                        double personalPart = insPaid ? entered : (entered - 200.0).clamp(0.0, entered);

                        pendingPaymentApprovals.add(PaymentSubmission(
                          member: widget.user, paymentType: 'Partial', monthsCount: 1, monthsText: monthName,
                          totalAmount: entered, fineAmount: 0, insuranceAmt: insurancePart, personalAmt: personalPart,
                          voucherFileName: uploadedVoucher!.name, voucherFileX: uploadedVoucher, monthIndexTarget: startIdx,
                        ));
                        widget.user.hasPendingSubmission = true;
                        widget.user.notifications.insert(0, 'आंशिक बचत ($monthName) रु $entered भुक्तानी पेस गरियो।');
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('आंशिक भुक्तानी पेस गरियो।'), backgroundColor: Colors.green));
                      }
                    : null,
                child: const Text('भुक्तानी पेस गर्नुहोस्', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- ADMIN DASHBOARD VIEW ----------------
class AdminDashboardView extends StatefulWidget {
  final Member user;
  const AdminDashboardView({super.key, required this.user});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  final TextEditingController _adminRemarkCtrl = TextEditingController();
  final TextEditingController _editableAmtCtrl = TextEditingController();

  void _showReviewDialog(int index) {
    PaymentSubmission sub = pendingPaymentApprovals[index];
    _adminRemarkCtrl.text = 'तपाईंको भुक्तानी स्वीकृत गरिएको छ।';
    _editableAmtCtrl.text = sub.totalAmount.toString();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          title: Text('${sub.member.name} को भुक्तानी समीक्षा'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('भुक्तानी प्रकार: ${sub.paymentType} (${sub.monthsText})'),
                const SizedBox(height: 8),

                const Text('भुक्तानी रकम (एडमिनले सच्याउन मिल्ने):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                const SizedBox(height: 4),
                TextField(
                  controller: _editableAmtCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                  onChanged: (val) {
                    double nAmt = double.tryParse(val) ?? sub.totalAmount;
                    setDlgState(() {
                      sub.totalAmount = nAmt;
                    });
                  },
                ),
                const SizedBox(height: 12),

                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (imgCtx) => Dialog(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('वास्तविक भौचर फाइल: ${sub.voucherFileName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              const Divider(),
                              Container(
                                height: 260, width: double.infinity,
                                decoration: BoxDecoration(color: Colors.grey.shade200, border: Border.all(color: Colors.grey)),
                                child: sub.voucherFileX != null
                                    ? buildVoucherPreview(sub.voucherFileX, height: 260)
                                    : const Icon(Icons.verified, size: 80, color: Colors.teal),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.download),
                                label: const Text('डाउनलोड गर्नुहोस् (Download)'),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('सक्कली भौचर (${sub.voucherFileName}) डाउनलोड भयो!'), backgroundColor: Colors.teal));
                                  Navigator.pop(imgCtx);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blue)),
                    child: Row(
                      children: [
                        const Icon(Icons.visibility, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(child: Text('सक्कली भौचर हेर्नुहोस् / डाउनलोड गर्नुहोस्\n(${sub.voucherFileName})', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 11))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('सन्देश (Remark):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                TextField(controller: _adminRemarkCtrl, maxLines: 2, decoration: const InputDecoration(border: OutlineInputBorder())),
              ],
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () { Navigator.pop(ctx); _rejectPayment(index, _adminRemarkCtrl.text); },
              child: const Text('अस्वीकृत'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () { Navigator.pop(ctx); _approvePayment(index, _adminRemarkCtrl.text); },
              child: const Text('स्वीकृत', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _approvePayment(int index, String remark) {
    PaymentSubmission sub = pendingPaymentApprovals[index];
    double remainingAmountToProcess = sub.totalAmount;

    setState(() {
      int currentMonthIdx = sub.member.paidMonthsCount.clamp(0, 11);
      double approvedInsurance = 0.0;
      double approvedPersonal = 0.0;

      if (sub.paymentType == 'Full' || sub.paymentType == 'Partial') {
        while (remainingAmountToProcess > 0 && currentMonthIdx < 12) {
          bool insPaid = sub.member.monthInsurancePaid[currentMonthIdx] ?? false;
          double prevPaidPersonal = sub.member.monthPaidPersonal[currentMonthIdx] ?? 0.0;

          if (!insPaid) {
            if (remainingAmountToProcess >= 200.0) {
              approvedInsurance += 200.0;
              sub.member.monthInsurancePaid[currentMonthIdx] = true;
              remainingAmountToProcess -= 200.0;
            } else {
              approvedInsurance += remainingAmountToProcess;
              remainingAmountToProcess = 0.0;
              break; 
            }
          }

          double neededPersonal = 2000.0 - prevPaidPersonal;
          if (neededPersonal > 0) {
            if (remainingAmountToProcess >= neededPersonal) {
              approvedPersonal += neededPersonal;
              sub.member.monthPaidPersonal[currentMonthIdx] = 2000.0;
              remainingAmountToProcess -= neededPersonal;
            } else {
              approvedPersonal += remainingAmountToProcess;
              sub.member.monthPaidPersonal[currentMonthIdx] = prevPaidPersonal + remainingAmountToProcess;
              remainingAmountToProcess = 0.0;
            }
          }

          if ((sub.member.monthInsurancePaid[currentMonthIdx] ?? false) && (sub.member.monthPaidPersonal[currentMonthIdx] ?? 0.0) >= 2000.0) {
            currentMonthIdx++;
            sub.member.paidMonthsCount = currentMonthIdx;
          } else {
            break;
          }
        }
      } else if (sub.paymentType == 'Additional') {
        approvedPersonal = remainingAmountToProcess;
      } else if (sub.paymentType == 'Donate') {
        approvedInsurance = remainingAmountToProcess * 0.5;
        approvedPersonal = remainingAmountToProcess * 0.5;
      }

      sub.member.personalSavings += approvedPersonal;
      sub.member.totalInsurance += approvedInsurance;
      totalInsuranceFund += approvedInsurance;
      totalFundSavings += approvedPersonal;

      globalTransactionHistory.insert(0, TransactionRecord(
        memberId: sub.member.id, memberName: sub.member.name, type: sub.paymentType,
        details: sub.monthsText, amount: sub.totalAmount, insuranceAmt: approvedInsurance, personalAmt: approvedPersonal, date: '२०८३ कार्तिक',
      ));

      sub.member.notificationBannerText = remark.isNotEmpty ? remark : 'तपाईंको भुक्तानी स्वीकृत भयो।';
      sub.member.notifications.insert(0, 'तपाईंको रु ${sub.totalAmount} को भुक्तानी एडमिनद्वारा स्वीकृत भयो।');
      sub.member.isBannerGreen = true;
      sub.member.hasPendingSubmission = false;
      pendingPaymentApprovals.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('भुक्तानी शुद्ध गणितीय नियम अनुसार स्वीकृत गरियो!'), backgroundColor: Colors.green));
  }

  void _rejectPayment(int index, String remark) {
    PaymentSubmission sub = pendingPaymentApprovals[index];
    setState(() {
      sub.member.notificationBannerText = remark.isNotEmpty ? remark : 'तपाईंको भुक्तानी अस्वीकृत भयो।';
      sub.member.notifications.insert(0, 'तपाईंको भुक्तानी अस्वीकृत भयो। कारण: $remark');
      sub.member.isBannerGreen = false;
      sub.member.hasPendingSubmission = false;
      pendingPaymentApprovals.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('भुक्तानी अस्वीकृत गरियो!'), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('पेन्डिङ भुक्तानी अप्रुवलहरू', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F3A5D))),
          const Divider(),
          if (pendingPaymentApprovals.isEmpty) const Text('कुनै पनि पेन्डिङ भुक्तानी छैन।'),
          ListView.builder(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            itemCount: pendingPaymentApprovals.length,
            itemBuilder: (ctx, idx) {
              PaymentSubmission sub = pendingPaymentApprovals[idx];
              return Card(
                child: ListTile(
                  title: Text('${sub.member.name} (${sub.paymentType})', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('विवरण: ${sub.monthsText}\nरकम: रु ${sub.totalAmount}'),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0E5C79)),
                    onPressed: () => _showReviewDialog(idx),
                    child: const Text('जाँच्नुहोस्', style: TextStyle(color: Colors.white)),
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

// ---------------- ADMIN PAYMENT SCREEN ----------------
class AdminPaymentScreen extends StatefulWidget {
  final Member user;
  const AdminPaymentScreen({super.key, required this.user});

  @override
  State<AdminPaymentScreen> createState() => _AdminPaymentScreenState();
}

class _AdminPaymentScreenState extends State<AdminPaymentScreen> {
  Member? selectedMember;
  String selectedType = 'Full';
  int selectedMonthsCount = 1;
  final TextEditingController amountCtrl = TextEditingController();
  XFile? adminUploadedVoucher;
  bool isChecked = false;
  String errorMessage = '';

  Future<void> _pickVoucher() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => adminUploadedVoucher = image);
  }

  void _processAdminPayment() {
    setState(() => errorMessage = '');
    int startIdx = selectedMember?.paidMonthsCount.clamp(0, 11) ?? 0;
    bool insPaid = selectedMember?.monthInsurancePaid[startIdx] ?? false;

    double enteredAmt = selectedType == 'Full' 
        ? (2200.0 - (insPaid ? 200.0 : 0.0) - (selectedMember?.monthPaidPersonal[startIdx] ?? 0.0) + ((selectedMonthsCount - 1) * 2200.0))
        : (double.tryParse(amountCtrl.text.trim()) ?? 0);

    double currentDue = 2200.0 - (insPaid ? 200.0 : 0.0) - (selectedMember?.monthPaidPersonal[startIdx] ?? 0.0);
    double minLimit = insPaid ? 50.0 : 200.0;

    if (selectedType == 'Partial') {
      if (enteredAmt < minLimit || enteredAmt > currentDue) {
        setState(() => errorMessage = 'आंशिक भुक्तानीमा रु ${minLimit.toStringAsFixed(0)} देखि रु ${currentDue.toStringAsFixed(0)} सम्म मात्र हाल्न पाइन्छ!');
        return;
      }
    }

    if (selectedMember == null || enteredAmt <= 0 || adminUploadedVoucher == null || !isChecked) {
      setState(() => errorMessage = 'कृपया सबै अनिवार्य विवरण भर्नुहोस् र भौचर अपलोड गर्नुहोस्!');
      return;
    }

    double remaining = enteredAmt;
    int currIdx = startIdx;
    double appInsurance = 0.0;
    double appPersonal = 0.0;

    int endIdx = (startIdx + selectedMonthsCount - 1).clamp(0, 11);
    String startM = fundMonthsList[startIdx].split(' ')[0];
    String endM = fundMonthsList[endIdx].split(' ')[0];
    String detailText = selectedType == 'Full'
        ? (selectedMonthsCount == 1 ? fundMonthsList[startIdx] : '$startM देखि $endM सम्म')
        : fundMonthsList[startIdx];

    setState(() {
      if (selectedType == 'Full' || selectedType == 'Partial') {
        while (remaining > 0 && currIdx < 12) {
          bool iPaid = selectedMember!.monthInsurancePaid[currIdx] ?? false;
          double pPaid = selectedMember!.monthPaidPersonal[currIdx] ?? 0.0;

          if (!iPaid) {
            if (remaining >= 200.0) {
              appInsurance += 200.0;
              selectedMember!.monthInsurancePaid[currIdx] = true;
              remaining -= 200.0;
            } else {
              appInsurance += remaining;
              remaining = 0.0;
              break;
            }
          }

          double needP = 2000.0 - pPaid;
          if (needP > 0) {
            if (remaining >= needP) {
              appPersonal += needP;
              selectedMember!.monthPaidPersonal[currIdx] = 2000.0;
              remaining -= needP;
            } else {
              appPersonal += remaining;
              selectedMember!.monthPaidPersonal[currIdx] = pPaid + remaining;
              remaining = 0.0;
            }
          }

          if ((selectedMember!.monthInsurancePaid[currIdx] ?? false) && (selectedMember!.monthPaidPersonal[currIdx] ?? 0.0) >= 2000.0) {
            currIdx++;
            selectedMember!.paidMonthsCount = currIdx;
          } else {
            break;
          }
        }
      } else if (selectedType == 'Additional') {
        appPersonal = remaining;
      } else if (selectedType == 'Donate') {
        appInsurance = remaining * 0.5;
        appPersonal = remaining * 0.5;
      }

      selectedMember!.personalSavings += appPersonal;
      selectedMember!.totalInsurance += appInsurance;
      totalInsuranceFund += appInsurance;
      totalFundSavings += appPersonal;

      globalTransactionHistory.insert(0, TransactionRecord(
        memberId: selectedMember!.id, memberName: selectedMember!.name, type: selectedType,
        details: detailText, amount: enteredAmt, insuranceAmt: appInsurance, personalAmt: appPersonal, date: '२०८३ कार्तिक',
      ));
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('भुक्तानी सफलतापूर्वक स्वीकृत भई अपडेट भयो!'), backgroundColor: Colors.green));
    amountCtrl.clear();
    setState(() {
      adminUploadedVoucher = null;
      isChecked = false;
      errorMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    int startIdx = selectedMember?.paidMonthsCount.clamp(0, 11) ?? 0;
    int maxRemaining = (12 - startIdx).clamp(1, 12);

    double alreadyPaid = selectedMember?.monthPaidPersonal[startIdx] ?? 0.0;
    bool insPaid = selectedMember?.monthInsurancePaid[startIdx] ?? false;

    double currentDue = 2200.0 - (insPaid ? 200.0 : 0.0) - alreadyPaid;

    int endIdx = (startIdx + selectedMonthsCount - 1).clamp(0, 11);
    String startM = fundMonthsList[startIdx].split(' ')[0];
    String endM = fundMonthsList[endIdx].split(' ')[0];
    String monthTextFormatted = selectedMonthsCount == 1 ? fundMonthsList[startIdx] : '$startM देखि $endM सम्म';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('सदस्यको भुक्तानी प्रबन्ध (Admin Direct Entry)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F3A5D))),
          const Divider(),

          if (errorMessage.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red)),
              child: Text(errorMessage, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 11)),
            ),
            const SizedBox(height: 10),
          ],

          const Text('१. सदस्य छान्नुहोस्:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          DropdownButton<Member>(
            isExpanded: true,
            hint: const Text('सदस्य छान्नुहोस्'),
            value: selectedMember,
            items: sampleMembers.where((m) => m.role == 'member').map((m) => DropdownMenuItem(value: m, child: Text('${m.name} (${m.id})'))).toList(),
            onChanged: (m) => setState(() { selectedMember = m; selectedMonthsCount = 1; amountCtrl.clear(); errorMessage = ''; }),
          ),
          const SizedBox(height: 12),
          const Text('२. भुक्तानी किसिम छान्नुहोस्:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          DropdownButton<String>(
            isExpanded: true,
            value: selectedType,
            items: const [
              DropdownMenuItem(value: 'Full', child: Text('पूर्ण बचत भुक्तानी')),
              DropdownMenuItem(value: 'Partial', child: Text('आंशिक बचत भुक्तानी')),
              DropdownMenuItem(value: 'Additional', child: Text('अतिरिक्त बचत')),
              DropdownMenuItem(value: 'Donate', child: Text('कोष दान (Donate)')),
            ],
            onChanged: (v) => setState(() { selectedType = v ?? 'Full'; amountCtrl.clear(); errorMessage = ''; }),
          ),
          const SizedBox(height: 12),

          if (selectedType == 'Full' && selectedMember != null) ...[
            Text('भुक्तानी अवधि: $monthTextFormatted', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 14)),
            const SizedBox(height: 4),
            Text('यस महिनाको बाँकी Due रकम: रु ${currentDue.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('कति महिनाको गर्ने हो छान्नुस:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            DropdownButton<int>(
              isExpanded: true,
              value: selectedMonthsCount,
              items: List.generate(maxRemaining, (i) => i + 1).map((val) {
                double calc = currentDue + ((val - 1) * 2200.0);
                int tmpEnd = (startIdx + val - 1).clamp(0, 11);
                String tmpStartM = fundMonthsList[startIdx].split(' ')[0];
                String tmpEndM = fundMonthsList[tmpEnd].split(' ')[0];
                String rangeStr = val == 1 ? fundMonthsList[startIdx] : '$tmpStartM देखि $tmpEndM सम्म';

                return DropdownMenuItem(value: val, child: Text('$val महिना ($rangeStr - रु $calc)'));
              }).toList(),
              onChanged: (val) => setState(() => selectedMonthsCount = val ?? 1),
            ),
          ] else if (selectedType == 'Partial' && selectedMember != null) ...[
            Text('भुक्तानी महिना: ${fundMonthsList[startIdx]}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
            Text('बाँकी Due रकम: रु ${currentDue.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(
              controller: amountCtrl, keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(border: const OutlineInputBorder(), hintText: 'रु ${insPaid ? 50 : 200} देखि रु ${currentDue.toStringAsFixed(0)} सम्म'),
              onChanged: (v) => setState(() => errorMessage = ''),
            ),
          ] else ...[
            TextField(
              controller: amountCtrl, keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'रकम राख्नुहोस्'),
              onChanged: (v) => setState(() => errorMessage = ''),
            ),
          ],
          const SizedBox(height: 14),

          buildBankDetailChips(context),
          const SizedBox(height: 12),

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade800),
            onPressed: _pickVoucher,
            icon: const Icon(Icons.photo_library, color: Colors.white),
            label: Text(adminUploadedVoucher != null ? 'भौचर रोजियो ✓' : 'भौचर Upload गर्नुहोस् (अनिवार्य)', style: const TextStyle(color: Colors.white)),
          ),
          if (adminUploadedVoucher != null) Text('फाइल: ${adminUploadedVoucher!.name}', style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          Row(children: [
            Checkbox(value: isChecked, onChanged: (v) => setState(() => isChecked = v ?? false)),
            const Expanded(child: Text('बैंक खातामा रकम प्राप्त भएको निश्चित गर्दछु।', style: TextStyle(fontSize: 11))),
          ]),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity, height: 46,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
              onPressed: _processAdminPayment,
              child: const Text('तुरुन्त अप्रुभ र अपडेट गर्नुहोस्', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- ADMIN LEDGER EDIT SCREEN ----------------
class AdminLedgerEditScreen extends StatefulWidget {
  final Member user;
  const AdminLedgerEditScreen({super.key, required this.user});

  @override
  State<AdminLedgerEditScreen> createState() => _AdminLedgerEditScreenState();
}

class _AdminLedgerEditScreenState extends State<AdminLedgerEditScreen> {
  Member? selectedMember;
  final TextEditingController personalSavCtrl = TextEditingController();
  final TextEditingController insuranceCtrl = TextEditingController();
  final TextEditingController paidMonthsCtrl = TextEditingController();

  void _loadMemberData(Member m) {
    setState(() {
      selectedMember = m;
      personalSavCtrl.text = m.personalSavings.toString();
      insuranceCtrl.text = m.totalInsurance.toString();
      paidMonthsCtrl.text = m.paidMonthsCount.toString();
    });
  }

  void _saveChanges() {
    if (selectedMember == null) return;
    double pSav = double.tryParse(personalSavCtrl.text) ?? selectedMember!.personalSavings;
    double ins = double.tryParse(insuranceCtrl.text) ?? selectedMember!.totalInsurance;
    int pMonths = int.tryParse(paidMonthsCtrl.text) ?? selectedMember!.paidMonthsCount;

    setState(() {
      selectedMember!.personalSavings = pSav;
      selectedMember!.totalInsurance = ins;
      selectedMember!.paidMonthsCount = pMonths.clamp(0, 12);
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${selectedMember!.name} को विवरण सफलतापुर्वक सच्याइयो!'), backgroundColor: Colors.teal));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('सम्पादन (Edit Member Ledger)'), backgroundColor: Colors.deepOrange),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('सच्याउनुपर्ने सदस्य छान्नुहोस्:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            DropdownButton<Member>(
              isExpanded: true,
              hint: const Text('सदस्य छान्नुहोस्'),
              value: selectedMember,
              items: sampleMembers.where((m) => m.role == 'member').map((m) => DropdownMenuItem(value: m, child: Text('${m.name} (${m.id})'))).toList(),
              onChanged: (m) => m != null ? _loadMemberData(m) : null,
            ),
            const SizedBox(height: 16),

            if (selectedMember != null) ...[
              Text('सदस्य: ${selectedMember!.name}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange, fontSize: 15)),
              const Divider(),

              const Text('१. कुल व्यक्तिगत बचत रकम:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              TextField(controller: personalSavCtrl, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true)),
              const SizedBox(height: 10),

              const Text('२. कुल बीमा कोष रकम:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              TextField(controller: insuranceCtrl, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true)),
              const SizedBox(height: 10),

              const Text('३. भुक्तानी भइसकेको महिना संख्या (० देखि १२):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              TextField(controller: paidMonthsCtrl, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true)),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity, height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  onPressed: _saveChanges,
                  child: const Text('विवरण सच्याउनुहोस् (Save Edit)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------- LOAN MANAGEMENT VIEW ----------------
class LoanManagementView extends StatefulWidget {
  final Member user;
  const LoanManagementView({super.key, required this.user});

  @override
  State<LoanManagementView> createState() => _LoanManagementViewState();
}

class _LoanManagementViewState extends State<LoanManagementView> {
  final TextEditingController amtCtrl = TextEditingController();
  final TextEditingController purposeCtrl = TextEditingController();
  final TextEditingController collateralCtrl = TextEditingController();
  
  Member? guarantor1;
  Member? guarantor2;
  bool isCheckAgreed = false;
  String loanErrorMsg = '';

  final TextEditingController repayAmtCtrl = TextEditingController();
  XFile? repayVoucher;
  bool repayChecked = false;

  Future<void> _pickRepayVoucher() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => repayVoucher = image);
  }

  void _submitLoanForm(double maxEligible) {
    setState(() => loanErrorMsg = '');
    double reqAmt = double.tryParse(amtCtrl.text.trim()) ?? 0;

    if (reqAmt <= 0) {
      setState(() => loanErrorMsg = 'कृपया सही ऋण रकम राख्नुहोस्!');
      return;
    }

    if (reqAmt > maxEligible) {
      setState(() => loanErrorMsg = 'रिन योग्य रकम भन्दा बढी भयो! (अधिकतम रु ${maxEligible.toStringAsFixed(2)} सम्म मात्र पाउन सकिन्छ)');
      return;
    }

    if (reqAmt > 200000) {
      if (collateralCtrl.text.trim().isEmpty || guarantor1 == null || guarantor2 == null) {
        setState(() => loanErrorMsg = 'रु २ लाखभन्दा बढीको ऋणमा अनिवार्य धितो र २ जना जमानी सदस्य छान्नुहोस्!');
        return;
      }
      if (guarantor1!.id == guarantor2!.id) {
        setState(() => loanErrorMsg = 'कृपया दुई फरक-फरक जमानी सदस्य छान्नुहोस्!');
        return;
      }
    }

    setState(() {
      globalLoanRequests.add(LoanRequest(
        loanId: 'LN${DateTime.now().millisecondsSinceEpoch}',
        member: widget.user,
        amount: reqAmt,
        purpose: purposeCtrl.text,
        collateralDetails: collateralCtrl.text,
        guarantor1Id: guarantor1?.id ?? '',
        guarantor2Id: guarantor2?.id ?? '',
      ));
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ऋण निवेदन पेस भयो! अब भोटिङका लागि सदस्यहरूकहाँ पठाइएको छ।'), backgroundColor: Colors.green));
    amtCtrl.clear();
    purposeCtrl.clear();
    collateralCtrl.clear();
    setState(() {
      guarantor1 = null;
      guarantor2 = null;
      isCheckAgreed = false;
      loanErrorMsg = '';
    });
  }

  void _submitLoanRepayment() {
    double repayAmt = double.tryParse(repayAmtCtrl.text.trim()) ?? 0;
    if (repayAmt <= 0 || repayAmt > widget.user.totalLoan) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('कृपया सही किस्ता रकम राख्नुहोस्!'), backgroundColor: Colors.red));
      return;
    }

    pendingPaymentApprovals.add(PaymentSubmission(
      member: widget.user,
      paymentType: 'LoanRepay',
      monthsCount: 0,
      monthsText: 'ऋण किस्ता भुक्तानी',
      totalAmount: repayAmt,
      fineAmount: 0,
      insuranceAmt: 0,
      personalAmt: repayAmt,
      voucherFileName: repayVoucher!.name,
      voucherFileX: repayVoucher,
      monthIndexTarget: 0,
    ));

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ऋण किस्ता भुक्तानी एडमिनकहाँ पेस गरियो।'), backgroundColor: Colors.green));
    repayAmtCtrl.clear();
    setState(() {
      repayVoucher = null;
      repayChecked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double eligibleLoanAmt = (totalFundSavings - emergencyReserve) * 0.70;
    if (eligibleLoanAmt < 0) eligibleLoanAmt = 0;

    double dailyInterest = (widget.user.totalLoan * (widget.user.loanInterestRate / 100)) / 365;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFF0F3A5D), borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet, color: Colors.yellowAccent, size: 36),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('हाल ऋण दिन योग्य रकम (70% Eligible)', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                      Text('रु ${eligibleLoanAmt.toStringAsFixed(2)}', style: const TextStyle(color: Colors.yellowAccent, fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (widget.user.totalLoan > 0) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.deepOrange)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('तपाईंको कुल ऋण बाँकी: रु ${widget.user.totalLoan.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.deepOrange)),
                  const SizedBox(height: 4),
                  Text('दैनिक ब्याज दर (${widget.user.loanInterestRate}% वार्षिक): रु ${dailyInterest.toStringAsFixed(2)} / दिन', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text('ऋण किस्ता भुक्तानी गर्नुहोस्', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F3A5D))),
            const Divider(),
            TextField(
              controller: repayAmtCtrl, keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'किस्ता रकम राख्नुहोस्'), onChanged: (v) => setState(() {}),
            ),
            const SizedBox(height: 10),
            buildBankDetailChips(context),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade800),
              onPressed: _pickRepayVoucher,
              icon: const Icon(Icons.photo_library, color: Colors.white),
              label: Text(repayVoucher != null ? 'भौचर रोजियो ✓' : 'किस्ता भौचर Upload गर्नुहोस्', style: const TextStyle(color: Colors.white)),
            ),
            if (repayVoucher != null) Text('फाइल: ${repayVoucher!.name}', style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)),
            Row(children: [
              Checkbox(value: repayChecked, onChanged: (v) => setState(() => repayChecked = v ?? false)),
              const Expanded(child: Text('बैंकमा रकम जम्मा गरेको सत्य हो।', style: TextStyle(fontSize: 11))),
            ]),
            SizedBox(
              width: double.infinity, height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
                onPressed: (repayVoucher != null && repayChecked) ? _submitLoanRepayment : null,
                child: const Text('ऋण किस्ता भुक्तानी पेस गर्नुहोस्', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],

          if (globalLoanRequests.where((r) => r.status == 'Pending' && r.member.id != widget.user.id).isNotEmpty) ...[
            const Text('सदस्य ऋण भोटिङ (Member Voting)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F3A5D))),
            const SizedBox(height: 6),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: globalLoanRequests.where((r) => r.status == 'Pending' && r.member.id != widget.user.id).length,
              itemBuilder: (ctx, i) {
                LoanRequest req = globalLoanRequests.where((r) => r.status == 'Pending' && r.member.id != widget.user.id).toList()[i];
                bool hasVoted = req.approvedMemberIds.contains(widget.user.id);

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ऋण आवेदक: ${req.member.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('माग रकम: रु ${req.amount} | कारण: ${req.purpose}'),
                        Text('स्वीकृति संख्या: ${req.approvedMemberIds.length} / ४ जना', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                        const SizedBox(height: 6),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: hasVoted ? Colors.grey : Colors.green),
                          onPressed: hasVoted ? null : () {
                            setState(() {
                              req.approvedMemberIds.add(widget.user.id);
                              if (req.approvedMemberIds.length >= 4) {
                                req.status = 'Approved';
                                req.member.totalLoan += req.amount;
                                totalFundSavings -= req.amount; 
                                req.member.notificationBannerText = 'तपाईंको रु ${req.amount} ऋण ४ जना सदस्यहरूको स्वीकृतिपछि स्वीकृत भयो!';
                                req.member.isBannerGreen = true;
                              }
                            });
                          },
                          child: Text(hasVoted ? 'भोट दिइसकियो ✓' : 'ऋण स्वीकृत गर्नुहोस् (Vote Accept)', style: const TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const Divider(),
          ],

          const Text('ऋण माग फारम (Loan Application)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F3A5D))),
          const SizedBox(height: 10),

          if (loanErrorMsg.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red)),
              child: Text(loanErrorMsg, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 11)),
            ),
            const SizedBox(height: 10),
          ],

          const Text('१. माग गर्ने ऋण रकम (नम्बर मात्र):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          TextField(
            controller: amtCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(border: const OutlineInputBorder(), hintText: 'अधिकतम रु ${eligibleLoanAmt.toStringAsFixed(0)} सम्म'),
            onChanged: (v) => setState(() => loanErrorMsg = ''),
          ),
          const SizedBox(height: 10),

          const Text('२. ऋण लिनुको कारण:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          TextField(controller: purposeCtrl, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'कारण खुलाउनुहोस्')),
          const SizedBox(height: 10),

          const Text('३. धितो विवरण (रु २ लाखभन्दा बढी भए अनिवार्य):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          TextField(controller: collateralCtrl, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'धितो विवरण')),
          const SizedBox(height: 10),

          const Text('४. प्रथम जमानी सदस्य छान्नुहोस्:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          DropdownButton<Member>(
            isExpanded: true,
            hint: const Text('जमानी सदस्य १'),
            value: guarantor1,
            items: sampleMembers.where((m) => m.id != widget.user.id).map((m) => DropdownMenuItem(value: m, child: Text('${m.name} (${m.id})'))).toList(),
            onChanged: (m) => setState(() => guarantor1 = m),
          ),
          const SizedBox(height: 10),

          const Text('५. द्वितीय जमानी सदस्य छान्नुहोस्:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          DropdownButton<Member>(
            isExpanded: true,
            hint: const Text('जमानी सदस्य २'),
            value: guarantor2,
            items: sampleMembers.where((m) => m.id != widget.user.id).map((m) => DropdownMenuItem(value: m, child: Text('${m.name} (${m.id})'))).toList(),
            onChanged: (m) => setState(() => guarantor2 = m),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Checkbox(value: isCheckAgreed, onChanged: (v) => setState(() => isCheckAgreed = v ?? false)),
              const Expanded(child: Text('म कोषको ऋण सम्बन्धी सम्पूर्ण नियमहरू पालना गर्न मञ्जुर गर्दछु।', style: TextStyle(fontSize: 11))),
            ],
          ),
          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity, height: 46,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
              onPressed: isCheckAgreed ? () => _submitLoanForm(eligibleLoanAmt) : null,
              child: const Text('निवेदन पेस गर्नुहोस्', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- ADMIN MEMBERS MANAGEMENT VIEW ----------------
class AdminMembersManagementView extends StatefulWidget {
  final Member user;
  const AdminMembersManagementView({super.key, required this.user});
  @override
  State<AdminMembersManagementView> createState() => _AdminMembersManagementViewState();
}

class _AdminMembersManagementViewState extends State<AdminMembersManagementView> {

  void _showEditMemberDialog(Member member) {
    final nameCtrl = TextEditingController(text: member.name);
    final phoneCtrl = TextEditingController(text: member.phone);
    final addressCtrl = TextEditingController(text: member.address);
    final passCtrl = TextEditingController(text: member.password);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${member.name} को विवरण र पासवर्ड सच्याउनुहोस्'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'नाम (Name)', border: OutlineInputBorder(), isDense: true)),
              const SizedBox(height: 8),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'फोन नम्बर', border: OutlineInputBorder(), isDense: true)),
              const SizedBox(height: 8),
              TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'ठेगाना', border: OutlineInputBorder(), isDense: true)),
              const SizedBox(height: 8),
              TextField(controller: passCtrl, decoration: const InputDecoration(labelText: 'पासवर्ड (Reset Password)', border: OutlineInputBorder(), isDense: true)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('रद्द गर्नुहोस्')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () {
              setState(() {
                member.name = nameCtrl.text.trim();
                member.phone = phoneCtrl.text.trim();
                member.address = addressCtrl.text.trim();
                member.password = passCtrl.text.trim();
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('सदस्यको विवरण र पासवर्ड सफलतापूर्वक अपडेट भयो!'), backgroundColor: Colors.teal));
            },
            child: const Text('सेभ गर्नुहोस्', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('सदस्यहरू व्यवस्थापन, सच्याउने र खाता Freeze/Unfreeze', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F3A5D))),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: sampleMembers.length,
              itemBuilder: (c, i) => Card(
                child: ListTile(
                  leading: GestureDetector(
                    onTap: () => _showEditMemberDialog(sampleMembers[i]),
                    child: buildGlobalAvatar(sampleMembers[i].profilePhotoPath, 22),
                  ),
                  title: Text(sampleMembers[i].name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('ID: ${sampleMembers[i].id} | मो: ${sampleMembers[i].phone}\nपासवर्ड: ${sampleMembers[i].password}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.teal),
                        onPressed: () => _showEditMemberDialog(sampleMembers[i]),
                      ),
                      IconButton(
                        icon: Icon(sampleMembers[i].isFrozen ? Icons.lock : Icons.lock_open, color: sampleMembers[i].isFrozen ? Colors.red : Colors.green),
                        onPressed: () => setState(() => sampleMembers[i].isFrozen = !sampleMembers[i].isFrozen),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- HISTORY & OTHER VIEWS ----------------
class HistoryView extends StatefulWidget {
  final Member user;
  const HistoryView({super.key, required this.user});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  Member? filterMember;

  @override
  Widget build(BuildContext context) {
    List<TransactionRecord> displayedHistory = widget.user.role == 'admin'
        ? (filterMember == null ? globalTransactionHistory : globalTransactionHistory.where((t) => t.memberId == filterMember!.id).toList())
        : globalTransactionHistory.where((t) => t.memberId == widget.user.id).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('कारोबार इतिहास (इतिहास)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F3A5D))),
          const Divider(),
          if (widget.user.role == 'admin') ...[
            DropdownButton<Member?>(
              isExpanded: true,
              value: filterMember,
              hint: const Text('सबै सदस्यहरूको इतिहास'),
              items: [
                const DropdownMenuItem<Member?>(value: null, child: Text('सबै सदस्यहरू')),
                ...sampleMembers.map((m) => DropdownMenuItem<Member?>(value: m, child: Text(m.name)))
              ],
              onChanged: (m) => setState(() => filterMember = m),
            ),
            const SizedBox(height: 10),
          ],
          Expanded(
            child: displayedHistory.isEmpty
                ? const Center(child: Text('इतिहास फेला परेन।'))
                : ListView.builder(
                    itemCount: displayedHistory.length,
                    itemBuilder: (ctx, i) => Card(
                      child: ListTile(
                        leading: const CircleAvatar(backgroundColor: Color(0xFF0F3A5D), child: Icon(Icons.receipt, color: Colors.white)),
                        title: Text('${displayedHistory[i].memberName} (${displayedHistory[i].type})', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('विवरण: ${displayedHistory[i].details}\nमिति: ${displayedHistory[i].date}'),
                        trailing: Text('रु ${displayedHistory[i].amount}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class AdminInsuranceView extends StatelessWidget {
  final Member user;
  const AdminInsuranceView({super.key, required this.user});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.teal.shade800, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('बीमा कोष व्यवस्थापन', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('कुल मौज्दात बीमा कोष: रु ${totalInsuranceFund.toStringAsFixed(2)}', style: const TextStyle(color: Colors.yellowAccent, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class FamilyChatView extends StatefulWidget {
  final Member user;
  const FamilyChatView({super.key, required this.user});
  @override
  State<FamilyChatView> createState() => _FamilyChatViewState();
}

class _FamilyChatViewState extends State<FamilyChatView> {
  final TextEditingController _msgController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12), color: const Color(0xFF0F3A5D), width: double.infinity,
          child: const Text('💬 परिवार छलफल तथा च्याट बोर्ड', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: globalChatMessages.length,
            itemBuilder: (context, index) => ListTile(title: Text(globalChatMessages[index].senderName, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)), subtitle: Text(globalChatMessages[index].message)),
          ),
        ),
        Row(
          children: [
            Expanded(child: TextField(controller: _msgController, decoration: const InputDecoration(hintText: 'सन्देश लेख्नुहोस्...'))),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.deepOrange),
              onPressed: () {
                if (_msgController.text.isNotEmpty) {
                  setState(() => globalChatMessages.add(ChatMessage(senderName: widget.user.name, senderId: widget.user.id, message: _msgController.text, time: 'भर्खरै')));
                  _msgController.clear();
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}

class InsuranceFundView extends StatelessWidget {
  final Member user;
  const InsuranceFundView({super.key, required this.user});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('बीमा कोष तथा औषधि उपचार', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F3A5D))),
        const Divider(),
        Card(
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('तपाईंको जम्मा बीमा रकम:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                const SizedBox(height: 6),
                Text('रु ${user.totalInsurance.toStringAsFixed(2)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F3A5D))),
                const Divider(height: 24),
                const Text('कोषको कुल बीमा मौज्दात:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                Text('रु ${totalInsuranceFund.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
