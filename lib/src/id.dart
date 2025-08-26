typedef EntityId = String;

class CompositeId {
  CompositeId(this.id1, this.id2);

  final EntityId id1;

  final EntityId id2;

  EntityId get id {
    // in composite id smaller id must be placed first
    return id1.compareTo(id2) < 0 ? '$id1-$id2' : '$id2-$id1';
  }
}

extension Compare on String {
  bool operator <(String b) {
    return compareTo(b) < 0;
  }

  bool operator <=(String b) {
    return compareTo(b) <= 0;
  }

  bool operator >(String b) {
    return compareTo(b) > 0;
  }

  bool operator >=(String b) {
    return compareTo(b) >= 0;
  }
}
