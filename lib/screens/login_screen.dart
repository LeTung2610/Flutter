import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _e = TextEditingController(), _p = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.cyan[400]!, Colors.cyan[800]!],
          ),
        ),
        child: Center(
          child: Card(
            elevation: 20,
            shadowColor: Colors.black26,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            child: Container(
              width: 450,
              padding: const EdgeInsets.all(48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.cyan[50], shape: BoxShape.circle),
                    child: const Icon(Icons.local_pharmacy, size: 64, color: Colors.cyan),
                  ),
                  const SizedBox(height: 32),
                  const Text("PHARMACY ADMIN", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.cyan)),
                  const SizedBox(height: 8),
                  Text("Hệ thống quản lý kho & bán hàng", style: TextStyle(color: Colors.grey[500], fontSize: 15)),
                  const SizedBox(height: 48),
                  TextField(
                    controller: _e,
                    decoration: const InputDecoration(
                      labelText: "Email đăng nhập",
                      prefixIcon: Icon(Icons.email_outlined),
                      hintText: "admin@pharmacy.com",
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _p,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: "Mật khẩu",
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          await FirebaseAuth.instance.signInWithEmailAndPassword(email: _e.text.trim(), password: _p.text.trim());
                        } catch (e) {
                          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: ${e.toString()}"), backgroundColor: Colors.red));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyan,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Text("ĐĂNG NHẬP HỆ THỐNG", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const RegisterScreen())),
                    child: const Text("Chưa có tài khoản? Đăng ký ngay", style: TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
          ),
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
  final _e = TextEditingController(), _p = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Center(
        child: Container(
          width: 400, padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min, 
            children: [
              const Icon(Icons.person_add_outlined, size: 60, color: Colors.cyan),
              const SizedBox(height: 24),
              const Text("TẠO TÀI KHOẢN ADMIN", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              TextField(controller: _e, decoration: const InputDecoration(labelText: "Email công việc")),
              const SizedBox(height: 20),
              TextField(controller: _p, decoration: const InputDecoration(labelText: "Mật khẩu bảo mật"), obscureText: true),
              const SizedBox(height: 40),
              SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: () async {
                try {
                  await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _e.text.trim(), password: _p.text.trim());
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }, 
              style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan, foregroundColor: Colors.white),
              child: const Text("XÁC NHẬN ĐĂNG KÝ")))
            ],
          ),
        ),
      ),
    );
  }
}
