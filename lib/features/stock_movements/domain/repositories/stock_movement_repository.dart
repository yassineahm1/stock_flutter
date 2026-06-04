import 'package:stock_flutter/features/stock_movements/domain/entities/stock_movement.dart';

/// Interface du repository des mouvements de stock - Domaine pur
abstract interface class StockMovementRepository {
  /// Récupère tous les mouvements du client connecté
  Future<List<StockMovement>> getAllMovements(String ownerId);

  /// Stream temps réel des mouvements (Firestore)
  Stream<List<StockMovement>> watchMovements(String ownerId);

  /// Récupère les mouvements dans une plage de dates
  Future<List<StockMovement>> getMovementsByDateRange(
    String ownerId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Récupère les mouvements d'un produit spécifique
  Future<List<StockMovement>> getMovementsByProduct(
    String ownerId,
    String productId,
  );

  /// Enregistre un nouveau mouvement (entrée ou vente)
  Future<StockMovement> addMovement(StockMovement movement);
}
