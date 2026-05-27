import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../theme/admin_theme.dart';
import '../widgets/admin_common_widgets.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late Stream<QuerySnapshot> _ordersStream;
  late Stream<QuerySnapshot> _medicinesStream;

  @override
  void initState() {
    super.initState();
    _ordersStream = FirebaseFirestore.instance.collection('orders')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots();
    _medicinesStream = FirebaseFirestore.instance.collection('medicines')
        .limit(100)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<QuerySnapshot>(
        stream: _ordersStream,
        builder: (context, orderSnapshot) {
          return StreamBuilder<QuerySnapshot>(
            stream: _medicinesStream,
            builder: (context, medSnapshot) {
              if (!orderSnapshot.hasData || !medSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator(color: AdminTheme.accentGold));
              }

              final orders = orderSnapshot.data!.docs;
              final medicines = medSnapshot.data!.docs;

              double totalRevenue = 0;
              int pendingOrders = 0;
              int totalStock = 0;
              int ordersToday = 0;
              final now = DateTime.now();

              Map<String, int> productSales = {};
              Map<String, int> categoryCounts = {};
              Map<int, double> monthlyRevenue = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0, 8: 0, 9: 0, 10: 0, 11: 0, 12: 0};

              for (var doc in orders) {
                final data = doc.data() as Map<String, dynamic>;
                final status = data['status'] ?? 'Chờ Duyệt';
                final price = (data['totalPrice'] ?? data['total_price'] ?? 0).toDouble();
                final date = (data['createdAt'] as Timestamp?)?.toDate() ?? now;

                if (status == 'Hoàn Thành') {
                  totalRevenue += price;
                  if (date.year == now.year) {
                    monthlyRevenue[date.month] = (monthlyRevenue[date.month] ?? 0) + price;
                  }

                  final items = data['items'] as List? ?? [];
                  for (var item in items) {
                    final itemName = item['name'] ?? 'Unknown';
                    productSales[itemName] = (productSales[itemName] ?? 0) + (item['quantity'] as int? ?? 1);
                  }
                }

                if (status == 'Chờ Duyệt') pendingOrders++;
                if (date.day == now.day && date.month == now.month && date.year == now.year) ordersToday++;
              }

              for (var doc in medicines) {
                final data = doc.data() as Map<String, dynamic>;
                totalStock += (data['stock'] as int? ?? 0);
                final cat = data['category'] ?? 'Khác';
                categoryCounts[cat] = (categoryCounts[cat] ?? 0) + 1;
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeHeader(),
                    const SizedBox(height: 35),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = constraints.maxWidth > 1200 ? 4 : (constraints.maxWidth > 700 ? 2 : 1);
                        // Tăng tỉ lệ aspectRatio để các thẻ có thêm chiều cao khi màn hình nhỏ
                        double aspectRatio = constraints.maxWidth > 1200 ? 1.5 : (constraints.maxWidth > 700 ? 1.8 : 2.8);
                        return GridView.count(
                          crossAxisCount: crossAxisCount,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          childAspectRatio: aspectRatio,
                          children: [
                            _buildStatCard("TỔNG DOANH THU", "₫${NumberFormat.compact().format(totalRevenue)}", Icons.payments_rounded, AdminTheme.tealGlow),
                            _buildStatCard("SẢN PHẨM TRONG KHO", totalStock.toString(), Icons.inventory_2_rounded, AdminTheme.purpleGlow),
                            _buildStatCard("ĐƠN CHỜ DUYỆT", pendingOrders.toString(), Icons.hourglass_top_rounded, AdminTheme.orangeGlow),
                            _buildStatCard("ĐƠN HÔM NAY", ordersToday.toString(), Icons.shopping_bag_rounded, AdminTheme.pinkGlow),
                          ],
                        );
                      }
                    ),
                    const SizedBox(height: 35),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        bool isDesktop = constraints.maxWidth > 950;
                        return Column(
                          children: [
                            if (isDesktop) 
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(flex: 2, child: _buildRevenueBarChart(monthlyRevenue)),
                                  const SizedBox(width: 30),
                                  Expanded(child: _buildRecentActivity(orders)),
                                ],
                              )
                            else ...[
                              _buildRevenueBarChart(monthlyRevenue),
                              const SizedBox(height: 30),
                              _buildRecentActivity(orders),
                            ],
                          ],
                        );
                      }
                    ),
                    const SizedBox(height: 35),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        bool isDesktop = constraints.maxWidth > 800;
                        return isDesktop 
                          ? Row(
                              children: [
                                Expanded(child: _buildCategoryPieChart(categoryCounts)),
                                const SizedBox(width: 25),
                                Expanded(child: _buildTopProductsList(productSales)),
                              ],
                            )
                          : Column(
                              children: [
                                _buildCategoryPieChart(categoryCounts),
                                const SizedBox(height: 25),
                                _buildTopProductsList(productSales),
                              ],
                            );
                      }
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

  Widget _buildWelcomeHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isSmall = constraints.maxWidth < 600;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("COMMAND CENTER", 
                    style: TextStyle(
                      fontSize: isSmall ? 24 : 32, 
                      fontWeight: FontWeight.w900, 
                      letterSpacing: 2, 
                      color: AdminTheme.accentGold
                    )
                  ),
                  const SizedBox(height: 4),
                  const Text("Hệ thống quản trị thời gian thực đang hoạt động tối ưu.", 
                    style: TextStyle(color: Colors.white24, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (!isSmall) _buildDateCard(),
          ],
        );
      }
    );
  }

  Widget _buildDateCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: AdminTheme.cardSurface, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_rounded, color: AdminTheme.accentGold, size: 14),
          const SizedBox(width: 10),
          Text(DateFormat('dd MMM, yyyy').format(DateTime.now()).toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }


  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return GlassCard(
      glowColor: color,
      padding: const EdgeInsets.all(15), // Giảm padding một chút để lấy thêm không gian
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Đảm bảo column thu gọn nhất có thể
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8), 
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), 
                child: Icon(icon, color: color, size: 16)
              ),
              Expanded( // Wrap text tiêu đề để tránh tràn ngang
                child: Text(
                  title, 
                  textAlign: TextAlign.right,
                  style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          FittedBox( // TỰ ĐỘNG THU NHỎ GIÁ TIỀN NẾU QUÁ DÀI
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text("+12.5%", style: TextStyle(color: AdminTheme.tealGlow, fontSize: 10, fontWeight: FontWeight.bold)),
              const SizedBox(width: 5),
              const Expanded(
                child: Text(
                  "vs tháng trước", 
                  style: TextStyle(color: Colors.white10, fontSize: 9),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueBarChart(Map<int, double> monthlyData) {
    final now = DateTime.now();
    return GlassCard(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("DOANH THU HÀNG THÁNG", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
          const SizedBox(height: 30),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, m) {
                        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                        int idx = v.toInt();
                        if (idx >= 0 && idx < 12) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(months[idx], style: const TextStyle(color: Colors.white24, fontSize: 10)),
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
                  int monthNum = now.month - 5 + index;
                  if (monthNum <= 0) monthNum += 12;
                  double val = (monthlyData[monthNum] ?? 0) / 1000000;
                  return BarChartGroupData(
                    x: monthNum - 1,
                    barRods: [
                      BarChartRodData(
                        toY: val == 0 ? 0.1 : val,
                        color: AdminTheme.accentGold,
                        width: 18,
                        borderRadius: BorderRadius.circular(4),
                      )
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPieChart(Map<String, int> categoryCounts) {
    List<Color> colors = [AdminTheme.tealGlow, AdminTheme.purpleGlow, AdminTheme.orangeGlow, AdminTheme.pinkGlow];
    int i = 0;
    
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("PHÂN LOẠI SẢN PHẨM", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: PieChart(
              PieChartData(
                sectionsSpace: 5,
                centerSpaceRadius: 40,
                sections: categoryCounts.isEmpty 
                  ? [PieChartSectionData(value: 1, color: Colors.white10, radius: 15, showTitle: false)]
                  : categoryCounts.entries.map((e) {
                      final color = colors[i % colors.length];
                      i++;
                      return PieChartSectionData(
                        value: e.value.toDouble(),
                        title: e.key,
                        color: color,
                        radius: 15,
                        showTitle: false,
                      );
                    }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: categoryCounts.keys.map((k) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 8, height: 8, color: colors[categoryCounts.keys.toList().indexOf(k) % colors.length]),
                const SizedBox(width: 4),
                Text(k, style: const TextStyle(color: Colors.white38, fontSize: 10)),
              ],
            )).toList(),
          )
        ],
      ),
    );
  }

  Widget _buildTopProductsList(Map<String, int> productSales) {
    final sortedProducts = productSales.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final products = sortedProducts.take(3).toList();
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("TOP SẢN PHẨM BÁN CHẠY", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 15),
          ...products.map((e) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(e.key, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                Text("${e.value} lượt bán", style: const TextStyle(color: AdminTheme.accentGold, fontWeight: FontWeight.bold, fontSize: 11)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(List<QueryDocumentSnapshot> orders) {
    final recentOrders = orders.take(6).toList();
    return GlassCard(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("HOẠT ĐỘNG GẦN ĐÂY", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
          const SizedBox(height: 20),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentOrders.length,
            separatorBuilder: (_, __) => const Divider(color: Colors.white10, height: 25),
            itemBuilder: (context, index) {
              final data = recentOrders[index].data() as Map<String, dynamic>;
              return Row(
                children: [
                  Container(
                    width: 35, 
                    height: 35, 
                    decoration: BoxDecoration(
                      color: AdminTheme.tealGlow.withValues(alpha: 0.1), 
                      borderRadius: BorderRadius.circular(8)
                    ), 
                    child: const Icon(Icons.shopping_cart, color: AdminTheme.tealGlow, size: 16)
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, 
                      children: [
                        Text(data['userName'] ?? "Khách hàng", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)), 
                        Text("₫${NumberFormat("#,###").format(data['totalPrice'] ?? data['total_price'] ?? 0)}", style: const TextStyle(color: Colors.white38, fontSize: 11))
                      ]
                    )
                  ),
                  Text("Mới", style: TextStyle(color: AdminTheme.accentGold.withValues(alpha: 0.5), fontSize: 10)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
