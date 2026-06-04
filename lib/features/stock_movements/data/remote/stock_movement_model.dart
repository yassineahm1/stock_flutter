import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stock_flutter/core/utils/constants.dart';
import 'package:stock_flutter/features/stock_movements/domain/entities/stock_movement.dart';
import 'package:stock_flutter/features/products/domain/entities/product.dart';

/// Modèle de données Firestore pour StockMovement
/// Équivalent à data/remote/ du professeur
class StockMovementModel extends StockMovement {
  const StockMovementModel({
    required super.id,
    required super.product,
    required super.type,
    required super.quantity,
    super.unitPrice,
    super.note,
    required super.ownerId,
    required super.date,
  });

  /// Convertit depuis un document Firestore
  factory StockMovementModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    Product product,
  ) {
    final data = doc.data()!;
    return StockMovementModel(
      id: doc.id,
      product: product,
      type: data['type'] == AppConstants.movementTypeEntry
          ? MovementType.entry
          : MovementType.sale,
      quantity: data['quantity'] as int,
      unitPrice: data['unitPrice'] != null
          ? (data['unitPrice'] as num).toDouble()
          : null,
      note: data['note'] as String?,
      ownerId: data['ownerId'] as String,
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  /// Convertit vers un Map Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'productId': product.id,
      'type': type == MovementType.entry
          ? AppConstants.movementTypeEntry
          : AppConstants.movementTypeSale,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'note': note,
      'ownerId': ownerId,
      'date': Timestamp.fromDate(date),
    };
  }

  /// Retourne le chemin Firestore (multi-tenant SaaS)
  static String collectionPath(String ownerId) =>
      '${AppConstants.usersCollection}/$ownerId/${AppConstants.movementsCollection}';
}
