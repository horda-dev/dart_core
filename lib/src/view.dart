import 'package:json_annotation/json_annotation.dart';

import 'id.dart';
import 'message.dart';

part 'view.g.dart';

/// Base class for all view changes in the Horda platform.
///
/// Changes represent modifications to entity views that are applied
/// to maintain real-time synchronization between entities and client applications.
abstract class Change extends RemoteMessage {
  /// Whether changes of this type overwrite or accumulate.
  ///
  /// - `true` - Changes overwrite the previous version (e.g., value updates)
  /// - `false` - Changes add to the previous version (e.g., counter increments)
  bool get isOverwriting;
}

/// Base class for changes to value views.
///
/// Value view changes always overwrite the previous value since
/// they represent setting a new typed value for the view.
abstract class ValueViewChange extends Change {
  @override
  bool get isOverwriting => true;
}

/// Change representing a new value being set in a typed value view.
///
/// The type parameter [T] represents the declared type of the value view,
/// not necessarily the runtime type of [newValue].
class ValueViewChanged<T> extends ValueViewChange {
  /// Creates a value change with the new value.
  ValueViewChanged(this.newValue);

  /// The new value to set in the view.
  final T newValue;

  factory ValueViewChanged.fromJson(Map<String, dynamic> json) {
    return ValueViewChanged<T>(_valueFromJson<T>(json));
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

  return {'val': val, 'type': T.toString()};
}

/// Base class for changes to counter views.
///
/// Counter view changes accumulate rather than overwrite, allowing
/// multiple increments, decrements, and resets to be applied in sequence.
abstract class CounterViewChange extends Change {
  @override
  bool get isOverwriting => false;
}

/// Change representing an increment operation on a counter view.
///
/// Adds the specified amount to the current counter value.
class CounterViewIncremented extends CounterViewChange {
  /// Creates a counter increment change.
  CounterViewIncremented({required this.by});

  /// Amount to increment the counter by (can be negative for decrement).
  final int by;

  factory CounterViewIncremented.fromJson(Map<String, dynamic> json) {
    return CounterViewIncremented(by: json['by']);
  }

  @override
  Map<String, dynamic> toJson() {
    return {'by': by};
  }
}

/// Change representing a decrement operation on a counter view.
///
/// Subtracts the specified amount from the current counter value.
class CounterViewDecremented extends CounterViewChange {
  /// Creates a counter decrement change.
  CounterViewDecremented({required this.by});

  /// Amount to decrement the counter by (must be positive).
  final int by;

  factory CounterViewDecremented.fromJson(Map<String, dynamic> json) {
    return CounterViewDecremented(by: json['by']);
  }

  @override
  Map<String, dynamic> toJson() {
    return {'by': by};
  }
}

/// Change representing a reset operation on a counter view.
///
/// Sets the counter to a specific value, discarding the previous count.
class CounterViewReset extends CounterViewChange {
  /// Creates a counter reset change.
  CounterViewReset({required this.newValue});

  /// The new value to set the counter to.
  final int newValue;

  factory CounterViewReset.fromJson(Map<String, dynamic> json) {
    return CounterViewReset(newValue: json['val']);
  }

  @override
  Map<String, dynamic> toJson() {
    return {'val': newValue};
  }
}

/// Base class for changes to reference views.
///
/// Reference view changes always overwrite the previous reference
/// since they represent changing which entity is being referenced.
abstract class RefViewChange extends Change {
  @override
  bool get isOverwriting => true;
}

/// Change representing a new entity reference being set in a reference view.
///
/// Updates the view to reference a different entity or clears the reference.
class RefViewChanged extends RefViewChange {
  /// Creates a reference change with the new entity ID.
  RefViewChanged(this.newValue);

  /// The ID of the new entity to reference, or null to clear the reference.
  final EntityId? newValue;

  factory RefViewChanged.fromJson(Map<String, dynamic> json) {
    return RefViewChanged(json['val']);
  }

  @override
  Map<String, dynamic> toJson() {
    return {'val': newValue};
  }

  @override
  String format() => '$newValue';
}

/// Base class for changes to list views.
///
/// List view changes accumulate to build up the list contents,
/// allowing multiple items to be added, removed, or modified.
abstract class ListViewChange extends Change {
  @override
  bool get isOverwriting => false;
}

/// Change representing an item being added to a list view.
///
/// Appends a new entity reference to the end of the list.
class ListViewItemAdded extends ListViewChange {
  /// Creates a list item addition change.
  ListViewItemAdded(this.item);

  /// ID of the entity to add to the list.
  final EntityId item;

  factory ListViewItemAdded.fromJson(Map<String, dynamic> json) {
    return ListViewItemAdded(json['item']);
  }

  @override
  Map<String, dynamic> toJson() {
    return {'item': item};
  }

  @override
  String format() => item.toString();
}

/// Change representing an item being removed from a list view.
///
/// Removes the specified entity from the list.
class ListViewItemRemoved extends ListViewChange {
  /// Creates a list item removal change.
  ListViewItemRemoved(this.item);

  /// ID of the entity to remove from the list.
  final EntityId item;

  factory ListViewItemRemoved.fromJson(Map<String, dynamic> json) {
    return ListViewItemRemoved(json['item']);
  }

  @override
  Map<String, dynamic> toJson() {
    return {'item': item};
  }
}

/// Change representing an item in a list view being replaced with another.
///
/// Replaces the item at the specified key with a new entity reference.
///
/// This change is not supported yet.
class ListViewItemChanged extends ListViewChange {
  /// Creates a list item replacement change.
  ListViewItemChanged({required this.key, required this.value});

  /// Key of the item to replace in the list.
  final String key;

  /// ID of the new entity to replace it with.
  final EntityId value;

  factory ListViewItemChanged.fromJson(Map<String, dynamic> json) {
    return ListViewItemChanged(
      key: json['key'],
      value: json['value'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {'key': key, 'value': value};
  }
}

/// Change representing an item in a list view being moved to a new position.
///
/// Moves the item with the specified key to a new position in the list.
///
/// This change is not supported yet.
class ListViewItemMoved extends ListViewChange {
  /// Creates a list item move change.
  ListViewItemMoved(this.key, this.toKey);

  /// Key of the item to move within the list.
  final String key;

  /// Key of the destination position to move the item to.
  final String toKey;

  factory ListViewItemMoved.fromJson(Map<String, dynamic> json) {
    return ListViewItemMoved(json['key'], json['toKey']);
  }

  @override
  Map<String, dynamic> toJson() {
    return {'key': key, 'toKey': toKey};
  }
}

/// Change representing all items being removed from a list view.
///
/// Clears the entire list, removing all entity references.
class ListViewCleared extends ListViewChange {
  /// Creates a list clear change.
  ListViewCleared();

  factory ListViewCleared.fromJson(Map<String, dynamic> json) {
    return ListViewCleared();
  }

  @override
  Map<String, dynamic> toJson() {
    return {};
  }
}

/// Base class for query list view changes.
///
/// Query list view changes include positional information for items in the list.
abstract class QueryListViewChange extends Change {
  @override
  bool get isOverwriting => false;
}

/// Change representing an item being added to a query list view with position.
///
/// Includes the position and reference ID of the added item.
@JsonSerializable()
class QueryListViewItemAdded extends QueryListViewChange {
  /// Creates a query list view item addition change.
  QueryListViewItemAdded({required this.pos, required this.refId});

  /// The position in the list.
  final double pos;

  /// The reference ID of the added item.
  final EntityId refId;

  factory QueryListViewItemAdded.fromJson(Map<String, dynamic> json) =>
      _$QueryListViewItemAddedFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$QueryListViewItemAddedToJson(this);
}

/// Change representing an item being removed from a query list view with position.
///
/// Includes the position and reference ID of the removed item.
@JsonSerializable()
class QueryListViewItemRemoved extends QueryListViewChange {
  /// Creates a query list view item removal change.
  QueryListViewItemRemoved({required this.pos, required this.refId});

  /// The position in the list.
  final double pos;

  /// The reference ID of the removed item.
  final EntityId refId;

  factory QueryListViewItemRemoved.fromJson(Map<String, dynamic> json) =>
      _$QueryListViewItemRemovedFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$QueryListViewItemRemovedToJson(this);
}

/// Type alias for identifying attributes attached to referenced entities.
///
/// Combines an entity ID with an attribute name to uniquely identify
/// a specific attribute on a specific entity within view structures.
typedef RefIdNamePair = ({String itemId, String name});

/// Base class for changes to attributes attached to referenced entities.
///
/// Attributes provide additional data associated with entity references
/// in views, such as counters or values specific to the relationship.
abstract class AttributeChange extends Change {
  /// ID of the entity that owns this attribute.
  EntityId get attrId;

  /// Name of the attribute being changed.
  String get attrName;
}

/// Change representing a value attribute on a referenced entity being updated.
///
/// Updates a named attribute associated with an entity reference,
/// storing arbitrary typed data related to the relationship.
class RefValueAttributeChanged extends AttributeChange {
  /// Creates a reference value attribute change.
  RefValueAttributeChanged({
    required this.attrId,
    required this.attrName,
    required this.newValue,
  });

  @override
  final EntityId attrId;

  @override
  final String attrName;

  /// The new value to set for this attribute.
  final dynamic newValue;

  @override
  final isOverwriting = true;

  factory RefValueAttributeChanged.fromJson(Map<String, dynamic> json) {
    return RefValueAttributeChanged(
      attrId: json['id'],
      attrName: json['name'],
      newValue: json['val'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {'id': attrId, 'name': attrName, 'val': newValue};
  }
}

/// Change representing a counter attribute on a referenced entity being incremented.
///
/// Increases a numeric attribute associated with an entity reference,
/// useful for tracking quantities or counts related to the relationship.
class CounterAttrIncremented extends AttributeChange {
  /// Creates a counter attribute increment change.
  CounterAttrIncremented({
    required this.attrId,
    required this.attrName,
    required this.by,
  });

  @override
  final EntityId attrId;

  @override
  final String attrName;

  /// Amount to increment the counter attribute by.
  final int by;

  @override
  final isOverwriting = false;

  factory CounterAttrIncremented.fromJson(Map<String, dynamic> json) {
    return CounterAttrIncremented(
      attrId: json['id'],
      attrName: json['name'],
      by: json['by'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {'id': attrId, 'name': attrName, 'by': by};
  }
}

/// Change representing a counter attribute on a referenced entity being decremented.
///
/// Decreases a numeric attribute associated with an entity reference,
/// useful for tracking reductions in quantities or counts.
class CounterAttrDecremented extends AttributeChange {
  /// Creates a counter attribute decrement change.
  CounterAttrDecremented({
    required this.attrId,
    required this.attrName,
    required this.by,
  });

  @override
  final EntityId attrId;

  @override
  final String attrName;

  /// Amount to decrement the counter attribute by.
  final int by;

  @override
  final isOverwriting = false;

  factory CounterAttrDecremented.fromJson(Map<String, dynamic> json) {
    return CounterAttrDecremented(
      attrId: json['id'],
      attrName: json['name'],
      by: json['by'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {'id': attrId, 'name': attrName, 'by': by};
  }
}

/// Change representing a counter attribute on a referenced entity being reset.
///
/// Sets a numeric attribute to a specific value, discarding the previous count.
class CounterAttrReset extends AttributeChange {
  /// Creates a counter attribute reset change.
  CounterAttrReset({
    required this.attrId,
    required this.attrName,
    required this.newValue,
  });

  @override
  final EntityId attrId;

  @override
  final String attrName;

  /// The new value to set the counter attribute to.
  final int newValue;

  @override
  final isOverwriting = false;

  factory CounterAttrReset.fromJson(Map<String, dynamic> json) {
    return CounterAttrReset(
      attrId: json['id'],
      attrName: json['name'],
      newValue: json['val'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {'id': attrId, 'name': attrName, 'val': newValue};
  }
}

/// Base class for changes to list pages during pagination synchronization.
///
/// List page changes represent modifications to paginated views of lists,
/// with each change associated with a specific page window identified by pageId.
abstract class ListPageChange extends Change {
  /// Creates a list page change for the specified page.
  ListPageChange({required this.pageId});

  /// The page ID identifying which page window the change applies to.
  final String pageId;

  @override
  bool get isOverwriting => false;
}

/// Page sync change representing an item added to a list page.
@JsonSerializable()
class ListPageItemAdded extends ListPageChange {
  ListPageItemAdded({
    required super.pageId,
    required this.pos,
    required this.refId,
  });

  /// The position in the list.
  final double pos;

  /// The reference ID of the added item.
  final EntityId refId;

  factory ListPageItemAdded.fromJson(Map<String, dynamic> json) =>
      _$ListPageItemAddedFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ListPageItemAddedToJson(this);
}

/// Page sync change representing an item removed from a list page.
@JsonSerializable()
class ListPageItemRemoved extends ListPageChange {
  ListPageItemRemoved({
    required super.pageId,
    required this.pos,
  });

  /// The position in the list.
  final double pos;

  factory ListPageItemRemoved.fromJson(Map<String, dynamic> json) =>
      _$ListPageItemRemovedFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ListPageItemRemovedToJson(this);
}

/// Page sync change representing a list page being cleared.
@JsonSerializable()
class ListPageCleared extends ListPageChange {
  ListPageCleared({
    required super.pageId,
  });

  factory ListPageCleared.fromJson(Map<String, dynamic> json) =>
      _$ListPageClearedFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ListPageClearedToJson(this);
}
