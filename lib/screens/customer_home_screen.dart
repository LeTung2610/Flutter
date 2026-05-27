import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final List<Map<String, dynamic>> _cart = [];
  int _currentIndex = 0;

  String _getProxiedUrl(String url) {
    if (url.isEmpty) return "";
    return "https://images.weserv.nl/?url=${Uri.encodeComponent(url)}";
  }

  void _addToCart(Map<String, dynamic> product, String id) {
    setState(() {
      final index = _cart.indexWhere((item) => item['id'] == id);
      if (index >= 0) {
        _cart[index]['quantity']++;
      } else {
        _cart.add({
          'id': id,
          'name': product['name'],
          'price': product['price'],
          'imageUrl': product['imageUrl'],
          'category': product['category'] ?? 'Dược phẩm',
          'quantity': 1,
        });
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Đã thêm ${product['name']} vào giỏ hàng"),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  double get _totalCartPrice => _cart.fold(0, (sum, item) => sum + (item['price'] as num) * (item['quantity'] as int));

  void _showCartDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Giỏ hàng của bạn", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 15),
            Expanded(
              child: _cart.isEmpty
                  ? const Center(child: Text("Giỏ hàng đang trống"))
                  : ListView.builder(
                      itemCount: _cart.length,
                      itemBuilder: (context, index) {
                        final item = _cart[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(_getProxiedUrl(item['imageUrl'] ?? ""), width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.medication)),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text("${NumberFormat("#,###").format(item['price'])}đ", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(icon: const Icon(Icons.remove_circle_outline, size: 20), onPressed: () => setState(() => item['quantity'] > 1 ? item['quantity']-- : _cart.removeAt(index))),
                                  Text("${item['quantity']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                  IconButton(icon: const Icon(Icons.add_circle_outline, size: 20), onPressed: () => setState(() => item['quantity']++)),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Tổng thanh toán:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  Text("${NumberFormat("#,###").format(_totalCartPrice)}đ", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _cart.isEmpty ? null : () => _checkout(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                child: const Text("XÁC NHẬN ĐẶT HÀNG", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkout(BuildContext context) async {
    showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.teal)));

    try {
      // Không trừ kho ở đây nữa, chỉ tạo đơn hàng
      await FirebaseFirestore.instance.collection('orders').add({
        'items': _cart,
        'totalPrice': _totalCartPrice,
        'total_price': _totalCartPrice,
        'status': 'Chờ Duyệt',
        'createdAt': FieldValue.serverTimestamp(),
        'userName': 'Khách Hàng Trực Tuyến',
        'type': 'Online',
        'stockUpdated': false, // Cờ đánh dấu chưa trừ kho
      });

      if (mounted) {
        Navigator.pop(context); // Close loading
        Navigator.pop(context); // Close cart
        setState(() => _cart.clear());
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Đơn hàng của bạn đã được gửi thành công!"), backgroundColor: Colors.teal));
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ Lỗi: $e"), backgroundColor: Colors.redAccent));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth > 1200 ? 5 : (screenWidth > 800 ? 3 : 2);
    double aspectRatio = screenWidth > 800 ? 0.8 : 0.7;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("QUÂN PHARMACY", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 16)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(icon: const Icon(Icons.shopping_cart_outlined, color: Colors.teal), onPressed: _showCartDialog),
              if (_cart.isNotEmpty)
                Positioned(
                  right: 8, top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: Text("${_cart.length}", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                )
            ],
          ),
          IconButton(icon: const Icon(Icons.account_circle_outlined, color: Colors.teal), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BANNER
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF00897B), Color(0xFF26A69A)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Ưu đãi đặc biệt hôm nay", style: TextStyle(color: Colors.white70, fontSize: 14)),
                  SizedBox(height: 8),
                  Text("Giảm giá 15% tất cả\nThực phẩm chức năng", 
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, height: 1.2)),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Sản phẩm nổi bật", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  Text("Tất cả", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('medicines').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                var docs = snapshot.data!.docs;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: aspectRatio,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var doc = docs[index];
                    var data = doc.data() as Map<String, dynamic>;
                    int stock = (data['stock'] ?? 0).toInt();

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              child: Container(
                                width: double.infinity,
                                color: Colors.grey[50],
                                child: data['imageUrl'] != null && data['imageUrl'].isNotEmpty
                                    ? Image.network(_getProxiedUrl(data['imageUrl']), fit: BoxFit.contain)
                                    : const Icon(Icons.medication, color: Colors.teal, size: 30),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(data['name'] ?? "", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 4),
                                  Text("${NumberFormat("#,###").format(data['price'] ?? 0)}đ", style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                                  const Spacer(),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 32,
                                    child: ElevatedButton(
                                      onPressed: stock > 0 ? () => _addToCart(data, doc.id) : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: stock > 0 ? const Color(0xFFE0F2F1) : Colors.grey[200],
                                        foregroundColor: stock > 0 ? Colors.teal : Colors.grey,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      child: Text(stock > 0 ? "Thêm" : "Hết hàng", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.teal,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Trang chủ"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: "Giỏ hàng"),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: "Đơn mua"),
        ],
      ),
    );
  }
}
