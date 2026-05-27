import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../theme/admin_theme.dart';
import '../widgets/admin_common_widgets.dart';

class CustomerScreen extends ConsumerStatefulWidget {
  const CustomerScreen({super.key});

  @override
  ConsumerState<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends ConsumerState<CustomerScreen> {
  late Stream<QuerySnapshot> _usersStream;
  late Stream<QuerySnapshot> _ordersStream;

  @override
  void initState() {
    super.initState();
    _usersStream = FirebaseFirestore.instance.collection('users').snapshots();
    _ordersStream = FirebaseFirestore.instance.collection('orders').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "QUẢN LÝ KHÁCH HÀNG",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: AdminTheme.accentGold,
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _usersStream,
                builder: (context, userSnapshot) {
                  return StreamBuilder<QuerySnapshot>(
                    stream: _ordersStream,
                    builder: (context, orderSnapshot) {
                      if (!userSnapshot.hasData || !orderSnapshot.hasData) {
                        return const Center(child: CircularProgressIndicator(color: AdminTheme.accentGold));
                      }

                      final users = userSnapshot.data!.docs;
                      final orders = orderSnapshot.data!.docs;

                      // Map để tính toán chi tiêu khách hàng
                      Map<String, double> userSpending = {};
                      Map<String, int> userOrderCount = {};

                      for (var orderDoc in orders) {
                        final orderData = orderDoc.data() as Map<String, dynamic>;
                        final uid = orderData['userId'] ?? '';
                        final total = (orderData['totalPrice'] ?? 0).toDouble();
                        final status = orderData['status'] ?? '';

                        if (status == 'Hoàn Thành') {
                          userSpending[uid] = (userSpending[uid] ?? 0) + total;
                        }
                        userOrderCount[uid] = (userOrderCount[uid] ?? 0) + 1;
                      }

                      return GlassCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _buildTableHeader(),
                            const Divider(color: Colors.white10),
                            Expanded(
                              child: ListView.separated(
                                itemCount: users.length,
                                separatorBuilder: (_, __) => const Divider(color: Colors.white10, height: 1),
                                itemBuilder: (context, index) {
                                  final userData = users[index].data() as Map<String, dynamic>;
                                  final uid = users[index].id;
                                  return _buildCustomerRow(
                                    userData,
                                    userSpending[uid] ?? 0,
                                    userOrderCount[uid] ?? 0,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text("KHÁCH HÀNG", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold))),
          Expanded(flex: 3, child: Text("LIÊN HỆ", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text("SỐ ĐƠN", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text("TỔNG CHI TIÊU", style: TextStyle(color: AdminTheme.accentGold, fontSize: 11, fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text("ĐỊA CHỈ", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildCustomerRow(Map<String, dynamic> data, double spending, int orderCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AdminTheme.accentGold.withOpacity(0.1),
                  child: Text(
                    (data['name'] ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(color: AdminTheme.accentGold, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['name'] ?? 'N/A', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                      const Text("Hạng Silver", style: TextStyle(color: Colors.white24, fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['email'] ?? 'N/A', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                Text(data['phone'] ?? 'N/A', style: const TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(6)),
              child: Text("$orderCount đơn", style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "₫${NumberFormat("#,###").format(spending)}",
              style: const TextStyle(color: AdminTheme.accentGold, fontWeight: FontWeight.w900, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              data['address'] ?? 'Chưa cập nhật',
              style: const TextStyle(color: Colors.white38, fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
