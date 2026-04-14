import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/login_screen.dart';
import 'screens/overview_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/order_manager_screen.dart';
import 'screens/pos_screen.dart';
import 'screens/revenue_screen.dart';

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
  runApp(const PharmacyApp());
}

class PharmacyApp extends StatelessWidget {
  const PharmacyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pharmacy Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[50],
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.cyan, width: 2)),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey[200]!)),
          color: Colors.white,
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) return const AdminDashboard();
          return const LoginScreen();
        },
      ),
    );
  }
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const OverviewScreen(),
    const InventoryScreen(),
    const OrderManagerScreen(),
    const PosScreen(),
    const RevenueScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) => setState(() => _selectedIndex = index),
            extended: MediaQuery.of(context).size.width > 1000,
            backgroundColor: Colors.white,
            elevation: 1,
            useIndicator: true,
            indicatorColor: Colors.cyan[50],
            unselectedIconTheme: const IconThemeData(color: Colors.grey, opacity: 0.8),
            unselectedLabelTextStyle: const TextStyle(color: Colors.grey),
            selectedIconTheme: const IconThemeData(color: Colors.cyan, size: 28),
            selectedLabelTextStyle: const TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold),
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: Text('Tổng quan')),
              NavigationRailDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: Text('Kho Hàng')),
              NavigationRailDestination(icon: Icon(Icons.local_shipping_outlined), selectedIcon: Icon(Icons.local_shipping), label: Text('Đơn Online')),
              NavigationRailDestination(icon: Icon(Icons.point_of_sale_outlined), selectedIcon: Icon(Icons.point_of_sale), label: Text('POS Tại Quầy')),
              NavigationRailDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: Text('Doanh Thu')),
            ],
            leading: Column(
              children: [
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.cyan, borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.local_pharmacy, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 12),
                if (MediaQuery.of(context).size.width > 1000) 
                  const Text("PHARMACY", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.cyan, fontSize: 16)),
                const SizedBox(height: 24),
              ],
            ),
            trailing: Expanded(
                child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: IconButton(
                            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                            onPressed: () => FirebaseAuth.instance.signOut()
                        )
                    )
                )
            ),
          ),
          Expanded(child: Container(color: Colors.grey[50], child: _screens[_selectedIndex])),
        ],
      ),
    );
  }
}
