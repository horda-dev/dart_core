import 'package:collection/collection.dart';

import 'error.dart';
import 'id.dart';
import 'view.dart';

class ViewSnapshot {
  ViewSnapshot(this.value, this.changeId);

  ViewSnapshot.fromJson(Map<String, dynamic> json)
      : value = _value(json),
        changeId = _changeId(json);

  final dynamic value;

  final String changeId;

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

class QueryResult {
  QueryResult(this.views);

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

abstract class ViewQueryResult {
  ViewQueryResult(this.value, this.changeId);

  final dynamic value;

  final String changeId;

  Map<String, dynamic> toJson();
}

class ValueQueryResult extends ViewQueryResult {
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

class CounterQueryResult extends ViewQueryResult {
  CounterQueryResult(super.value, super.changeId);

  factory CounterQueryResult.fromJson(Map<String, dynamic> json) {
    assert(json['type'] == 'cnt');

    dynamic val = json['val']!;
    String ver = json['chid'];

    return CounterQueryResult(val, ver);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'cnt',
      'val': value,
      'chid': changeId,
    };
  }
}

class RefQueryResult extends ViewQueryResult {
  RefQueryResult(super.value, this.attrs, super.changeId, this.query);

  @override
  EntityId? get value => super.value;

  final QueryResult? query;

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

class ListQueryResult extends ViewQueryResult {
  ListQueryResult(
    super.value,
    this.attrs,
    super.changeId,
    this.items,
  );

  @override
  Iterable<EntityId> get value => super.value;

  final Iterable<QueryResult> items;

  // maps itemId to {'attrName': attrValue}
  final Map<String, Map<String, dynamic>> attrs;

  factory ListQueryResult.fromJson(Map<String, dynamic> json) {
    assert(json['type'] == 'list');

    List<EntityId> val = List<EntityId>.from(json['val']);
    Map<String, Map<String, dynamic>> attrs = Map.from(json['attrs'] ?? {});
    List<Map<String, dynamic>> itemsJson = List.from(json['items']);
    String ver = json['chid'];

    var value = <EntityId>[];
    var items = <QueryResult>[];

    for (var pair in IterableZip([val, itemsJson])) {
      value.add(pair[0] as EntityId);
      items.add(QueryResult.fromJson(pair[1] as Map<String, dynamic>));
    }

    return ListQueryResult(value, attrs, ver, items);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'list',
      'val': value.toList(),
      if (attrs.isNotEmpty) 'attrs': attrs,
      'chid': changeId,
      'items': items.map((i) => i.toJson()).toList(),
    };
  }
}

// query result builder

class QueryResultBuilder {
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

abstract class ViewQueryResultBuilder {
  ViewQueryResultBuilder(this.name, this.snap);

  final String name;

  final ViewSnapshot snap;

  ViewQueryResult build();
}

class ValueQueryResultBuilder extends ViewQueryResultBuilder {
  ValueQueryResultBuilder(super.name, super.snap);

  @override
  ViewQueryResult build() {
    return ValueQueryResult(snap.value, snap.changeId);
  }
}

class RefQueryResultBuilder extends ViewQueryResultBuilder {
  RefQueryResultBuilder(super.name, super.snap, this.attrs, this.subquery);

  final Map<String, dynamic> attrs;

  final QueryResultBuilder? subquery;

  @override
  ViewQueryResult build() {
    return RefQueryResult(
      snap.value,
      attrs,
      snap.changeId,
      subquery?.build(),
    );
  }
}

class ListQueryResultBuilder extends ViewQueryResultBuilder {
  ListQueryResultBuilder(
    super.name,
    this.attrs,
    super.snap,
    this.items,
  );

  final List<QueryResultBuilder> items;

  final Map<String, Map<String, dynamic>> attrs;

  @override
  ViewQueryResult build() {
    return ListQueryResult(
      snap.value,
      attrs,
      snap.changeId,
      items.map((i) => i.build()),
    );
  }
}

// query result builder extensions

extension QueryResultBuilderManual on QueryResultBuilder {
  void val(String name, dynamic value, String changeId) {
    add(
      ValueQueryResultBuilder(
        name,
        ViewSnapshot(value, changeId),
      ),
    );
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
    void Function(Map<EntityId, QueryResultBuilder> items) fun,
  ) {
    final attrsMap = <String, Map<String, dynamic>>{};

    for (final kv in attrs.entries) {
      final attr = attrsMap.putIfAbsent(kv.key.itemId, () => {});
      attr[kv.key.name] = kv.value;
    }

    var items = <EntityId, QueryResultBuilder>{};
    fun(items);
    add(ListQueryResultBuilder(
      name,
      attrsMap,
      ViewSnapshot(items.keys, changeId),
      items.values.toList(),
    ));
  }
}

extension ListQueryResultBuilderManual on Map<EntityId, QueryResultBuilder> {
  void item(EntityId actorId, void Function(QueryResultBuilder rb) fun) {
    var qrb = QueryResultBuilder();
    fun(qrb);
    this[actorId] = qrb;
  }
}
