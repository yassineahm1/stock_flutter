/// Entité Category - Domaine pur
/// Équivalent à domain/entities/ du professeur
class Category {
  final String id;
  final String name;
  final String? description;
  final String ownerId; // uid du client (multi-tenant SaaS)
  final DateTime createdAt;

  const Category({
    required this.id,
    required this.name,
    this.description,
    required this.ownerId,
    required this.createdAt,
  });

  Category copyWith({
    String? id,
    String? name,
    String? description,
    String? ownerId,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Category(id: $id, name: $name)';
}
