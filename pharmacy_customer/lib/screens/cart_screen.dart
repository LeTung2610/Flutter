import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CartScreen extends StatelessWidget {
  final Map<String, Map<String, dynamic>> cart;
  final Function(String, Map<String, dynamic>, int) onUpdate;
  final VoidCallback onClear;

  const CartScreen({
    super.key,
    required this.cart,
    required this.onUpdate,
    required this.onClear,
  });

  static const Color primaryTeal = Color(0xFF00796B);
  static const Color softTeal = Color(0xFFE0F2F1);
  static const Color softBg = Color(0xFFFDFCFB);

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat("#,###", "vi_VN");
    num total = cart.values.fold(0, (sum, item) => sum + (item['price'] * item['qty']));

    return Scaffold(
      backgroundColor: softBg,
      appBar: AppBar(
        title: const Text("Giỏ Hàng"),
        actions: [
          if (cart.isNotEmpty)
            IconButton(
              onPressed: () => _confirmClear(context),
              icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: cart.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    itemCount: cart.length,
                    itemBuilder: (context, i) {
                      String id = cart.keys.elementAt(i);
                      var item = cart[id]!;
                      return _buildCartItem(id, item, fmt);
                    },
                  ),
                ),
                _buildCheckoutSection(context, total, fmt),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: softTeal.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shopping_basket_outlined, size: 80, color: primaryTeal),
          ),
          const SizedBox(height: 24),
          const Text(
            "Giỏ hàng của bạn đang trống",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 12),
          const Text(
            "Khám phá ngay hàng ngàn sản phẩm\nchăm sóc sức khỏe tại NeelMilk",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(String id, Map<String, dynamic> item, NumberFormat fmt) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 85,
              height: 85,
              color: softTeal.withValues(alpha: 0.3),
              child: item['image'] != null && item['image'] != ''
                  ? Image.network(item['image'], fit: BoxFit.cover)
                  : const Icon(Icons.medication, color: primaryTeal, size: 35),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF1A1A1A)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  "${fmt.format(item['price'])}đ",
                  style: const TextStyle(color: primaryTeal, fontWeight: FontWeight.w900, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _qtyBtn(Icons.remove, () => onUpdate(id, {}, -1)),
                    Container(
                      constraints: const BoxConstraints(minWidth: 40),
                      alignment: Alignment.center,
                      child: Text(
                        "${item['qty']}",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                      ),
                    ),
                    _qtyBtn(Icons.add, () => onUpdate(id, {}, 1)),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => onUpdate(id, {}, -item['qty'] as int),
            icon: Icon(Icons.delete_outline_rounded, color: Colors.red[300], size: 20),
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback tap) {
    return GestureDetector(
      onTap: tap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: softTeal,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: primaryTeal),
      ),
    );
  }

  Widget _buildCheckoutSection(BuildContext context, num total, NumberFormat fmt) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Tổng cộng",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black54),
                ),
                Text(
                  "${fmt.format(total)}đ",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: primaryTeal),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () => _checkout(context, total),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryTeal,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text(
                  "THANH TOÁN NGAY",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text("Xóa giỏ hàng?"),
        content: const Text("Bạn có chắc chắn muốn xóa tất cả sản phẩm trong giỏ hàng không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("HỦY")),
          TextButton(
            onPressed: () {
              onClear();
              Navigator.pop(c);
            },
            child: const Text("XÓA TẤT CẢ", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _checkout(BuildContext context, num total) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator(color: primaryTeal)),
    );

    try {
      List<Map<String, dynamic>> itemsList = cart.entries.map((e) => {
        'id': e.key,
        'name': e.value['name'],
        'price': e.value['price'],
        'qty': e.value['qty'],
        'image': e.value['image'],
      }).toList();

      await FirebaseFirestore.instance.collection('orders').add({
        'userId': user.email,
        'totalPrice': total,
        'status': 'Chờ Duyệt',
        'createdAt': FieldValue.serverTimestamp(),
        'items': itemsList,
      });

      if (context.mounted) {
        Navigator.pop(context); // Close loading
        onClear();
        _showSuccessDialog(context);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.check_circle_rounded, color: primaryTeal, size: 80),
            const SizedBox(height: 24),
            const Text(
              "Đặt hàng thành công!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            const Text(
              "Đơn hàng của bạn đang được xử lý.\nCảm ơn bạn đã tin tưởng NeelMilk!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, height: 1.4),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(c),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryTeal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("TIẾP TỤC MUA SẮM", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
