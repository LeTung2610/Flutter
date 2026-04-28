import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProductDetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  final String docId;
  final Function(String, Map<String, dynamic>) onAdd;
  const ProductDetailScreen({super.key, required this.data, required this.docId, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat("#,###", "vi_VN");
    int stock = int.tryParse(data['stock']?.toString() ?? '0') ?? 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.teal[50]),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: 320, width: double.infinity, 
                    decoration: BoxDecoration(color: Colors.teal[50], borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40))),
                    child: (data['image'] != null && data['image'] != '') 
                      ? Hero(tag: docId, child: Image.network(data['image'], fit: BoxFit.contain))
                      : const Icon(Icons.medication_rounded, size: 100, color: Colors.teal),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data['name'] ?? '', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 10),
                        Text("${fmt.format(num.tryParse(data['price']?.toString() ?? '0') ?? 0)}đ", style: const TextStyle(fontSize: 24, color: Colors.redAccent, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(color: Colors.teal.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                          child: Text("Sẵn có: $stock sản phẩm", style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 30),
                        const Text("Mô tả sản phẩm", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Text(data['description'] ?? "Sản phẩm dược phẩm đạt chuẩn GPP, an toàn và hiệu quả cho người sử dụng. Cam kết hàng chính hãng 100%.", 
                          style: TextStyle(color: Colors.grey[700], height: 1.6)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(25),
            child: ElevatedButton(
              onPressed: stock > 0 ? () { onAdd(docId, data); Navigator.pop(context); } : null,
              child: Text(stock > 0 ? "THÊM VÀO GIỎ HÀNG" : "TẠM HẾT HÀNG"),
            ),
          )
        ],
      ),
    );
  }
}
