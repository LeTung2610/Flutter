import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/login_screen.dart';
import 'screens/shop_home_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/order_history_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBvZi1k_ezN33dEEk6gMRRK-UeLnWXDA_4",
      authDomain: "pharmacy-online-9bcf5.firebaseapp.com",
      projectId: "pharmacy-online-9bcf5",
      storageBucket: "pharmacy-online-9bcf5.firebasestorage.app",
      messagingSenderId: "196680610389",
      appId: "1:196680610389:web:35e67c036a3cfc835f5adc",
    ),
  );
  runApp(const CustomerApp());
}

class CustomerApp extends StatelessWidget {
  const CustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nhà Thuốc Quân Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal, primary: Colors.teal[700]),
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF8FAFA),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(color: Colors.teal, fontSize: 20, fontWeight: FontWeight.bold),
          iconTheme: IconThemeData(color: Colors.teal),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal[700],
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        if (snapshot.hasData) return const MainNavigation();
        return const LoginScreen();
      },
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  Map<String, Map<String, dynamic>> cart = {};

  void _updateCart(String id, Map<String, dynamic> data, int qtyChange) {
    setState(() {
      if (cart.containsKey(id)) {
        int newQty = cart[id]!['qty'] + qtyChange;
        int stock = int.tryParse(cart[id]!['maxStock']?.toString() ?? '0') ?? 0;
        
        if (newQty > stock && qtyChange > 0) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã đạt giới hạn tồn kho!")));
          return;
        }
        
        cart[id]!['qty'] = newQty;
        if (cart[id]!['qty'] <= 0) cart.remove(id);
      } else if (qtyChange > 0) {
        cart[id] = {
          'name': data['name'],
          'price': num.tryParse(data['price']?.toString() ?? '0') ?? 0,
          'qty': 1,
          'maxStock': int.tryParse(data['stock']?.toString() ?? '0') ?? 0,
          'image': data['image'] ?? '',
        };
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      ShopHomeScreen(onAdd: (id, data) => _updateCart(id, data, 1)),
      CartScreen(cart: cart, onUpdate: _updateCart, onClear: () => setState(() => cart.clear())),
      const OrderHistoryScreen(),
    ];

    int cartTotal = cart.values.fold(0, (sum, item) => sum + (item['qty'] as int));

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: [
          const NavigationDestination(icon: Icon(Icons.home_outlined), label: "Trang chủ"),
          NavigationDestination(
              icon: Badge(label: Text("$cartTotal"), isLabelVisible: cartTotal > 0, child: const Icon(Icons.shopping_cart_outlined)),
              label: "Giỏ hàng"
          ),
          const NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: "Đơn mua"),
        ],
      ),
    );
  }
}
