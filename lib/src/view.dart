import 'id.dart';
import 'message.dart';

abstract class Change extends RemoteMessage {
  /// Whether changes of this type:
  /// - `true` - overwrite the previous version
  /// - `false` - add up
  bool get isOverwriting;
}

// :sealed
abstract class ValueViewChange extends Change {
  @override
  bool get isOverwriting => true;
}

/// Type parameter [T] is the type of value view, it's not simply the current runtime type of [newValue].
class ValueViewChanged<T> extends ValueViewChange {
  ValueViewChanged(this.newValue);

  final T newValue;

  factory ValueViewChanged.fromJson(Map<String, dynamic> json) {
    return ValueViewChanged<T>(
      _valueFromJson<T>(json),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return _valueToJson(newValue);
  }

  @override
  String format() => newValue.toString();
}

T _valueFromJson<T>(Map<String, dynamic> json) {
  final val = json['val'];
  final type = json['type'];

  switch (type) {
    case 'DateTime':
      return DateTime.fromMillisecondsSinceEpoch(val) as T;
    case 'DateTime?':
      if (val == null) {
        return null as T;
      }
      return DateTime.fromMillisecondsSinceEpoch(val) as T;
    default:
      return val as T;
  }
}

Map<String, dynamic> _valueToJson<T>(T value) {
  dynamic val = value;
  if (val is DateTime) {
    val = val.millisecondsSinceEpoch;
  }

  return {
    'val': val,
    'type': T.toString(),
  };
}

abstract class CounterViewChange extends Change {
  @override
  bool get isOverwriting => false;
}

class CounterViewIncremented extends CounterViewChange {
  CounterViewIncremented({required this.by});

  final int by;

  factory CounterViewIncremented.fromJson(Map<String, dynamic> json) {
    return CounterViewIncremented(
      by: json['by'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'by': by,
    };
  }
}

class CounterViewDecremented extends CounterViewChange {
  CounterViewDecremented({required this.by});

  final int by;

  factory CounterViewDecremented.fromJson(Map<String, dynamic> json) {
    return CounterViewDecremented(
      by: json['by'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'by': by,
    };
  }
}

class CounterViewReset extends CounterViewChange {
  CounterViewReset({required this.newValue});

  final int newValue;

  factory CounterViewReset.fromJson(Map<String, dynamic> json) {
    return CounterViewReset(
      newValue: json['val'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'val': newValue,
    };
  }
}

// :sealed
abstract class RefViewChange extends Change {
  @override
  bool get isOverwriting => true;
}

class RefViewChanged extends RefViewChange {
  RefViewChanged(this.newValue);

  final ActorId? newValue;

  factory RefViewChanged.fromJson(Map<String, dynamic> json) {
    return RefViewChanged(
      json['val'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'val': newValue,
    };
  }

  @override
  String format() => '$newValue';
}

// :sealed
abstract class ListViewChange extends Change {
  @override
  bool get isOverwriting => false;
}

class ListViewItemAdded extends ListViewChange {
  ListViewItemAdded(this.itemId);

  final ActorId itemId;

  factory ListViewItemAdded.fromJson(Map<String, dynamic> json) {
    return ListViewItemAdded(
      json['item'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'item': itemId,
    };
  }

  @override
  String format() => itemId;
}

class ListViewItemAddedIfAbsent extends ListViewChange {
  ListViewItemAddedIfAbsent(this.itemId);

  final ActorId itemId;

  factory ListViewItemAddedIfAbsent.fromJson(Map<String, dynamic> json) {
    return ListViewItemAddedIfAbsent(
      json['item'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'item': itemId,
    };
  }

  @override
  String format() => itemId;
}

class ListViewItemRemoved extends ListViewChange {
  ListViewItemRemoved(this.itemId);

  final ActorId itemId;

  factory ListViewItemRemoved.fromJson(Map<String, dynamic> json) {
    return ListViewItemRemoved(
      json['item'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'item': itemId,
    };
  }
}

class ListViewItemChanged extends ListViewChange {
  ListViewItemChanged({required this.oldItemId, required this.newItemId});

  final ActorId oldItemId;

  final ActorId newItemId;

  factory ListViewItemChanged.fromJson(Map<String, dynamic> json) {
    return ListViewItemChanged(
      oldItemId: json['oitem'],
      newItemId: json['nitem'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'oitem': oldItemId,
      'nitem': newItemId,
    };
  }
}

class ListViewItemMoved extends ListViewChange {
  ListViewItemMoved(this.itemId, this.newIndex);

  final ActorId itemId;

  final int newIndex;

  factory ListViewItemMoved.fromJson(Map<String, dynamic> json) {
    return ListViewItemMoved(
      json['item'],
      json['idx'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'item': itemId,
      'idx': newIndex,
    };
  }
}

class ListViewCleared extends ListViewChange {
  ListViewCleared();

  factory ListViewCleared.fromJson(Map<String, dynamic> json) {
    return ListViewCleared();
  }

  @override
  Map<String, dynamic> toJson() {
    return {};
  }
}

typedef RefIdNamePair = ({String itemId, String name});

abstract class AttributeChange extends Change {
  ActorId get attrId;
  String get attrName;
}

class RefValueAttributeChanged2 extends AttributeChange {
  RefValueAttributeChanged2({
    required this.attrId,
    required this.attrName,
    required this.newValue,
  });

  @override
  final ActorId attrId;

  @override
  final String attrName;

  final dynamic newValue;

  @override
  final isOverwriting = true;

  factory RefValueAttributeChanged2.fromJson(Map<String, dynamic> json) {
    return RefValueAttributeChanged2(
      attrId: json['id'],
      attrName: json['name'],
      newValue: json['val'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': attrId,
      'name': attrName,
      'val': newValue,
    };
  }
}

class CounterAttrIncremented2 extends AttributeChange {
  CounterAttrIncremented2({
    required this.attrId,
    required this.attrName,
    required this.by,
  });

  @override
  final ActorId attrId;

  @override
  final String attrName;

  final int by;

  @override
  final isOverwriting = false;

  factory CounterAttrIncremented2.fromJson(Map<String, dynamic> json) {
    return CounterAttrIncremented2(
      attrId: json['id'],
      attrName: json['name'],
      by: json['by'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': attrId,
      'name': attrName,
      'by': by,
    };
  }
}

class CounterAttrDecremented2 extends AttributeChange {
  CounterAttrDecremented2({
    required this.attrId,
    required this.attrName,
    required this.by,
  });

  @override
  final ActorId attrId;

  @override
  final String attrName;

  final int by;

  @override
  final isOverwriting = false;

  factory CounterAttrDecremented2.fromJson(Map<String, dynamic> json) {
    return CounterAttrDecremented2(
      attrId: json['id'],
      attrName: json['name'],
      by: json['by'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': attrId,
      'name': attrName,
      'by': by,
    };
  }
}

class CounterAttrReset2 extends AttributeChange {
  CounterAttrReset2({
    required this.attrId,
    required this.attrName,
    required this.newValue,
  });

  @override
  final ActorId attrId;

  @override
  final String attrName;

  final int newValue;

  @override
  final isOverwriting = false;

  factory CounterAttrReset2.fromJson(Map<String, dynamic> json) {
    return CounterAttrReset2(
      attrId: json['id'],
      attrName: json['name'],
      newValue: json['val'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': attrId,
      'name': attrName,
      'val': newValue,
    };
  }
}
