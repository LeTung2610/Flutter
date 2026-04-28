import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final fmt = NumberFormat("#,###", "vi_VN");

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("ĐƠN MUA CỦA TÔI", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Bỏ orderBy ở đây để tránh lỗi Firebase Index, chúng ta sẽ sắp xếp bằng code Dart phía dưới
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: user?.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Lỗi: ${snapshot.error}"));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.teal));
          }

          var docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_late_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text("Bạn chưa có đơn hàng nào", style: TextStyle(color: Colors.grey[400], fontSize: 16)),
                ],
              ),
            );
          }

          // Sắp xếp đơn hàng mới nhất lên đầu bằng code Dart
          List<QueryDocumentSnapshot> sortedDocs = List.from(docs);
          sortedDocs.sort((a, b) {
            var dataA = a.data() as Map<String, dynamic>;
            var dataB = b.data() as Map<String, dynamic>;
            var timeA = dataA['createdAt'] ?? dataA['timestamp'] ?? Timestamp.now();
            var timeB = dataB['createdAt'] ?? dataB['timestamp'] ?? Timestamp.now();
            return (timeB as Timestamp).compareTo(timeA as Timestamp);
          });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedDocs.length,
            itemBuilder: (context, i) {
              var data = sortedDocs[i].data() as Map<String, dynamic>;
              String status = data['status'] ?? 'Chờ Duyệt';

              // Cấu hình màu sắc trạng thái
              Color statusColor;
              switch (status) {
                case 'Đang Giao': statusColor = Colors.blue; break;
                case 'Hoàn Thành': statusColor = Colors.green; break;
                case 'Hủy': statusColor = Colors.red; break;
                default: statusColor = Colors.orange;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))]
                ),
                child: Column(
                  children: [
                    // Header của đơn hàng
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.local_shipping_outlined, size: 18, color: Colors.teal),
                              const SizedBox(width: 8),
                              Text("Mã: #${sortedDocs[i].id.substring(sortedDocs[i].id.length - 6).toUpperCase()}",
                                   style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    // Danh sách sản phẩm
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          ...?((data['items'] as List?)?.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                Container(
                                  width: 40, height: 40,
                                  decoration: BoxDecoration(color: Colors.teal[50], borderRadius: BorderRadius.circular(8)),
                                  child: const Icon(Icons.medication_outlined, color: Colors.teal),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("${item['name']}", style: const TextStyle(fontWeight: FontWeight.w500)),
                                      Text("Số lượng: ${item['qty']}", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                                    ],
                                  ),
                                ),
                                Text("${fmt.format(item['price'])}đ", style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ))),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    // Footer: Tổng tiền
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Tổng thanh toán:", style: TextStyle(color: Colors.grey[600])),
                          Text(
                            "${fmt.format(num.tryParse(data['totalPrice']?.toString() ?? '0') ?? 0)} VNĐ",
                            style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
