import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../features/admin/widgets/admin_common_widgets.dart';
import '../features/admin/theme/admin_theme.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});
  @override State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  List<Map<String, dynamic>> cart = [];
  String searchQuery = "";
  late Stream<QuerySnapshot> _medicinesStream;

  @override
  void initState() {
    super.initState();
    _medicinesStream = FirebaseFirestore.instance.collection('medicines').snapshots();
  }

  void _addToCart(Map<String, dynamic> item, String id) {
    setState(() {
      final index = cart.indexWhere((element) => element['id'] == id);
      if (index >= 0) {
        cart[index]['qty']++;
      } else {
        cart.add({...item, 'id': id, 'qty': 1});
      }
    });
  }

  num get totalAmount => cart.fold(0.0, (sum, item) => sum + (item['price'] as num) * (item['qty'] as int));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isSmall = constraints.maxWidth < 900;
          return Row(
            children: [
              // LEFT: PRODUCT GRID
              Expanded(
                flex: 3,
                child: Padding(
                  padding: EdgeInsets.all(isSmall ? 15 : 35),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(isSmall),
                      const SizedBox(height: 30),
                      _buildSearchField(),
                      const SizedBox(height: 30),
                      Expanded(child: _buildProductGrid()),
                      if (isSmall && cart.isNotEmpty) ...[
                        const SizedBox(height: 15),
                        _buildMobileCartSummary(),
                      ],
                    ],
                  ),
                ),
              ),
              // RIGHT: CART SIDEBAR (Desktop)
              if (!isSmall) _buildCartSidebar(),
            ],
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
            "POS TERMINAL",
            style: AdminTheme.darkTheme.textTheme.displayLarge?.copyWith(
              fontSize: 28,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Unified Fintech & Inventory management system",
          style: TextStyle(
            color: AdminTheme.textGrey.withValues(alpha: 0.8),
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildMobileCartSummary() {
    return InkWell(
      onTap: () => _showMobileCartDrawer(),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        borderRadius: 20,
        child: Row(
          children: [
            const Icon(Icons.shopping_cart_checkout_rounded, color: AdminTheme.primaryTeal),
            const SizedBox(width: 15),
            Expanded(
              child: Text("${cart.length} sản phẩm", style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text("₫${NumberFormat("#,###").format(totalAmount)}", 
                   style: const TextStyle(fontWeight: FontWeight.w900, color: AdminTheme.primaryTeal, fontSize: 18)),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.arrow_upward_rounded, size: 16, color: AdminTheme.textGrey),
          ],
        ),
      ),
    ).animate().slideY(begin: 1, end: 0);
  }

  void _showMobileCartDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 25),
              const Text("GIỎ HÀNG CỦA BẠN", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 20),
              Expanded(child: _buildCartItems()),
              const Divider(height: 40),
              _buildTotalSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: AdminTheme.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AdminTheme.borderGold),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: TextField(
        onChanged: (v) => setState(() => searchQuery = v.toLowerCase()),
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: "Scan barcode or search assets...",
          hintStyle: TextStyle(color: AdminTheme.textGrey.withValues(alpha: 0.6), fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded, color: AdminTheme.accentGold),
          suffixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AdminTheme.accentGold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.qr_code_scanner_rounded, color: AdminTheme.accentGold, size: 20),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildProductGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: _medicinesStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs.where((d) => d['name'].toString().toLowerCase().contains(searchQuery)).toList();
        
        return LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = constraints.maxWidth > 1000 ? 3 : (constraints.maxWidth > 600 ? 2 : 1);
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 0.82,
              ),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;
                final id = docs[index].id;
                return _buildPosCard(data, id);
              },
            );
          }
        );
      },
    );
  }

  Widget _buildPosCard(Map<String, dynamic> data, String id) {
    return GestureDetector(
      onTap: () => _addToCart(data, id),
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        glowColor: AdminTheme.accentGold.withValues(alpha: 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: data['imageUrl'] != null 
                    ? Image.network(
                        data['imageUrl'], 
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image_rounded, size: 40, color: AdminTheme.accentGold),
                      )
                    : const Icon(Icons.medication_rounded, size: 40, color: AdminTheme.accentGold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              data['name'], 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white), 
              maxLines: 1, 
              overflow: TextOverflow.ellipsis
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "₫${NumberFormat("#,###").format(data['price'])}", 
                  style: const TextStyle(color: AdminTheme.accentGold, fontWeight: FontWeight.w900, fontSize: 14)
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AdminTheme.accentGold.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add_rounded, color: AdminTheme.accentGold, size: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().scale(begin: const Offset(0.95, 0.95), duration: 200.ms);
  }

  Widget _buildCartSidebar() {
    return Container(
      width: 400,
      margin: const EdgeInsets.all(25),
      child: GlassCard(
        glowColor: AdminTheme.accentGold.withValues(alpha: 0.1),
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AdminTheme.accentGold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.shopping_cart_outlined, color: AdminTheme.accentGold, size: 20),
                ),
                const SizedBox(width: 15),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("ACTIVE BUCKET", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1, color: Colors.white)),
                    Text("Transaction session", style: TextStyle(fontSize: 10, color: AdminTheme.textGrey)),
                  ],
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 25),
              child: Divider(color: AdminTheme.borderGold, thickness: 0.5),
            ),
            Expanded(child: _buildCartItems()),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 25),
              child: Divider(color: AdminTheme.borderGold, thickness: 0.5),
            ),
            _buildTotalSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItems() {
    if (cart.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_basket_outlined, size: 48, color: AdminTheme.textGrey.withValues(alpha: 0.2)),
            const SizedBox(height: 15),
            const Text("Cart is empty", style: TextStyle(color: AdminTheme.textGrey, fontSize: 13, letterSpacing: 1)),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: cart.length,
      separatorBuilder: (_, __) => const SizedBox(height: 15),
      itemBuilder: (context, index) {
        final item = cart[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AdminTheme.borderGold.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Container(
                width: 40, height: 40, 
                decoration: BoxDecoration(
                  color: AdminTheme.accentGold.withValues(alpha: 0.05), 
                  borderRadius: BorderRadius.circular(10)
                ), 
                child: const Icon(Icons.medication_rounded, color: AdminTheme.accentGold, size: 20)
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'], 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white), 
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis, // Chống tràn tên sản phẩm trong giỏ
                    ),
                    Text("${item['qty']} x ₫${NumberFormat("#,###").format(item['price'])}", style: const TextStyle(color: AdminTheme.textGrey, fontSize: 11)),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => setState(() => cart.removeAt(index)), 
                icon: const Icon(Icons.delete_outline_rounded, color: AdminTheme.pinkGlow, size: 18)
              ),
            ],
          ),
        ).animate().fadeIn().slideX(begin: 0.1);
      },
    );
  }

  Widget _buildTotalSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("TOTAL VALUATION", style: TextStyle(color: AdminTheme.textGrey, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1)),
            const SizedBox(width: 10),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  "₫${NumberFormat("#,###").format(totalAmount)}", 
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AdminTheme.accentGold, letterSpacing: 0.5)
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 25),
        SizedBox(
          width: double.infinity,
          child: AdminButton(
            label: "FINALIZE TRANSACTION",
            onTap: () => _showCheckoutDialog(),
            icon: Icons.qr_code_rounded,
          ),
        ),
      ],
    );
  }

  void _showCheckoutDialog() {
    if (cart.isEmpty) return;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: GlassCard(
            padding: const EdgeInsets.all(30),
            width: MediaQuery.of(context).size.width * 0.9,
            maxWidth: 450,
            glowColor: AdminTheme.accentGold,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StatefulBuilder(
                    builder: (context, setDialogState) {
                      bool isProcessing = false;

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AdminTheme.accentGold.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check_circle_outline_rounded, size: 50, color: AdminTheme.accentGold),
                          ),
                          const SizedBox(height: 25),
                          const Text(
                            "AUTHORIZE TRANSACTION", 
                            style: TextStyle(color: AdminTheme.accentGold, fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 11)
                          ),
                          const SizedBox(height: 15),
                          // Giao diện giống biên lai (Receipt)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.03),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AdminTheme.borderGold.withValues(alpha: 0.3)),
                            ),
                            child: Column(
                              children: [
                                ...cart.take(3).map((item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(child: Text(item['name'], style: const TextStyle(color: AdminTheme.textGrey, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                      Text("x${item['qty']}", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                    ],
                                  ),
                                )),
                                if (cart.length > 3) 
                                  const Text("...", style: TextStyle(color: AdminTheme.textGrey)),
                                const Divider(color: AdminTheme.borderGold, height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Total Payable", style: TextStyle(color: AdminTheme.textGrey, fontSize: 12, fontWeight: FontWeight.bold)),
                                    Flexible(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          "₫${NumberFormat("#,###").format(totalAmount)}", 
                                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AdminTheme.accentGold)
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: isProcessing ? null : () => Navigator.pop(context),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 15),
                                    foregroundColor: AdminTheme.textGrey,
                                  ),
                                  child: const Text("CANCEL", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 12)),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: AdminButton(
                                  label: "CONFIRM",
                                  isLoading: isProcessing,
                                  onTap: () async {
                                    setDialogState(() => isProcessing = true);
                                    try {
                                      await FirebaseFirestore.instance.runTransaction((transaction) async {
                                        // 1. Verify stock for all items first
                                        List<DocumentReference> itemRefs = [];
                                        List<DocumentSnapshot> itemSnapshots = [];

                                        for (var item in cart) {
                                          DocumentReference ref = FirebaseFirestore.instance.collection('medicines').doc(item['id']);
                                          DocumentSnapshot snap = await transaction.get(ref);
                                          
                                          if (!snap.exists) {
                                            throw Exception("Medicine ${item['name']} not found!");
                                          }

                                          int currentStock = ((snap.data() as Map<String, dynamic>)['stock'] ?? 0).toInt();
                                          int requiredQty = (item['qty'] as num).toInt();
                                          
                                          if (currentStock < requiredQty) {
                                            throw Exception("Insufficient stock for ${item['name']}! (Available: $currentStock)");
                                          }

                                          itemRefs.add(ref);
                                          itemSnapshots.add(snap);
                                        }

                                        // 2. Create Order Reference
                                        DocumentReference orderRef = FirebaseFirestore.instance.collection('orders').doc();
                                        
                                        final orderData = {
                                          'items': cart.map((i) => {
                                            'id': i['id'],
                                            'name': i['name'],
                                            'price': i['price'],
                                            'quantity': i['qty'],
                                          }).toList(),
                                          'totalPrice': totalAmount,
                                          'total_price': totalAmount, // Added for dual-field compatibility
                                          'status': 'Hoàn Thành',
                                          'createdAt': FieldValue.serverTimestamp(),
                                          'userName': 'Counter Customer',
                                          'type': 'POS',
                                        };

                                        // 3. Execute Writes
                                        debugPrint("[POS Transaction] Finalizing order for ₫$totalAmount");
                                        transaction.set(orderRef, orderData);

                                        for (int i = 0; i < cart.length; i++) {
                                          final itemData = itemSnapshots[i].data() as Map<String, dynamic>;
                                          // Ép kiểu an toàn cho cả Web và Mobile
                                          int currentStock = (itemData['stock'] ?? 0).toInt();
                                          int qtyToSubtract = (cart[i]['qty'] as num).toInt();
                                          int newStock = currentStock - qtyToSubtract;

                                          debugPrint("[POS Transaction] Updating stock for ${cart[i]['name']}: $currentStock -> $newStock");
                                          transaction.update(itemRefs[i], {
                                            'stock': newStock,
                                          });
                                        }
                                        debugPrint("[POS Transaction] Transaction successfully committed.");
                                      });

                                      if (mounted) {
                                        setState(() => cart.clear());
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text("✅ TRANSACTION SECURED SUCCESSFULLY"), 
                                            backgroundColor: AdminTheme.accentGold,
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text("❌ ERROR: ${e.toString()}"), 
                                            backgroundColor: Colors.redAccent,
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      }
                                    } finally {
                                      if (mounted) setDialogState(() => isProcessing = false);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }
                  ),

                ],
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
}
