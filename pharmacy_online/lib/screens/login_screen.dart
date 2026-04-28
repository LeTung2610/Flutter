import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _login() async {
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
            content: Text("Lỗi: ${e.toString()}"),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
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
      body: Stack(
        children: [
          // Background lấp lánh với các hình khối động
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF001F3F), Color(0xFF00796B), Color(0xFF004D40)],
              ),
            ),
          ),
          ..._buildBackgroundOrnaments(),
          
          Center(
            child: SingleChildScrollView(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    width: 400,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 50),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo lấp lánh
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [Colors.cyanAccent.withOpacity(0.5), Colors.transparent],
                            ),
                          ),
                          child: const Icon(
                            Icons.local_pharmacy_rounded,
                            size: 60,
                            color: Colors.cyanAccent,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "PHARMACY ADMIN",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            color: Colors.white,
                            shadows: [Shadow(color: Colors.cyanAccent, blurRadius: 10)],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Excellence in Management",
                          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                        ),
                        const SizedBox(height: 40),

                        _buildTextField(
                          controller: _emailController,
                          hint: "Email",
                          icon: Icons.alternate_email_rounded,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: _passwordController,
                          hint: "Password",
                          icon: Icons.lock_outline_rounded,
                          isPassword: true,
                        ),
                        const SizedBox(height: 40),

                        // Nút bấm Gradient
                        Container(
                          width: double.infinity,
                          height: 55,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            gradient: const LinearGradient(
                              colors: [Colors.cyanAccent, Color(0xFF00BCD4)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.cyanAccent.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              )
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text(
                                    "LOGIN",
                                    style: TextStyle(
                                      color: Color(0xFF004D40),
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                          child: Text(
                            "Create New Admin Account",
                            style: TextStyle(color: Colors.cyanAccent.withOpacity(0.8), fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !_isPasswordVisible,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
          prefixIcon: Icon(icon, color: Colors.cyanAccent.withOpacity(0.7)),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  List<Widget> _buildBackgroundOrnaments() {
    return [
      _AnimatedCircle(top: -100, left: -100, size: 300, color: Colors.cyanAccent.withOpacity(0.1)),
      _AnimatedCircle(bottom: -50, right: -50, size: 250, color: Colors.tealAccent.withOpacity(0.05)),
      Positioned(
        top: 100,
        right: 150,
        child: Icon(Icons.star, color: Colors.white.withOpacity(0.1), size: 20),
      ),
      Positioned(
        bottom: 200,
        left: 100,
        child: Icon(Icons.star, color: Colors.white.withOpacity(0.05), size: 15),
      ),
    ];
  }
}

class _AnimatedCircle extends StatelessWidget {
  final double? top, left, bottom, right;
  final double size;
  final Color color;

  const _AnimatedCircle({this.top, this.left, this.bottom, this.right, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      bottom: bottom,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001F3F),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: Colors.white)),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person_add_rounded, size: 70, color: Colors.cyanAccent),
              const SizedBox(height: 24),
              const Text(
                "REGISTER ADMIN",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2),
              ),
              const SizedBox(height: 40),
              _buildSimpleField(controller: _emailController, hint: "Email", icon: Icons.email),
              const SizedBox(height: 20),
              _buildSimpleField(controller: _passwordController, hint: "Password", icon: Icons.lock, isPassword: true),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await FirebaseAuth.instance.createUserWithEmailAndPassword(
                        email: _emailController.text.trim(),
                        password: _passwordController.text.trim(),
                      );
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent,
                    foregroundColor: const Color(0xFF004D40),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("CONFIRM REGISTRATION", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleField({required TextEditingController controller, required String hint, required IconData icon, bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        prefixIcon: Icon(icon, color: Colors.cyanAccent),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
      ),
    );
  }
}
