import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import '../config/image_upload_config.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});
  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String searchQuery = "";
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 30),
            _buildSearchBar(),
            const SizedBox(height: 30),
            _buildProductGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "QUẢN LÝ KHO HÀNG",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF1A202C), letterSpacing: 1),
            ),
            const SizedBox(height: 5),
            Text("Theo dõi và điều chỉnh danh mục dược phẩm cao cấp", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          ],
        ),
        Container(
          height: 50,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF00D4C4), Color(0xFF00A89B)]),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: const Color(0xFF00D4C4).withOpacity(0.3), blurRadius: 15)],
          ),
          child: ElevatedButton.icon(
            onPressed: () => _showProductDialog(context),
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text("THÊM THUỐC MỚI", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Tìm kiếm tên thuốc, mã sản phẩm hoặc danh mục...",
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF00D4C4)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
        onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
      ),
    );
  }

  Widget _buildProductGrid() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('medicines').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          var docs = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return (data['name'] ?? "").toString().toLowerCase().contains(searchQuery);
          }).toList();

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 350,
              mainAxisSpacing: 25,
              crossAxisSpacing: 25,
              childAspectRatio: 0.8,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final id = docs[index].id;
              return _buildProductCard(id, data);
            },
          );
        },
      ),
    );
  }

  Widget _buildProductCard(String id, Map<String, dynamic> data) {
    final expiryDate = _parseExpiryDate(data['expiryDate']);
    final isExpired = _isExpired(expiryDate);
    final price = data['price'] ?? 0;
    final stock = data['stock'] ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  child: Container(
                    width: double.infinity,
                    color: const Color(0xFFF7FAFC),
                    child: data['imageUrl'] != null && data['imageUrl'].isNotEmpty
                        ? Image.network(
                            "https://images.weserv.nl/?url=${Uri.encodeComponent(data['imageUrl'])}",
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(Icons.medication_rounded, size: 60, color: Color(0xFF00D4C4)),
                          )
                        : const Icon(Icons.medication_rounded, size: 60, color: Color(0xFF00D4C4)),
                  ),
                ),
                Positioned(top: 15, right: 15, child: _buildStatusBadge(isExpired, stock)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['name'] ?? "Sản phẩm", style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF2D3748)), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 5),
                      Text("Kho: $stock | HSD: ${_formatExpiryDate(expiryDate)}", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("₫${NumberFormat("#,###").format(price)}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF00D4C4))),
                      Row(
                        children: [
                          _buildIconButton(Icons.edit_note_rounded, Colors.blue, () => _showProductDialog(context, id: id, data: data)),
                          const SizedBox(width: 8),
                          _buildIconButton(Icons.delete_outline_rounded, Colors.redAccent, () => _confirmDelete(context, id)),
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isExpired, int stock) {
    Color color = const Color(0xFF00D4C4);
    String text = "CÒN HÀNG";
    if (isExpired) {
      color = Colors.redAccent;
      text = "QUÁ HẠN";
    } else if (stock <= 0) {
      color = Colors.orangeAccent;
      text = "HẾT HÀNG";
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withOpacity(0.9), borderRadius: BorderRadius.circular(10)),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildIconButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  // ==================== DIALOG XỬ LÝ SẢN PHẨM (IMPECCABLE) ====================
  
  void _showProductDialog(BuildContext context, {String? id, Map<String, dynamic>? data}) {
    final nameCtrl = TextEditingController(text: data?['name']);
    final catCtrl = TextEditingController(text: data?['category'] ?? 'Dược phẩm');
    final priceCtrl = TextEditingController(text: data?['price']?.toString());
    final stockCtrl = TextEditingController(text: data?['stock']?.toString());
    final imgCtrl = TextEditingController(text: data?['imageUrl']);
    final expiryCtrl = TextEditingController(text: _formatExpiryDate(_parseExpiryDate(data?['expiryDate'])));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
          title: Text(id == null ? "THÊM SẢN PHẨM MỚI" : "CHỈNH SỬA SẢN PHẨM", 
            style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2D3748))),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Image Preview Area
                  GestureDetector(
                    onTap: () => _handleUploadImage(context, imgCtrl, setStateDialog),
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7FAFC),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.grey.shade200),
                        image: imgCtrl.text.isNotEmpty 
                          ? DecorationImage(image: NetworkImage(imgCtrl.text), fit: BoxFit.contain)
                          : null,
                      ),
                      child: imgCtrl.text.isEmpty 
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_rounded, size: 50, color: Color(0xFF00D4C4)),
                              SizedBox(height: 10),
                              Text("Tải ảnh sản phẩm lên", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                            ],
                          )
                        : null,
                    ),
                  ),
                  const SizedBox(height: 25),
                  _buildDialogField(nameCtrl, "Tên thuốc / Thực phẩm chức năng", Icons.medication_rounded),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(child: _buildDialogField(priceCtrl, "Giá bán (₫)", Icons.payments_rounded, isNumber: true)),
                      const SizedBox(width: 15),
                      Expanded(child: _buildDialogField(stockCtrl, "Số lượng kho", Icons.inventory_rounded, isNumber: true)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildDialogField(expiryCtrl, "Hạn sử dụng", Icons.calendar_today_rounded, readOnly: true, onTap: () => _pickDate(context, expiryCtrl, setStateDialog)),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("HỦY BỎ", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
            const SizedBox(width: 10),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF00D4C4), Color(0xFF00A89B)]),
                borderRadius: BorderRadius.circular(15),
              ),
              child: ElevatedButton(
                onPressed: () => _saveProduct(context, id, nameCtrl, catCtrl, priceCtrl, stockCtrl, imgCtrl, expiryCtrl),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, foregroundColor: Colors.white),
                child: Text(id == null ? "LƯU SẢN PHẨM" : "CẬP NHẬT NGAY", style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogField(TextEditingController ctrl, String hint, IconData icon, {bool isNumber = false, bool readOnly = false, VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF7FAFC), borderRadius: BorderRadius.circular(15)),
      child: TextField(
        controller: ctrl,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF00D4C4), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  // --- Logic Helpers ---

  Future<void> _pickDate(BuildContext context, TextEditingController ctrl, void Function(void Function()) setStateDialog) async {
    final picked = await showDatePicker(context: context, initialDate: DateTime.now().add(const Duration(days: 365)), firstDate: DateTime.now(), lastDate: DateTime(2100));
    if (picked != null) {
      setStateDialog(() => ctrl.text = _dateFormat.format(picked));
    }
  }

  Future<void> _handleUploadImage(BuildContext context, TextEditingController imgCtrl, void Function(void Function()) setStateDialog) async {
    try {
      final picked = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
      if (picked == null) return;

      showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xFF00D4C4))));
      
      final base64Image = base64Encode(picked.files.first.bytes!);
      final response = await http.post(
        Uri.parse('https://api.imgbb.com/1/upload?key=${ImageUploadConfig.imgbbApiKey}'),
        body: {'image': base64Image},
      );

      Navigator.pop(context); // Close loading

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setStateDialog(() => imgCtrl.text = data['data']['url']);
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi tải ảnh: $e"), backgroundColor: Colors.redAccent));
    }
  }

  void _saveProduct(BuildContext context, String? id, var name, var cat, var price, var stock, var img, var expiry) {
    final expiryDate = expiry.text.isNotEmpty ? _dateFormat.parse(expiry.text) : null;
    final map = {
      'name': name.text,
      'category': cat.text,
      'price': int.tryParse(price.text) ?? 0,
      'stock': int.tryParse(stock.text) ?? 0,
      'imageUrl': img.text,
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate) : null,
    };

    if (id == null) {
      FirebaseFirestore.instance.collection('medicines').add(map);
    } else {
      FirebaseFirestore.instance.collection('medicines').doc(id).update(map);
    }
    Navigator.pop(context);
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa?"),
        content: const Text("Hành động này không thể hoàn tác."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("HỦY")),
          TextButton(onPressed: () {
            FirebaseFirestore.instance.collection('medicines').doc(id).delete();
            Navigator.pop(context);
          }, child: const Text("XÓA VĨNH VIỄN", style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
  }

  DateTime? _parseExpiryDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  bool _isExpired(DateTime? date) => date != null && date.isBefore(DateTime.now());
  String _formatExpiryDate(DateTime? date) => date != null ? _dateFormat.format(date) : "N/A";
}
