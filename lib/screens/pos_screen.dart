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
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }

  bool _isExpired(DateTime? expiryDate) {
    if (expiryDate == null) return false;
    final endOfExpiryDay = DateTime(
      expiryDate.year,
      expiryDate.month,
      expiryDate.day,
      23,
      59,
      59,
    );
    return DateTime.now().isAfter(endOfExpiryDay);
  }

  String _formatExpiryDate(DateTime? expiryDate) {
    if (expiryDate == null) return "Chưa cập nhật";
    return _dateFormat.format(expiryDate);
  }

  String _getProxiedUrl(String url) {
    if (url.isEmpty) return "";
    return "https://images.weserv.nl/?url=${Uri.encodeComponent(url)}";
  }

  void addToCart(Map<String, dynamic> med, String id) {
    int stock = int.tryParse(med['stock']?.toString() ?? '0') ?? 0;
    final expiryDate = _parseExpiryDate(med['expiryDate']);
    final isExpired = _isExpired(expiryDate);
    int idx = cart.indexWhere((item) => item['id'] == id);

    if (isExpired) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${med['name'] ?? 'Thuốc'} đã quá hạn, không thể bán."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (idx >= 0) {
      if (cart[idx]['qty'] >= stock) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Hết hàng trong kho!"),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      setState(() => cart[idx]['qty']++);
    } else {
      if (stock <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Sản phẩm hết hàng!"),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
      setState(() {
        cart.add({
          'id': id,
          'name': med['name'],
          'price': int.tryParse(med['price']?.toString() ?? '0') ?? 0,
          'qty': 1,
          'maxStock': stock,
        });
      });
    }
    _calculateTotal();
  }

  void _calculateTotal() {
    total = cart.fold(
      0,
      (sum, item) => sum + (item['price'] as int) * (item['qty'] as int),
    );
    setState(() {});
  }

  void removeFromCart(int index) {
    setState(() {
      cart.removeAt(index);
      _calculateTotal();
    });
  }

  void clearCart() {
    setState(() {
      cart.clear();
      total = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          "POS TẠI QUẦY",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Row(
        children: [
          // ==================== DANH SÁCH SẢN PHẨM ====================
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Tìm thuốc nhanh...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) =>
                        setState(() => searchQuery = value.toLowerCase()),
                  ),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('medicines')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      var docs = snapshot.data!.docs.where((doc) {
                        var data = doc.data() as Map<String, dynamic>;
                        return data['name'].toString().toLowerCase().contains(
                          searchQuery,
                        );
                      }).toList();

                      return GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          var data = docs[index].data() as Map<String, dynamic>;
                          String id = docs[index].id;
                          final expiryDate = _parseExpiryDate(
                            data['expiryDate'],
                          );
                          final isExpired = _isExpired(expiryDate);

                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: isExpired
                                  ? null
                                  : () => addToCart(data, id),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child:
                                            data['imageUrl'] != null &&
                                                data['imageUrl']
                                                    .toString()
                                                    .isNotEmpty
                                            ? Image.network(
                                                _getProxiedUrl(
                                                  data['imageUrl'],
                                                ),
                                                fit: BoxFit.cover,
                                              )
                                            : Container(
                                                color: Colors.cyan[50],
                                                child: const Icon(
                                                  Icons.medication,
                                                  color: Colors.cyan,
                                                  size: 48,
                                                ),
                                              ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      data['name'] ?? "",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${data['price'] ?? 0}đ",
                                      style: const TextStyle(
                                        color: Colors.redAccent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      "Kho: ${data['stock'] ?? 0}",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "HSD: ${_formatExpiryDate(expiryDate)}",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isExpired
                                            ? Colors.redAccent
                                            : Colors.grey[700],
                                        fontWeight: isExpired
                                            ? FontWeight.w700
                                            : FontWeight.w400,
                                      ),
                                    ),
                                    if (isExpired)
                                      Container(
                                        margin: const EdgeInsets.only(top: 6),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                        ),
                                        child: const Text(
                                          "QUÁ HẠN - KHÔNG BÁN",
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.redAccent,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // ==================== GIỎ HÀNG BÊN PHẢI ====================
          Container(
            width: 380,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(left: BorderSide(color: Colors.grey, width: 1)),
            ),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    "ĐƠN HÀNG TẠI QUẦY",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.cyan,
                    ),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: cart.isEmpty
                      ? const Center(
                          child: Text(
                            "Giỏ hàng trống",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: cart.length,
                          itemBuilder: (context, index) {
                            var item = cart[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                title: Text(
                                  item['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  "${item['price']}đ × ${item['qty']}",
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "${item['price'] * item['qty']}đ",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => removeFromCart(index),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Tổng tiền:",
                            style: TextStyle(fontSize: 18),
                          ),
                          Text(
                            "$total đ",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: cart.isEmpty
                              ? null
                              : () {
                                  // TODO: Thêm logic thanh toán thực tế sau
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Thanh toán thành công!"),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  clearCart();
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyan,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            "THANH TOÁN",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
