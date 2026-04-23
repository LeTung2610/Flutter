import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat("#,###", "vi_VN");

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("TỔNG QUAN HỆ THỐNG", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Báo cáo hoạt động hôm nay",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),

            Wrap(
              spacing: 24,
              runSpacing: 24,
              children: [
                _buildMetricCard(
                  context,
                  title: "Tổng Doanh Thu",
                  collection: "invoices",
                  icon: Icons.attach_money_rounded,
                  color: Colors.cyan,
                  isMoney: true,
                  formatter: fmt,
                ),
                _buildMetricCard(
                  context,
                  title: "Sản phẩm trong kho",
                  collection: "medicines",
                  icon: Icons.inventory_2_rounded,
                  color: Colors.blue,
                ),
                _buildMetricCard(
                  context,
                  title: "Đơn chờ duyệt",
                  collection: "orders",
                  icon: Icons.pending_actions_rounded,
                  color: Colors.orange,
                  statusFilter: "Chờ Duyệt",
                ),
              ],
            ),

            const SizedBox(height: 48),
            const Text("Hoạt động gần đây", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Đơn hàng mới nhất", style: TextStyle(fontWeight: FontWeight.w600)),
                    SizedBox(height: 16),
                    Text("Chưa có dữ liệu gần đây", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String collection,
    required IconData icon,
    required Color color,
    bool isMoney = false,
    String? statusFilter,
    NumberFormat? formatter,
  }) {
    return Container(
      width: 320,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection(collection).snapshots(),
        builder: (context, snapshot) {
          int value = 0;

          if (snapshot.hasData) {
            if (isMoney) {
              for (var doc in snapshot.data!.docs) {
                var data = doc.data() as Map<String, dynamic>;
                value += int.tryParse(data['totalPrice']?.toString() ?? '0') ?? 0;
              }
            } else if (statusFilter != null) {
              value = snapshot.data!.docs.where((doc) {
                var data = doc.data() as Map<String, dynamic>;
                return data['status'] == statusFilter;
              }).length;
            } else {
              value = snapshot.data!.docs.length;
            }
          }

          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),   // ← Đã sửa deprecation
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: color, size: 36),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 15)),
                        const SizedBox(height: 8),
                        Text(
                          isMoney ? "${formatter?.format(value) ?? value} đ" : "$value",
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}