import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  static const Color primaryTeal = Color(0xFF00796B);
  static const Color softTeal = Color(0xFFE0F2F1);
  static const Color softBg = Color(0xFFFDFCFB);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final fmt = NumberFormat("#,###", "vi_VN");
    final dateFormat = DateFormat('dd/MM/yyyy - HH:mm');

    return Scaffold(
      backgroundColor: softBg,
      appBar: AppBar(
        title: const Text("Đơn Hàng Của Tôi"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: user?.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Lỗi: ${snapshot.error}"));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primaryTeal));
          }

          var docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return _buildEmptyState();
          }

          // Sort orders - newest first
          List<QueryDocumentSnapshot> sortedDocs = List.from(docs);
          sortedDocs.sort((a, b) {
            var dataA = a.data() as Map<String, dynamic>;
            var dataB = b.data() as Map<String, dynamic>;
            var timeA = dataA['createdAt'] ?? dataA['timestamp'] ?? Timestamp.now();
            var timeB = dataB['createdAt'] ?? dataB['timestamp'] ?? Timestamp.now();
            return (timeB as Timestamp).compareTo(timeA as Timestamp);
          });

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
            itemCount: sortedDocs.length,
            itemBuilder: (context, i) {
              var data = sortedDocs[i].data() as Map<String, dynamic>;
              String status = data['status'] ?? 'Chờ Duyệt';
              num totalPrice = num.tryParse(data['totalPrice']?.toString() ?? '0') ?? 0;
              var createdAt = data['createdAt'] ?? data['timestamp'] ?? Timestamp.now();
              String formattedDate = dateFormat.format((createdAt as Timestamp).toDate());

              return _buildOrderCard(sortedDocs[i].id, status, totalPrice, formattedDate, data['items'] ?? [], fmt);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: softTeal.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.assignment_late_outlined, size: 80, color: primaryTeal),
          ),
          const SizedBox(height: 24),
          const Text(
            "Chưa có đơn hàng nào",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 12),
          const Text(
            "Hãy thực hiện đơn hàng đầu tiên\nđể chăm sóc sức khỏe tốt hơn!",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(String id, String status, num total, String date, List items, NumberFormat fmt) {
    Color statusColor;
    Color statusBg;
    IconData statusIcon;

    switch (status) {
      case 'Đang Giao':
        statusColor = Colors.blue[700]!;
        statusBg = Colors.blue[50]!;
        statusIcon = Icons.local_shipping_rounded;
        break;
      case 'Hoàn Thành':
        statusColor = Colors.green[700]!;
        statusBg = Colors.green[50]!;
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'Hủy':
        statusColor = Colors.red[700]!;
        statusBg = Colors.red[50]!;
        statusIcon = Icons.cancel_rounded;
        break;
      default:
        statusColor = Colors.orange[700]!;
        statusBg = Colors.orange[50]!;
        statusIcon = Icons.schedule_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Mã đơn: #${id.substring(id.length - 6).toUpperCase()}",
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(date, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          Icon(statusIcon, color: statusColor, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            status,
                            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(height: 1),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length > 2 ? 2 : items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(color: softTeal, borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.medication, color: primaryTeal, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item['name'] ?? "Sản phẩm",
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text("x${item['qty'] ?? item['quantity'] ?? 1}", style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    );
                  },
                ),
                if (items.length > 2)
                  Text(
                    "và ${items.length - 2} sản phẩm khác",
                    style: TextStyle(color: Colors.grey[400], fontSize: 12, fontStyle: FontStyle.italic),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: primaryTeal.withValues(alpha: 0.03),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Tổng thanh toán", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black54)),
                Text(
                  "${fmt.format(total)}đ",
                  style: const TextStyle(fontWeight: FontWeight.w900, color: primaryTeal, fontSize: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
