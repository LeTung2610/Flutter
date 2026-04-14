import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});
  @override State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  List cart = [];
  int total = 0;
  String searchQuery = "";

  void addToCart(Map med, String id) {
    int stock = int.tryParse(med['stock']?.toString() ?? '0') ?? 0;
    int idx = cart.indexWhere((i) => i['id'] == id);
    int currentQtyInCart = idx >= 0 ? cart[idx]['qty'] : 0;

    if (stock <= currentQtyInCart) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Không đủ tồn kho hoặc đã hết hàng"),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 1),
      ));
      return;
    }

    setState(() {
      int price = int.tryParse(med['price']?.toString() ?? '0') ?? 0;
      if (idx >= 0) {
        cart[idx]['qty']++;
      } else {
        cart.add({'id': id, 'name': med['name'], 'price': price, 'qty': 1, 'maxStock': stock});
      }
      total = cart.fold(0, (prev, item) => prev + (item['price'] as int) * (item['qty'] as int));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Tìm kiếm tên thuốc...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                  onChanged: (v) => setState(() => searchQuery = v.toLowerCase()),
                ),
              ),
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance.collection('medicines').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    var docs = snapshot.data!.docs.where((d) => d.data()['name'].toString().toLowerCase().contains(searchQuery)).toList();
                    
                    if (docs.isEmpty) return const Center(child: Text("Không tìm thấy sản phẩm"));

                    double screenWidth = MediaQuery.of(context).size.width;
                    int crossAxisCount = screenWidth > 1600 ? 5 : (screenWidth > 1200 ? 4 : (screenWidth > 900 ? 3 : 2));

                    return GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                      ),
                      itemCount: docs.length,
                      itemBuilder: (context, i) {
                        var data = docs[i].data();
                        int price = int.tryParse(data['price']?.toString() ?? '0') ?? 0;
                        int stock = int.tryParse(data['stock']?.toString() ?? '0') ?? 0;
                        
                        return Card(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => addToCart(data, docs[i].id),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 80, height: 80,
                                    decoration: BoxDecoration(color: Colors.cyan[50], shape: BoxShape.circle),
                                    child: data['imageUrl'] != null && data['imageUrl'].toString().isNotEmpty
                                      ? ClipOval(child: Image.network(data['imageUrl'], fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.broken_image, color: Colors.grey)))
                                      : const Icon(Icons.medication, color: Colors.cyan, size: 30),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(data['name'], textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 8),
                                  Text("$priceđ", style: const TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text("Kho: $stock", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
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
        Container(
          width: 400,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(-5, 0))],
          ),
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.shopping_cart_checkout, color: Colors.cyan),
                  SizedBox(width: 12),
                  Text("GIỎ HÀNG TẠI QUẦY", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 32),
              Expanded(
                child: cart.isEmpty 
                  ? Center(child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_basket_outlined, size: 80, color: Colors.grey[200]),
                        const SizedBox(height: 16),
                        Text("Chưa có sản phẩm", style: TextStyle(color: Colors.grey[400])),
                      ],
                    ))
                  : ListView.separated(
                      itemCount: cart.length,
                      separatorBuilder: (c, i) => const Divider(height: 40),
                      itemBuilder: (context, i) => Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(cart[i]['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                const SizedBox(height: 4),
                                Text("${cart[i]['price']}đ", style: TextStyle(color: Colors.cyan, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
                                onPressed: () => setState(() {
                                  if (cart[i]['qty'] > 1) cart[i]['qty']--;
                                  else cart.removeAt(i);
                                  total = cart.fold(0, (prev, item) => prev + (item['price'] as int) * (item['qty'] as int));
                                }),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Text("${cart[i]['qty']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, color: Colors.cyan),
                                onPressed: () {
                                  addToCart({'name': cart[i]['name'], 'price': cart[i]['price'], 'stock': cart[i]['maxStock']}, cart[i]['id']);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
              ),
              const Divider(height: 64),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("TỔNG CỘNG:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("$total VNĐ", style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: cart.isEmpty ? null : () async {
                    try {
                      WriteBatch batch = FirebaseFirestore.instance.batch();
                      for (var item in cart) {
                        DocumentReference ref = FirebaseFirestore.instance.collection('medicines').doc(item['id']);
                        batch.update(ref, {'stock': FieldValue.increment(-(item['qty'] as int))});
                      }
                      DocumentReference invRef = FirebaseFirestore.instance.collection('invoices').doc();
                      batch.set(invRef, {
                        'totalPrice': total,
                        'items': cart,
                        'timestamp': FieldValue.serverTimestamp()
                      });
                      await batch.commit();
                      setState(() { cart = []; total = 0; });
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Thanh toán & Xuất hóa đơn thành công!"), backgroundColor: Colors.green));
                    } catch (e) {
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan, 
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text("THANH TOÁN NGAY", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
