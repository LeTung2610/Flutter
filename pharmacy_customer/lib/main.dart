import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'theme/app_theme.dart';
import 'routes/app_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  runApp(const ProviderScope(child: NeelMilkApp()));
}

class NeelMilkApp extends StatelessWidget {
  const NeelMilkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'NeelMilk Premium Pharmacy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.luxuryTheme,
      routerConfig: AppRouter.router,
      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: child!,
        breakpoints: [
          const Breakpoint(start: 0, end: 450, name: MOBILE),
          const Breakpoint(start: 451, end: 800, name: TABLET),
          const Breakpoint(start: 801, end: 1920, name: DESKTOP),
          const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
        ],
      ),
    );
  }
}

// Giữ lại MainNavigation để đảm bảo app chạy được ngay
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final Map<String, Map<String, dynamic>> _cart = {};

  void _updateCart(String id, Map<String, dynamic> data, int qtyChange) {
    setState(() {
      if (_cart.containsKey(id)) {
        final newQty = _cart[id]!['qty'] + qtyChange;
        if (newQty <= 0) _cart.remove(id); else _cart[id]!['qty'] = newQty;
      } else if (qtyChange > 0) {
        _cart[id] = {
          'name': data['name'],
          'price': num.tryParse(data['price']?.toString() ?? '0') ?? 0,
          'qty': 1,
          'image': data['image'] ?? data['imageUrl'] ?? '',
        };
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      ShopHomeScreen(onAdd: (id, data) => _updateCart(id, data, 1)),
      CartScreen(cart: _cart, onUpdate: _updateCart, onClear: () => setState(() => _cart.clear())),
      const OrderHistoryScreen(),
    ];

    bool isWeb = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      extendBody: true,
      body: Row(
        children: [
          if (isWeb) _buildSideNavigation(),
          Expanded(child: IndexedStack(index: _currentIndex, children: screens)),
        ],
      ),
      bottomNavigationBar: isWeb ? null : _LuxuryBottomBar(
        currentIndex: _currentIndex,
        cartCount: _cart.values.fold(0, (sum, item) => sum + (item['qty'] as int)),
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }

  Widget _buildSideNavigation() {
    return Container(
      width: 100,
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Icon(Icons.spa_rounded, color: AppTheme.primaryTeal, size: 40),
          const Spacer(),
          _SideNavItem(icon: Icons.dashboard_rounded, isSelected: _currentIndex == 0, onTap: () => setState(() => _currentIndex = 0)),
          _SideNavItem(icon: Icons.shopping_bag_rounded, isSelected: _currentIndex == 1, onTap: () => setState(() => _currentIndex = 1)),
          _SideNavItem(icon: Icons.person_rounded, isSelected: _currentIndex == 2, onTap: () => setState(() => _currentIndex = 2)),
          const Spacer(),
          IconButton(onPressed: () => FirebaseAuth.instance.signOut(), icon: const Icon(Icons.logout_rounded, color: Colors.grey)),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _SideNavItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  const _SideNavItem({required this.icon, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: IconButton(
        icon: Icon(icon, color: isSelected ? AppTheme.primaryTeal : Colors.grey[400], size: 28),
        onPressed: onTap,
      ),
    );
  }
}

class _LuxuryBottomBar extends StatelessWidget {
  final int currentIndex;
  final int cartCount;
  final ValueChanged<int> onTap;
  const _LuxuryBottomBar({required this.currentIndex, required this.cartCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 25),
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 30, offset: const Offset(0, 10))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: onTap,
          backgroundColor: Colors.white,
          indicatorColor: AppTheme.primaryTeal.withValues(alpha: 0.1),
          destinations: [
            const NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard_rounded, color: AppTheme.primaryTeal), label: "Home"),
            NavigationDestination(icon: Badge(label: Text("$cartCount"), child: const Icon(Icons.shopping_bag_outlined)), label: "Cart"),
            const NavigationDestination(icon: Icon(Icons.person_outline), label: "Profile"),
          ],
        ),
      ),
    );
  }
}
