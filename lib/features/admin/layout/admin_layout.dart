import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/admin_nav_provider.dart';
import '../theme/admin_theme.dart';
import '../screens/dashboard_screen.dart';
import '../screens/customer_screen.dart';
import '../screens/category_screen.dart';
import '../screens/report_screen.dart';
import '../../../screens/inventory_screen.dart';
import '../../../screens/order_manager_screen.dart';
import '../../../screens/pos_screen.dart';
import '../../../screens/revenue_screen.dart';
import '../widgets/admin_common_widgets.dart';

class AdminLayout extends ConsumerWidget {
  const AdminLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(adminNavProvider);
    final isExpanded = ref.watch(adminSidebarExpandedProvider);

    final List<Widget> screens = [
      const DashboardScreen(key: ValueKey(0)),
      const InventoryScreen(key: ValueKey(1)),
      const OrderManagerScreen(key: ValueKey(2)),
      const PosScreen(key: ValueKey(3)),
      const RevenueScreen(key: ValueKey(4)),
      const CustomerScreen(key: ValueKey(5)),
      const CategoryScreen(key: ValueKey(6)),
      const ReportScreen(key: ValueKey(7)),
    ];

    return Scaffold(
      backgroundColor: AdminTheme.luxuryBlack,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isMobile = constraints.maxWidth < 900;
          if (isMobile && isExpanded) {
            Future.delayed(Duration.zero, () {
              ref.read(adminSidebarExpandedProvider.notifier).state = false;
            });
          }

          return Stack(
            children: [
              // Background Ambient Glow
              Positioned(
                top: -100,
                right: -100,
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AdminTheme.accentGold.withValues(alpha: 0.03),
                  ),
                ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.5, 1.5),
                  duration: 5.seconds,
                ),
              ),
              
              Row(
                children: [
                  if (constraints.maxWidth > 600)
                    _buildSidebar(context, ref, currentIndex, isExpanded, isMobile),
                  
                  Expanded(
                    child: Column(
                      children: [
                        _buildTopbar(context, ref, constraints.maxWidth),
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: 500.ms,
                            switchInCurve: Curves.easeInOutQuart,
                            switchOutCurve: Curves.easeInOutQuart,
                            transitionBuilder: (child, animation) => FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.02),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            ),
                            child: screens[currentIndex],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        }
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, WidgetRef ref, int currentIndex, bool isExpanded, bool isMobile) {
    double width = isExpanded ? 280 : 100;

    return AnimatedContainer(
      duration: 400.ms,
      curve: Curves.easeOutQuart,
      width: width,
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminTheme.sidebarSurface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 40,
            offset: const Offset(0, 20),
          )
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 40),
          _buildLogo(isExpanded),
          const SizedBox(height: 40),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildMenuItem(ref, 0, Icons.grid_view_rounded, "Dashboard", currentIndex, isExpanded),
                _buildMenuItem(ref, 1, Icons.inventory_2_rounded, "Inventory", currentIndex, isExpanded),
                _buildMenuItem(ref, 2, Icons.shopping_bag_rounded, "Orders", currentIndex, isExpanded),
                _buildMenuItem(ref, 3, Icons.point_of_sale_rounded, "POS System", currentIndex, isExpanded),
                _buildMenuItem(ref, 4, Icons.analytics_rounded, "Revenue", currentIndex, isExpanded),
                _buildMenuItem(ref, 5, Icons.people_alt_rounded, "Customers", currentIndex, isExpanded),
                _buildMenuItem(ref, 6, Icons.category_rounded, "Categories", currentIndex, isExpanded),
                _buildMenuItem(ref, 7, Icons.assessment_rounded, "Reports", currentIndex, isExpanded),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _buildAdminProfile(context, isExpanded),
          const SizedBox(height: 25),
        ],
      ),
    );
  }

  Widget _buildLogo(bool isExpanded) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AdminTheme.accentGold, Color(0xFFB8860B)]),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: AdminTheme.accentGold.withValues(alpha: 0.4), blurRadius: 15, spreadRadius: -2)
              ],
            ),
            child: const Icon(Icons.local_pharmacy_rounded, color: Colors.black, size: 24),
          ),
          if (isExpanded) ...[
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("NEELMILK", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white, letterSpacing: 1)),
                Text("Enterprise SaaS", style: TextStyle(fontSize: 10, color: AdminTheme.accentGold.withValues(alpha: 0.7), fontWeight: FontWeight.bold)),
              ],
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildMenuItem(WidgetRef ref, int index, IconData icon, String title, int current, bool isExpanded) {
    final isSelected = current == index;
    return GestureDetector(
      onTap: () => ref.read(adminNavProvider.notifier).state = index,
      child: AnimatedContainer(
        duration: 300.ms,
        margin: const EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.symmetric(horizontal: isExpanded ? 20 : 0, vertical: 15),
        decoration: BoxDecoration(
          color: isSelected ? AdminTheme.accentGold.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          gradient: isSelected ? LinearGradient(
            colors: [AdminTheme.accentGold.withValues(alpha: 0.15), Colors.transparent],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ) : null,
        ),
        child: Row(
          mainAxisAlignment: isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            Icon(
              icon, 
              color: isSelected ? AdminTheme.accentGold : Colors.white.withValues(alpha: 0.4), 
              size: 22
            ).animate(target: isSelected ? 1 : 0).shimmer(color: AdminTheme.accentGold.withValues(alpha: 0.4)),
            if (isExpanded) ...[
              const SizedBox(width: 18),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.5),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 14,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              if (isSelected)
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AdminTheme.accentGold, 
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: AdminTheme.accentGold.withValues(alpha: 0.8), blurRadius: 10)]
                  ),
                ).animate().scale().fadeIn(),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildTopbar(BuildContext context, WidgetRef ref, double screenWidth) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 30, 25, 10),
      child: Row(
        children: [
          _buildGlassIconButton(
            Icons.menu_open_rounded, 
            () => ref.read(adminSidebarExpandedProvider.notifier).update((s) => !s)
          ),
          const SizedBox(width: 25),
          if (screenWidth > 800)
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                height: 54,
                decoration: BoxDecoration(
                  color: AdminTheme.cardSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20)
                  ]
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded, color: Colors.white54, size: 20),
                    const SizedBox(width: 15),
                    const Expanded(
                      child: TextField(
                        style: TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: "Search Analytics, Transactions, Resources...",
                          hintStyle: TextStyle(color: Colors.white24, fontSize: 13),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text("⌘ K", style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            )
          else const Spacer(),
          const SizedBox(width: 25),
          _buildIconBadge(Icons.notifications_outlined),
          const SizedBox(width: 20),
          _buildProfileBadge(),
        ],
      ),
    );
  }

  Widget _buildGlassIconButton(IconData icon, VoidCallback onTap) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AdminTheme.cardSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AdminTheme.borderGold),
          ),
          child: Icon(icon, color: AdminTheme.accentGold, size: 20),
        ),
      ),
    );
  }

  Widget _buildIconBadge(IconData icon) {
    return Stack(
      children: [
        _buildGlassIconButton(icon, () {}),
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AdminTheme.accentGold,
              shape: BoxShape.circle,
              border: Border.all(color: AdminTheme.luxuryBlack, width: 1.5),
              boxShadow: [BoxShadow(color: AdminTheme.accentGold.withValues(alpha: 0.5), blurRadius: 4)],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileBadge() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AdminTheme.accentGold, width: 1.5),
      ),
      child: CircleAvatar(
        radius: 18,
        backgroundColor: AdminTheme.accentGold.withValues(alpha: 0.1),
        child: ClipOval(
          child: Image.network(
            "https://i.pravatar.cc/150?u=admin",
            width: 36,
            height: 36,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.person_rounded,
              color: AdminTheme.accentGold,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminProfile(BuildContext context, bool isExpanded) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: AdminButton(
        label: isExpanded ? "SIGN OUT" : "",
        icon: Icons.logout_rounded,
        isPrimary: false,
        onTap: () async => await FirebaseAuth.instance.signOut(),
      ),
    );
  }
}
