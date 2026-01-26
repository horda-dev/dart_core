import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';

import 'error.dart';
import 'id.dart';
import 'view.dart';

part 'query_res.g.dart';

/// Snapshot of a view's current value with version information.
///
/// Represents the current state of an entity view at a specific point in time,
/// including the change ID for tracking updates and synchronization.
class ViewSnapshot {
  /// Creates a view snapshot with value and change ID.
  ViewSnapshot(this.value, this.changeId);

  ViewSnapshot.fromJson(Map<String, dynamic> json)
    : value = _value(json),
      changeId = _changeId(json);

  /// Current value of the view (type depends on view type).
  final dynamic value;

  /// Unique identifier for the last change applied to this view.
  final String changeId;

  /// Whether the view value is null.
  bool get isNull => value == null;

  Map<String, dynamic> toJson() {
    return {
      'val': switch (value) {
        DateTime() => (value as DateTime).millisecondsSinceEpoch,
        _ => value,
      },
      'chid': changeId,
      'type': value.runtimeType.toString(),
    };
  }

  static dynamic _value(Map<String, dynamic> json) {
    final type = json['type'];
    var val = json['val'];

    if (type == 'DateTime') {
      val = DateTime.fromMillisecondsSinceEpoch(val);
    }
    if (val is List) {
      // cast empty list that is of type List<dynamic> to List<String>
      val = val.cast<String>();
    }

    return val;
  }

  static String _changeId(Map<String, dynamic> json) {
    var ver = json['chid'];
    if (ver is! String) {
      throw FluirError('error parsing view snapshot changeId $json');
    }
    return ver;
  }
}

// query result

/// Result of executing a query against entity views.
///
/// Contains the retrieved view data organized by view name,
/// with each view providing its specific result type.
class QueryResult {
  /// Creates a query result with the specified view results.
  QueryResult(this.views);

  /// Map of view names to their query results.
  final Map<String, ViewQueryResult> views;

  factory QueryResult.fromJson(Map<String, dynamic> json) {
    var views = <String, ViewQueryResult>{};

    for (var entry in json.entries) {
      var type = entry.value['type'];
      switch (type) {
        case 'val':
          views[entry.key] = ValueQueryResult.fromJson(entry.value);
          break;
        case 'cnt':
          views[entry.key] = CounterQueryResult.fromJson(entry.value);
          break;
        case 'ref':
          views[entry.key] = RefQueryResult.fromJson(entry.value);
          break;
        case 'list':
          views[entry.key] = ListQueryResult.fromJson(entry.value);
          break;
        default:
          throw FluirError('unknown query result type: $type');
      }
    }
    return QueryResult(views);
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{};

    for (var entry in views.entries) {
      json[entry.key] = entry.value.toJson();
    }

    return json;
  }
}

/// Base class for view-specific query results.
///
/// Provides common functionality for different types of view results
/// while allowing type-specific implementations.
abstract class ViewQueryResult {
  /// Creates a view query result with value and change ID.
  ViewQueryResult(this.value, this.changeId);

  /// The value retrieved from the view.
  final dynamic value;

  /// Change ID indicating the version of this result.
  final String changeId;

  /// Converts the result to JSON for network transmission.
  Map<String, dynamic> toJson();
}

/// Query result for value views.
///
/// Contains a single typed value retrieved from an entity view.
class ValueQueryResult extends ViewQueryResult {
  /// Creates a value query result.
  ValueQueryResult(super.value, super.changeId);

  factory ValueQueryResult.fromJson(Map<String, dynamic> json) {
    assert(json['type'] == 'val');

    dynamic val = json['val'];
    String ver = json['chid'];

    return ValueQueryResult(val, ver);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'val',
      'val': switch (value) {
        DateTime() => (value as DateTime).millisecondsSinceEpoch,
        _ => value,
      },
      'chid': changeId,
    };
  }
}

/// Query result for counter views.
///
/// Contains an integer counter value retrieved from an entity view.
class CounterQueryResult extends ViewQueryResult {
  /// Creates a counter query result.
  CounterQueryResult(super.value, super.changeId);

  factory CounterQueryResult.fromJson(Map<String, dynamic> json) {
    assert(json['type'] == 'cnt');

    dynamic val = json['val']!;
    String ver = json['chid'];

    return CounterQueryResult(val, ver);
  }

  @override
  Map<String, dynamic> toJson() {
    return {'type': 'cnt', 'val': value, 'chid': changeId};
  }
}

/// Query result for reference views.
///
/// Contains an entity reference with optional nested query results
/// and attributes associated with the reference.
class RefQueryResult extends ViewQueryResult {
  /// Creates a reference query result with attributes and nested query.
  RefQueryResult(super.value, this.attrs, super.changeId, this.query);

  /// The referenced entity ID, or null if no reference is set.
  @override
  EntityId? get value => super.value;

  /// Results from querying the referenced entity (if requested).
  final QueryResult? query;

  /// Attributes associated with this reference.
  final Map<String, dynamic> attrs;

  factory RefQueryResult.fromJson(Map<String, dynamic> json) {
    assert(json['type'] == 'ref');

    EntityId? val = json['val'];
    Map<String, dynamic> attrs = Map.from(json['attrs'] ?? {});
    Map<String, dynamic>? refJson = json['ref'];
    String ver = json['chid'];

    return RefQueryResult(
      val,
      attrs,
      ver,
      refJson != null ? QueryResult.fromJson(refJson) : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'ref',
      'val': value,
      if (attrs.isNotEmpty) 'attrs': attrs,
      'chid': changeId,
      'ref': query?.toJson(),
    };
  }
}

/// A single item in a list view with its position and referenced entity ID.
@JsonSerializable()
class ListItem {
  /// Creates a list item with the specified key and value.
  ListItem(this.position, this.refId);

  /// Creates a list item from JSON.
  factory ListItem.fromJson(Map<String, dynamic> json) =>
      _$ListItemFromJson(json);

  /// Unique list position for this item.
  final double position;

  /// The referenced entity ID.
  final EntityId refId;

  /// Converts the list item to JSON.
  Map<String, dynamic> toJson() => _$ListItemToJson(this);

  @override
  String toString() {
    return 'ListItem(position:$position, refId:$refId)';
  }
}

/// Query result for list views.
///
/// Contains a list of entity references with per-item query results
/// and attributes for complex list data structures.
class ListQueryResult extends ViewQueryResult {
  /// Creates a list query result with items and attributes.
  ListQueryResult(
    super.value,
    this.attrs,
    super.changeId,
    this.items,
    this.pageId,
  );

  /// List of items this view.
  @override
  Iterable<ListItem> get value => super.value;

  /// Query results for each item in the list.
  final Iterable<QueryResult> items;

  /// Maps each referenced ID to its attributes (refId -> {attrName: attrValue}).
  final Map<String, Map<String, dynamic>> attrs;

  /// Page identifier indicating which page this result belongs to.
  final String pageId;

  factory ListQueryResult.fromJson(Map<String, dynamic> json) {
    assert(json['type'] == 'list');

    List<Map<String, dynamic>> valJson = List<Map<String, dynamic>>.from(
      json['val'],
    );
    Map<String, Map<String, dynamic>> attrs = Map.from(json['attrs'] ?? {});
    List<Map<String, dynamic>> itemsJson = List.from(json['items']);
    String ver = json['chid'];
    String pageId = json['pageId'];

    var value = <ListItem>[];
    var items = <QueryResult>[];

    for (var pair in IterableZip([valJson, itemsJson])) {
      value.add(ListItem.fromJson(pair[0]));
      items.add(QueryResult.fromJson(pair[1]));
    }

    return ListQueryResult(value, attrs, ver, items, pageId);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'list',
      'val': value.map((item) => item.toJson()).toList(),
      if (attrs.isNotEmpty) 'attrs': attrs,
      'chid': changeId,
      'items': items.map((i) => i.toJson()).toList(),
      'pageId': pageId,
    };
  }
}

// query result builder

/// Builder for constructing QueryResult objects programmatically.
///
/// Enables building complex query results with multiple view results
/// for testing, mocking, or programmatic result construction.
class QueryResultBuilder {
  /// Adds a view query result builder to this query result.
  void add(ViewQueryResultBuilder b) {
    _resultBuilders.add(b);
  }

  QueryResult build() {
    var views = <String, ViewQueryResult>{};

    for (var b in _resultBuilders) {
      var res = b.build();
      views[b.name] = res;
    }

    return QueryResult(views);
  }

  final _resultBuilders = <ViewQueryResultBuilder>[];
}

/// Base class for building view-specific query results.
///
/// Provides common functionality for constructing different types
/// of view query results from snapshots.
abstract class ViewQueryResultBuilder {
  /// Creates a view query result builder with name and snapshot.
  ViewQueryResultBuilder(this.name, this.snap);

  /// Name of the view this result represents.
  final String name;

  /// View snapshot containing the current value and change ID.
  final ViewSnapshot snap;

  /// Builds the specific ViewQueryResult implementation.
  ViewQueryResult build();
}

/// Builder for value query results.
///
/// Constructs value query results from view snapshots.
class ValueQueryResultBuilder extends ViewQueryResultBuilder {
  /// Creates a value query result builder.
  ValueQueryResultBuilder(super.name, super.snap);

  @override
  ViewQueryResult build() {
    return ValueQueryResult(snap.value, snap.changeId);
  }
}

/// Builder for reference query results.
///
/// Constructs reference query results with attributes and nested queries.
class RefQueryResultBuilder extends ViewQueryResultBuilder {
  /// Creates a reference query result builder.
  RefQueryResultBuilder(super.name, super.snap, this.attrs, this.subquery);

  /// Attributes associated with the reference.
  final Map<String, dynamic> attrs;

  /// Optional nested query result builder for the referenced entity.
  final QueryResultBuilder? subquery;

  @override
  ViewQueryResult build() {
    return RefQueryResult(snap.value, attrs, snap.changeId, subquery?.build());
  }
}

/// Builder for list query results.
///
/// Constructs list query results with per-item attributes and nested queries.
class ListQueryResultBuilder extends ViewQueryResultBuilder {
  /// Creates a list query result builder.
  ListQueryResultBuilder(
    super.name,
    this.attrs,
    super.snap,
    this.items,
    this.pageId,
  );

  /// Query result builders for each item in the list.
  final List<QueryResultBuilder> items;

  /// Attributes mapped by ref ID and attribute name.
  final Map<String, Map<String, dynamic>> attrs;

  /// Page identifier for this list result.
  final String pageId;

  @override
  ViewQueryResult build() {
    return ListQueryResult(
      snap.value,
      attrs,
      snap.changeId,
      items.map((i) => i.build()),
      pageId,
    );
  }
}

// query result builder extensions

extension QueryResultBuilderManual on QueryResultBuilder {
  void val(String name, dynamic value, String changeId) {
    add(ValueQueryResultBuilder(name, ViewSnapshot(value, changeId)));
  }

  void ref(
    String name,
    EntityId value,
    Map<String, dynamic> attrs,
    String changeId,
    void Function(QueryResultBuilder rb) fun,
  ) {
    var subquery = QueryResultBuilder();
    fun(subquery);
    add(
      RefQueryResultBuilder(
        name,
        ViewSnapshot(value, changeId),
        attrs,
        subquery,
      ),
    );
  }

  void list(
    String name,
    Map<RefIdNamePair, dynamic> attrs,
    String changeId,
    String pageId,
    void Function(
      Map<double, ({EntityId refId, QueryResultBuilder query})> items,
    )
    fun,
  ) {
    final attrsMap = <String, Map<String, dynamic>>{};

    for (final kv in attrs.entries) {
      final attr = attrsMap.putIfAbsent(kv.key.itemId, () => {});
      attr[kv.key.name] = kv.value;
    }

    var items = <double, ({EntityId refId, QueryResultBuilder query})>{};
    fun(items);

    // Create ListItem objects from the positions and ref ids
    var listItems = items.entries
        .map((e) => ListItem(e.key, e.value.refId))
        .toList();

    // Extract the query builders in the same order
    var queryBuilders = items.entries.map((e) => e.value.query).toList();

    add(
      ListQueryResultBuilder(
        name,
        attrsMap,
        ViewSnapshot(listItems, changeId),
        queryBuilders,
        pageId,
      ),
    );
  }
}

extension ListQueryResultBuilderManual
    on Map<double, ({EntityId refId, QueryResultBuilder query})> {
  void item(
    double position,
    EntityId refId,
    void Function(QueryResultBuilder rb) fun,
  ) {
    var qrb = QueryResultBuilder();
    fun(qrb);
    this[position] = (refId: refId, query: qrb);
  }
}
