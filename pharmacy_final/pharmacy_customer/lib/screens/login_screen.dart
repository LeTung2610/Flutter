import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _isLogin = true;

  Future<void> _submit() async {
    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _email.text.trim(), password: _pass.text.trim());
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _email.text.trim(), password: _pass.text.trim());
      }
    } on FirebaseAuthException catch (e) {
      String message = "Đã xảy ra lỗi";
      if (e.code == 'user-not-found') message = "Email này chưa được đăng ký";
      else if (e.code == 'wrong-password') message = "Sai mật khẩu";
      else if (e.code == 'invalid-email') message = "Định dạng email không hợp lệ";
      else if (e.code == 'network-request-failed') message = "Lỗi kết nối mạng";
      else if (e.code == 'invalid-credential') message = "Email hoặc mật khẩu không chính xác";
      
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal[800]!, Colors.teal[400]!],
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 100),
            const Icon(Icons.local_pharmacy_rounded, size: 80, color: Colors.white),
            const SizedBox(height: 16),
            const Text("QUÂN PHARMACY", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 2)),
            const Text("Sức khỏe của bạn là niềm hạnh phúc của chúng tôi", style: TextStyle(color: Colors.white70, fontSize: 12)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFA),
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: Column(
                children: [
                  Text(_isLogin ? "Chào Mừng Trở Lại" : "Đăng Ký Tài Khoản", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal)),
                  const SizedBox(height: 30),
                  TextField(controller: _email, decoration: const InputDecoration(hintText: "Email", prefixIcon: Icon(Icons.email_outlined))),
                  const SizedBox(height: 15),
                  TextField(controller: _pass, obscureText: true, decoration: const InputDecoration(hintText: "Mật khẩu", prefixIcon: Icon(Icons.lock_outline))),
                  const SizedBox(height: 30),
                  ElevatedButton(onPressed: _submit, child: Text(_isLogin ? "ĐĂNG NHẬP" : "ĐĂNG KÝ")),
                  TextButton(
                    onPressed: () => setState(() => _isLogin = !_isLogin),
                    child: Text(_isLogin ? "Chưa có tài khoản? Đăng ký ngay" : "Đã có tài khoản? Đăng nhập"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
