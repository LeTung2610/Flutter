import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/admin_theme.dart';
import '../widgets/admin_common_widgets.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late Stream<QuerySnapshot> _categoryStream;

  @override
  void initState() {
    super.initState();
    _categoryStream = FirebaseFirestore.instance.collection('categories').snapshots();
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
            _buildHeader(context),
            const SizedBox(height: 35),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _categoryStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AdminTheme.accentGold));
                  
                  final categories = snapshot.data!.docs;
                  
                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 400,
                      crossAxisSpacing: 25,
                      mainAxisSpacing: 25,
                      childAspectRatio: 2.0, // Tăng tỉ lệ để thẻ dẹt hơn, tránh ép chiều cao
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final data = categories[index].data() as Map<String, dynamic>;
                      final docId = categories[index].id;
                      return _buildCategoryCard(context, docId, data);
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

  Widget _buildHeader(BuildContext context) {
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
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.white, AdminTheme.accentGold],
                    ).createShader(bounds),
                    child: Text(
                      "Classification Repository", 
                      style: AdminTheme.darkTheme.textTheme.headlineMedium?.copyWith(
                        fontSize: isSmall ? 20 : 24,
                      )
                    ),
                  ),
                  Text(
                    "Organizing pharmacological assets into enterprise segments", 
                    style: TextStyle(color: AdminTheme.textGrey, fontSize: isSmall ? 10 : 12, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            isSmall 
              ? IconButton(
                  onPressed: () => _showAddEditCategoryDialog(context),
                  icon: const Icon(Icons.add_box_rounded, color: AdminTheme.accentGold, size: 32),
                )
              : AdminButton(
                  label: "REGISTER CATEGORY",
                  icon: Icons.add_rounded,
                  onTap: () => _showAddEditCategoryDialog(context),
                ),
          ],
        );
      }
    ).animate().fadeIn().slideY(begin: -0.1);
  }

  Widget _buildCategoryCard(BuildContext context, String id, Map<String, dynamic> data) {
    return GlassCard(
      padding: const EdgeInsets.all(25),
      glowColor: AdminTheme.tealGlow,
      child: Stack(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AdminTheme.accentGold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AdminTheme.borderGold.withValues(alpha: 0.2)),
                ),
                child: const Icon(Icons.category_rounded, color: AdminTheme.accentGold, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // Chống tràn theo chiều dọc
                  children: [
                    FittedBox( // Chống tràn tên category nếu quá dài
                      fit: BoxFit.scaleDown,
                      child: Text(
                        data['name'] ?? 'N/A',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${data['itemCount'] ?? 0} Items", // Rút ngắn text để tiết kiệm chỗ
                      style: const TextStyle(color: AdminTheme.textGrey, fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Row(
              children: [
                _buildActionIcon(
                  Icons.edit_note_rounded,
                  AdminTheme.tealGlow,
                  onTap: () => _showAddEditCategoryDialog(context, docId: id, data: data),
                ),
                const SizedBox(width: 8),
                _buildActionIcon(
                  Icons.delete_outline_rounded,
                  AdminTheme.pinkGlow,
                  onTap: () => _showDeleteConfirmDialog(context, id, data['name']),
                ),
              ],
            ),
          )
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.98, 0.98));
  }

  Widget _buildActionIcon(IconData icon, Color color, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1), 
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 0.5),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  void _showAddEditCategoryDialog(BuildContext context, {String? docId, Map<String, dynamic>? data}) {
    final isEditing = docId != null;
    final controller = TextEditingController(text: data?['name']);
    
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: GlassCard(
            width: MediaQuery.of(context).size.width * 0.9,
            maxWidth: 450,
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? "Modify Category" : "New Segment Registry",
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 25),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("CATEGORY IDENTIFIER", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AdminTheme.accentGold, letterSpacing: 1)),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AdminTheme.borderGold),
                      ),
                      child: TextField(
                        controller: controller,
                        style: const TextStyle(fontSize: 14, color: Colors.white),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.label_outline_rounded, size: 18, color: AdminTheme.textGrey),
                          hintText: "Enter segment name...",
                          hintStyle: TextStyle(color: AdminTheme.textGrey, fontSize: 13),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("CANCEL", style: TextStyle(color: AdminTheme.textGrey, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    const SizedBox(width: 15),
                    AdminButton(
                      label: isEditing ? "UPDATE" : "COMMIT",
                      onTap: () {
                        if (controller.text.isNotEmpty) {
                          if (isEditing) {
                            FirebaseFirestore.instance.collection('categories').doc(docId).update({
                              'name': controller.text,
                              'updatedAt': FieldValue.serverTimestamp(),
                            });
                          } else {
                            FirebaseFirestore.instance.collection('categories').add({
                              'name': controller.text,
                              'itemCount': 0,
                              'createdAt': FieldValue.serverTimestamp(),
                            });
                          }
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(opacity: anim1, child: ScaleTransition(scale: anim1, child: child));
      },
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, String docId, String name) {
    showDialog(
      context: context,
      builder: (context) => Center(
        child: GlassCard(
          width: 400,
          padding: const EdgeInsets.all(35),
          glowColor: AdminTheme.pinkGlow,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AdminTheme.pinkGlow.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.warning_amber_rounded, size: 40, color: AdminTheme.pinkGlow),
              ),
              const SizedBox(height: 25),
              const Text("Security Confirmation", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(
                "Permanently remove segment '$name'? This may affect asset classification.", 
                textAlign: TextAlign.center, 
                style: const TextStyle(color: AdminTheme.textGrey, fontSize: 13)
              ),
              const SizedBox(height: 35),
              Row(
                children: [
                  Expanded(
                    child: AdminButton(
                      label: "ABORT", 
                      isPrimary: false,
                      onTap: () => Navigator.pop(context)
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: AdminButton(
                      label: "CONFIRM DELETE", 
                      color: AdminTheme.pinkGlow,
                      onTap: () async {
                        await FirebaseFirestore.instance.collection('categories').doc(docId).delete();
                        Navigator.pop(context);
                      }
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
