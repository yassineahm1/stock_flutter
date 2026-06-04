import 'package:stock_flutter/features/products/domain/entities/product.dart';
import 'package:stock_flutter/features/products/domain/repositories/product_repository.dart';
import 'package:stock_flutter/features/stock_movements/domain/entities/stock_movement.dart';
import 'package:stock_flutter/features/stock_movements/domain/repositories/stock_movement_repository.dart';

/// Use Case : Effectuer une vente (sortie du stock)
/// Équivalent à domain/usecase/ du professeur
class MakeSaleUseCase {
  final StockMovementRepository _movementRepository;
  final ProductRepository _productRepository;

  const MakeSaleUseCase(this._movementRepository, this._productRepository);

  Future<StockMovement> execute({
    required Product product,
    required int quantity,
    required String ownerId,
    double? salePrice,
    String? note,
  }) async {
    if (quantity <= 0) {
      throw ArgumentError('La quantité doit être positive');
    }
    if (quantity > product.quantity) {
      throw ArgumentError(
          'Stock insuffisant. Disponible: ${product.quantity}, demandé: $quantity');
    }

    // Créer le mouvement de vente
    final movement = StockMovement(
      id: '', // généré par Firestore
      product: product,
      type: MovementType.sale,
      quantity: quantity,
      unitPrice: salePrice ?? product.price,
      note: note,
      ownerId: ownerId,
      date: DateTime.now(),
    );

    // Sauvegarder le mouvement
    final savedMovement = await _movementRepository.addMovement(movement);

    // Mettre à jour la quantité du produit
    final newQuantity = product.quantity - quantity;
    await _productRepository.updateProductQuantity(product.id, ownerId, newQuantity);

    return savedMovement;
  }
}
