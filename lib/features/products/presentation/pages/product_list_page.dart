import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stock_flutter/core/providers/firebase_providers.dart';
import 'package:stock_flutter/core/theme/app_theme.dart';
import 'package:stock_flutter/features/categories/application/category_providers.dart';
import 'package:stock_flutter/features/categories/domain/entities/category.dart';
import 'package:stock_flutter/features/products/application/product_providers.dart';
import 'package:stock_flutter/features/products/domain/entities/product.dart';
import 'package:stock_flutter/core/utils/constants.dart';
import 'package:stock_flutter/shared/widgets/app_bottom_nav.dart';
import 'package:stock_flutter/shared/widgets/app_glass_background.dart';

class ProductListPage extends ConsumerStatefulWidget {
  const ProductListPage({super.key});

  @override
  ConsumerState<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends ConsumerState<ProductListPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsStreamProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text(
          'Produits',
          style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => _showAddProductDialog(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryColor, Color(0xFF9C63FF)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
      body: AppGlassBackground(
        child: Column(
          children: [
          // ── Barre de recherche ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Rechercher un produit...',
                hintStyle:
                    TextStyle(color: AppTheme.textSecondary.withOpacity(0.6)),
                prefixIcon: const Icon(Icons.search,
                    color: AppTheme.textSecondary, size: 20),
                filled: true,
                fillColor: AppTheme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // ── Liste des produits ────────────────────────────────────────
          Expanded(
            child: productsAsync.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(
                      color: AppTheme.primaryColor)),
              error: (e, _) => Center(
                child: Text('Erreur: $e',
                    style: TextStyle(color: AppTheme.errorColor)),
              ),
              data: (products) {
                final filtered = products
                    .where((p) =>
                        p.name.toLowerCase().contains(_searchQuery) ||
                        p.category.name.toLowerCase().contains(_searchQuery))
                    .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_rounded,
                            size: 64,
                            color: AppTheme.textSecondary.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        Text(
                          products.isEmpty
                              ? 'Aucun produit ajouté'
                              : 'Aucun résultat',
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 16),
                        ),
                        if (products.isEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Appuyez sur + pour ajouter un produit',
                            style: TextStyle(
                                color: AppTheme.textSecondary.withOpacity(0.6),
                                fontSize: 13),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) =>
                      _ProductCard(product: filtered[i]),
                );
              },
            ),
          ),
        ],
      ),),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddProductSheet(),
    );
  }
}

// ── Product Card ──────────────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  final Product product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final isLow = product.isLowStock;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLow
              ? const Color(0xFFFF6B6B).withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icône catégorie
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.inventory_2_rounded,
                color: AppTheme.primaryColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    if (isLow)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B6B).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Stock faible',
                          style: TextStyle(
                              color: Color(0xFFFF6B6B),
                              fontSize: 10,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  product.category.name,
                  style: TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _InfoChip(
                      label: '${product.quantity} unités',
                      color: isLow
                          ? const Color(0xFFFF6B6B)
                          : AppTheme.secondaryColor,
                    ),
                    const SizedBox(width: 8),
                    _InfoChip(
                      label: '${product.price.toStringAsFixed(2)} MAD',
                      color: AppTheme.primaryColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;

  const _InfoChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 11, fontWeight: FontWeight.w500),
      ),
    );
  }
}

// ── Add Product Bottom Sheet ──────────────────────────────────────────────────

class _AddProductSheet extends ConsumerStatefulWidget {
  const _AddProductSheet();

  @override
  ConsumerState<_AddProductSheet> createState() => _AddProductSheetState();
}

class _AddProductSheetState extends ConsumerState<_AddProductSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  final _thresholdCtrl = TextEditingController(
      text: '${AppConstants.defaultLowStockThreshold}');
  final _descCtrl = TextEditingController();
  Category? _selectedCategory;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _quantityCtrl.dispose();
    _thresholdCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionnez une catégorie')),
      );
      return;
    }
    setState(() => _isLoading = true);
    final user = ref.read(firebaseAuthProvider).currentUser;
    if (user == null) return;

    final now = DateTime.now();
    final product = Product(
      id: '',
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      price: double.parse(_priceCtrl.text),
      quantity: int.parse(_quantityCtrl.text),
      lowStockThreshold: int.parse(_thresholdCtrl.text),
      category: _selectedCategory!,
      ownerId: user!.uid,
      createdAt: now,
      updatedAt: now,
    );

    await ref.read(productNotifierProvider.notifier).addProduct(product);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.textSecondary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Ajouter un produit',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Nom
              _SheetField(
                controller: _nameCtrl,
                label: 'Nom du produit',
                icon: Icons.label_rounded,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Nom requis' : null,
              ),
              const SizedBox(height: 12),

              // Catégorie
              categoriesAsync.when(
                loading: () => const LinearProgressIndicator(
                    color: AppTheme.primaryColor),
                error: (e, _) => Text('Erreur catégories: $e'),
                data: (categories) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<Category>(
                      value: _selectedCategory,
                      dropdownColor: AppTheme.surfaceColor,
                      style: const TextStyle(
                          color: AppTheme.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Catégorie',
                        labelStyle: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 13),
                        prefixIcon: const Icon(Icons.category_rounded,
                            color: AppTheme.primaryColor, size: 20),
                        filled: true,
                        fillColor: AppTheme.cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: AppTheme.primaryColor, width: 1.5),
                        ),
                      ),
                      items: categories
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(c.name),
                              ))
                          .toList(),
                      onChanged: (c) => setState(() => _selectedCategory = c),
                    ),
                    // Bouton ajouter catégorie si vide
                    if (categories.isEmpty)
                      TextButton.icon(
                        onPressed: () =>
                            _showAddCategoryDialog(context),
                        icon: const Icon(Icons.add,
                            size: 16, color: AppTheme.primaryColor),
                        label: const Text(
                          'Créer une catégorie',
                          style: TextStyle(
                              color: AppTheme.primaryColor, fontSize: 13),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Prix + Quantité
              Row(
                children: [
                  Expanded(
                    child: _SheetField(
                      controller: _priceCtrl,
                      label: 'Prix (MAD)',
                      icon: Icons.attach_money_rounded,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Requis';
                        if (double.tryParse(v) == null) return 'Invalide';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SheetField(
                      controller: _quantityCtrl,
                      label: 'Quantité',
                      icon: Icons.numbers_rounded,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Requis';
                        if (int.tryParse(v) == null) return 'Invalide';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Seuil d'approvisionnement
              _SheetField(
                controller: _thresholdCtrl,
                label: "Seuil d'alerte (quantité min.)",
                icon: Icons.warning_amber_rounded,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Requis';
                  if (int.tryParse(v) == null) return 'Invalide';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Description (optionnel)
              _SheetField(
                controller: _descCtrl,
                label: 'Description (optionnel)',
                icon: Icons.description_rounded,
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              // Bouton enregistrer
              SizedBox(
                width: double.infinity,
                height: 50,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryColor, Color(0xFF9C63FF)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'Enregistrer',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 15),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('Nouvelle catégorie',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: TextField(
          controller: ctrl,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: 'Nom de la catégorie',
            hintStyle: TextStyle(
                color: AppTheme.textSecondary.withOpacity(0.5)),
            filled: true,
            fillColor: AppTheme.cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              if (ctrl.text.trim().isNotEmpty) {
                await ref
                    .read(categoryNotifierProvider.notifier)
                    .addCategory(ctrl.text.trim());
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Créer',
                style: TextStyle(color: AppTheme.primaryColor)),
          ),
        ],
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  const _SheetField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        prefixIcon: Icon(icon, color: AppTheme.primaryColor, size: 18),
        filled: true,
        fillColor: AppTheme.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: AppTheme.errorColor, width: 1),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}
