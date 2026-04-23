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
  String _filter = "Tất cả"; // "Tất cả", "Hôm nay", "Tuần này", "Tháng này"

  bool _isInRange(DateTime date) {
    DateTime now = DateTime.now();
    if (_filter == "Hôm nay") {
      return date.year == now.year && date.month == now.month && date.day == now.day;
    } else if (_filter == "Tuần này") {
      DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      startOfWeek = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
      return date.isAfter(startOfWeek.subtract(const Duration(seconds: 1)));
    } else if (_filter == "Tháng này") {
      return date.year == now.year && date.month == now.month;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat("#,###", "vi_VN");

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("THỐNG KÊ DOANH THU", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: "Tất cả", label: Text("Tất cả")),
                ButtonSegment(value: "Hôm nay", label: Text("Hôm nay")),
                ButtonSegment(value: "Tuần này", label: Text("Tuần")),
                ButtonSegment(value: "Tháng này", label: Text("Tháng")),
              ],
              selected: {_filter},
              onSelectionChanged: (newVal) => setState(() => _filter = newVal.first),
            ),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('invoices')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var docs = snapshot.data!.docs;
          int totalRevenue = 0;
          List<FlSpot> spots = [];
          Map<String, int> dailyRevenue = {};

          for (var doc in docs) {
            var data = doc.data() as Map<String, dynamic>;
            Timestamp? ts = data['timestamp'] as Timestamp?;
            if (ts == null) continue;

            DateTime date = ts.toDate();
            if (!_isInRange(date)) continue;

            int price = int.tryParse(data['totalPrice']?.toString() ?? '0') ?? 0;
            totalRevenue += price;

            String dateKey = "${date.day}/${date.month}";
            dailyRevenue[dateKey] = (dailyRevenue[dateKey] ?? 0) + price;
          }

          // Tạo dữ liệu cho biểu đồ
          int i = 0;
          dailyRevenue.forEach((date, value) {
            spots.add(FlSpot(i.toDouble(), value.toDouble()));
            i++;
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thẻ tổng doanh thu
                Card(
                  color: Colors.cyan,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Text("DOANH THU ${_filter.toUpperCase()}", style: const TextStyle(color: Colors.white70, fontSize: 16)),
                        const SizedBox(height: 12),
                        FittedBox(
                          child: Text("${fmt.format(totalRevenue)} VNĐ",
                              style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                Text("Biểu đồ tăng trưởng ($_filter)", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),

                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: SizedBox(
                      height: 420,
                      child: spots.isEmpty
                          ? const Center(child: Text("Không có dữ liệu trong khoảng thời gian này"))
                          : LineChart(
                              LineChartData(
                                gridData: const FlGridData(show: true, drawVerticalLine: false),
                                titlesData: const FlTitlesData(
                                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 60)),
                                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                ),
                                borderData: FlBorderData(show: false),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: spots,
                                    isCurved: true,
                                    color: Colors.cyan,
                                    barWidth: 5,
                                    isStrokeCapRound: true,
                                    dotData: const FlDotData(show: true),
                                    belowBarData: BarAreaData(show: true, color: Colors.cyan.withOpacity(0.15)),
                                  )
                                ],
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}