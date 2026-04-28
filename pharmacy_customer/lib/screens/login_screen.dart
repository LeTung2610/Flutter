import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import 'dart:math' as math;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  late AnimationController _floatController;
  late AnimationController _particleController;

  // Modern Luxury Palette
  static const Color primaryTeal = Color(0xFF00D4C4); // Xanh ngọc nhạt 2026
  static const Color darkTeal = Color(0xFF004D40);
  static const Color deepTeal = Color(0xFF00796B);
  static const Color softTeal = Color(0xFFE0F2F1);
  static const Color softBg = Color(0xFFFDFCFB);
  static const Color accentGold = Color(0xFFFFD700);

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutBack),
      ),
    );

    _floatController = AnimationController(vsync: this, duration: const Duration(seconds: 12))..repeat();
    _particleController = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _floatController.dispose();
    _particleController.dispose();
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_email.text.isEmpty || _pass.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _pass.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      String message = "Đã xảy ra lỗi";
      if (e.code == 'user-not-found') message = "Email này chưa được đăng ký";
      else if (e.code == 'wrong-password') message = "Sai mật khẩu";
      else if (e.code == 'invalid-email') message = "Định dạng email không hợp lệ";
      else if (e.code == 'network-request-failed') message = "Lỗi kết nối mạng";
      else if (e.code == 'invalid-credential') message = "Email hoặc mật khẩu không chính xác";

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message, style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
            backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            elevation: 20,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWeb = size.width > 800;

    return Scaffold(
      backgroundColor: softBg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // --- 1. Masterpiece Background ---
          _buildCinematicBackground(size),

          // --- 2. Main Login UI ---
          Row(
            children: [
              if (isWeb)
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(80),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Nền tảng\nDược phẩm\nCao cấp",
                          style: TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.w900,
                            color: darkTeal,
                            height: 1.1,
                            letterSpacing: -2,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Container(
                          width: 80,
                          height: 6,
                          decoration: BoxDecoration(
                            color: primaryTeal,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          "Trải nghiệm dịch vụ chăm sóc sức khỏe\nchuẩn quốc tế ngay tại Việt Nam.",
                          style: TextStyle(fontSize: 18, color: Colors.grey, height: 1.6),
                        ),
                      ],
                    ),
                  ),
                ),
              Expanded(
                flex: 1,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 460),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildPremiumLoginCard(),
                              const SizedBox(height: 32),
                              _buildTrustBadges(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCinematicBackground(Size size) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [softBg, Color(0xFFE0F7F6), softBg],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        
        // Volumetric Light Effect
        Positioned(
          top: -200,
          left: -100,
          child: Opacity(
            opacity: 0.4,
            child: Container(
              width: 800,
              height: 800,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [primaryTeal.withValues(alpha: 0.2), Colors.transparent],
                  stops: const [0.0, 0.7],
                ),
              ),
            ),
          ),
        ),

        // Animated Particles
        ...List.generate(20, (index) => _buildAnimatedParticle(size, index)),

        // Floating 3D Ornaments
        _buildFloatingOrnament(Icons.medication_rounded, size.width * 0.1, size.height * 0.15, 120, 0.04),
        _buildFloatingOrnament(Icons.spa_rounded, size.width * 0.85, size.height * 0.1, 150, 0.03),
        _buildFloatingOrnament(Icons.healing_rounded, size.width * 0.15, size.height * 0.8, 100, 0.035),
        _buildFloatingOrnament(Icons.biotech_rounded, size.width * 0.8, size.height * 0.75, 110, 0.03),
      ],
    );
  }

  Widget _buildAnimatedParticle(Size size, int index) {
    final random = math.Random(index);
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        double t = (_particleController.value + (index * 0.05)) % 1.0;
        return Positioned(
          left: (random.nextDouble() * size.width) + (math.sin(t * math.pi * 2) * 50),
          top: size.height - (t * size.height * 1.2),
          child: Opacity(
            opacity: math.sin(t * math.pi) * 0.3,
            child: Container(
              width: 4 + random.nextDouble() * 4,
              height: 4 + random.nextDouble() * 4,
              decoration: const BoxDecoration(color: primaryTeal, shape: BoxShape.circle),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingOrnament(IconData icon, double x, double y, double size, double alpha) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        double offset = math.sin(_floatController.value * 2 * math.pi + x) * 20;
        return Positioned(
          left: x,
          top: y + offset,
          child: Transform.rotate(
            angle: 0.1 * math.sin(_floatController.value * 2 * math.pi + y),
            child: Icon(icon, size: size, color: deepTeal.withValues(alpha: alpha)),
          ),
        );
      },
    );
  }

  Widget _buildPremiumLoginCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(48),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 60),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(48),
            border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 40, offset: const Offset(0, 20)),
              BoxShadow(color: primaryTeal.withValues(alpha: 0.05), blurRadius: 60, spreadRadius: -10),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLogoSection(),
              const SizedBox(height: 56),
              _buildModernTextField(
                controller: _email,
                label: "EMAIL ADDRESS",
                icon: Icons.alternate_email_rounded,
                hint: "yourname@luxury.com",
              ),
              const SizedBox(height: 28),
              _buildModernTextField(
                controller: _pass,
                label: "PASSWORD",
                icon: Icons.lock_open_rounded,
                isPassword: true,
                isVisible: _isPasswordVisible,
                hint: "••••••••",
                onToggle: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),
              const SizedBox(height: 48),
              _buildAnimatedSubmitButton(),
              const SizedBox(height: 32),
              _buildFooterLinks(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: softTeal,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: primaryTeal.withValues(alpha: 0.15), blurRadius: 25, offset: const Offset(0, 8))
                ],
              ),
            ),
            const Icon(Icons.local_pharmacy_rounded, size: 40, color: deepTeal),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          "NEELMILK",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: 10,
            color: darkTeal,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "PREMIUM PHARMACY",
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 4,
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 12),
          child: Text(
            label,
            style: TextStyle(
              color: darkTeal.withValues(alpha: 0.7),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword && !isVisible,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: darkTeal),
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Icon(icon, color: primaryTeal, size: 22),
              ),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(isVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded, color: Colors.grey[400], size: 20),
                      onPressed: onToggle,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 20),
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[300], fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedSubmitButton() {
    return Container(
      width: double.infinity,
      height: 68,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          colors: [primaryTeal, deepTeal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryTeal.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        ),
        child: _isLoading
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("TIẾP TỤC", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  SizedBox(width: 12),
                  Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
      ),
    );
  }

  Widget _buildFooterLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Chưa có tài khoản? ", style: TextStyle(color: Colors.grey[600])),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const RegisterScreen())),
          child: const Text(
            "Đăng ký ngay",
            style: TextStyle(color: deepTeal, fontWeight: FontWeight.w800, decoration: TextDecoration.underline),
          ),
        ),
      ],
    );
  }

  Widget _buildTrustBadges() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_rounded, size: 12, color: Colors.grey[400]),
          const SizedBox(width: 8),
          Text(
            "SECURE LOGIN • AES 256 BIT",
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFCFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF004D40)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "CREATE ACCOUNT",
          style: TextStyle(color: Color(0xFF004D40), fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(color: Color(0xFFE0F2F1), shape: BoxShape.circle),
              child: const Icon(Icons.person_add_rounded, size: 50, color: Color(0xFF00796B)),
            ),
            const SizedBox(height: 60),
            _buildField("EMAIL ADDRESS", Icons.alternate_email_rounded, _email),
            const SizedBox(height: 32),
            _buildField("PASSWORD", Icons.lock_open_rounded, _pass, isPassword: true),
            const SizedBox(height: 60),
            SizedBox(
              width: double.infinity,
              height: 68,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () async {
                  if (_email.text.isEmpty || _pass.text.isEmpty) return;
                  setState(() => _isLoading = true);
                  try {
                    await FirebaseAuth.instance.createUserWithEmailAndPassword(
                      email: _email.text.trim(),
                      password: _pass.text.trim()
                    );
                    if (mounted) Navigator.pop(context);
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent)
                      );
                    }
                  } finally {
                    if (mounted) setState(() => _isLoading = false);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D4C4),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                  elevation: 10,
                  shadowColor: const Color(0xFF00D4C4).withValues(alpha: 0.3),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("TẠO TÀI KHOẢN", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, IconData icon, TextEditingController controller, {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 12),
          child: Text(label, style: const TextStyle(color: Color(0xFF004D40), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 8))],
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            style: const TextStyle(color: Color(0xFF004D40), fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: const Color(0xFF00D4C4), size: 22),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 20),
            ),
          ),
        ),
      ],
    );
  }
}
