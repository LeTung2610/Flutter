import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});
  @override State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String searchQuery = "";

  String _getProxiedUrl(String url) {
    if (url.isEmpty) return "";
    return "https://images.weserv.nl/?url=${Uri.encodeComponent(url)}&default=https://via.placeholder.com/150";
  }

  Widget _buildProductImage(String? url, String category) {
    if (url != null && url.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          _getProxiedUrl(url),
          fit: BoxFit.cover,
          width: 56,
          height: 56,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholderIcon(category),
        ),
      );
    }
    return _buildPlaceholderIcon(category);
  }

  Widget _buildPlaceholderIcon(String category) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.cyan.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.medication, color: Colors.cyan, size: 28),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final catCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final stockCtrl = TextEditingController();
    final imgCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text("Thêm sản phẩm mới"),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: imgCtrl.text.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(_getProxiedUrl(imgCtrl.text), fit: BoxFit.cover),
                        )
                      : const Icon(Icons.image, size: 60, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: imgCtrl,
                  decoration: const InputDecoration(labelText: "Link ảnh (URL)"),
                  onChanged: (v) => setStateDialog(() {}),
                ),
                const SizedBox(height: 12),
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Tên thuốc")),
                const SizedBox(height: 12),
                TextField(controller: catCtrl, decoration: const InputDecoration(labelText: "Danh mục")),
                const SizedBox(height: 12),
                TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: "Giá bán"), keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                TextField(controller: stockCtrl, decoration: const InputDecoration(labelText: "Số lượng tồn kho"), keyboardType: TextInputType.number),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
            ElevatedButton(
              onPressed: () {
                FirebaseFirestore.instance.collection('medicines').add({
                  'name': nameCtrl.text,
                  'category': catCtrl.text,
                  'price': int.tryParse(priceCtrl.text) ?? 0,
                  'stock': int.tryParse(stockCtrl.text) ?? 0,
                  'imageUrl': imgCtrl.text,
                });
                Navigator.pop(context);
              },
              child: const Text("Lưu sản phẩm"),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProductDialog(BuildContext context, String id, Map<String, dynamic> data) {
    final nameCtrl = TextEditingController(text: data['name']?.toString());
    final catCtrl = TextEditingController(text: data['category']?.toString());
    final priceCtrl = TextEditingController(text: data['price']?.toString());
    final stockCtrl = TextEditingController(text: data['stock']?.toString());
    final imgCtrl = TextEditingController(text: data['imageUrl']?.toString());

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text("Chỉnh sửa sản phẩm"),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(16)),
                  child: imgCtrl.text.isNotEmpty
                      ? ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.network(_getProxiedUrl(imgCtrl.text), fit: BoxFit.cover))
                      : const Icon(Icons.image, size: 60, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                TextField(controller: imgCtrl, decoration: const InputDecoration(labelText: "Link ảnh"), onChanged: (v) => setStateDialog(() {})),
                const SizedBox(height: 12),
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Tên thuốc")),
                const SizedBox(height: 12),
                TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: "Giá bán"), keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                TextField(controller: stockCtrl, decoration: const InputDecoration(labelText: "Số lượng"), keyboardType: TextInputType.number),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
            ElevatedButton(
              onPressed: () {
                FirebaseFirestore.instance.collection('medicines').doc(id).update({
                  'name': nameCtrl.text,
                  'price': int.tryParse(priceCtrl.text) ?? 0,
                  'stock': int.tryParse(stockCtrl.text) ?? 0,
                  'imageUrl': imgCtrl.text,
                });
                Navigator.pop(context);
              },
              child: const Text("Cập nhật"),
            ),
          ],
        ),
      ),
    );
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
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Tìm kiếm thuốc...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
              onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('medicines').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                var docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return (data['name'] ?? "").toString().toLowerCase().contains(searchQuery);
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final id = docs[index].id;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        leading: _buildProductImage(data['imageUrl'], data['category'] ?? ""),
                        title: Text(data['name'] ?? "Không tên", style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("${data['price'] ?? 0}đ  •  Tồn: ${data['stock'] ?? 0}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showEditProductDialog(context, id, data),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => FirebaseFirestore.instance.collection('medicines').doc(id).delete(),
                            ),
                          ],
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
    );
  }
}