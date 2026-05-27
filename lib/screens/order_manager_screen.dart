import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../features/admin/widgets/admin_common_widgets.dart';
import '../features/admin/theme/admin_theme.dart';

class OrderManagerScreen extends StatefulWidget {
  const OrderManagerScreen({super.key});
  @override
  State<OrderManagerScreen> createState() => _OrderManagerScreenState();
}

class _OrderManagerScreenState extends State<OrderManagerScreen> {
  String selectedFilter = "Tất cả";
  late Stream<QuerySnapshot> _ordersStream;

  num _readNumericValue(dynamic value, {num fallback = 0}) {
    if (value is num) return value;
    return num.tryParse(value?.toString() ?? '') ?? fallback;
  }

  num _readItemQuantity(dynamic item) {
    if (item is! Map<String, dynamic>) return 1;

    final dynamic rawQuantity = item['quantity'] ?? item['qty'] ?? 1;
    return _readNumericValue(rawQuantity, fallback: 1);
  }

  @override
  void initState() {
    super.initState();
    // Removed orderBy to avoid index issues on Web, using client-side sort
    _ordersStream = FirebaseFirestore.instance.collection('orders')
        .limit(200)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isSmall = constraints.maxWidth < 650;
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmall ? 15 : 35, 
              vertical: 30
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(isSmall),
                const SizedBox(height: 35),
                _buildFilterTabs(),
                const SizedBox(height: 30),
                Expanded(child: _buildOrderList()),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _buildHeader(bool isSmall) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AdminTheme.accentGold, Color(0xFFFFF1AD), AdminTheme.accentGold],
          ).createShader(bounds),
          child: Text(
            "TRANSACTION REPOSITORY",
            style: AdminTheme.darkTheme.textTheme.displayLarge?.copyWith(
              fontSize: isSmall ? 22 : 28,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Real-time order management & logistics tracking system",
          style: TextStyle(
            color: AdminTheme.textGrey.withValues(alpha: 0.8),
            fontSize: isSmall ? 11 : 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildFilterTabs() {
    final filters = ["Tất cả", "Chờ Duyệt", "Đang Giao", "Hoàn Thành", "Hủy"];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((f) {
          final isSelected = selectedFilter == f;
          return GestureDetector(
            onTap: () => setState(() => selectedFilter = f),
            child: AnimatedContainer(
              duration: 300.ms,
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AdminTheme.accentGold.withValues(alpha: 0.1) : AdminTheme.cardSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AdminTheme.accentGold : AdminTheme.borderGold,
                  width: isSelected ? 1.5 : 0.5,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: AdminTheme.accentGold.withValues(alpha: 0.2),
                    blurRadius: 15,
                    spreadRadius: -5,
                  )
                ] : [],
              ),
              child: Text(
                f.toUpperCase(),
                style: TextStyle(
                  color: isSelected ? AdminTheme.accentGold : AdminTheme.textGrey,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                  fontSize: 11,
                  letterSpacing: 1,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOrderList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _ordersStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        var docs = snapshot.data!.docs;
        
        // Client-side filtering
        var filteredDocs = docs.where((doc) {
          if (selectedFilter == "Tất cả") return true;
          return doc['status'] == selectedFilter;
        }).toList();

        // Client-side sorting (Newest first)
        filteredDocs.sort((a, b) {
          final timeA = (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
          final timeB = (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
          if (timeA == null || timeB == null) return 0;
          return timeB.compareTo(timeA);
        });

        if (filteredDocs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long_outlined, size: 60, color: AdminTheme.accentGold.withValues(alpha: 0.2)),
                const SizedBox(height: 20),
                Text("No $selectedFilter orders found", style: const TextStyle(color: AdminTheme.textGrey)),
              ],
            ),
          );
        }

        return ListView.separated(
          itemCount: filteredDocs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 20),
          itemBuilder: (context, index) {
            final doc = filteredDocs[index];
            final data = doc.data() as Map<String, dynamic>;
            final id = doc.id;
            return _buildOrderCard(id, data);
          },
        );
      },
    );
  }

  Widget _buildOrderCard(String id, Map<String, dynamic> data) {
    final statusColor = _getStatusColor(data['status']);
    final date = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();

    return GlassCard(
      glowColor: statusColor,
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isSmall = constraints.maxWidth < 650;
          
          if (isSmall) {
            return Column(
              children: [
                Row(
                  children: [
                    _buildLeadingIcon(statusColor),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "ID: #${id.substring(id.length - 6).toUpperCase()}", 
                            style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5)
                          ),
                          Text(
                            data['userName'] ?? "Anonymous Client", 
                            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: AdminTheme.textGrey), 
                            maxLines: 1, 
                            overflow: TextOverflow.ellipsis
                          ),
                        ],
                      ),
                    ),
                    StatusBadge(text: data['status'].toString(), color: statusColor),
                  ],
                ),
                const Divider(height: 30, color: AdminTheme.borderGold, thickness: 0.5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("TIMESTAMP", style: TextStyle(fontSize: 9, color: AdminTheme.textGrey, fontWeight: FontWeight.bold, letterSpacing: 1)),
                        const SizedBox(height: 4),
                        Text(DateFormat('dd MMM, HH:mm').format(date), style: const TextStyle(fontSize: 12, color: Colors.white70)),
                      ],
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text("TOTAL ASSET", style: TextStyle(fontSize: 9, color: AdminTheme.textGrey, fontWeight: FontWeight.bold, letterSpacing: 1)),
                            const SizedBox(height: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Text(
                                "₫${NumberFormat("#,###").format((data['totalPrice'] ?? data['total_price'] ?? 0).toDouble())}", 
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AdminTheme.accentGold)
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _buildViewButton(() => _showOrderDetailDialog(context, id, data)),
                  ],
                )
              ],
            );
          }

          return Row(
            children: [
              _buildLeadingIcon(statusColor),
              const SizedBox(width: 25),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ORDER #${id.substring(id.length - 8).toUpperCase()}", 
                      style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1, fontSize: 15)
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data['userName'] ?? "Anonymous Client", 
                      style: const TextStyle(fontWeight: FontWeight.w500, color: AdminTheme.textGrey, fontSize: 13)
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("TRANSACTION DATE", style: TextStyle(color: AdminTheme.textGrey, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    const SizedBox(height: 6),
                    Text(DateFormat('dd MMM yyyy, HH:mm').format(date), style: const TextStyle(fontSize: 13, color: Colors.white70)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "₫${NumberFormat("#,###").format((data['totalPrice'] ?? data['total_price'] ?? 0).toDouble())}",
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AdminTheme.accentGold, letterSpacing: 0.5)
                      ),
                    ),
                    const SizedBox(height: 6),
                    StatusBadge(text: data['status'].toString(), color: statusColor),
                  ],
                ),
              ),
              const SizedBox(width: 30),
              _buildViewButton(() => _showOrderDetailDialog(context, id, data)),
            ],
          );
        }
      ),
    ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.05, end: 0, curve: Curves.easeOutQuart);
  }

  Widget _buildViewButton(VoidCallback onTap) {
    return IconButton(
      onPressed: onTap,
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: const Icon(Icons.arrow_forward_rounded, size: 18, color: AdminTheme.accentGold),
    );
  }

  void _showOrderDetailDialog(BuildContext context, String id, Map<String, dynamic> data) {
    String currentStatus = data['status'] ?? "Chờ Duyệt";
    final items = data['items'] as List<dynamic>? ?? [];
    bool isCommitting = false;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: StatefulBuilder(
            builder: (context, setModalState) => GlassCard(
              width: MediaQuery.of(context).size.width * 0.9,
              maxWidth: 700,
              glowColor: _getStatusColor(currentStatus),
              padding: const EdgeInsets.all(25),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("TRANSACTION DETAILS", style: TextStyle(color: AdminTheme.accentGold, fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 10)),
                              const SizedBox(height: 4),
                              Text("Manifest: #${id.toUpperCase().substring(0, 8)}", 
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        _buildGlassIconButton(Icons.close_rounded, () => Navigator.pop(context)),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Divider(color: AdminTheme.borderGold, thickness: 0.5),
                    ),
                    LayoutBuilder(
                      builder: (context, c) {
                        bool isSmall = c.maxWidth < 500;
                        return Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildInfoSection("CLIENT", data['userName'] ?? "Anonymous Client", Icons.person_outline_rounded)),
                                if (!isSmall) const SizedBox(width: 20),
                                if (!isSmall) Expanded(child: _buildInfoSection("CONTACT", data['userPhone'] ?? "No Contact", Icons.phone_outlined)),
                              ],
                            ),
                            if (isSmall) const SizedBox(height: 20),
                            if (isSmall) _buildInfoSection("CONTACT", data['userPhone'] ?? "No Contact", Icons.phone_outlined),
                          ],
                        );
                      }
                    ),
                    const SizedBox(height: 20),
                    _buildInfoSection("DELIVERY ENDPOINT", data['address'] ?? "On-site pickup", Icons.location_on_outlined),
                    const SizedBox(height: 30),
                    const Text("ASSET INVENTORY", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: AdminTheme.textGrey, letterSpacing: 1.5)),
                    const SizedBox(height: 15),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final item = items[i];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.03),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AdminTheme.borderGold.withValues(alpha: 0.1)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 35, height: 35,
                                decoration: BoxDecoration(
                                  color: AdminTheme.accentGold.withValues(alpha: 0.1), 
                                  borderRadius: BorderRadius.circular(8)
                                ),
                                child: const Icon(Icons.medication_rounded, size: 18, color: AdminTheme.accentGold),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item['name'] ?? "Unknown Asset", 
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                                      maxLines: 1, overflow: TextOverflow.ellipsis
                                    ),
                                    Text("₫${NumberFormat("#,###").format(item['price'] ?? 0)}", style: const TextStyle(fontSize: 10, color: AdminTheme.textGrey)),
                                  ],
                                ),
                              ),
                              Text("x${_readItemQuantity(item)}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.white)),
                            ],
                          ),
                        );
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: Divider(color: AdminTheme.borderGold, thickness: 0.5),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("TOTAL VALUATION", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AdminTheme.textGrey, letterSpacing: 1)),
                        FittedBox(
                          child: Text("₫${NumberFormat("#,###").format((data['totalPrice'] ?? data['total_price'] ?? 0).toDouble())}",
                               style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: AdminTheme.accentGold, letterSpacing: 1)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    const Text("LIFECYCLE STATUS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: AdminTheme.textGrey, letterSpacing: 1.5)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ["Chờ Duyệt", "Đang Giao", "Hoàn Thành", "Hủy"].map((s) {
                        final isSelected = currentStatus == s;
                        final sColor = _getStatusColor(s);
                        return GestureDetector(
                          onTap: () => setModalState(() => currentStatus = s),
                          child: AnimatedContainer(
                            duration: 200.ms,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? sColor.withValues(alpha: 0.15) : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? sColor : AdminTheme.borderGold,
                                width: isSelected ? 1.5 : 0.5,
                              ),
                            ),
                            child: Text(
                              s.toUpperCase(),
                              style: TextStyle(
                                color: isSelected ? sColor : AdminTheme.textGrey,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: AdminButton(
                        label: "COMMIT STATUS CHANGE",
                        icon: Icons.check_circle_outline_rounded,
                        isLoading: isCommitting,
                        onTap: () async {
                          if (isCommitting) return;

                          setModalState(() => isCommitting = true);
                          try {
                            await FirebaseFirestore.instance.runTransaction((transaction) async {
                              DocumentReference orderRef = FirebaseFirestore.instance.collection('orders').doc(id);
                              DocumentSnapshot orderSnap = await transaction.get(orderRef);
                              Map<String, dynamic> orderData = orderSnap.data() as Map<String, dynamic>;
                              
                              bool wasStockUpdated = orderData['stockUpdated'] ?? false;
                              List<dynamic> orderItems = orderData['items'] ?? [];

                              // 1. Nếu duyệt đơn (Đang Giao/Hoàn Thành) mà CHƯA trừ kho -> Tiến hành trừ kho
                              if ((currentStatus == "Đang Giao" || currentStatus == "Hoàn Thành") && !wasStockUpdated) {
                                final stockUpdates = <Map<String, dynamic>>[];

                                for (var item in orderItems) {
                                  final rawProdId = item is Map<String, dynamic> ? item['id'] : null;
                                  if (rawProdId == null || rawProdId.toString().trim().isEmpty) {
                                    continue;
                                  }
                                  final String prodId = rawProdId.toString();
                                  int buyQty = _readItemQuantity(item).toInt();
                                  DocumentReference prodRef = FirebaseFirestore.instance.collection('medicines').doc(prodId);
                                  DocumentSnapshot prodSnap = await transaction.get(prodRef);
                                  
                                  if (prodSnap.exists) {
                                    final prodData = prodSnap.data() as Map<String, dynamic>? ?? {};
                                    int currentStock = _readNumericValue(prodData['stock']).toInt();
                                    stockUpdates.add({
                                      'ref': prodRef,
                                      'stock': currentStock - buyQty,
                                    });
                                  }
                                }

                                for (final update in stockUpdates) {
                                  transaction.update(update['ref'] as DocumentReference, {'stock': update['stock']});
                                }

                                transaction.update(orderRef, {'stockUpdated': true});
                              }
                              
                              // 2. Nếu Hủy đơn mà TRƯỚC ĐÓ ĐÃ trừ kho -> Cộng lại kho cho cửa hàng
                              else if (currentStatus == "Hủy" && wasStockUpdated) {
                                final stockUpdates = <Map<String, dynamic>>[];

                                for (var item in orderItems) {
                                  final rawProdId = item is Map<String, dynamic> ? item['id'] : null;
                                  if (rawProdId == null || rawProdId.toString().trim().isEmpty) {
                                    continue;
                                  }
                                  final String prodId = rawProdId.toString();
                                  int buyQty = _readItemQuantity(item).toInt();
                                  DocumentReference prodRef = FirebaseFirestore.instance.collection('medicines').doc(prodId);
                                  DocumentSnapshot prodSnap = await transaction.get(prodRef);
                                  
                                  if (prodSnap.exists) {
                                    final prodData = prodSnap.data() as Map<String, dynamic>? ?? {};
                                    int currentStock = _readNumericValue(prodData['stock']).toInt();
                                    stockUpdates.add({
                                      'ref': prodRef,
                                      'stock': currentStock + buyQty,
                                    });
                                  }
                                }

                                for (final update in stockUpdates) {
                                  transaction.update(update['ref'] as DocumentReference, {'stock': update['stock']});
                                }

                                transaction.update(orderRef, {'stockUpdated': false});
                              }

                              // 3. Cập nhật trạng thái đơn hàng
                              transaction.update(orderRef, {'status': currentStatus});
                            });

                            if (mounted) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                const SnackBar(content: Text("✅ Đã cập nhật trạng thái và tồn kho!"), backgroundColor: Colors.teal)
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                SnackBar(content: Text("❌ Lỗi: $e"), backgroundColor: Colors.redAccent)
                              );
                            }
                          } finally {
                            if (mounted) {
                              setModalState(() => isCommitting = false);
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(opacity: anim1, child: ScaleTransition(scale: anim1, child: child));
      },
    );
  }

  Widget _buildInfoSection(String title, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: AdminTheme.textGrey, letterSpacing: 1.5)),
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(icon, size: 16, color: AdminTheme.accentGold.withValues(alpha: 0.7)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(value, style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGlassIconButton(IconData icon, VoidCallback onTap) {
    return IconButton(
      onPressed: onTap,
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: AdminTheme.borderGold, width: 0.5),
      ),
      icon: Icon(icon, color: AdminTheme.textGrey, size: 20),
    );
  }

  Widget _buildLeadingIcon(Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
      child: Icon(Icons.shopping_bag_outlined, color: color, size: 24),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Hoàn Thành': return AdminTheme.tealGlow;
      case 'Đang Giao': return AdminTheme.purpleGlow;
      case 'Hủy': return AdminTheme.pinkGlow;
      default: return AdminTheme.orangeGlow;
    }
  }
}
