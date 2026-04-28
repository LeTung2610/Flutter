import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBvZi1k_ezN33dEEk6gMRRK-UeLnWXDA_4",
      authDomain: "pharmacy-online-9bcf5.firebaseapp.com",
      projectId: "pharmacy-online-9bcf5",
      storageBucket: "pharmacy-online-9bcf5.firebasestorage.app",
      messagingSenderId: "196680610389",
      appId: "1:196680610389:web:35e67c036a3cfc835f5adc",
    ),
  );
  runApp(const PharmacyApp());
}

class PharmacyApp extends StatelessWidget {
  const PharmacyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pharmacy Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[50],
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.cyan, width: 2)),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey[200]!)),
          color: Colors.white,
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) return const AdminDashboard();
          return const LoginScreen();
        },
      ),
    );
  }
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const OverviewScreen(),
    const InventoryScreen(),
    const OrderManagerScreen(),
    const PosScreen(),
    const RevenueScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) => setState(() => _selectedIndex = index),
            extended: MediaQuery.of(context).size.width > 1000,
            backgroundColor: Colors.white,
            elevation: 1,
            useIndicator: true,
            indicatorColor: Colors.cyan[50],
            unselectedIconTheme: const IconThemeData(color: Colors.grey, opacity: 0.8),
            unselectedLabelTextStyle: const TextStyle(color: Colors.grey),
            selectedIconTheme: const IconThemeData(color: Colors.cyan, size: 28),
            selectedLabelTextStyle: const TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold),
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: Text('Tổng quan')),
              NavigationRailDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: Text('Kho Hàng')),
              NavigationRailDestination(icon: Icon(Icons.local_shipping_outlined), selectedIcon: Icon(Icons.local_shipping), label: Text('Đơn Online')),
              NavigationRailDestination(icon: Icon(Icons.point_of_sale_outlined), selectedIcon: Icon(Icons.point_of_sale), label: Text('POS Tại Quầy')),
              NavigationRailDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: Text('Doanh Thu')),
            ],
            leading: Column(
              children: [
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.cyan, borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.local_pharmacy, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 12),
                if (MediaQuery.of(context).size.width > 1000) 
                  const Text("PHARMACY", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.cyan, fontSize: 16)),
                const SizedBox(height: 24),
              ],
            ),
            trailing: Expanded(
                child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: IconButton(
                            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                            onPressed: () => FirebaseAuth.instance.signOut()
                        )
                    )
                )
            ),
          ),
          Expanded(child: Container(color: Colors.grey[50], child: _screens[_selectedIndex])),
        ],
      ),
    );
  }
}

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text("TỔNG QUAN HỆ THỐNG", style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.transparent),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Báo cáo hoạt động", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Wrap(
              spacing: 24,
              runSpacing: 24,
              children: [
                _buildMetricCard(context, 'Tổng Doanh Thu', 'invoices', Icons.attach_money, Colors.cyan, isMoney: true),
                _buildMetricCard(context, 'Sản phẩm trong kho', 'medicines', Icons.medication, Colors.blue),
                _buildMetricCard(context, 'Đơn chờ duyệt', 'orders', Icons.pending_actions, Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, String title, String collection, IconData icon, Color color, {bool isMoney = false}) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = screenWidth > 1200 ? (screenWidth - 350 - 64 - 48) / 3 : (screenWidth > 800 ? (screenWidth - 150 - 64 - 24) / 2 : screenWidth - 64);

    return Container(
      width: cardWidth,
      constraints: const BoxConstraints(minWidth: 280),
      child: StreamBuilder(
        stream: FirebaseFirestore.instance.collection(collection).snapshots(),
        builder: (context, snapshot) {
          int value = 0;
          if (snapshot.hasData) {
            if (isMoney) {
              for (var doc in snapshot.data!.docs) {
                var d = doc.data();
                value += int.tryParse(d['totalPrice']?.toString() ?? '0') ?? 0;
              }
            } else {
              value = snapshot.data!.docs.length;
            }
          }
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                    child: Icon(icon, color: color, size: 30),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                        const SizedBox(height: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(isMoney ? "$value VNĐ" : "$value", style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String searchQuery = "";

  void _showAddProductDialog(BuildContext context) {
    final name = TextEditingController(), cat = TextEditingController(), price = TextEditingController(), stock = TextEditingController(), img = TextEditingController();
    showDialog(context: context, builder: (context) => AlertDialog(
      title: const Text("Thêm Sản Phẩm Mới"),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: "Tên thuốc", prefixIcon: Icon(Icons.medication))),
          const SizedBox(height: 12),
          TextField(controller: cat, decoration: const InputDecoration(labelText: "Danh mục", prefixIcon: Icon(Icons.category))),
          const SizedBox(height: 12),
          TextField(controller: price, decoration: const InputDecoration(labelText: "Giá bán", prefixIcon: Icon(Icons.attach_money)), keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          TextField(controller: stock, decoration: const InputDecoration(labelText: "Số lượng tồn kho", prefixIcon: Icon(Icons.storage)), keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          TextField(controller: img, decoration: const InputDecoration(labelText: "Link ảnh (URL)", prefixIcon: Icon(Icons.image))),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
        ElevatedButton(
          onPressed: () {
            FirebaseFirestore.instance.collection('medicines').add({
              'name': name.text,
              'category': cat.text,
              'price': int.tryParse(price.text) ?? 0,
              'stock': int.tryParse(stock.text) ?? 0,
              'imageUrl': img.text,
            });
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan, foregroundColor: Colors.white),
          child: const Text("Lưu Sản Phẩm")
        )
      ],
    ));
  }

  void _showEditProductDialog(BuildContext context, String id, Map data) {
    final name = TextEditingController(text: data['name']?.toString()), 
          cat = TextEditingController(text: data['category']?.toString()),
          price = TextEditingController(text: data['price']?.toString()), 
          stock = TextEditingController(text: data['stock']?.toString()),
          img = TextEditingController(text: data['imageUrl']?.toString());
    showDialog(context: context, builder: (context) => AlertDialog(
      title: const Text("Chỉnh Sửa Sản Phẩm"),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: "Tên thuốc", prefixIcon: Icon(Icons.medication))),
          const SizedBox(height: 12),
          TextField(controller: cat, decoration: const InputDecoration(labelText: "Danh mục", prefixIcon: Icon(Icons.category))),
          const SizedBox(height: 12),
          TextField(controller: price, decoration: const InputDecoration(labelText: "Giá bán", prefixIcon: Icon(Icons.attach_money)), keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          TextField(controller: stock, decoration: const InputDecoration(labelText: "Số lượng tồn kho", prefixIcon: Icon(Icons.storage)), keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          TextField(controller: img, decoration: const InputDecoration(labelText: "Link ảnh (URL)", prefixIcon: Icon(Icons.image))),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
        ElevatedButton(
          onPressed: () {
            FirebaseFirestore.instance.collection('medicines').doc(id).update({
              'name': name.text,
              'category': cat.text,
              'price': int.tryParse(price.text) ?? 0,
              'stock': int.tryParse(stock.text) ?? 0,
              'imageUrl': img.text,
            });
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan, foregroundColor: Colors.white),
          child: const Text("Cập Nhật")
        )
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("QUẢN LÝ KHO HÀNG", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: () => _showAddProductDialog(context),
              icon: const Icon(Icons.add),
              label: const Text("Thêm thuốc"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan, foregroundColor: Colors.white),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Tìm kiếm sản phẩm trong kho...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (v) => setState(() => searchQuery = v.toLowerCase()),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('medicines').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                var docs = snapshot.data!.docs.where((d) => 
                  d.data()['name'].toString().toLowerCase().contains(searchQuery) ||
                  d.data()['category'].toString().toLowerCase().contains(searchQuery)
                ).toList();
                
                if (docs.isEmpty) return const Center(child: Text("Không tìm thấy sản phẩm"));

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var data = docs[index].data();
                    int stock = int.tryParse(data['stock']?.toString() ?? '0') ?? 0;
                    int price = int.tryParse(data['price']?.toString() ?? '0') ?? 0;
                    Color stockColor = stock < 10 ? Colors.red : Colors.green;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        leading: Container(
                          width: 50, height: 50,
                          decoration: BoxDecoration(color: Colors.cyan[50], borderRadius: BorderRadius.circular(12)),
                          child: data['imageUrl'] != null && data['imageUrl'].toString().isNotEmpty
                            ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(data['imageUrl'], fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.broken_image, color: Colors.grey)))
                            : const Icon(Icons.medication, color: Colors.cyan),
                        ),
                        title: Text(data['name']?.toString() ?? "N/A", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${data['category']} • $price VNĐ", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(width: 8, height: 8, decoration: BoxDecoration(color: stockColor, shape: BoxShape.circle)),
                                  const SizedBox(width: 8),
                                  Text("Tồn kho: $stock", style: TextStyle(color: stockColor, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                          IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.blue), onPressed: () => _showEditProductDialog(context, docs[index].id, data)),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (c) => AlertDialog(
                                  title: const Text("Xác nhận xóa"),
                                  content: Text("Bạn có chắc chắn muốn xóa thuốc '${data['name']}'?"),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(c), child: const Text("Hủy")),
                                    TextButton(
                                      onPressed: () {
                                        FirebaseFirestore.instance.collection('medicines').doc(docs[index].id).delete();
                                        Navigator.pop(c);
                                      },
                                      child: const Text("Xóa", style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ]),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class OrderManagerScreen extends StatelessWidget {
  const OrderManagerScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text("ĐƠN HÀNG ONLINE", style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.transparent, elevation: 0),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('orders').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          var docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text("Không có đơn hàng nào"));

          return ListView.builder(
            padding: const EdgeInsets.all(32),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var data = docs[index].data();
              String status = data['status'] ?? 'Chờ Duyệt';
              Color statusColor = status == 'Chờ Duyệt' ? Colors.orange : (status == 'Đang Giao' ? Colors.blue : Colors.green);

              return Card(
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: Colors.cyan[50], borderRadius: BorderRadius.circular(10)),
                                child: const Icon(Icons.receipt_long, color: Colors.cyan),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Mã đơn: #${docs[index].id.substring(0, 8).toUpperCase()}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text(data['customerName'] ?? "Khách hàng ẩn danh", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                            child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ],
                      ),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider()),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${int.tryParse(data['totalPrice']?.toString() ?? '0')} VNĐ", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.phone, size: 14, color: Colors.grey),
                                  const SizedBox(width: 6),
                                  Text("${data['phone']}", style: TextStyle(color: Colors.grey[600])),
                                ],
                              ),
                            ],
                          ),
                          if (status != 'Hoàn Thành') ElevatedButton(
                            onPressed: () {
                              String nextStatus = status == 'Chờ Duyệt' ? 'Đang Giao' : 'Hoàn Thành';
                              FirebaseFirestore.instance.collection('orders').doc(docs[index].id).update({'status': nextStatus});
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.cyan, 
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(status == 'Chờ Duyệt' ? "Duyệt Đơn" : "Giao Thành Công"),
                          ) else const Row(children: [Icon(Icons.check_circle, color: Colors.green), SizedBox(width: 8), Text("Hoàn thành", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))]),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});
  @override State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  List cart = [];
  int total = 0;
  String searchQuery = "";

  void addToCart(Map med, String id) {
    int stock = int.tryParse(med['stock']?.toString() ?? '0') ?? 0;
    int idx = cart.indexWhere((i) => i['id'] == id);
    int currentQtyInCart = idx >= 0 ? cart[idx]['qty'] : 0;

    if (stock <= currentQtyInCart) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Không đủ tồn kho hoặc đã hết hàng"),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 1),
      ));
      return;
    }

    setState(() {
      int price = int.tryParse(med['price']?.toString() ?? '0') ?? 0;
      if (idx >= 0) {
        cart[idx]['qty']++;
      } else {
        cart.add({'id': id, 'name': med['name'], 'price': price, 'qty': 1, 'maxStock': stock});
      }
      total = cart.fold(0, (prev, item) => prev + (item['price'] as int) * (item['qty'] as int));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Tìm kiếm tên thuốc...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                  onChanged: (v) => setState(() => searchQuery = v.toLowerCase()),
                ),
              ),
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance.collection('medicines').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    var docs = snapshot.data!.docs.where((d) => d.data()['name'].toString().toLowerCase().contains(searchQuery)).toList();
                    
                    if (docs.isEmpty) return const Center(child: Text("Không tìm thấy sản phẩm"));

                    double screenWidth = MediaQuery.of(context).size.width;
                    int crossAxisCount = screenWidth > 1600 ? 5 : (screenWidth > 1200 ? 4 : (screenWidth > 900 ? 3 : 2));

                    return GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                      ),
                      itemCount: docs.length,
                      itemBuilder: (context, i) {
                        var data = docs[i].data();
                        int price = int.tryParse(data['price']?.toString() ?? '0') ?? 0;
                        int stock = int.tryParse(data['stock']?.toString() ?? '0') ?? 0;
                        
                        return Card(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => addToCart(data, docs[i].id),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 80, height: 80,
                                    decoration: BoxDecoration(color: Colors.cyan[50], shape: BoxShape.circle),
                                    child: data['imageUrl'] != null && data['imageUrl'].toString().isNotEmpty
                                      ? ClipOval(child: Image.network(data['imageUrl'], fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.broken_image, color: Colors.grey)))
                                      : const Icon(Icons.medication, color: Colors.cyan, size: 30),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(data['name'], textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 8),
                                  Text("$priceđ", style: const TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text("Kho: $stock", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                                ],
                              ),
                            ),
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
        Container(
          width: 400,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(-5, 0))],
          ),
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.shopping_cart_checkout, color: Colors.cyan),
                  SizedBox(width: 12),
                  Text("GIỎ HÀNG TẠI QUẦY", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 32),
              Expanded(
                child: cart.isEmpty 
                  ? Center(child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_basket_outlined, size: 80, color: Colors.grey[200]),
                        const SizedBox(height: 16),
                        Text("Chưa có sản phẩm", style: TextStyle(color: Colors.grey[400])),
                      ],
                    ))
                  : ListView.separated(
                      itemCount: cart.length,
                      separatorBuilder: (c, i) => const Divider(height: 40),
                      itemBuilder: (context, i) => Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(cart[i]['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                const SizedBox(height: 4),
                                Text("${cart[i]['price']}đ", style: TextStyle(color: Colors.cyan, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
                                onPressed: () => setState(() {
                                  if (cart[i]['qty'] > 1) cart[i]['qty']--;
                                  else cart.removeAt(i);
                                  total = cart.fold(0, (prev, item) => prev + (item['price'] as int) * (item['qty'] as int));
                                }),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Text("${cart[i]['qty']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, color: Colors.cyan),
                                onPressed: () {
                                  addToCart({'name': cart[i]['name'], 'price': cart[i]['price'], 'stock': cart[i]['maxStock']}, cart[i]['id']);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
              ),
              const Divider(height: 64),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("TỔNG CỘNG:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("$total VNĐ", style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: cart.isEmpty ? null : () async {
                    try {
                      WriteBatch batch = FirebaseFirestore.instance.batch();
                      for (var item in cart) {
                        DocumentReference ref = FirebaseFirestore.instance.collection('medicines').doc(item['id']);
                        batch.update(ref, {'stock': FieldValue.increment(-(item['qty'] as int))});
                      }
                      DocumentReference invRef = FirebaseFirestore.instance.collection('invoices').doc();
                      batch.set(invRef, {
                        'totalPrice': total,
                        'items': cart,
                        'timestamp': FieldValue.serverTimestamp()
                      });
                      await batch.commit();
                      setState(() { cart = []; total = 0; });
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Thanh toán & Xuất hóa đơn thành công!"), backgroundColor: Colors.green));
                    } catch (e) {
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan, 
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text("THANH TOÁN NGAY", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}

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
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("THỐNG KÊ DOANH THU", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 32),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: "Tất cả", label: Text("Tất cả")),
                ButtonSegment(value: "Hôm nay", label: Text("Hôm nay")),
                ButtonSegment(value: "Tuần này", label: Text("Tuần")),
                ButtonSegment(value: "Tháng này", label: Text("Tháng")),
              ],
              selected: {_filter},
              onSelectionChanged: (newVal) => setState(() => _filter = newVal.first),
              style: const ButtonStyle(visualDensity: VisualDensity.compact),
            ),
          )
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('invoices')
            .orderBy('timestamp', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          var docs = snapshot.data!.docs;
          
          int totalRevenue = 0;
          List<FlSpot> spots = [];
          Map<String, int> dailyRevenue = {};

          for (var doc in docs) {
            var data = doc.data();
            Timestamp? ts = data['timestamp'] as Timestamp?;
            if (ts == null) continue;
            
            DateTime date = ts.toDate();
            if (!_isInRange(date)) continue;

            int price = int.tryParse(data['totalPrice']?.toString() ?? '0') ?? 0;
            totalRevenue += price;

            String dateKey = "${date.day}/${date.month}";
            dailyRevenue[dateKey] = (dailyRevenue[dateKey] ?? 0) + price;
          }

          if (totalRevenue == 0) return const Center(child: Text("Không có dữ liệu trong khoảng thời gian này"));

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
                Card(
                  color: Colors.cyan,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(40),
                    child: Column(children: [
                      Text("DOANH THU ${_filter.toUpperCase()}", style: const TextStyle(color: Colors.white70, fontSize: 16)),
                      const SizedBox(height: 12),
                      FittedBox(
                        child: Text("$totalRevenue VNĐ",
                            style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                      ),
                    ]),
                  ),
                ),
                const SizedBox(height: 48),
                Text("Biểu đồ tăng trưởng ($_filter)", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: SizedBox(
                      height: 400,
                      child: spots.isEmpty
                          ? const Center(child: Text("Không đủ dữ liệu hiển thị biểu đồ"))
                          : LineChart(LineChartData(
                              gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: Colors.grey[100]!, strokeWidth: 1)),
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
                                  belowBarData: BarAreaData(show: true, color: Colors.cyan.withValues(alpha: 0.1)),
                                )
                              ],
                            )),
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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _e = TextEditingController(), _p = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.cyan[400]!, Colors.cyan[800]!],
          ),
        ),
        child: Center(
          child: Card(
            elevation: 20,
            shadowColor: Colors.black26,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            child: Container(
              width: 450,
              padding: const EdgeInsets.all(48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.cyan[50], shape: BoxShape.circle),
                    child: const Icon(Icons.local_pharmacy, size: 64, color: Colors.cyan),
                  ),
                  const SizedBox(height: 32),
                  const Text("PHARMACY ADMIN", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.cyan)),
                  const SizedBox(height: 8),
                  Text("Hệ thống quản lý kho & bán hàng", style: TextStyle(color: Colors.grey[500], fontSize: 15)),
                  const SizedBox(height: 48),
                  TextField(
                    controller: _e,
                    decoration: InputDecoration(
                      labelText: "Email đăng nhập",
                      prefixIcon: const Icon(Icons.email_outlined),
                      hintText: "admin@pharmacy.com",
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _p,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: "Mật khẩu",
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          await FirebaseAuth.instance.signInWithEmailAndPassword(email: _e.text.trim(), password: _p.text.trim());
                        } catch (e) {
                          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: ${e.toString()}"), backgroundColor: Colors.red));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyan,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Text("ĐĂNG NHẬP HỆ THỐNG", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const RegisterScreen())),
                    child: const Text("Chưa có tài khoản? Đăng ký ngay", style: TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _e = TextEditingController(), _p = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Center(
        child: Container(
          width: 400, padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min, 
            children: [
              const Icon(Icons.person_add_outlined, size: 60, color: Colors.cyan),
              const SizedBox(height: 24),
              const Text("TẠO TÀI KHOẢN ADMIN", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              TextField(controller: _e, decoration: const InputDecoration(labelText: "Email công việc")),
              const SizedBox(height: 20),
              TextField(controller: _p, decoration: const InputDecoration(labelText: "Mật khẩu bảo mật"), obscureText: true),
              const SizedBox(height: 40),
              SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: () async {
                try {
                  await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _e.text.trim(), password: _p.text.trim());
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }, 
              style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan, foregroundColor: Colors.white),
              child: const Text("XÁC NHẬN ĐĂNG KÝ")))
            ],
          ),
        ),
      ),
    );
  }
}
