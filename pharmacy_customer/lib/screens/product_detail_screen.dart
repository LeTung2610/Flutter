import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../theme/app_theme.dart';
import 'dart:ui';
import 'dart:math' as math;

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  final String docId;
  final Function(String, Map<String, dynamic>) onAdd;

  const ProductDetailScreen({
    super.key,
    required this.data,
    required this.docId,
    required this.onAdd,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;
  final fmt = NumberFormat("#,###", "vi_VN");
  int _selectedImageIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;
    final stock = int.tryParse(widget.data['stock']?.toString() ?? '0') ?? 0;
    final price = num.tryParse(widget.data['price']?.toString() ?? '0') ?? 0;
    final imageUrl = widget.data['imageUrl'] ?? widget.data['image'] ?? '';

    return Scaffold(
      backgroundColor: AppTheme.softBg,
      body: Stack(
        children: [
          _buildBackgroundEffects(size),
          
          CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? size.width * 0.1 : 24,
                    vertical: 40,
                  ),
                  child: isDesktop 
                    ? _buildDesktopLayout(imageUrl, price, stock)
                    : _buildMobileLayout(imageUrl, price, stock),
                ),
              ),
              _buildRelatedProductsSection(isDesktop),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundEffects(Size size) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0.8, -0.6),
          radius: 1.2,
          colors: [Color(0xFFE0F7F6), AppTheme.softBg],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.white,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppTheme.darkTeal),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      actions: [
        CircleAvatar(
          backgroundColor: Colors.white,
          child: IconButton(
            icon: const Icon(Icons.favorite_border_rounded, size: 20, color: AppTheme.darkTeal),
            onPressed: () {},
          ),
        ),
        const SizedBox(width: 16),
        CircleAvatar(
          backgroundColor: Colors.white,
          child: IconButton(
            icon: const Icon(Icons.share_outlined, size: 20, color: AppTheme.darkTeal),
            onPressed: () {},
          ),
        ),
        const SizedBox(width: 24),
      ],
    );
  }

  Widget _buildDesktopLayout(String imageUrl, num price, int stock) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Interactive Gallery
        Expanded(
          flex: 6,
          child: Column(
            children: [
              _buildMainImage(imageUrl, stock),
              const SizedBox(height: 24),
              _buildThumbnails(imageUrl),
            ],
          ),
        ),
        const SizedBox(width: 80),
        // Right Column: Product Info
        Expanded(
          flex: 4,
          child: _buildProductInfo(price, stock),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(String imageUrl, num price, int stock) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMainImage(imageUrl, stock),
        const SizedBox(height: 32),
        _buildProductInfo(price, stock),
      ],
    );
  }

  Widget _buildMainImage(String imageUrl, int stock) {
    return Hero(
      tag: 'prod_${widget.docId}',
      child: Container(
        height: 500,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 40)],
        ),
        child: Stack(
          children: [
            Center(
              child: imageUrl.isNotEmpty
                  ? Image.network(imageUrl, fit: BoxFit.contain)
                  : const Icon(Icons.medication_rounded, size: 150, color: AppTheme.softTeal),
            ),
            if (stock == 0)
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text("HẾT HÀNG", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnails(String imageUrl) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return GestureDetector(
          onTap: () => setState(() => _selectedImageIndex = index),
          child: Container(
            width: 80,
            height: 80,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _selectedImageIndex == index ? AppTheme.primaryTeal : Colors.transparent,
                width: 2,
              ),
            ),
            child: imageUrl.isNotEmpty 
              ? Opacity(opacity: 0.5 + (index == _selectedImageIndex ? 0.5 : 0), child: Image.network(imageUrl, fit: BoxFit.scaleDown))
              : const Icon(Icons.image, color: Colors.grey),
          ),
        );
      }),
    );
  }

  Widget _buildProductInfo(num price, int stock) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBadge(widget.data['category'] ?? "PREMIUM"),
        const SizedBox(height: 24),
        Text(
          widget.data['name'] ?? "Sản phẩm cao cấp",
          style: GoogleFonts.playfairDisplay(
            fontSize: 48,
            fontWeight: FontWeight.w900,
            color: AppTheme.darkTeal,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const Icon(Icons.star_rounded, color: Colors.orange, size: 24),
            const SizedBox(width: 8),
            const Text("4.9", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            const SizedBox(width: 8),
            Text("(120 đánh giá)", style: TextStyle(color: Colors.grey[500])),
          ],
        ),
        const SizedBox(height: 32),
        Text(
          "${fmt.format(price)}đ",
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w900,
            color: AppTheme.primaryTeal,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 40),
        const Text(
          "Mô tả sản phẩm",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppTheme.darkTeal),
        ),
        const SizedBox(height: 16),
        Text(
          widget.data['description'] ?? "Chiết xuất từ những thành phần tinh túy nhất, sản phẩm mang lại hiệu quả vượt trội trong việc chăm sóc sức khỏe toàn diện. Đạt chuẩn GMP quốc tế.",
          style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.8),
        ),
        const SizedBox(height: 48),
        _buildTrustBadges(),
        const SizedBox(height: 48),
        _buildPurchaseSection(stock),
      ],
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFFE0F2F1), borderRadius: BorderRadius.circular(10)),
      child: Text(text.toUpperCase(), style: const TextStyle(color: AppTheme.deepTeal, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5)),
    );
  }

  Widget _buildTrustBadges() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _trustItem(Icons.verified_user_rounded, "Chính hãng"),
        _trustItem(Icons.local_shipping_rounded, "Giao nhanh 2h"),
        _trustItem(Icons.support_agent_rounded, "Dược sĩ tư vấn"),
      ],
    );
  }

  Widget _trustItem(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryTeal, size: 28),
        const SizedBox(height: 8),
        Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.darkTeal)),
      ],
    );
  }

  Widget _buildPurchaseSection(int stock) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
          child: Row(
            children: [
              _qtyBtn(Icons.remove, () => setState(() => quantity = math.max(1, quantity - 1))),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Text("$quantity", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900))),
              _qtyBtn(Icons.add, () => setState(() => quantity = math.min(stock, quantity + 1))),
            ],
          ),
        ),
        const SizedBox(width: 32),
        Expanded(
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppTheme.primaryTeal, AppTheme.deepTeal]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: AppTheme.primaryTeal.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: ElevatedButton(
              onPressed: stock > 0 ? () {
                for(int i=0; i<quantity; i++) {
                  widget.onAdd(widget.docId, widget.data);
                }
                _showSuccess();
              } : null,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, foregroundColor: Colors.white),
              child: const Text("THÊM VÀO GIỎ HÀNG", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return IconButton(onPressed: onTap, icon: Icon(icon, size: 20, color: AppTheme.darkTeal));
  }

  Widget _buildRelatedProductsSection(bool isDesktop) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isDesktop ? MediaQuery.of(context).size.width * 0.1 : 24, vertical: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Sản phẩm tương tự", style: GoogleFonts.playfairDisplay(fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.darkTeal)),
            const SizedBox(height: 40),
            SizedBox(
              height: 350,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: 5,
                itemBuilder: (context, i) => _buildSmallProductCard(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallProductCard() {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(color: Color(0xFFF1F8F8), borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
              child: const Center(child: Icon(Icons.medication_rounded, color: AppTheme.primaryTeal, size: 50)),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Sản phẩm bổ sung", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                SizedBox(height: 8),
                Text("450.000đ", style: TextStyle(color: AppTheme.primaryTeal, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Đã thêm vào giỏ hàng thành công!", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.deepTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
