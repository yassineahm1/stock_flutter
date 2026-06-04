import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:stock_flutter/core/theme/app_theme.dart';
import 'package:stock_flutter/features/products/application/product_providers.dart';
import 'package:stock_flutter/features/products/domain/entities/product.dart';
import 'package:stock_flutter/features/stock_movements/application/stock_movement_providers.dart';
import 'package:stock_flutter/features/stock_movements/domain/entities/stock_movement.dart';
import 'package:stock_flutter/shared/widgets/app_bottom_nav.dart';
import 'package:stock_flutter/shared/widgets/app_glass_background.dart';

class StockMovementPage extends ConsumerStatefulWidget {
  const StockMovementPage({super.key});

  @override
  ConsumerState<StockMovementPage> createState() => _StockMovementPageState();
}

class _StockMovementPageState extends ConsumerState<StockMovementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isHistoryExpanded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final movementsAsync = ref.watch(movementsStreamProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        automaticallyImplyLeading: false,
        title: const Text(
          'Mouvements de stock',
          style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: const [
            Tab(
              icon: Icon(Icons.arrow_downward_rounded, size: 18),
              text: 'Entrée stock',
            ),
            Tab(
              icon: Icon(Icons.point_of_sale_rounded, size: 18),
              text: 'Vente',
            ),
          ],
        ),
      ),
      body: AppGlassBackground(
        child: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _MovementForm(type: MovementType.entry),
                _MovementForm(type: MovementType.sale),
              ],
            ),
          ),

          // ── Historique des mouvements ──────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            height: _isHistoryExpanded ? 280 : 54,
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor.withValues(alpha: 0.9),
              border: Border(
                  top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => setState(() => _isHistoryExpanded = !_isHistoryExpanded),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Historique récent',
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              _isHistoryExpanded
                                  ? Icons.keyboard_arrow_down_rounded
                                  : Icons.keyboard_arrow_up_rounded,
                              color: AppTheme.textSecondary,
                              size: 18,
                            ),
                          ],
                        ),
                        if (_isHistoryExpanded)
                          movementsAsync.when(
                            data: (m) => Text(
                              '${m.length} mouvement(s)',
                              style: TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 12),
                            ),
                            loading: () => const SizedBox.shrink(),
                            error: (_, __) => const SizedBox.shrink(),
                          )
                        else
                          movementsAsync.when(
                            data: (m) => m.isNotEmpty
                                ? Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${m.length}',
                                      style: const TextStyle(
                                          color: AppTheme.primaryColor,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                            loading: () => const SizedBox.shrink(),
                            error: (_, __) => const SizedBox.shrink(),
                          ),
                      ],
                    ),
                  ),
                ),
                if (_isHistoryExpanded)
                  Expanded(
                    child: movementsAsync.when(
                      loading: () => const Center(
                          child: CircularProgressIndicator(
                              color: AppTheme.primaryColor)),
                      error: (e, _) => Center(
                        child: Text('Erreur: $e',
                            style: TextStyle(color: AppTheme.errorColor)),
                      ),
                      data: (movements) {
                        if (movements.isEmpty) {
                          return Center(
                            child: Text(
                              'Aucun mouvement',
                              style: TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 13),
                            ),
                          );
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: movements.take(20).length,
                          itemBuilder: (ctx, i) =>
                              _HistoryTile(movement: movements[i]),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }
}

// ── Formulaire de mouvement ───────────────────────────────────────────────────

class _MovementForm extends ConsumerStatefulWidget {
  final MovementType type;

  const _MovementForm({required this.type});

  @override
  ConsumerState<_MovementForm> createState() => _MovementFormState();
}

class _MovementFormState extends ConsumerState<_MovementForm> {
  final _quantityCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  Product? _selectedProduct;
  bool _isLoading = false;

  @override
  void dispose() {
    _quantityCtrl.dispose();
    _priceCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  bool get isEntry => widget.type == MovementType.entry;

  Future<void> _submit() async {
    if (_selectedProduct == null) {
      _showSnack('Sélectionnez un produit');
      return;
    }
    final qty = int.tryParse(_quantityCtrl.text);
    if (qty == null || qty <= 0) {
      _showSnack('Quantité invalide');
      return;
    }

    setState(() => _isLoading = true);

    final notifier = ref.read(stockMovementNotifierProvider.notifier);

    if (isEntry) {
      await notifier.addEntry(
        _selectedProduct!,
        qty,
        note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      );
    } else {
      final price = double.tryParse(_priceCtrl.text);
      await notifier.makeSale(
        _selectedProduct!,
        qty,
        salePrice: price,
        note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      );
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
        _selectedProduct = null;
        _quantityCtrl.clear();
        _priceCtrl.clear();
        _noteCtrl.clear();
      });
      _showSnack(isEntry ? 'Entrée enregistrée ✓' : 'Vente enregistrée ✓',
          isSuccess: true);
    }
  }

  void _showSnack(String msg, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor:
            isSuccess ? AppTheme.secondaryColor : AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsStreamProvider);
    final color = isEntry ? AppTheme.secondaryColor : const Color(0xFFFF6B6B);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Info banner ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                Icon(
                  isEntry
                      ? Icons.arrow_downward_rounded
                      : Icons.point_of_sale_rounded,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  isEntry
                      ? 'Enregistrer une réception de marchandises'
                      : 'Enregistrer une vente client',
                  style: TextStyle(
                      color: color, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Sélection produit ─────────────────────────────────────────
          productsAsync.when(
            loading: () => const LinearProgressIndicator(
                color: AppTheme.primaryColor),
            error: (e, _) => Text('Erreur: $e',
                style: TextStyle(color: AppTheme.errorColor)),
            data: (products) {
              return DropdownButtonFormField<Product>(
                value: _selectedProduct,
                dropdownColor: AppTheme.surfaceColor,
                style: const TextStyle(
                    color: AppTheme.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Produit',
                  labelStyle: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13),
                  prefixIcon: const Icon(Icons.inventory_2_rounded,
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
                items: products
                    .map((p) => DropdownMenuItem(
                          value: p,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(p.name,
                                  style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 14)),
                              Text(
                                'Stock: ${p.quantity} | ${p.price.toStringAsFixed(2)} MAD',
                                style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 11),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
                onChanged: (p) {
                  setState(() {
                    _selectedProduct = p;
                    if (!isEntry && p != null) {
                      _priceCtrl.text = p.price.toStringAsFixed(2);
                    }
                  });
                },
              );
            },
          ),

          // ── Stock actuel si produit sélectionné ──────────────────────
          if (_selectedProduct != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: AppTheme.textSecondary, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Stock actuel : ${_selectedProduct!.quantity} unités',
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 13),
                  ),
                  if (_selectedProduct!.isLowStock) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.warning_amber_rounded,
                        color: Color(0xFFFF6B6B), size: 16),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),

          // ── Quantité ──────────────────────────────────────────────────
          TextField(
            controller: _quantityCtrl,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: InputDecoration(
              labelText: 'Quantité',
              labelStyle: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 13),
              prefixIcon: Icon(Icons.numbers_rounded,
                  color: color, size: 20),
              filled: true,
              fillColor: AppTheme.cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: color, width: 1.5),
              ),
            ),
          ),

          // ── Prix de vente (seulement pour les ventes) ─────────────────
          if (!isEntry) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _priceCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                labelText: 'Prix de vente (MAD)',
                labelStyle: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13),
                prefixIcon: const Icon(Icons.attach_money_rounded,
                    color: Color(0xFFFF6B6B), size: 20),
                filled: true,
                fillColor: AppTheme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                      color: Color(0xFFFF6B6B), width: 1.5),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),

          // ── Note ────────────────────────────────────────────────────
          TextField(
            controller: _noteCtrl,
            style: const TextStyle(color: AppTheme.textPrimary),
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Note (optionnel)',
              labelStyle: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 13),
              prefixIcon: const Icon(Icons.note_rounded,
                  color: AppTheme.textSecondary, size: 20),
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
          ),
          const SizedBox(height: 24),

          // ── Bouton submit ────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 50,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isEntry
                      ? [AppTheme.secondaryColor, const Color(0xFF00BFA5)]
                      : [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _submit,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Icon(
                        isEntry
                            ? Icons.arrow_downward_rounded
                            : Icons.point_of_sale_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                label: Text(
                  isEntry ? 'Confirmer l\'entrée' : 'Confirmer la vente',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── History Tile ──────────────────────────────────────────────────────────────

class _HistoryTile extends StatelessWidget {
  final StockMovement movement;

  const _HistoryTile({required this.movement});

  @override
  Widget build(BuildContext context) {
    final isEntry = movement.isEntry;
    final color = isEntry ? AppTheme.secondaryColor : const Color(0xFFFF6B6B);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.cardColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Icon(
            isEntry
                ? Icons.arrow_downward_rounded
                : Icons.arrow_upward_rounded,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movement.product.name,
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                ),
                Text(
                  DateFormat('dd/MM/yy HH:mm').format(movement.date),
                  style: TextStyle(
                      color: AppTheme.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            '${isEntry ? '+' : '-'}${movement.quantity}',
            style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14),
          ),
          if (!isEntry) ...[
            const SizedBox(width: 8),
            Text(
              '${movement.totalAmount.toStringAsFixed(0)} MAD',
              style: TextStyle(
                  color: AppTheme.textSecondary, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}
