import 'dart:ui';
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
      title: 'NeelMilk Pharmacy Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'SF Pro Display', // Giả định font cao cấp
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00D4C4),
          primary: const Color(0xFF00D4C4),
          surface: const Color(0xFFF0F4F8),
        ),
        scaffoldBackgroundColor: const Color(0xFFF0F4F8),
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
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
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
      body: Stack(
        children: [
          // Background lấp lánh nhẹ cho toàn hệ thống
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF0F4F8), Color(0xFFE8EEF5), Color(0xFFFDFCFB)],
                ),
              ),
            ),
          ),
          
          Row(
            children: [
              // Sidebar Siêu Sang Trọng
              _buildModernSidebar(),
              
              // Nội dung chính
              Expanded(
                child: Column(
                  children: [
                    _buildTopNavbar(),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.05),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                            child: child,
                          ),
                        ),
                        child: KeyedSubtree(
                          key: ValueKey(_selectedIndex),
                          child: _screens[_selectedIndex],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernSidebar() {
    bool isExtended = MediaQuery.of(context).size.width > 1200;
    
    return Container(
      width: isExtended ? 280 : 100,
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 30,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Logo NeelMilk
              _buildLogo(isExtended),
              const SizedBox(height: 50),
              
              // Menu Items
              _buildMenuItem(0, Icons.dashboard_rounded, "Tổng quan", isExtended),
              _buildMenuItem(1, Icons.inventory_2_rounded, "Kho hàng", isExtended),
              _buildMenuItem(2, Icons.local_shipping_rounded, "Đơn online", isExtended),
              _buildMenuItem(3, Icons.point_of_sale_rounded, "POS quầy", isExtended),
              _buildMenuItem(4, Icons.analytics_rounded, "Doanh thu", isExtended),
              
              const Spacer(),
              
              // Admin Profile Card
              _buildAdminCard(isExtended),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(bool extended) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF00D4C4), Color(0xFF00A89B)]),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: const Color(0xFF00D4C4).withOpacity(0.3), blurRadius: 15)],
          ),
          child: const Icon(Icons.local_pharmacy_rounded, color: Colors.white, size: 30),
        ),
        if (extended) ...[
          const SizedBox(height: 15),
          const Text(
            "NeelMilk",
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF2D3748), letterSpacing: 1),
          ),
          const Text(
            "PHARMACY ADMIN",
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF00D4C4), letterSpacing: 2),
          ),
        ]
      ],
    );
  }

  Widget _buildMenuItem(int index, IconData icon, String title, bool extended) {
    bool isSelected = _selectedIndex == index;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: extended ? 15 : 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00D4C4).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: extended ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF00D4C4) : const Color(0xFF718096),
              size: 24,
            ),
            if (extended) ...[
              const SizedBox(width: 15),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF2D3748) : const Color(0xFF718096),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard(bool extended) {
    final user = FirebaseAuth.instance.currentUser;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFFE6FFFA),
            child: Icon(Icons.person_outline, color: Color(0xFF00D4C4)),
          ),
          if (extended) ...[
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(user?.email?.split('@')[0] ?? "Admin", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const Text("Premium Staff", style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout_rounded, size: 18, color: Colors.redAccent),
              onPressed: () => FirebaseAuth.instance.signOut(),
            )
          ]
        ],
      ),
    );
  }

  Widget _buildTopNavbar() {
    return Container(
      height: 80,
      margin: const EdgeInsets.only(top: 20, right: 20, bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 30),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          const Text(
            "Bảng Điều Khiển Hệ Thống",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF2D3748)),
          ),
          const Spacer(),
          // Search Bar
          Container(
            width: 300,
            height: 45,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: "Tìm kiếm thông tin...",
                prefixIcon: Icon(Icons.search, size: 20),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 20),
          const Icon(Icons.notifications_none_rounded, color: Color(0xFF718096)),
        ],
      ),
    );
  }
}
