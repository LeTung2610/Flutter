import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class RevenueScreen extends StatefulWidget {
  const RevenueScreen({super.key});

  @override
  State<RevenueScreen> createState() => _RevenueScreenState();
}

class _RevenueScreenState extends State<RevenueScreen> {
  String _filter = 'Tháng này';

  @override
  Widget build(BuildContext context) {
    final moneyFmt = NumberFormat('#,###', 'vi_VN');

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('invoices').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          int totalRevenue = 0;
          for (var doc in docs) {
            totalRevenue += int.tryParse(doc['totalPrice']?.toString() ?? '0') ?? 0;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 35),
                
                // Card Doanh Thu Tổng Khổng Lồ
                _buildMainRevenueCard(totalRevenue, moneyFmt),
                const SizedBox(height: 35),
                
                // KPI Cards Row
                _buildKPIRow(moneyFmt, docs.length),
                const SizedBox(height: 40),
                
                // Layout Biểu Đồ Phức Hợp
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _buildPrimaryBarChart()),
                    const SizedBox(width: 30),
                    Expanded(child: _buildDistributionPieChart()),
                  ],
                ),
                const SizedBox(height: 40),
                
                // Biểu Đồ Xu Hướng Full-Width
                _buildTrendLineChart(),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "THỐNG KÊ DOANH THU",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF1A202C), letterSpacing: 1),
            ),
            const SizedBox(height: 5),
            Text("Phân tích dữ liệu tăng trưởng kinh doanh NeelMilk", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          ],
        ),
        _buildFilterSelector(),
      ],
    );
  }

  Widget _buildFilterSelector() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]),
      child: Row(
        children: ['Hôm nay', 'Tuần này', 'Tháng này'].map((f) => GestureDetector(
          onTap: () => setState(() => _filter = f),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: _filter == f ? const Color(0xFF00D4C4) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(f, style: TextStyle(color: _filter == f ? Colors.white : Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildMainRevenueCard(int amount, NumberFormat fmt) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF00D4C4), Color(0xFF00A89B), Color(0xFF004D40)],
        ),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(color: const Color(0xFF00D4C4).withOpacity(0.4), blurRadius: 40, offset: const Offset(0, 20)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(right: -20, top: -20, child: Icon(Icons.auto_graph_rounded, size: 200, color: Colors.white.withOpacity(0.1))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("DOANH THU TẤT CẢ", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 14)),
              const SizedBox(height: 15),
              Text(
                "₫${fmt.format(amount)}",
                style: const TextStyle(color: Colors.white, fontSize: 56, fontWeight: FontWeight.w900, letterSpacing: -1),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildMiniBadge(Icons.trending_up, "+24.5%"),
                  const SizedBox(width: 15),
                  const Text("Tăng trưởng mạnh mẽ so với cùng kỳ", style: TextStyle(color: Colors.white60, fontSize: 13)),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildKPIRow(NumberFormat fmt, int count) {
    return Row(
      children: [
        Expanded(child: _buildKPIItem("Trung bình/đơn", "₫450.000", Icons.analytics_rounded, const Color(0xFF8B5CF6))),
        const SizedBox(width: 20),
        Expanded(child: _buildKPIItem("Ngày cao nhất", "₫85.000.000", Icons.star_rounded, const Color(0xFFF59E0B))),
        const SizedBox(width: 20),
        Expanded(child: _buildKPIItem("Số đơn hàng", count.toString(), Icons.shopping_cart_rounded, const Color(0xFF00D4C4))),
        const SizedBox(width: 20),
        Expanded(child: _buildKPIItem("Tỷ lệ chuyển đổi", "8.2%", Icons.ads_click_rounded, const Color(0xFFEC4899))),
      ],
    );
  }

  Widget _buildKPIItem(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF2D3748))),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPrimaryBarChart() {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(35), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 30)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("DOANH THU THEO TUẦN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 40),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(show: true, topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false))),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: false),
                barGroups: List.generate(7, (i) => BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: (i + 3) * 10.0,
                      color: const Color(0xFF00D4C4),
                      width: 20,
                      borderRadius: BorderRadius.circular(6),
                      backDrawRodData: BackgroundBarChartRodData(show: true, toY: 100, color: const Color(0xFFF1F5F9)),
                    )
                  ],
                )),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDistributionPieChart() {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(35), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 30)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("PHÂN BỔ DANH MỤC", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 5,
                centerSpaceRadius: 60,
                sections: [
                  PieChartSectionData(value: 40, color: const Color(0xFF00D4C4), title: 'Dược phẩm', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                  PieChartSectionData(value: 30, color: const Color(0xFF8B5CF6), title: 'TP Chức năng', radius: 45, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                  PieChartSectionData(value: 20, color: const Color(0xFFF59E0B), title: 'Vật tư y tế', radius: 40, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                  PieChartSectionData(value: 10, color: const Color(0xFFEC4899), title: 'Mỹ phẩm', radius: 35, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTrendLineChart() {
    return Container(
      height: 350,
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(35), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 30)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("XU HƯỚNG TĂNG TRƯỞNG", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 30),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 1, getDrawingHorizontalLine: (value) => FlLine(color: const Color(0xFFF1F5F9), strokeWidth: 1)),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [const FlSpot(0, 3), const FlSpot(2.6, 2), const FlSpot(4.9, 5), const FlSpot(6.8, 3.1), const FlSpot(8, 4), const FlSpot(9.5, 3), const FlSpot(11, 4)],
                    isCurved: true,
                    color: const Color(0xFF00D4C4),
                    barWidth: 6,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(colors: [const Color(0xFF00D4C4).withOpacity(0.3), const Color(0xFF00D4C4).withOpacity(0)]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
