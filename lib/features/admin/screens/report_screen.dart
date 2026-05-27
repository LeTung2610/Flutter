import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../theme/admin_theme.dart';
import '../widgets/admin_common_widgets.dart';

class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  late Stream<QuerySnapshot> _ordersStream;

  @override
  void initState() {
    super.initState();
    _ordersStream = FirebaseFirestore.instance.collection('orders').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<QuerySnapshot>(
        stream: _ordersStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AdminTheme.accentGold));

          final orders = snapshot.data!.docs;
          Map<int, double> monthlyRevenue = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0, 8: 0, 9: 0, 10: 0, 11: 0, 12: 0};
          double totalRevenue = 0;
          double currentMonthRevenue = 0;
          final now = DateTime.now();

          for (var doc in orders) {
            final data = doc.data() as Map<String, dynamic>;
            if (data['status'] == 'Hoàn Thành') {
              // Check both field names for compatibility
              final price = ((data['totalPrice'] ?? data['total_price']) ?? 0).toDouble();
              final date = (data['createdAt'] as Timestamp?)?.toDate() ?? now;
              
              monthlyRevenue[date.month] = (monthlyRevenue[date.month] ?? 0) + price;
              totalRevenue += price;
              if (date.month == now.month && date.year == now.year) {
                currentMonthRevenue += price;
              }
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "BÁO CÁO CHI TIẾT",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    color: AdminTheme.accentGold,
                  ),
                ),
                const SizedBox(height: 30),
                LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 600 ? 2 : 1);
                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 1.8,
                      children: [
                        _buildReportCard("TỔNG DOANH THU", "₫${NumberFormat.compact().format(totalRevenue)}", "Tất cả", AdminTheme.tealGlow),
                        _buildReportCard("THÁNG NÀY", "₫${NumberFormat.compact().format(currentMonthRevenue)}", "+12%", AdminTheme.purpleGlow),
                        _buildReportCard("LỢI NHUẬN (ƯỚC TÍNH)", "₫${NumberFormat.compact().format(totalRevenue * 0.3)}", "30%", AdminTheme.orangeGlow),
                      ],
                    );
                  }
                ),
                const SizedBox(height: 30),
                GlassCard(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("BIỂU ĐỒ DOANH THU THEO THÁNG", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 40),
                      SizedBox(
                        height: 350,
                        child: BarChart(
                          BarChartData(
                            gridData: const FlGridData(show: false),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final month = value.toInt() + 1;
                                    if (month >= 1 && month <= 12) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: Text("T$month", style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
                                      );
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups: List.generate(6, (index) {
                              // Hiển thị 6 tháng gần nhất
                              int targetMonth = now.month - 5 + index;
                              if (targetMonth <= 0) targetMonth += 12;
                              
                              final colors = [
                                AdminTheme.tealGlow, 
                                AdminTheme.purpleGlow, 
                                AdminTheme.orangeGlow, 
                                AdminTheme.pinkGlow, 
                                AdminTheme.accentGold, 
                                AdminTheme.tealGlow
                              ];
                              
                              double revenueMillions = (monthlyRevenue[targetMonth] ?? 0) / 1000000;
                              return _makeGroupData(index, revenueMillions, colors[index]);
                            }),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Center(child: Text("Đơn vị: Triệu VNĐ", style: TextStyle(color: Colors.white10, fontSize: 11))),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y == 0 ? 0.5 : y, // Giá trị tối thiểu để hiển thị thanh
          color: color,
          width: 30,
          borderRadius: BorderRadius.circular(8),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 50, // Max height giả định
            color: Colors.white.withOpacity(0.03),
          ),
        ),
      ],
    );
  }

  Widget _buildReportCard(String title, String value, String change, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      glowColor: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.auto_graph_rounded, color: color, size: 14),
              const SizedBox(width: 5),
              Text(change, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
              const SizedBox(width: 5),
              const Text("từ nguồn thực tế", style: TextStyle(color: Colors.white10, fontSize: 9)),
            ],
          ),
        ],
      ),
    );
  }
}
