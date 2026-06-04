import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stock_flutter/features/products/data/remote/product_model.dart';
import 'package:stock_flutter/features/products/data/services/product_repository_impl.dart';
import 'package:stock_flutter/features/stock_movements/data/remote/stock_movement_model.dart';
import 'package:stock_flutter/features/stock_movements/domain/entities/stock_movement.dart';
import 'package:stock_flutter/features/stock_movements/domain/repositories/stock_movement_repository.dart';

/// Implémentation du StockMovementRepository via Firestore
/// Équivalent à data/services/ du professeur
class StockMovementRepositoryImpl implements StockMovementRepository {
  final FirebaseFirestore _firestore;
  final ProductRepositoryImpl _productRepository;

  const StockMovementRepositoryImpl(this._firestore, this._productRepository);

  CollectionReference<Map<String, dynamic>> _collection(String ownerId) {
    return _firestore.collection(StockMovementModel.collectionPath(ownerId));
  }

  @override
  Future<List<StockMovement>> getAllMovements(String ownerId) async {
    final snapshot = await _collection(ownerId)
        .orderBy('date', descending: true)
        .get();
    return _mapDocuments(snapshot.docs, ownerId);
  }

  @override
  Stream<List<StockMovement>> watchMovements(String ownerId) {
    return _collection(ownerId)
        .orderBy('date', descending: true)
        .snapshots()
        .asyncMap((snapshot) => _mapDocuments(snapshot.docs, ownerId));
  }

  @override
  Future<List<StockMovement>> getMovementsByDateRange(
    String ownerId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final snapshot = await _collection(ownerId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('date', descending: true)
        .get();
    return _mapDocuments(snapshot.docs, ownerId);
  }

  @override
  Future<List<StockMovement>> getMovementsByProduct(
    String ownerId,
    String productId,
  ) async {
    final snapshot = await _collection(ownerId)
        .where('productId', isEqualTo: productId)
        .orderBy('date', descending: true)
        .get();
    return _mapDocuments(snapshot.docs, ownerId);
  }

  @override
  Future<StockMovement> addMovement(StockMovement movement) async {
    final model = StockMovementModel(
      id: '',
      product: movement.product,
      type: movement.type,
      quantity: movement.quantity,
      unitPrice: movement.unitPrice,
      note: movement.note,
      ownerId: movement.ownerId,
      date: movement.date,
    );
    final docRef = await _collection(movement.ownerId).add(model.toFirestore());
    return StockMovementModel(
      id: docRef.id,
      product: movement.product,
      type: movement.type,
      quantity: movement.quantity,
      unitPrice: movement.unitPrice,
      note: movement.note,
      ownerId: movement.ownerId,
      date: movement.date,
    );
  }

  Future<List<StockMovement>> _mapDocuments(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    String ownerId,
  ) async {
    final movements = <StockMovement>[];
    for (final doc in docs) {
      final productId = doc.data()['productId'] as String;
      final products = await _productRepository.getAllProducts(ownerId);
      final product = products.firstWhere((p) => p.id == productId);
      movements.add(StockMovementModel.fromFirestore(doc, product));
    }
    return movements;
  }
}
