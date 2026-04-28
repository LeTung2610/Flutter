import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String searchQuery = "";

  void _showAddProductDialog(BuildContext context) {
    final name = TextEditingController(), cat = TextEditingController(), price = TextEditingController(), stock = TextEditingController(), img = TextEditingController();
    showDialog(context: context, builder: (context) => AlertDialog(
      title: const Text("Thêm Sản Phẩm Mới"),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: "Tên thuốc", prefixIcon: Icon(Icons.medication))),
          const SizedBox(height: 12),
          TextField(controller: cat, decoration: const InputDecoration(labelText: "Danh mục", prefixIcon: Icon(Icons.category))),
          const SizedBox(height: 12),
          TextField(controller: price, decoration: const InputDecoration(labelText: "Giá bán", prefixIcon: Icon(Icons.attach_money)), keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          TextField(controller: stock, decoration: const InputDecoration(labelText: "Số lượng tồn kho", prefixIcon: Icon(Icons.storage)), keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          TextField(controller: img, decoration: const InputDecoration(labelText: "Link ảnh (URL)", prefixIcon: Icon(Icons.image))),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
        ElevatedButton(
          onPressed: () {
            FirebaseFirestore.instance.collection('medicines').add({
              'name': name.text,
              'category': cat.text,
              'price': int.tryParse(price.text) ?? 0,
              'stock': int.tryParse(stock.text) ?? 0,
              'imageUrl': img.text,
            });
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan, foregroundColor: Colors.white),
          child: const Text("Lưu Sản Phẩm")
        )
      ],
    ));
  }

  void _showEditProductDialog(BuildContext context, String id, Map data) {
    final name = TextEditingController(text: data['name']?.toString()), 
          cat = TextEditingController(text: data['category']?.toString()),
          price = TextEditingController(text: data['price']?.toString()), 
          stock = TextEditingController(text: data['stock']?.toString()),
          img = TextEditingController(text: data['imageUrl']?.toString());
    showDialog(context: context, builder: (context) => AlertDialog(
      title: const Text("Chỉnh Sửa Sản Phẩm"),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: "Tên thuốc", prefixIcon: Icon(Icons.medication))),
          const SizedBox(height: 12),
          TextField(controller: cat, decoration: const InputDecoration(labelText: "Danh mục", prefixIcon: Icon(Icons.category))),
          const SizedBox(height: 12),
          TextField(controller: price, decoration: const InputDecoration(labelText: "Giá bán", prefixIcon: Icon(Icons.attach_money)), keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          TextField(controller: stock, decoration: const InputDecoration(labelText: "Số lượng tồn kho", prefixIcon: Icon(Icons.storage)), keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          TextField(controller: img, decoration: const InputDecoration(labelText: "Link ảnh (URL)", prefixIcon: Icon(Icons.image))),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
        ElevatedButton(
          onPressed: () {
            FirebaseFirestore.instance.collection('medicines').doc(id).update({
              'name': name.text,
              'category': cat.text,
              'price': int.tryParse(price.text) ?? 0,
              'stock': int.tryParse(stock.text) ?? 0,
              'imageUrl': img.text,
            });
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan, foregroundColor: Colors.white),
          child: const Text("Cập Nhật")
        )
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("QUẢN LÝ KHO HÀNG", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: () => _showAddProductDialog(context),
              icon: const Icon(Icons.add),
              label: const Text("Thêm thuốc"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan, foregroundColor: Colors.white),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Tìm kiếm sản phẩm trong kho...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (v) => setState(() => searchQuery = v.toLowerCase()),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('medicines').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                var docs = snapshot.data!.docs.where((d) => 
                  d.data()['name'].toString().toLowerCase().contains(searchQuery) ||
                  d.data()['category'].toString().toLowerCase().contains(searchQuery)
                ).toList();
                
                if (docs.isEmpty) return const Center(child: Text("Không tìm thấy sản phẩm"));

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var data = docs[index].data();
                    int stock = int.tryParse(data['stock']?.toString() ?? '0') ?? 0;
                    int price = int.tryParse(data['price']?.toString() ?? '0') ?? 0;
                    Color stockColor = stock < 10 ? Colors.red : Colors.green;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        leading: Container(
                          width: 50, height: 50,
                          decoration: BoxDecoration(color: Colors.cyan[50], borderRadius: BorderRadius.circular(12)),
                          child: data['imageUrl'] != null && data['imageUrl'].toString().isNotEmpty
                            ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(data['imageUrl'], fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.broken_image, color: Colors.grey)))
                            : const Icon(Icons.medication, color: Colors.cyan),
                        ),
                        title: Text(data['name']?.toString() ?? "N/A", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${data['category']} • $price VNĐ", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(width: 8, height: 8, decoration: BoxDecoration(color: stockColor, shape: BoxShape.circle)),
                                  const SizedBox(width: 8),
                                  Text("Tồn kho: $stock", style: TextStyle(color: stockColor, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                          IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.blue), onPressed: () => _showEditProductDialog(context, docs[index].id, data)),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (c) => AlertDialog(
                                  title: const Text("Xác nhận xóa"),
                                  content: Text("Bạn có chắc chắn muốn xóa thuốc '${data['name']}'?"),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(c), child: const Text("Hủy")),
                                    TextButton(
                                      onPressed: () {
                                        FirebaseFirestore.instance.collection('medicines').doc(docs[index].id).delete();
                                        Navigator.pop(c);
                                      },
                                      child: const Text("Xóa", style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ]),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
