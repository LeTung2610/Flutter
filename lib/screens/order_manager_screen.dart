import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderManagerScreen extends StatelessWidget {
  const OrderManagerScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text("ĐƠN HÀNG ONLINE", style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.transparent, elevation: 0),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('orders').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          var docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text("Không có đơn hàng nào"));

          return ListView.builder(
            padding: const EdgeInsets.all(32),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var data = docs[index].data();
              String status = data['status'] ?? 'Chờ Duyệt';
              Color statusColor = status == 'Chờ Duyệt' ? Colors.orange : (status == 'Đang Giao' ? Colors.blue : Colors.green);

              return Card(
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: Colors.cyan[50], borderRadius: BorderRadius.circular(10)),
                                child: const Icon(Icons.receipt_long, color: Colors.cyan),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Mã đơn: #${docs[index].id.substring(0, 8).toUpperCase()}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text(data['customerName'] ?? "Khách hàng ẩn danh", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                            child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ],
                      ),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider()),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${int.tryParse(data['totalPrice']?.toString() ?? '0')} VNĐ", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.phone, size: 14, color: Colors.grey),
                                  const SizedBox(width: 6),
                                  Text("${data['phone']}", style: TextStyle(color: Colors.grey[600])),
                                ],
                              ),
                            ],
                          ),
                          if (status != 'Hoàn Thành') ElevatedButton(
                            onPressed: () {
                              String nextStatus = status == 'Chờ Duyệt' ? 'Đang Giao' : 'Hoàn Thành';
                              FirebaseFirestore.instance.collection('orders').doc(docs[index].id).update({'status': nextStatus});
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.cyan, 
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(status == 'Chờ Duyệt' ? "Duyệt Đơn" : "Giao Thành Công"),
                          ) else const Row(children: [Icon(Icons.check_circle, color: Colors.green), SizedBox(width: 8), Text("Hoàn thành", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))]),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
