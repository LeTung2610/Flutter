import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../features/admin/widgets/admin_common_widgets.dart';
import '../features/admin/theme/admin_theme.dart';

class RevenueScreen extends StatefulWidget {
  const RevenueScreen({super.key});

  @override
  State<RevenueScreen> createState() => _RevenueScreenState();
}

class _RevenueScreenState extends State<RevenueScreen> {
  late Stream<QuerySnapshot> _revenueStream;

  @override
  void initState() {
    super.initState();
    // Removed specific where filter to allow client-side handling if needed, 
    // but keep it if performance is key. For now, just ensuring it's initialized here.
    _revenueStream = FirebaseFirestore.instance.collection('orders').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<QuerySnapshot>(
        stream: _revenueStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AdminTheme.accentGold));
          }

          final docs = snapshot.data?.docs ?? [];
          double totalRevenue = 0;
          Map<int, double> monthlyData = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0, 8: 0, 9: 0, 10: 0, 11: 0, 12: 0};
          Map<int, double> dailyData = {}; // Store day -> revenue
          Map<String, double> categoryData = {};
          
          final now = DateTime.now();

          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            if (data['status'] != 'Hoàn Thành') continue;

            final price = (data['totalPrice'] ?? data['total_price'] ?? 0).toDouble();
            final date = (data['createdAt'] as Timestamp?)?.toDate() ?? now;

            totalRevenue += price;
            
            // Monthly accumulation
            if (date.year == now.year) {
              monthlyData[date.month] = (monthlyData[date.month] ?? 0) + price;
            }

            // Daily accumulation for current month
            if (date.year == now.year && date.month == now.month) {
              dailyData[date.day] = (dailyData[date.day] ?? 0) + price;
            }

            final items = data['items'] as List? ?? [];
            for (var item in items) {
              final cat = item['category'] ?? 'Dược phẩm'; // Default to Dược phẩm
              final itemTotal = ((item['price'] ?? 0) * (item['quantity'] ?? 1)).toDouble();
              categoryData[cat] = (categoryData[cat] ?? 0) + itemTotal;
            }
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              bool isSmall = constraints.maxWidth < 900;
              return SingleChildScrollView(
                padding: EdgeInsets.all(isSmall ? 20 : 35),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 40),
                    _buildMainRevenueCard(isSmall, totalRevenue),
                    const SizedBox(height: 40),
                    if (isSmall) ...[
                      _buildChartWithTitle("Monthly Revenue (Million ₫)", Icons.bar_chart_rounded, _buildBarChart(monthlyData)),
                      const SizedBox(height: 30),
                      _buildChartWithTitle("Category Distribution", Icons.pie_chart_rounded, _buildPieChart(categoryData)),
                      const SizedBox(height: 30),
                      _buildDailyRevenueTable(dailyData),
                    ] else ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 2, child: _buildChartWithTitle("Monthly Revenue (Million ₫)", Icons.bar_chart_rounded, _buildBarChart(monthlyData))),
                          const SizedBox(width: 30),
                          Expanded(child: _buildChartWithTitle("Category Distribution", Icons.pie_chart_rounded, _buildPieChart(categoryData))),
                        ],
                      ),
                      const SizedBox(height: 30),
                      _buildDailyRevenueTable(dailyData),
                    ],
                  ],
                ),
              );
            }
          );
        }
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AdminTheme.accentGold, Color(0xFFFFF1AD), AdminTheme.accentGold],
          ).createShader(bounds),
          child: const Text(
            "FINANCIAL ANALYTICS",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "In-depth revenue stream analysis and business intelligence",
          style: TextStyle(
            color: AdminTheme.textGrey.withAlpha(200),
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildChartWithTitle(String title, IconData icon, Widget chart) {
    return GlassCard(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AdminTheme.accentGold, size: 20),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 25),
          chart,
        ],
      ),
    );
  }

  Widget _buildMainRevenueCard(bool isSmall, double total) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmall ? 35 : 50),
      decoration: BoxDecoration(
        color: AdminTheme.cardSurface,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: AdminTheme.borderGold),
        boxShadow: [
          BoxShadow(
            color: AdminTheme.accentGold.withAlpha(15),
            blurRadius: 40,
            spreadRadius: -10,
          )
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AdminTheme.accentGold.withAlpha(25),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("NET REVENUE ASSETS", style: TextStyle(color: AdminTheme.accentGold, fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 14)),
                    SizedBox(height: 4),
                    Text("Consolidated from completed transactions", 
                      style: TextStyle(color: AdminTheme.textGrey, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _buildMiniBadge(Icons.analytics_outlined, "REAL-TIME"),
            ],
          ),
          const SizedBox(height: 40),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              "₫${NumberFormat("#,###").format(total)}", 
              style: TextStyle(
                color: Colors.white, 
                fontSize: isSmall ? 48 : 64, 
                fontWeight: FontWeight.w900, 
                letterSpacing: -1,
                shadows: [
                  Shadow(
                    color: AdminTheme.accentGold.withAlpha(80),
                    blurRadius: 20,
                  )
                ]
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.trending_up, color: Colors.greenAccent, size: 20),
              const SizedBox(width: 8),
              Text(
                "Data synchronized with global repository",
                style: TextStyle(color: Colors.greenAccent.withAlpha(200), fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack);
  }

  Widget _buildBarChart(Map<int, double> monthlyData) {
    final now = DateTime.now();
    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const titles = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                  int idx = value.toInt();
                  if (idx >= 0 && idx < 12) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(titles[idx], style: const TextStyle(color: AdminTheme.textGrey, fontSize: 10)),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(6, (index) {
            int monthNum = now.month - 5 + index;
            if (monthNum <= 0) monthNum += 12;
            double val = (monthlyData[monthNum] ?? 0) / 1000000;
            return _makeGroupData(monthNum - 1, val);
          }),
        ),
      ),
    );
  }

  Widget _buildPieChart(Map<String, double> categoryData) {
    if (categoryData.isEmpty) {
      return const Center(child: Text("No data available", style: TextStyle(color: AdminTheme.textGrey)));
    }

    final List<Color> colors = [AdminTheme.accentGold, Colors.tealAccent, Colors.purpleAccent, Colors.orangeAccent, Colors.pinkAccent];
    int colorIdx = 0;

    return SizedBox(
      height: 300,
      child: PieChart(
        PieChartData(
          sectionsSpace: 5,
          centerSpaceRadius: 40,
          sections: categoryData.entries.map((e) {
            final color = colors[colorIdx % colors.length];
            colorIdx++;
            return PieChartSectionData(
              color: color, 
              value: e.value, 
              title: e.key, 
              radius: 50, 
              titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
            );
          }).toList(),
        ),
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y == 0 ? 0.1 : y,
          color: AdminTheme.accentGold,
          width: 16,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }

  Widget _buildMiniBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AdminTheme.accentGold.withAlpha(40),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminTheme.accentGold.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AdminTheme.accentGold, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: AdminTheme.accentGold, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyRevenueTable(Map<int, double> dailyData) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    
    // Sort days descending
    final sortedDays = dailyData.keys.toList()..sort((a, b) => b.compareTo(a));

    return GlassCard(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("DAILY REVENUE LOG", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Text("Month ${now.month}/${now.year}", style: const TextStyle(color: AdminTheme.textGrey, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          if (sortedDays.isEmpty)
            const Center(child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text("No transactions recorded this month", style: TextStyle(color: AdminTheme.textGrey)),
            ))
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sortedDays.length > 7 ? 7 : sortedDays.length, // Show last 7 active days
              separatorBuilder: (_, __) => Divider(color: Colors.white.withAlpha(10), height: 20),
              itemBuilder: (context, index) {
                final day = sortedDays[index];
                final amount = dailyData[day] ?? 0;
                return Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AdminTheme.accentGold.withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        day.toString().padLeft(2, '0'),
                        style: const TextStyle(color: AdminTheme.accentGold, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 15),
                    const Expanded(
                      child: Text("Total daily aggregation", style: TextStyle(color: AdminTheme.textGrey, fontSize: 13)),
                    ),
                    Text(
                      "₫${NumberFormat("#,###").format(amount)}",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}
