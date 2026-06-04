import 'package:stock_flutter/features/products/domain/entities/product.dart';

/// Types de mouvements de stock
enum MovementType {
  entry, // Entrée en stock
  sale,  // Vente (sortie du stock)
}

/// Entité StockMovement - Domaine pur
/// Équivalent à domain/entities/ du professeur
class StockMovement {
  final String id;
  final Product product;
  final MovementType type;
  final int quantity;
  final double? unitPrice;  // prix unitaire (pour les ventes)
  final String? note;
  final String ownerId;     // uid du client (multi-tenant SaaS)
  final DateTime date;

  const StockMovement({
    required this.id,
    required this.product,
    required this.type,
    required this.quantity,
    this.unitPrice,
    this.note,
    required this.ownerId,
    required this.date,
  });

  /// Calcule le montant total du mouvement
  double get totalAmount => (unitPrice ?? product.price) * quantity;

  /// Vérifie si c'est une entrée en stock
  bool get isEntry => type == MovementType.entry;

  /// Vérifie si c'est une vente
  bool get isSale => type == MovementType.sale;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StockMovement && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'StockMovement(id: $id, type: $type, quantity: $quantity)';
}
