import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nepali_utils/nepali_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

    String bsYearStr = nepaliNow.format('yyyy');
    String bsMonthStr = nepaliNow.format('MMMM');
    String bsDayStr = nepaliNow.format('dd');
    String bsDayName = nepaliNow.format('EEEE');

    String dayNameAd = adDaysShort[now.weekday - 1];
    String monthNameAd = adMonthsShort[now.month - 1];
    String adYearStr = now.year.toString();

    return "$bsMonthStr $bsDayStr, $bsYearStr ($bsDayName)\n${monthNameAd.toLowerCase()} $adYearStr";
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
      const Center(child: Text('ऋण व्यवस्थापन')),
      const Center(child: Text('बीमा कोष')),
      const Center(child: Text('च्याट')),
      const Center(child: Text('इतिहास')),
    ];

    List<Widget> adminPages = [
      MemberDashboardView(user: widget.user),
      const Center(child: Text('भुक्तानी प्रबन्धक')),
      const Center(child: Text('बीमा एडमिन')),
      const Center(child: Text('सदस्य व्यवस्थापन')),
      const Center(child: Text('इतिहास')),
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
                    Row(
                      children: [
                        buildGlobalAvatar(widget.user.profilePhotoPath, 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.user.name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                              Text(widget.user.address, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                            ],
                          ),
                        ),
                        const Icon(Icons.touch_app, color: Colors.white70, size: 18),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('कुल व्यक्तिगत बचत', style: TextStyle(color: Colors.white70, fontSize: 11)),
                            Row(
                              children: [
                                Text(_showSavings ? 'रु ${widget.user.personalSavings.toStringAsFixed(2)}' : 'रु ••••••••', style: const TextStyle(color: Colors.greenAccent, fontSize: 15, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 6),
                                GestureDetector(onTap: () => setState(() => _showSavings = !_showSavings), child: Icon(_showSavings ? Icons.visibility : Icons.visibility_off, color: Colors.white70, size: 16)),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('कुल ऋण', style: TextStyle(color: Colors.white70, fontSize: 11)),
                            Text('रु ${widget.user.totalLoan.toStringAsFixed(2)}', style: const TextStyle(color: Colors.orangeAccent, fontSize: 15, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
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
              InkWell(onTap: () {}, child: _serviceCard('मासिक बचत\nभुक्तानी', Icons.calendar_month)),
              InkWell(onTap: () {}, child: _serviceCard('अतिरिक्त बचत\nभुक्तानी', Icons.savings)),
              InkWell(onTap: () {}, child: _serviceCard('Donate\nगर्नुहोस्', Icons.volunteer_activism)),
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
