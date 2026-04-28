import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import 'dart:ui';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F4), // Xám xanh rất nhạt cho Admin
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 40),
                  _buildStatGrid(),
                  const SizedBox(height: 40),
                  _buildChartsRow(),
                  const SizedBox(height: 40),
                  _buildRecentOrders(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: AppTheme.darkTeal,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20)],
      ),
      child: Column(
        children: [
          const SizedBox(height: 60),
          const Text("NEELMILK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: 4)),
          const Text("ADMIN PANEL", style: TextStyle(color: AppTheme.primaryTeal, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
          const SizedBox(height: 60),
          _buildSidebarItem(Icons.dashboard_rounded, "Tổng quan", true),
          _buildSidebarItem(Icons.inventory_2_rounded, "Kho hàng", false),
          _buildSidebarItem(Icons.shopping_cart_rounded, "Đơn online", false),
          _buildSidebarItem(Icons.point_of_sale_rounded, "POS tại quầy", false),
          _buildSidebarItem(Icons.bar_chart_rounded, "Doanh thu", false),
          const Spacer(),
          _buildSidebarItem(Icons.settings_rounded, "Cài đặt", false),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String title, bool isSelected) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryTeal.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: isSelected ? Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.3)) : null,
      ),
      child: Row(
        children: [
          Icon(icon, color: isSelected ? AppTheme.primaryTeal : Colors.white60, size: 20),
          const SizedBox(width: 16),
          Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.white60, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Chào buổi sáng, Quản trị viên", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppTheme.darkTeal)),
            Text("Hệ thống NeelMilk Premium Pharmacy đang hoạt động ổn định", style: TextStyle(color: Colors.grey)),
          ],
        ),
        Row(
          children: [
            _buildHeaderAction(Icons.notifications_none_rounded),
            const SizedBox(width: 16),
            _buildHeaderAction(Icons.search_rounded),
            const SizedBox(width: 24),
            const CircleAvatar(radius: 24, backgroundColor: AppTheme.primaryTeal, child: Icon(Icons.person, color: Colors.white)),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderAction(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Icon(icon, color: AppTheme.darkTeal, size: 20),
    );
  }

  Widget _buildStatGrid() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 4,
      crossAxisSpacing: 24,
      childAspectRatio: 1.8,
      children: [
        _buildStatCard("Doanh thu ngày", "12.450.000đ", "+12.5%", Icons.payments_rounded, AppTheme.primaryTeal),
        _buildStatCard("Đơn hàng mới", "42", "+8%", Icons.shopping_bag_rounded, Colors.orange),
        _buildStatCard("Khách hàng", "1.204", "+5.2%", Icons.people_rounded, Colors.blue),
        _buildStatCard("Sản phẩm sắp hết", "18", "-2%", Icons.warning_rounded, Colors.redAccent),
      ],
    );
  }

  Widget _buildStatCard(String title, String val, String trend, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(val, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.darkTeal)),
              const SizedBox(height: 4),
              Text(trend, style: TextStyle(color: trend.startsWith('+') ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartsRow() {
    return Row(
      children: [
        Expanded(flex: 2, child: _buildMainChart()),
        const SizedBox(width: 24),
        Expanded(flex: 1, child: _buildPieChart()),
      ],
    );
  }

  Widget _buildMainChart() {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Biểu đồ doanh thu 7 ngày qua", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.darkTeal)),
          const SizedBox(height: 40),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [FlSpot(0, 3), FlSpot(1, 4), FlSpot(2, 3.5), FlSpot(3, 5), FlSpot(4, 4), FlSpot(5, 6), FlSpot(6, 5)],
                    isCurved: true,
                    color: AppTheme.primaryTeal,
                    barWidth: 6,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: AppTheme.primaryTeal.withValues(alpha: 0.1)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Cơ cấu danh mục", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.darkTeal)),
          const SizedBox(height: 40),
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 0,
                centerSpaceRadius: 60,
                sections: [
                  PieChartSectionData(color: AppTheme.primaryTeal, value: 40, title: 'Thuốc', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  PieChartSectionData(color: Colors.orange, value: 30, title: 'Vitamin', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  PieChartSectionData(color: Colors.blue, value: 30, title: 'Khác', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrders() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Đơn hàng mới nhất", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.darkTeal)),
              TextButton(onPressed: () {}, child: const Text("Xem tất cả", style: TextStyle(color: AppTheme.primaryTeal, fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 24),
          _buildOrderRow("ORD-9921", "Lê Tùng", "Vitamin C, Panadol", "1.250.000đ", "Chờ xử lý"),
          _buildOrderRow("ORD-9920", "Nguyễn An", "Skincare Set", "3.450.000đ", "Đang giao"),
          _buildOrderRow("ORD-9919", "Trần Bình", "Máy đo huyết áp", "850.000đ", "Hoàn thành"),
        ],
      ),
    );
  }

  Widget _buildOrderRow(String id, String name, String items, String total, String status) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(id, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(name)),
          Expanded(flex: 2, child: Text(items, style: TextStyle(color: Colors.grey[600]))),
          Expanded(child: Text(total, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.darkTeal))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: status == "Chờ xử lý" ? Colors.orange.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(status, style: TextStyle(color: status == "Chờ xử lý" ? Colors.orange : Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
