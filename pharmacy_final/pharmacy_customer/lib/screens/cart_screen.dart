import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CartScreen extends StatelessWidget {
  final Map<String, Map<String, dynamic>> cart;
  final Function(String, Map<String, dynamic>, int) onUpdate;
  final VoidCallback onClear;
  const CartScreen({super.key, required this.cart, required this.onUpdate, required this.onClear});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat("#,###", "vi_VN");
    num total = cart.values.fold(0, (sum, item) => sum + (item['price'] * item['qty']));

    return Scaffold(
      appBar: AppBar(title: const Text("Giỏ Hàng Của Bạn")),
      body: cart.isEmpty 
        ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.shopping_basket_outlined, size: 100, color: Colors.teal.withOpacity(0.2)),
            const Text("Giỏ hàng trống", style: TextStyle(color: Colors.grey, fontSize: 16)),
          ]))
        : Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: cart.length,
                  itemBuilder: (context, i) {
                    String id = cart.keys.elementAt(i);
                    var item = cart[id]!;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]),
                      child: Row(
                        children: [
                          Container(
                            width: 70, height: 70, decoration: BoxDecoration(color: Colors.teal[50], borderRadius: BorderRadius.circular(15)),
                            child: (item['image'] != null && item['image'] != '') ? Image.network(item['image']) : const Icon(Icons.medication, color: Colors.teal),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text("${fmt.format(item['price'])}đ", style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                            ]),
                          ),
                          Row(children: [
                            _qtyBtn(Icons.remove, () => onUpdate(id, {}, -1)),
                            Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text("${item['qty']}", style: const TextStyle(fontWeight: FontWeight.bold))),
                            _qtyBtn(Icons.add, () => onUpdate(id, {}, 1)),
                          ]),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(30),
                decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(40))),
                child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text("Tổng thanh toán:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      Text("${fmt.format(total)}đ", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.redAccent)),
                    ]),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => _checkout(context, total),
                      child: const Text("ĐẶT HÀNG NGAY"),
                    ),
                  ],
                ),
              )
            ],
          ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback tap) => GestureDetector(
    onTap: tap,
    child: Container(padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: Colors.teal[50], borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 18, color: Colors.teal)),
  );

  Future<void> _checkout(BuildContext context, num total) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    List<Map<String, dynamic>> itemsList = cart.entries.map((e) => {
      'id': e.key,
      'name': e.value['name'],
      'price': e.value['price'],
      'qty': e.value['qty'],
    }).toList();

    await FirebaseFirestore.instance.collection('orders').add({
      'userId': user.email,
      'totalPrice': total,
      'status': 'Chờ Duyệt',
      'createdAt': FieldValue.serverTimestamp(),
      'items': itemsList,
    });

    onClear();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đặt hàng thành công!"), backgroundColor: Colors.teal));
  }
}
