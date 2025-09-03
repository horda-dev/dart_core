/// Unique identifier for entities in the Horda platform.
/// 
/// Entities are stateful business domain objects like User, Order, or BlogPost.
/// Each entity instance has a unique ID that persists throughout its lifecycle.
typedef EntityId = String;

/// Identifier composed of two entity IDs for representing relationships.
/// 
/// Used when you need to create a unique identifier from two entity IDs,
/// such as for many-to-many relationships or composite keys.
class CompositeId {
  /// Creates a composite ID from two entity identifiers.
  CompositeId(this.id1, this.id2);

  /// First component of the composite identifier.
  final EntityId id1;

  /// Second component of the composite identifier.
  final EntityId id2;

  /// Returns the composite identifier as a single string.
  /// 
  /// The smaller ID is placed first to ensure consistent ordering
  /// regardless of the order the IDs were passed to the constructor.
  EntityId get id {
    // in composite id smaller id must be placed first
    return id1.compareTo(id2) < 0 ? '$id1-$id2' : '$id2-$id1';
  }
}

/// Extension adding comparison operators to String for entity ID ordering.
/// 
/// Provides convenient comparison operators for string-based entity IDs,
/// enabling sorting and range operations on entity identifiers.
extension Compare on String {
  /// Returns true if this string is lexicographically less than [b].
  bool operator <(String b) {
    return compareTo(b) < 0;
  }

  /// Returns true if this string is lexicographically less than or equal to [b].
  bool operator <=(String b) {
    return compareTo(b) <= 0;
  }

  /// Returns true if this string is lexicographically greater than [b].
  bool operator >(String b) {
    return compareTo(b) > 0;
  }

  /// Returns true if this string is lexicographically greater than or equal to [b].
  bool operator >=(String b) {
    return compareTo(b) >= 0;
  }
}
