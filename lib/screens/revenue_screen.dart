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
  String _filter = 'Tất cả';

  DateTime _dateOnly(DateTime value) => DateTime(value.year, value.month, value.day);

  bool _isInRange(DateTime date) {
    final now = _dateOnly(DateTime.now());
    final target = _dateOnly(date);

    if (_filter == 'Hôm nay') {
      return target == now;
    }
    if (_filter == 'Tuần này') {
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      return !target.isBefore(startOfWeek);
    }
    if (_filter == 'Tháng này') {
      return target.year == now.year && target.month == now.month;
    }
    return true;
  }

  String _filterLabel() {
    switch (_filter) {
      case 'Hôm nay':
        return 'Hôm nay';
      case 'Tuần này':
        return 'Tuần này';
      case 'Tháng này':
        return 'Tháng này';
      default:
        return 'Tất cả';
    }
  }

  double _niceInterval(double maxY) {
    if (maxY <= 0) return 1;
    if (maxY <= 50000) return 10000;
    if (maxY <= 200000) return 50000;
    if (maxY <= 1000000) return 200000;
    return maxY / 5;
  }

  @override
  Widget build(BuildContext context) {
    final moneyFmt = NumberFormat('#,###', 'vi_VN');
    final compactFmt = NumberFormat.compact(locale: 'vi_VN');

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: const Text(
          'THỐNG KÊ DOANH THU',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'Tất cả', label: Text('Tất cả')),
                ButtonSegment(value: 'Hôm nay', label: Text('Hôm nay')),
                ButtonSegment(value: 'Tuần này', label: Text('Tuần')),
                ButtonSegment(value: 'Tháng này', label: Text('Tháng')),
              ],
              selected: {_filter},
              onSelectionChanged: (value) => setState(() => _filter = value.first),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('invoices')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          int totalRevenue = 0;
          int orderCount = 0;
          final revenueByDay = <DateTime, int>{};

          for (final doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final ts = data['timestamp'] as Timestamp?;
            if (ts == null) continue;

            final date = ts.toDate();
            if (!_isInRange(date)) continue;

            final day = _dateOnly(date);
            final amount = int.tryParse(data['totalPrice']?.toString() ?? '0') ?? 0;

            totalRevenue += amount;
            orderCount += 1;
            revenueByDay[day] = (revenueByDay[day] ?? 0) + amount;
          }

          final sortedDays = revenueByDay.keys.toList()..sort();
          final chartData = sortedDays
              .map(
                (day) => _RevenuePoint(
                  date: day,
                  revenue: revenueByDay[day] ?? 0,
                ),
              )
              .toList();

          _RevenuePoint? bestDay;
          for (final point in chartData) {
            if (bestDay == null || point.revenue > bestDay.revenue) {
              bestDay = point;
            }
          }

          final avgOrder = orderCount == 0 ? 0 : totalRevenue ~/ orderCount;
          final maxRevenue = chartData.isEmpty
              ? 1000.0
              : (chartData.map((e) => e.revenue).reduce((a, b) => a > b ? a : b) * 1.25) + 1;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF06B6D4).withOpacity(0.20),
                          blurRadius: 24,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DOANH THU ${_filterLabel().toUpperCase()}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${moneyFmt.format(totalRevenue)} VNĐ',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$orderCount đơn hàng • TB ${moneyFmt.format(avgOrder)} VNĐ/đơn',
                          style: const TextStyle(color: Colors.white70, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth > 900;
                      final cardWidth = wide
                          ? (constraints.maxWidth - 48) / 4
                          : (constraints.maxWidth - 16) / 2;

                      return Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _StatCard(
                            width: cardWidth,
                            title: 'Tổng doanh thu',
                            value: '${moneyFmt.format(totalRevenue)} VNĐ',
                            icon: Icons.payments_rounded,
                            color: const Color(0xFF0EA5E9),
                          ),
                          _StatCard(
                            width: cardWidth,
                            title: 'Đơn hàng',
                            value: compactFmt.format(orderCount),
                            icon: Icons.receipt_long_rounded,
                            color: const Color(0xFF22C55E),
                          ),
                          _StatCard(
                            width: cardWidth,
                            title: 'Trung bình/đơn',
                            value: '${moneyFmt.format(avgOrder)} VNĐ',
                            icon: Icons.query_stats_rounded,
                            color: const Color(0xFFF59E0B),
                          ),
                          _StatCard(
                            width: cardWidth,
                            title: 'Ngày cao nhất',
                            value: bestDay == null ? 'N/A' : '${moneyFmt.format(bestDay.revenue)} VNĐ',
                            subtitle: bestDay == null ? null : DateFormat('dd/MM/yyyy').format(bestDay.date),
                            icon: Icons.trending_up_rounded,
                            color: const Color(0xFF8B5CF6),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Biểu đồ doanh thu theo ngày',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey[900],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      height: 360,
                      child: chartData.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.bar_chart_rounded, size: 64, color: Colors.grey[400]),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Không có dữ liệu trong khoảng thời gian này',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            )
                          : BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: maxRevenue,
                                barTouchData: BarTouchData(
                                  enabled: true,
                                  touchTooltipData: BarTouchTooltipData(
                                    tooltipRoundedRadius: 12,
                                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                      final point = chartData[group.x.toInt()];
                                      return BarTooltipItem(
                                        '${DateFormat('dd/MM').format(point.date)}\n',
                                        const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: '${moneyFmt.format(point.revenue)} VNĐ',
                                            style: const TextStyle(color: Colors.white),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 56,
                                      interval: _niceInterval(maxRevenue),
                                      getTitlesWidget: (value, meta) => Padding(
                                        padding: const EdgeInsets.only(right: 8),
                                        child: Text(
                                          compactFmt.format(value).replaceAll(',', '.'),
                                          style: TextStyle(color: Colors.grey[600], fontSize: 11),
                                        ),
                                      ),
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 32,
                                      interval: 1,
                                      getTitlesWidget: (value, meta) {
                                        final index = value.toInt();
                                        if (index < 0 || index >= chartData.length) {
                                          return const SizedBox.shrink();
                                        }
                                        final shouldShow = chartData.length <= 10 || index % 2 == 0;
                                        if (!shouldShow) return const SizedBox.shrink();
                                        return SideTitleWidget(
                                          axisSide: meta.axisSide,
                                          child: Text(
                                            DateFormat('dd/MM').format(chartData[index].date),
                                            style: TextStyle(color: Colors.grey[600], fontSize: 11),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                ),
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  horizontalInterval: _niceInterval(maxRevenue),
                                  getDrawingHorizontalLine: (value) => FlLine(
                                    color: Colors.grey.shade200,
                                    strokeWidth: 1,
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                barGroups: [
                                  for (int i = 0; i < chartData.length; i++)
                                    BarChartGroupData(
                                      x: i,
                                      barRods: [
                                        BarChartRodData(
                                          toY: chartData[i].revenue.toDouble(),
                                          width: 18,
                                          borderRadius: BorderRadius.circular(8),
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFF0EA5E9), Color(0xFF22C55E)],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (chartData.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Top ngày doanh thu',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.grey[900],
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...chartData.take(5).map(
                                (point) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF06B6D4),
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          DateFormat('dd/MM/yyyy').format(point.date),
                                          style: const TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      Text(
                                        '${moneyFmt.format(point.revenue)} VNĐ',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
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

class _RevenuePoint {
  final DateTime date;
  final int revenue;

  _RevenuePoint({
    required this.date,
    required this.revenue,
  });
}

class _StatCard extends StatelessWidget {
  final double width;
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  const _StatCard({
    required this.width,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.grey[900],
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
