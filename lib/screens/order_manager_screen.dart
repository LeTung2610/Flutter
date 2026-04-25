import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class OrderManagerScreen extends StatelessWidget {
  const OrderManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat("#,###", "vi_VN");
    final dateFormat = DateFormat('dd/MM/yyyy - HH:mm');

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("QUẢN LÝ ĐƠN HÀNG ONLINE", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Lỗi: ${snapshot.error}"));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          var docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text("Chưa có đơn hàng nào", style: TextStyle(fontSize: 18)));
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
            padding: const EdgeInsets.all(24),
            itemCount: sortedDocs.length,
            itemBuilder: (context, index) {
              var data = sortedDocs[index].data() as Map<String, dynamic>;
              String docId = sortedDocs[index].id;
              String status = data['status'] ?? 'Chờ Duyệt';
              int totalPrice = int.tryParse(data['totalPrice']?.toString() ?? '0') ?? 0;

              // Status styling
              Color statusColor;
              IconData statusIcon;
              String statusText = status;

              switch (status) {
                case 'Đang Giao':
                  statusColor = Colors.blue;
                  statusIcon = Icons.local_shipping;
                  break;
                case 'Hoàn Thành':
                  statusColor = Colors.green;
                  statusIcon = Icons.check_circle;
                  break;
                case 'Hủy':
                  statusColor = Colors.red;
                  statusIcon = Icons.cancel;
                  break;
                default:
                  statusColor = Colors.orange;
                  statusIcon = Icons.pending_actions;
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 3,
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: statusColor.withOpacity(0.1),
                    child: Icon(statusIcon, color: statusColor),
                  ),
                  title: Row(
                    children: [
                      Text("Mã: #${docId.substring(docId.length - 6).toUpperCase()}", style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    "Khách: ${data['userId'] ?? 'Khách vãng lai'} • ${dateFormat.format(((data['createdAt'] ?? data['timestamp'] ?? Timestamp.now()) as Timestamp).toDate())}",
                    style: const TextStyle(fontSize: 13),
                  ),
                  trailing: Text(
                    "${fmt.format(totalPrice)}đ",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent),
                  ),
                  children: [
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("CHI TIẾT ĐƠN HÀNG", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
                          const SizedBox(height: 12),
                          if (data['items'] != null)
                            ...(data['items'] as List).map((item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("• ${item['name']} x${item['qty']}", style: const TextStyle(fontSize: 15)),
                                      Text("${fmt.format(item['price'])}đ", style: const TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                                )),
                          const Divider(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (status == 'Chờ Duyệt' || status == 'Đang Giao') ...[
                                OutlinedButton(
                                  onPressed: () => _updateStatus(docId, 'Hủy', data),
                                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                                  child: const Text("Hủy đơn"),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: () {
                                    String next = status == 'Chờ Duyệt' ? 'Đang Giao' : 'Hoàn Thành';
                                    _updateStatus(docId, next, data);
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan, foregroundColor: Colors.white),
                                  child: Text(status == 'Chờ Duyệt' ? "Duyệt & Giao" : "Hoàn thành"),
                                ),
                              ] else
                                Text(
                                  status == 'Hoàn Thành' ? "Đã giao thành công ✅" : "Đơn đã hủy ❌",
                                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                            ],
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

  void _updateStatus(String id, String newStatus, Map<String, dynamic> orderData) {
    FirebaseFirestore.instance.collection('orders').doc(id).update({'status': newStatus}).then((_) {
      // Nếu trạng thái là Hoàn Thành, tự động tạo hóa đơn để nhảy số doanh thu
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
