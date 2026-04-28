import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final moneyFmt = NumberFormat('#,###', 'vi_VN');

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 35),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('invoices').snapshots(),
            builder: (context, invSnapshot) {
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('medicines').snapshots(),
                builder: (context, medSnapshot) {
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('orders').snapshots(),
                    builder: (context, ordSnapshot) {
                      int totalRevenue = 0;
                      if (invSnapshot.hasData) {
                        for (var doc in invSnapshot.data!.docs) {
                          totalRevenue += int.tryParse(doc['totalPrice']?.toString() ?? '0') ?? 0;
                        }
                      }

                      int totalProducts = medSnapshot.hasData ? medSnapshot.data!.docs.length : 0;
                      int pendingOrders = 0;
                      int todayOrders = 0;

                      if (ordSnapshot.hasData) {
                        final now = DateTime.now();
                        for (var doc in ordSnapshot.data!.docs) {
                          final data = doc.data() as Map<String, dynamic>;
                          if (data['status'] == 'Chờ Duyệt') pendingOrders++;
                          
                          final ts = data['createdAt'] ?? data['timestamp'];
                          if (ts != null) {
                            final date = (ts as Timestamp).toDate();
                            if (date.day == now.day && date.month == now.month && date.year == now.year) {
                              todayOrders++;
                            }
                          }
                        }
                      }

                      return _buildStatsGrid(moneyFmt.format(totalRevenue), totalProducts.toString(), pendingOrders.toString(), todayOrders.toString());
                    },
                  );
                },
              );
            },
          ),
          const SizedBox(height: 40),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildMainChartSection()),
              const SizedBox(width: 30),
              Expanded(child: _buildRecentActivity()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Chào buổi sáng, Admin!",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1A202C)),
        ),
        const SizedBox(height: 5),
        Text(
          "Hệ thống NeelMilk Pharmacy đang hoạt động ổn định.",
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600, letterSpacing: 0.5),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(String revenue, String products, String pending, String today) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.count(
          crossAxisCount: constraints.maxWidth > 1200 ? 4 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 25,
          mainAxisSpacing: 25,
          childAspectRatio: 1.6,
          children: [
            _buildStatCard("TỔNG DOANH THU", "₫$revenue", Icons.payments_rounded, const [Color(0xFF00D4C4), Color(0xFF00A89B)]),
            _buildStatCard("SẢN PHẨM TRONG KHO", products, Icons.inventory_2_rounded, const [Color(0xFF667EEA), Color(0xFF764BA2)]),
            _buildStatCard("ĐƠN CHỜ DUYỆT", pending, Icons.hourglass_top_rounded, const [Color(0xFFF6AD55), Color(0xFFED8936)]),
            _buildStatCard("ĐƠN HÔM NAY", today, Icons.local_shipping_rounded, const [Color(0xFFF687B3), Color(0xFFED64A6)]),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, List<Color> colors) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: colors[0].withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              Icon(icon, color: Colors.white, size: 28),
            ],
          ),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
          const Row(
            children: [
              Icon(Icons.trending_up, color: Colors.white, size: 16),
              SizedBox(width: 5),
              Text("Cập nhật theo thời gian thực", style: TextStyle(color: Colors.white70, fontSize: 11)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMainChartSection() {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(35), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 30)]),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Phân Tích Doanh Thu", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
          Spacer(),
          Center(child: Opacity(opacity: 0.1, child: Icon(Icons.show_chart_rounded, size: 200, color: Color(0xFF00D4C4)))),
          Spacer(),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(35), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 30)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Hoạt động gần đây", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
          const SizedBox(height: 25),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('orders').orderBy('createdAt', descending: true).limit(5).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return _buildActivityItem("Đơn hàng mới", "Mã đơn: #${doc.id.substring(doc.id.length-4).toUpperCase()}", "Vừa xong", Colors.blue);
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String subtitle, String time, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ],
            ),
          ),
          Text(time, style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
        ],
      ),
    );
  }
}
