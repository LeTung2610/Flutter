import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../features/admin/theme/admin_theme.dart';
import '../features/admin/widgets/admin_common_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Lỗi đăng nhập: ${e.toString()}"),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminTheme.backgroundCream,
      body: Stack(
        children: [
          _buildBackgroundDecorations(),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: GlassCard(
                width: 480,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 60),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLogo(),
                    const SizedBox(height: 30),
                    Text(
                      "CHÀO MỪNG TRỞ LẠI",
                      style: AdminTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Hệ thống quản trị NeelMilk Pharmacy",
                      style: TextStyle(color: AdminTheme.textGrey, fontSize: 14),
                    ),
                    const SizedBox(height: 50),
                    _buildInputField(
                      controller: _emailController,
                      label: "EMAIL QUẢN TRỊ",
                      hint: "admin@neelmilk.com",
                      icon: Icons.alternate_email_rounded,
                    ),
                    const SizedBox(height: 25),
                    _buildInputField(
                      controller: _passwordController,
                      label: "MẬT KHẨU BẢO MẬT",
                      hint: "••••••••",
                      icon: Icons.lock_outline_rounded,
                      isPassword: true,
                    ),
                    const SizedBox(height: 15),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text(
                          "Quên mật khẩu?",
                          style: TextStyle(color: AdminTheme.primaryTeal, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: AdminButton(
                        label: _isLoading ? "ĐANG XÁC THỰC..." : "ĐĂNG NHẬP HỆ THỐNG",
                        onTap: _isLoading ? () {} : _login,
                        icon: _isLoading ? null : Icons.vpn_key_rounded,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Chưa có quyền quản trị?", style: TextStyle(color: AdminTheme.textGrey, fontSize: 13)),
                        TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                          child: const Text(
                            "Yêu cầu cấp quyền",
                            style: TextStyle(color: AdminTheme.primaryTeal, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 800.ms).scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutBack),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundDecorations() {
    return Stack(
      children: [
        Positioned(
          top: -150,
          right: -150,
          child: _AnimatedBlob(color: AdminTheme.primaryTeal.withValues(alpha: 0.1), size: 500),
        ),
        Positioned(
          bottom: -200,
          left: -100,
          child: _AnimatedBlob(color: Colors.teal.shade200.withValues(alpha: 0.08), size: 600),
        ),
      ],
    );
  }

  Widget _buildLogo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminTheme.primaryTeal.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(color: AdminTheme.primaryTeal.withValues(alpha: 0.2)),
      ),
      child: const Icon(Icons.local_pharmacy_rounded, size: 50, color: AdminTheme.primaryTeal),
    ).animate().shimmer(duration: 2.seconds, color: Colors.white24);
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AdminTheme.textGrey, letterSpacing: 1),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.teal.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword && !_isPasswordVisible,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.normal),
              prefixIcon: Icon(icon, color: AdminTheme.primaryTeal, size: 20),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(_isPasswordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded, color: AdminTheme.textGrey, size: 20),
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
          ),
        ),
      ],
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _register() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Yêu cầu cấp quyền đã được gửi!"), backgroundColor: AdminTheme.primaryTeal),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Lỗi: ${e.toString()}"), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminTheme.backgroundCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AdminTheme.textDark),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: GlassCard(
            width: 480,
            padding: const EdgeInsets.all(50),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.admin_panel_settings_rounded, size: 70, color: AdminTheme.primaryTeal),
                const SizedBox(height: 30),
                Text("CẤP QUYỀN ADMIN", style: AdminTheme.lightTheme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 40),
                _buildField(_emailController, "Admin Email", Icons.email_outlined),
                const SizedBox(height: 25),
                _buildField(_passwordController, "Security Password", Icons.lock_open_rounded, isPass: true),
                const SizedBox(height: 50),
                SizedBox(
                  width: double.infinity,
                  child: AdminButton(
                    label: _isLoading ? "ĐANG XỬ LÝ..." : "XÁC NHẬN YÊU CẦU",
                    onTap: _isLoading ? () {} : _register,
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn().slideY(begin: 0.1),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String hint, IconData icon, {bool isPass = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(hint.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AdminTheme.textGrey, letterSpacing: 1)),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.teal.withValues(alpha: 0.1))),
          child: TextField(
            controller: ctrl,
            obscureText: isPass,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AdminTheme.primaryTeal, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
          ),
        ),
      ],
    );
  }
}

class _AnimatedBlob extends StatelessWidget {
  final Color color;
  final double size;
  const _AnimatedBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
     .moveY(begin: -20, end: 20, duration: 3.seconds, curve: Curves.easeInOut)
     .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 4.seconds);
  }
}
