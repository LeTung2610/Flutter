import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'product_detail_screen.dart';

class ShopHomeScreen extends StatefulWidget {
  final Function(String, Map<String, dynamic>) onAdd;
  const ShopHomeScreen({super.key, required this.onAdd});
  @override State<ShopHomeScreen> createState() => _ShopHomeScreenState();
}

class _ShopHomeScreenState extends State<ShopHomeScreen> {
  String searchQuery = "";
  final fmt = NumberFormat("#,###", "vi_VN");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text("QUÂN PHARMACY",
                style: TextStyle(fontWeight: FontWeight.w900, color: Colors.teal[800], fontSize: 18, letterSpacing: 1.2)),
              centerTitle: true,
            ),
            actions: [
              IconButton(
                icon: CircleAvatar(
                  radius: 15,
                  backgroundColor: Colors.teal.withOpacity(0.1),
                  child: const Icon(Icons.person_outline, size: 20, color: Colors.teal),
                ),
                onPressed: () => _showUserMenu(context),
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  TextField(
                    onChanged: (v) => setState(() => searchQuery = v.toLowerCase()),
                    decoration: InputDecoration(
                      hintText: "Tìm thuốc, thực phẩm chức năng...",
                      prefixIcon: const Icon(Icons.search_rounded, color: Colors.teal),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                  const SizedBox(height: 25),
                  _buildPromoBanner(),
                  const SizedBox(height: 30),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Sản phẩm dành cho bạn", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3436))),
                      Text("Xem tất cả", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('medicines').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return SliverToBoxAdapter(child: Center(child: Text("Lỗi: ${snapshot.error}")));
              if (!snapshot.hasData) return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator(color: Colors.teal)));

              var docs = snapshot.data!.docs.where((d) {
                var data = d.data() as Map<String, dynamic>;
                return data['name'].toString().toLowerCase().contains(searchQuery);
              }).toList();

              if (docs.isEmpty) return const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.only(top: 50), child: Text("Không tìm thấy sản phẩm"))));

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _buildProductCard(context, docs[i].data() as Map<String, dynamic>, docs[i].id),
                    childCount: docs.length
                  ),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.teal[700]!, Colors.teal[400]!], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.teal.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("ƯU ĐÃI THÁNG 10", style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)), child: const Text("HOT", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 8),
          const Text("Giảm giá 15% tất cả\nThực phẩm chức năng", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, height: 1.2)),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> data, String id) {
    int stock = int.tryParse(data['stock']?.toString() ?? '0') ?? 0;
    num price = num.tryParse(data['price']?.toString() ?? '0') ?? 0;
    String imageUrl = data['imageUrl']?.toString() ?? '';

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => ProductDetailScreen(data: data, docId: id, onAdd: widget.onAdd))),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey[100]!),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phần hiển thị ảnh
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(color: Colors.grey[50], borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      child: (imageUrl.isNotEmpty)
                        ? Image.network(imageUrl, fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Center(child: Icon(Icons.broken_image_outlined, color: Colors.grey[300], size: 40)),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(child: CircularProgressIndicator(value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null, strokeWidth: 2, color: Colors.teal[100]));
                            },
                          )
                        : Center(child: Icon(Icons.medication_outlined, size: 50, color: Colors.teal.withOpacity(0.2))),
                    ),
                  ),
                  if (stock <= 5 && stock > 0)
                    Positioned(top: 10, right: 10, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(8)), child: const Text("Sắp hết", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))),
                ],
              ),
            ),
            // Thông tin sản phẩm
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data['name'] ?? 'Không tên', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2D3436)), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(data['category'] ?? "Chung", style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${fmt.format(price)}đ", style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, fontSize: 15)),
                        GestureDetector(
                          onTap: stock > 0 ? () => widget.onAdd(id, data) : null,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(color: Colors.teal[50], borderRadius: BorderRadius.circular(10)),
                            child: Icon(Icons.add_shopping_cart, size: 18, color: stock > 0 ? Colors.teal : Colors.grey),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showUserMenu(BuildContext context) {
    showModalBottomSheet(context: context, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))), builder: (c) => Padding(
      padding: const EdgeInsets.all(30),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        CircleAvatar(radius: 35, backgroundColor: Colors.teal[50], child: const Icon(Icons.person, color: Colors.teal, size: 40)),
        const SizedBox(height: 15),
        Text(FirebaseAuth.instance.currentUser?.email ?? "Người dùng", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 25),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => FirebaseAuth.instance.signOut().then((_) => Navigator.pop(c)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[50], foregroundColor: Colors.red, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            child: const Text("ĐĂNG XUẤT", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 15),
      ]),
    ));
  }
}
