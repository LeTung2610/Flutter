import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});
  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  List<Map<String, dynamic>> cart = [];
  int total = 0;
  String searchQuery = "";
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  DateTime? _parseExpiryDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  bool _isExpired(DateTime? expiryDate) {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate);
  }

  void addToCart(Map<String, dynamic> med, String id) {
    int stock = int.tryParse(med['stock']?.toString() ?? '0') ?? 0;
    int idx = cart.indexWhere((item) => item['id'] == id);

    if (idx >= 0) {
      if (cart[idx]['qty'] < stock) {
        setState(() => cart[idx]['qty']++);
      }
    } else {
      if (stock > 0) {
        setState(() {
          cart.add({
            'id': id,
            'name': med['name'],
            'price': int.tryParse(med['price']?.toString() ?? '0') ?? 0,
            'qty': 1,
          });
        });
      }
    }
    _calculateTotal();
  }

  void _calculateTotal() {
    total = cart.fold(0, (sum, item) => sum + (item['price'] as int) * (item['qty'] as int));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final moneyFmt = NumberFormat('#,###', 'vi_VN');

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Row(
        children: [
          // DANH SÁCH SẢN PHẨM (MÀN CHÍNH)
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 25),
                  _buildSearchBar(),
                  const SizedBox(height: 25),
                  Expanded(child: _buildProductGrid()),
                ],
              ),
            ),
          ),

          // GIỎ HÀNG (SIDEBAR GLASS)
          _buildCartSidebar(moneyFmt),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "HỆ THỐNG POS TẠI QUẦY",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1A202C), letterSpacing: 1),
        ),
        Text("NeelMilk Pharmacy Terminal - Ready for service", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)],
      ),
      child: TextField(
        onChanged: (v) => setState(() => searchQuery = v.toLowerCase()),
        decoration: InputDecoration(
          hintText: "Tìm kiếm thuốc hoặc quét mã vạch...",
          prefixIcon: const Icon(Icons.search, color: Color(0xFF00D4C4)),
          suffixIcon: const Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF00D4C4)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        ),
      ),
    );
  }

  Widget _buildProductGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('medicines').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        var docs = snapshot.data!.docs.where((d) => d['name'].toString().toLowerCase().contains(searchQuery)).toList();

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.82,
            crossAxisSpacing: 25,
            mainAxisSpacing: 25,
          ),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var data = docs[index].data() as Map<String, dynamic>;
            var id = docs[index].id;
            return _buildProductCard(data, id);
          },
        );
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> data, String id) {
    return GestureDetector(
      onTap: () => addToCart(data, id),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 10))],
        ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(25),
                      image: data['imageUrl'] != null ? DecorationImage(image: NetworkImage(data['imageUrl']), fit: BoxFit.cover) : null,
                    ),
                  ),
                  Positioned(top: 25, right: 25, child: _buildStockBadge(data['stock'])),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(data['name'] ?? "", style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16), textAlign: TextAlign.center, maxLines: 1),
                  const SizedBox(height: 5),
                  Text("₫${NumberFormat('#,###').format(data['price'])}", style: const TextStyle(color: Color(0xFF00D4C4), fontWeight: FontWeight.w900, fontSize: 18)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockBadge(dynamic stock) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)]),
      child: Text("Kho: $stock", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
    );
  }

  Widget _buildCartSidebar(NumberFormat fmt) {
    return Container(
      width: 450,
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Padding(
            padding: const EdgeInsets.all(35),
            child: Column(
              children: [
                const Row(
                  children: [
                    Icon(Icons.shopping_bag_outlined, color: Color(0xFF00D4C4), size: 30),
                    SizedBox(width: 15),
                    Text("GIỎ HÀNG", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ],
                ),
                const SizedBox(height: 30),
                Expanded(child: _buildCartItems()),
                const SizedBox(height: 30),
                _buildTotalSection(fmt),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCartItems() {
    return ListView.separated(
      itemCount: cart.length,
      separatorBuilder: (_, __) => const SizedBox(height: 15),
      itemBuilder: (context, index) {
        var item = cart[index];
        return Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(20)),
          child: Row(
            children: [
              Container(width: 50, height: 50, decoration: BoxDecoration(color: const Color(0xFF00D4C4).withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.medication_liquid, color: Color(0xFF00D4C4))),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text("₫${NumberFormat('#,###').format(item['price'])} x ${item['qty']}", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  ],
                ),
              ),
              IconButton(onPressed: () => setState(() => cart.removeAt(index)), icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTotalSection(NumberFormat fmt) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("TỔNG CỘNG", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            Text("₫${fmt.format(total)}", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1A202C))),
          ],
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 70,
          child: ElevatedButton(
            onPressed: cart.isEmpty ? null : _handleCheckout,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D4C4),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 10,
              shadowColor: const Color(0xFF00D4C4).withOpacity(0.4),
            ),
            child: const Text("THANH TOÁN NGAY", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          ),
        )
      ],
    );
  }

  void _handleCheckout() async {
    await FirebaseFirestore.instance.collection('invoices').add({
      'totalPrice': total,
      'items': cart,
      'timestamp': FieldValue.serverTimestamp(),
      'type': 'pos'
    });
    setState(() {
      cart.clear();
      total = 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Thanh toán thành công!"), backgroundColor: Color(0xFF00D4C4)));
  }
}
