import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'product_detail_screen.dart';
import '../theme/app_theme.dart';
import 'dart:ui';
import 'dart:math' as math;

class ShopHomeScreen extends StatefulWidget {
  final Function(String, Map<String, dynamic>) onAdd;
  const ShopHomeScreen({super.key, required this.onAdd});

  @override
  State<ShopHomeScreen> createState() => _ShopHomeScreenState();
}

class _ShopHomeScreenState extends State<ShopHomeScreen> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  String searchQuery = "";
  final fmt = NumberFormat("#,###", "vi_VN");
  
  late AnimationController _parallaxController;

  @override
  void initState() {
    super.initState();
    _parallaxController = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _scrollController.addListener(() {
      if (mounted) {
        _parallaxController.value = (_scrollController.offset / 500).clamp(0, 1);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _parallaxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;

    return Scaffold(
      backgroundColor: AppTheme.softBg,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildHeroSection(size, isDesktop),
              _buildCategoriesSection(isDesktop),
              _buildProductSection(size),
              _buildFooter(isDesktop),
            ],
          ),
          _buildFloatingNavbar(isDesktop),
        ],
      ),
    );
  }

  Widget _buildFloatingNavbar(bool isDesktop) {
    return Positioned(
      top: 20,
      left: 0,
      right: 0,
      child: Center(
        child: AnimatedBuilder(
          animation: _parallaxController,
          builder: (context, child) {
            double opacity = (_parallaxController.value * 2).clamp(0, 1);
            return Opacity(
              opacity: opacity,
              child: Transform.translate(
                offset: Offset(0, -20 * (1 - opacity)),
                child: Container(
                  width: isDesktop ? 1000 : MediaQuery.of(context).size.width * 0.9,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(35),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 30)],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(35),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Row(
                          children: [
                            Text("NEELMILK", style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w900, color: AppTheme.darkTeal, fontSize: 20, letterSpacing: 2)),
                            const Spacer(),
                            if (isDesktop) ...[
                              _navItem("TRANG CHỦ"),
                              _navItem("SẢN PHẨM"),
                              _navItem("VỀ CHÚNG TÔI"),
                              _navItem("LIÊN HỆ"),
                            ],
                            const Icon(Icons.search_rounded, color: AppTheme.darkTeal),
                            const SizedBox(width: 20),
                            const Icon(Icons.shopping_bag_outlined, color: AppTheme.darkTeal),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _navItem(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.darkTeal)),
    );
  }

  Widget _buildHeroSection(Size size, bool isDesktop) {
    return SliverToBoxAdapter(
      child: Container(
        height: size.height,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.darkTeal, AppTheme.primaryTeal, AppTheme.softBg],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Floating Elements with Parallax
            AnimatedBuilder(
              animation: _parallaxController,
              builder: (context, child) {
                return Stack(
                  children: [
                    _buildParallaxIcon(Icons.spa_rounded, 0.1, 0.2, 180, 0.05, 0.2),
                    _buildParallaxIcon(Icons.medication_liquid_rounded, 0.8, 0.1, 250, 0.03, 0.1),
                    _buildParallaxIcon(Icons.healing_rounded, 0.7, 0.6, 150, 0.04, 0.3),
                    _buildParallaxIcon(Icons.biotech_rounded, 0.2, 0.8, 120, 0.03, 0.15),
                  ],
                );
              },
            ),

            // Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Sức khỏe là Kiệt tác",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: isDesktop ? 96 : 48,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "TRẢI NGHIỆM DƯỢC PHẨM CAO CẤP CHUẨN QUỐC TẾ",
                    style: TextStyle(
                      fontSize: isDesktop ? 18 : 14,
                      fontWeight: FontWeight.w300,
                      color: Colors.white.withValues(alpha: 0.8),
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 60),
                  _buildPremiumSearchBar(isDesktop),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParallaxIcon(IconData icon, double left, double top, double size, double alpha, double speed) {
    double offset = _parallaxController.value * 500 * speed;
    return Positioned(
      left: MediaQuery.of(context).size.width * left,
      top: (MediaQuery.of(context).size.height * top) - offset,
      child: Icon(icon, size: size, color: Colors.white.withValues(alpha: alpha)),
    );
  }

  Widget _buildPremiumSearchBar(bool isDesktop) {
    return Container(
      width: isDesktop ? 700 : MediaQuery.of(context).size.width * 0.85,
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 50, offset: const Offset(0, 20)),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 32),
          const Icon(Icons.search_rounded, color: AppTheme.primaryTeal, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              onChanged: (v) => setState(() => searchQuery = v.toLowerCase()),
              decoration: const InputDecoration(
                hintText: "Tìm kiếm sản phẩm chăm sóc sức khỏe...",
                border: InputBorder.none,
                hintStyle: TextStyle(fontSize: 18),
              ),
            ),
          ),
          if (isDesktop)
            Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppTheme.primaryTeal, AppTheme.deepTeal]),
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Center(child: Text("TÌM KIẾM", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection(bool isDesktop) {
    final cats = [
      {'n': 'Thuốc kê đơn', 'i': Icons.assignment_rounded, 'c': AppTheme.primaryTeal},
      {'n': 'Vitamin & TPCN', 'i': Icons.spa_rounded, 'c': Colors.orangeAccent},
      {'n': 'Chăm sóc da', 'i': Icons.face_retouching_natural_rounded, 'c': Colors.pinkAccent},
      {'n': 'Mẹ & Bé', 'i': Icons.child_care_rounded, 'c': Colors.blueAccent},
      {'n': 'Thiết bị y tế', 'i': Icons.biotech_rounded, 'c': Colors.purpleAccent},
    ];

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 100),
        child: Column(
          children: [
            Text("Danh mục chọn lọc", style: GoogleFonts.playfairDisplay(fontSize: 42, fontWeight: FontWeight.w900, color: AppTheme.darkTeal)),
            const SizedBox(height: 60),
            Center(
              child: Wrap(
                spacing: 32,
                runSpacing: 32,
                children: cats.map((cat) => _buildCategoryCard(cat, isDesktop)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> cat, bool isDesktop) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isHover = false;
        return MouseRegion(
          onEnter: (_) => setState(() => isHover = true),
          onExit: (_) => setState(() => isHover = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isDesktop ? 220 : 160,
            height: isDesktop ? 260 : 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: (cat['c'] as Color).withValues(alpha: isHover ? 0.2 : 0.05),
                  blurRadius: isHover ? 40 : 20,
                  offset: isHover ? const Offset(0, 15) : const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  scale: isHover ? 1.2 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(cat['i'] as IconData, color: cat['c'] as Color, size: 60),
                ),
                const SizedBox(height: 24),
                Text(
                  cat['n'] as String,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductSection(Size size) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('medicines').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
        
        final docs = snapshot.data!.docs.where((d) {
          final data = d.data() as Map<String, dynamic>;
          return data['name'].toString().toLowerCase().contains(searchQuery);
        }).toList();

        int crossAxisCount = ResponsiveBreakpoints.of(context).isDesktop ? 5 : (ResponsiveBreakpoints.of(context).isTablet ? 3 : 2);

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 80),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 40,
              crossAxisSpacing: 40,
              childAspectRatio: 0.75,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, i) => _buildLuxuryProductCard(docs[i].data() as Map<String, dynamic>, docs[i].id),
              childCount: docs.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildLuxuryProductCard(Map<String, dynamic> data, String id) {
    final price = num.tryParse(data['price']?.toString() ?? '0') ?? 0;
    final imageUrl = (data['imageUrl'] ?? data['image'] ?? '').toString();

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => ProductDetailScreen(data: data, docId: id, onAdd: widget.onAdd),
          transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 30, offset: const Offset(0, 15))],
        ),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                child: imageUrl.isNotEmpty
                    ? Image.network(imageUrl, fit: BoxFit.cover, width: double.infinity)
                    : const Icon(Icons.medication_rounded, size: 80, color: AppTheme.primaryTeal),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      data['name'] ?? 'Premium Medicine',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppTheme.darkTeal, height: 1.2),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${fmt.format(price)}đ", style: const TextStyle(color: AppTheme.primaryTeal, fontWeight: FontWeight.w900, fontSize: 20)),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(color: AppTheme.primaryTeal, shape: BoxShape.circle),
                          child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(bool isDesktop) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.only(top: 150),
        padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 80),
        color: AppTheme.darkTeal,
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("NEELMILK", style: GoogleFonts.playfairDisplay(fontSize: 32, color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 4)),
                      const SizedBox(height: 24),
                      const Text(
                        "Chúng tôi tin rằng sức khỏe là tài sản quý giá nhất. NeelMilk mang đến những giải pháp chăm sóc sức khỏe tinh hoa, kết hợp giữa truyền thống và công nghệ hiện đại.",
                        style: TextStyle(color: Colors.white60, height: 1.8),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (isDesktop) ...[
                  _footerLinkCol("KHÁM PHÁ", ["Sản phẩm mới", "Vitamin", "Skincare", "Combo tiết kiệm"]),
                  const SizedBox(width: 80),
                  _footerLinkCol("CHĂM SÓC", ["Hỗ trợ 24/7", "Chính sách đổi trả", "Vận chuyển", "Dược sĩ tư vấn"]),
                  const SizedBox(width: 80),
                  _footerLinkCol("LIÊN HỆ", ["Facebook", "Instagram", "LinkedIn", "Zalo"]),
                ],
              ],
            ),
            const SizedBox(height: 80),
            const Divider(color: Colors.white10),
            const SizedBox(height: 40),
            const Text("© 2026 NeelMilk Premium Pharmacy. All rights reserved.", style: TextStyle(color: Colors.white30, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _footerLinkCol(String title, List<String> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2)),
        const SizedBox(height: 24),
        ...links.map((link) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(link, style: const TextStyle(color: Colors.white60, fontSize: 14)),
        )),
      ],
    );
  }
}
