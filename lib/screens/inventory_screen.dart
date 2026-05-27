import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../features/admin/widgets/admin_common_widgets.dart';
import '../features/admin/theme/admin_theme.dart';
import '../helpers/image_picker_helper.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String _searchQuery = "";
  String? _selectedCategory;
  late Stream<QuerySnapshot> _categoryStream;
  late Stream<QuerySnapshot> _productStream;

  @override
  void initState() {
    super.initState();
    _categoryStream = FirebaseFirestore.instance.collection('categories').snapshots();
    _productStream = FirebaseFirestore.instance.collection('medicines').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 35),
            _buildSearchAndFilter(),
            const SizedBox(height: 25),
            Expanded(child: _buildProductGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isSmall = constraints.maxWidth < 600;
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: AdminTheme.cardSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AdminTheme.borderGold.withValues(alpha: 0.5)),
                    ),
                    child: TextField(
                      onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: const InputDecoration(
                        icon: Icon(Icons.search_rounded, color: AdminTheme.accentGold, size: 20),
                        hintText: "Tìm kiếm thuốc...",
                        hintStyle: TextStyle(color: Colors.white24, fontSize: 13),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                if (!isSmall) ...[
                  const SizedBox(width: 20),
                  Expanded(flex: 2, child: _buildCategoryDropdown()),
                ],
              ],
            ),
            if (isSmall) ...[
              const SizedBox(height: 15),
              _buildCategoryDropdown(),
            ],
          ],
        );
      }
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildCategoryDropdown() {
    return StreamBuilder<QuerySnapshot>(
      stream: _categoryStream,
      builder: (context, snapshot) {
        List<String> categories = ["Tất cả danh mục"];
        if (snapshot.hasData) {
          categories.addAll(snapshot.data!.docs.map((d) => d['name'] as String));
        }
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: AdminTheme.cardSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AdminTheme.borderGold.withValues(alpha: 0.5)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedCategory ?? "Tất cả danh mục",
              dropdownColor: AdminTheme.sidebarSurface,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AdminTheme.accentGold),
              items: categories.map((c) => DropdownMenuItem(
                value: c,
                child: Text(c, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
              )).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val == "Tất cả danh mục" ? null : val),
            ),
          ),
        );
      }
    );
  }

  Widget _buildProductGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: _productStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AdminTheme.accentGold));
        
        var filteredDocs = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final name = (data['name'] ?? "").toString().toLowerCase();
          final category = data['category'] ?? "";
          return name.contains(_searchQuery) && (_selectedCategory == null || category == _selectedCategory);
        }).toList();

        if (filteredDocs.isEmpty) return const Center(child: Text("Không tìm thấy sản phẩm", style: TextStyle(color: AdminTheme.textGrey)));
        
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 300,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 0.8,
          ),
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            final doc = filteredDocs[index];
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return _buildProductCard(context, data);
          },
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Kho Dược Phẩm", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            Text("Quản lý danh mục sản phẩm và tồn kho", style: TextStyle(color: AdminTheme.textGrey, fontSize: 14)),
          ],
        ),
        AdminButton(
          label: "THÊM SẢN PHẨM",
          icon: Icons.add_rounded,
          onTap: () => _showAddEditMedicineDialog(context),
        ),
      ],
    );
  }

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> data) {
    final stock = (data['stock'] ?? 0).toInt();
    final price = (data['price'] ?? 0).toDouble();

    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                image: data['imageUrl'] != null 
                  ? DecorationImage(image: NetworkImage(data['imageUrl']), fit: BoxFit.contain)
                  : null,
              ),
              child: data['imageUrl'] == null ? const Icon(Icons.medication, size: 50, color: AdminTheme.accentGold) : null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['name'] ?? "", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 5),
                Text("Tồn kho: $stock", style: const TextStyle(color: AdminTheme.textGrey, fontSize: 12)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("₫${NumberFormat("#,###").format(price)}", style: const TextStyle(color: AdminTheme.accentGold, fontWeight: FontWeight.bold, fontSize: 16)),
                    Row(
                      children: [
                        IconButton(icon: const Icon(Icons.edit, color: Colors.blue, size: 20), onPressed: () => _showAddEditMedicineDialog(context, docId: data['id'], data: data)),
                        IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20), onPressed: () => _showDeleteConfirmDialog(context, data['id'], data['name'])),
                      ],
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  void _showAddEditMedicineDialog(BuildContext context, {String? docId, Map<String, dynamic>? data}) {
    final isEditing = docId != null;
    final nameController = TextEditingController(text: data?['name']);
    final priceController = TextEditingController(text: data?['price']?.toString() ?? "");
    final stockController = TextEditingController(text: data?['stock']?.toString() ?? "");
    final descriptionController = TextEditingController(text: data?['description']);
    String? imageUrl = data?['imageUrl'];
    String? selectedCategory = data?['category'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AdminTheme.sidebarSurface,
            title: Text(isEditing ? "Sửa Sản Phẩm" : "Thêm Sản Phẩm Mới", style: const TextStyle(color: Colors.white)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final url = await ImagePickerHelper.pickAndUploadImage(context);
                      if (url != null) setDialogState(() => imageUrl = url);
                    },
                    child: Container(
                      height: 120, width: 120,
                      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(15), border: Border.all(color: AdminTheme.borderGold)),
                      child: imageUrl == null ? const Icon(Icons.add_a_photo, color: AdminTheme.accentGold) : Image.network(imageUrl!, fit: BoxFit.contain),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildField("Tên sản phẩm", nameController),
                  _buildField("Giá (₫)", priceController, isNumber: true),
                  _buildField("Số lượng", stockController, isNumber: true),
                  _buildField("Mô tả", descriptionController, maxLines: 3),
                  const SizedBox(height: 10),
                  _buildCategorySelect(selectedCategory, (val) => setDialogState(() => selectedCategory = val)),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("HỦY", style: TextStyle(color: AdminTheme.textGrey))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.accentGold),
                onPressed: () async {
                  if (nameController.text.isEmpty || priceController.text.isEmpty) return;
                  final medicineData = {
                    'name': nameController.text.trim(),
                    'price': double.tryParse(priceController.text) ?? 0.0,
                    'stock': int.tryParse(stockController.text) ?? 0,
                    'category': selectedCategory ?? "Dược phẩm",
                    'description': descriptionController.text.trim(),
                    'imageUrl': imageUrl,
                    'updatedAt': FieldValue.serverTimestamp(),
                  };
                  if (isEditing) {
                    await FirebaseFirestore.instance.collection('medicines').doc(docId).update(medicineData);
                  } else {
                    medicineData['createdAt'] = FieldValue.serverTimestamp();
                    await FirebaseFirestore.instance.collection('medicines').add(medicineData);
                  }
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text("LƯU", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        }
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {bool isNumber = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AdminTheme.textGrey),
          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AdminTheme.accentGold)),
        ),
      ),
    );
  }

  Widget _buildCategorySelect(String? current, Function(String) onChanged) {
    return StreamBuilder<QuerySnapshot>(
      stream: _categoryStream,
      builder: (context, snapshot) {
        List<String> items = snapshot.hasData ? snapshot.data!.docs.map((d) => d['name'] as String).toList() : ["Dược phẩm"];
        return DropdownButton<String>(
          value: items.contains(current) ? current : items.first,
          isExpanded: true,
          dropdownColor: AdminTheme.sidebarSurface,
          style: const TextStyle(color: Colors.white),
          items: items.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
          onChanged: (val) { if (val != null) onChanged(val); },
        );
      }
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, String docId, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AdminTheme.sidebarSurface,
        title: const Text("Xác nhận xóa", style: TextStyle(color: Colors.white)),
        content: Text("Bạn có chắc chắn muốn xóa $name?", style: const TextStyle(color: AdminTheme.textGrey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("HỦY")),
          TextButton(onPressed: () async {
            await FirebaseFirestore.instance.collection('medicines').doc(docId).delete();
            if (context.mounted) Navigator.pop(context);
          }, child: const Text("XÓA", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}
