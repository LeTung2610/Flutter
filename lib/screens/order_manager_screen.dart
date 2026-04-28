import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class OrderManagerScreen extends StatelessWidget {
  const OrderManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat("#,###", "vi_VN");
    final dateFormat = DateFormat('dd/MM/yyyy • HH:mm');

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 30),
            _buildFilterTabs(),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('orders').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return Center(child: Text("Lỗi: ${snapshot.error}"));
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_rounded, size: 80, color: Colors.grey.withOpacity(0.2)),
                          const SizedBox(height: 15),
                          const Text("Chưa có đơn hàng nào được ghi nhận", style: TextStyle(color: Colors.grey, fontSize: 16)),
                        ],
                      ),
                    );
                  }

                  // Sắp xếp đơn mới nhất lên trên
                  List<QueryDocumentSnapshot> sortedDocs = List.from(docs);
                  sortedDocs.sort((a, b) {
                    var dataA = a.data() as Map<String, dynamic>;
                    var dataB = b.data() as Map<String, dynamic>;
                    var timeA = dataA['createdAt'] ?? dataA['timestamp'] ?? Timestamp.now();
                    var timeB = dataB['createdAt'] ?? dataB['timestamp'] ?? Timestamp.now();
                    return (timeB as Timestamp).compareTo(timeA as Timestamp);
                  });

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: sortedDocs.length,
                    itemBuilder: (context, index) {
                      var data = sortedDocs[index].data() as Map<String, dynamic>;
                      String docId = sortedDocs[index].id;
                      return _buildOrderCard(context, docId, data, fmt, dateFormat);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "ĐƠN HÀNG ONLINE",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF1A202C), letterSpacing: 1),
        ),
        const SizedBox(height: 5),
        Text("Quản lý luồng vận hành đơn hàng từ hệ thống E-commerce", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
      ],
    );
  }

  Widget _buildFilterTabs() {
    return Row(
      children: [
        _buildTab("Tất cả", true),
        const SizedBox(width: 15),
        _buildTab("Chờ duyệt", false),
        const SizedBox(width: 15),
        _buildTab("Đang giao", false),
        const SizedBox(width: 15),
        _buildTab("Hoàn thành", false),
      ],
    );
  }

  Widget _buildTab(String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF00D4C4) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: active ? [BoxShadow(color: const Color(0xFF00D4C4).withOpacity(0.3), blurRadius: 10)] : [],
      ),
      child: Text(
        label,
        style: TextStyle(color: active ? Colors.white : const Color(0xFF718096), fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, String id, Map<String, dynamic> data, NumberFormat fmt, DateFormat dateFormat) {
    String status = data['status'] ?? 'Chờ Duyệt';
    int totalPrice = int.tryParse(data['totalPrice']?.toString() ?? '0') ?? 0;
    Timestamp timestamp = data['createdAt'] ?? data['timestamp'] ?? Timestamp.now();

    Color statusColor;
    switch (status) {
      case 'Đang Giao': statusColor = Colors.blueAccent; break;
      case 'Hoàn Thành': statusColor = const Color(0xFF00D4C4); break;
      case 'Hủy': statusColor = Colors.redAccent; break;
      default: statusColor = Colors.orangeAccent;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 5))],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.shopping_bag_outlined, color: statusColor, size: 24),
          ),
          title: Row(
            children: [
              Text("ID: #${id.substring(id.length - 6).toUpperCase()}", style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2D3748))),
              const SizedBox(width: 15),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1),
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              "Khách: ${data['userName'] ?? data['userId'] ?? 'Khách cao cấp'} • ${dateFormat.format(timestamp.toDate())}",
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ),
          trailing: Text(
            "₫${fmt.format(totalPrice)}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF2D3748)),
          ),
          children: [
            _buildOrderDetails(context, id, data, fmt, status, statusColor),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetails(BuildContext context, String id, Map<String, dynamic> data, NumberFormat fmt, String status, Color statusColor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 30),
          const Text("CHI TIẾT MẶT HÀNG", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey, letterSpacing: 1)),
          const SizedBox(height: 15),
          if (data['items'] != null)
            ...(data['items'] as List).map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(color: const Color(0xFFF7FAFC), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.medication_rounded, size: 20, color: Color(0xFF00D4C4)),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text("Số lượng: ${item['qty']}", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                          ],
                        ),
                      ),
                      Text("₫${fmt.format(item['price'])}", style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                )),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (status == 'Chờ Duyệt' || status == 'Đang Giao') ...[
                TextButton(
                  onPressed: () => _updateStatus(id, 'Hủy', data),
                  child: const Text("Hủy Đơn", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 15),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF00D4C4), Color(0xFF00A89B)]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      String next = status == 'Chờ Duyệt' ? 'Đang Giao' : 'Hoàn Thành';
                      _updateStatus(id, next, data);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                    ),
                    child: Text(status == 'Chờ Duyệt' ? "DUYỆT ĐƠN" : "XÁC NHẬN GIAO", style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ] else ...[
                Icon(status == 'Hoàn Thành' ? Icons.verified_rounded : Icons.cancel_rounded, color: statusColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  status == 'Hoàn Thành' ? "Đơn hàng đã được phục vụ hoàn tất" : "Đơn hàng đã bị hủy bỏ",
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _updateStatus(String id, String newStatus, Map<String, dynamic> orderData) {
    FirebaseFirestore.instance.collection('orders').doc(id).update({'status': newStatus}).then((_) {
      if (newStatus == 'Hoàn Thành') {
        FirebaseFirestore.instance.collection('invoices').add({
          'totalPrice': orderData['totalPrice'],
          'items': orderData['items'],
          'timestamp': FieldValue.serverTimestamp(),
          'orderId': id,
          'type': 'online'
        });
      }
    });
  }
}
