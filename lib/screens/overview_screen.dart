import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text("TỔNG QUAN HỆ THỐNG", style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.transparent),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Báo cáo hoạt động", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Wrap(
              spacing: 24,
              runSpacing: 24,
              children: [
                _buildMetricCard(context, 'Tổng Doanh Thu', 'invoices', Icons.attach_money, Colors.cyan, isMoney: true),
                _buildMetricCard(context, 'Sản phẩm trong kho', 'medicines', Icons.medication, Colors.blue),
                _buildMetricCard(context, 'Đơn chờ duyệt', 'orders', Icons.pending_actions, Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, String title, String collection, IconData icon, Color color, {bool isMoney = false}) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = screenWidth > 1200 ? (screenWidth - 350 - 64 - 48) / 3 : (screenWidth > 800 ? (screenWidth - 150 - 64 - 24) / 2 : screenWidth - 64);

    return Container(
      width: cardWidth,
      constraints: const BoxConstraints(minWidth: 280),
      child: StreamBuilder(
        stream: FirebaseFirestore.instance.collection(collection).snapshots(),
        builder: (context, snapshot) {
          int value = 0;
          if (snapshot.hasData) {
            if (isMoney) {
              for (var doc in snapshot.data!.docs) {
                var d = doc.data();
                value += int.tryParse(d['totalPrice']?.toString() ?? '0') ?? 0;
              }
            } else {
              value = snapshot.data!.docs.length;
            }
          }
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: Icon(icon, color: color, size: 30),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                        const SizedBox(height: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(isMoney ? "$value VNĐ" : "$value", style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
