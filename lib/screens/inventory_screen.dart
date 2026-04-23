import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
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

  Future<PlatformFile?> _pickImageFromDevice() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (picked == null ||
        picked.files.isEmpty ||
        picked.files.first.bytes == null) {
      return null;
    }
    return picked.files.first;
  }

  Future<String> _uploadImageToImgBb(Uint8List fileBytes) async {
    if (!ImageUploadConfig.isConfigured) {
      throw Exception(
        'ImgBB API key chưa được cấu hình. Vui lòng nhập key vào lib/config/image_upload_config.dart',
      );
    }

    final base64Image = base64Encode(fileBytes);
    final uri = Uri.parse(
      'https://api.imgbb.com/1/upload?key=${ImageUploadConfig.imgbbApiKey}',
    );

    final response = await http
        .post(uri, body: {'image': base64Image})
        .timeout(
          const Duration(seconds: 30),
          onTimeout: () =>
              throw TimeoutException('Upload bị timeout sau 30 giây'),
        );

    if (response.statusCode != 200) {
      throw Exception(
        'ImgBB API trả lỗi: HTTP ${response.statusCode} - ${response.body}',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>?;
    if (body?['success'] != true) {
      throw Exception(
        'ImgBB upload thất bại: ${body?['error']?['message'] ?? "Không xác định"}',
      );
    }

    final imageUrl = body?['data']?['url']?.toString();
    if (imageUrl == null || imageUrl.isEmpty) {
      throw Exception('Không lấy được URL ảnh từ ImgBB');
    }

    return imageUrl;
  }

  void _closeLoadingDialog(BuildContext context) {
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  Future<void> _handleUploadImage(
    BuildContext context,
    TextEditingController imgCtrl,
    void Function(void Function()) setStateDialog,
  ) async {
    bool loadingShown = false;
    try {
      final pickedFile = await _pickImageFromDevice();
      if (pickedFile == null) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      loadingShown = true;

      final imageUrl = await _uploadImageToImgBb(pickedFile.bytes!);
      if (mounted && loadingShown) _closeLoadingDialog(context);
      loadingShown = false;

      setStateDialog(() {
        imgCtrl.text = imageUrl;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tải ảnh lên thành công"),
          backgroundColor: Colors.green,
        ),
      );
    } on TimeoutException {
      if (mounted && loadingShown) _closeLoadingDialog(context);
      loadingShown = false;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Upload bị timeout. Kiểm tra mạng hoặc ImgBB API."),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      if (mounted && loadingShown) _closeLoadingDialog(context);
      loadingShown = false;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Upload ảnh thất bại: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

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

  Future<void> _pickExpiryDate(
    BuildContext context,
    TextEditingController expiryCtrl,
    void Function(void Function()) setStateDialog,
  ) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (selected != null) {
      setStateDialog(() {
        expiryCtrl.text = _dateFormat.format(selected);
      });
    }
  }

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
          errorBuilder: (context, error, stackTrace) =>
              _buildPlaceholderIcon(category),
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
    final expiryCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text("Thêm sản phẩm mới"),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
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
                          child: Image.network(
                            _getProxiedUrl(imgCtrl.text),
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(Icons.image, size: 60, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: imgCtrl,
                  decoration: const InputDecoration(
                    labelText: "Link ảnh (URL)",
                  ),
                  onChanged: (v) => setStateDialog(() {}),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _handleUploadImage(context, imgCtrl, setStateDialog),
                    icon: const Icon(Icons.upload_file),
                    label: const Text("Tải ảnh từ máy"),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: "Tên thuốc"),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: catCtrl,
                  decoration: const InputDecoration(labelText: "Danh mục"),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceCtrl,
                  decoration: const InputDecoration(labelText: "Giá bán"),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: stockCtrl,
                  decoration: const InputDecoration(
                    labelText: "Số lượng tồn kho",
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: expiryCtrl,
                  readOnly: true,
                  onTap: () =>
                      _pickExpiryDate(context, expiryCtrl, setStateDialog),
                  decoration: InputDecoration(
                    labelText: "Hạn sử dụng",
                    hintText: "Chọn ngày hết hạn",
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_month),
                      onPressed: () =>
                          _pickExpiryDate(context, expiryCtrl, setStateDialog),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () {
                DateTime? expiryDate;
                if (expiryCtrl.text.isNotEmpty) {
                  expiryDate = _dateFormat.parseStrict(expiryCtrl.text);
                }

                FirebaseFirestore.instance.collection('medicines').add({
                  'name': nameCtrl.text,
                  'category': catCtrl.text,
                  'price': int.tryParse(priceCtrl.text) ?? 0,
                  'stock': int.tryParse(stockCtrl.text) ?? 0,
                  'imageUrl': imgCtrl.text,
                  'expiryDate': expiryDate != null
                      ? Timestamp.fromDate(expiryDate)
                      : null,
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

  void _showEditProductDialog(
    BuildContext context,
    String id,
    Map<String, dynamic> data,
  ) {
    final nameCtrl = TextEditingController(text: data['name']?.toString());
    final catCtrl = TextEditingController(text: data['category']?.toString());
    final priceCtrl = TextEditingController(text: data['price']?.toString());
    final stockCtrl = TextEditingController(text: data['stock']?.toString());
    final imgCtrl = TextEditingController(text: data['imageUrl']?.toString());
    final existingExpiry = _parseExpiryDate(data['expiryDate']);
    final expiryCtrl = TextEditingController(
      text: _formatExpiryDate(existingExpiry),
    );

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text("Chỉnh sửa sản phẩm"),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
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
                          child: Image.network(
                            _getProxiedUrl(imgCtrl.text),
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(Icons.image, size: 60, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: imgCtrl,
                  decoration: const InputDecoration(labelText: "Link ảnh"),
                  onChanged: (v) => setStateDialog(() {}),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _handleUploadImage(context, imgCtrl, setStateDialog),
                    icon: const Icon(Icons.upload_file),
                    label: const Text("Tải ảnh từ máy"),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: "Tên thuốc"),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceCtrl,
                  decoration: const InputDecoration(labelText: "Giá bán"),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: stockCtrl,
                  decoration: const InputDecoration(labelText: "Số lượng"),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: expiryCtrl,
                  readOnly: true,
                  onTap: () =>
                      _pickExpiryDate(context, expiryCtrl, setStateDialog),
                  decoration: InputDecoration(
                    labelText: "Hạn sử dụng",
                    hintText: "Chọn ngày hết hạn",
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_month),
                      onPressed: () =>
                          _pickExpiryDate(context, expiryCtrl, setStateDialog),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () {
                DateTime? expiryDate;
                if (expiryCtrl.text.isNotEmpty) {
                  expiryDate = _dateFormat.parseStrict(expiryCtrl.text);
                }

                FirebaseFirestore.instance
                    .collection('medicines')
                    .doc(id)
                    .update({
                      'name': nameCtrl.text,
                      'price': int.tryParse(priceCtrl.text) ?? 0,
                      'stock': int.tryParse(stockCtrl.text) ?? 0,
                      'imageUrl': imgCtrl.text,
                      'expiryDate': expiryDate != null
                          ? Timestamp.fromDate(expiryDate)
                          : null,
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
        title: const Text(
          "QUẢN LÝ KHO HÀNG",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: () => _showAddProductDialog(context),
              icon: const Icon(Icons.add),
              label: const Text("Thêm thuốc"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan,
                foregroundColor: Colors.white,
              ),
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
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());

                var docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return (data['name'] ?? "").toString().toLowerCase().contains(
                    searchQuery,
                  );
                }).toList();

                final expiredCount = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return _isExpired(_parseExpiryDate(data['expiryDate']));
                }).length;

                return Column(
                  children: [
                    if (expiredCount > 0)
                      Container(
                        margin: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.redAccent,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Có $expiredCount thuốc đã quá hạn. Cần ngưng bán và xử lý kho.",
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final data =
                              docs[index].data() as Map<String, dynamic>;
                          final id = docs[index].id;
                          final expiryDate = _parseExpiryDate(
                            data['expiryDate'],
                          );
                          final isExpired = _isExpired(expiryDate);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              leading: _buildProductImage(
                                data['imageUrl'],
                                data['category'] ?? "",
                              ),
                              title: Text(
                                data['name'] ?? "Không tên",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${data['price'] ?? 0}đ  •  Tồn: ${data['stock'] ?? 0}",
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "HSD: ${_formatExpiryDate(expiryDate)}",
                                    style: TextStyle(
                                      color: isExpired
                                          ? Colors.redAccent
                                          : Colors.grey[700],
                                      fontWeight: isExpired
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isExpired)
                                    Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      child: const Text(
                                        "QUÁ HẠN",
                                        style: TextStyle(
                                          color: Colors.redAccent,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () => _showEditProductDialog(
                                      context,
                                      id,
                                      data,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () => FirebaseFirestore.instance
                                        .collection('medicines')
                                        .doc(id)
                                        .delete(),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
