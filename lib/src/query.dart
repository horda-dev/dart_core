import 'package:collection/collection.dart';

import 'error.dart';
import 'view.dart';
import 'worker.dart';

class ViewSnapshot {
  ViewSnapshot(this.value, this.version);

  ViewSnapshot.fromJson(Map<String, dynamic> json)
      : value = _value(json),
        version = _version(json);

  final dynamic value;

  final int version;

  bool get isNull => value == null;

  Map<String, dynamic> toJson() {
    return {
      'val': switch (value) {
        DateTime() => (value as DateTime).millisecondsSinceEpoch,
        _ => value,
      },
      'ver': version,
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

  static int _version(Map<String, dynamic> json) {
    var ver = json['ver'];
    if (ver == null || ver is! int || ver < 0) {
      throw FluirError('error parsing view snapshot version $json');
    }
    return ver;
  }
}

class QueryDef {
  QueryDef(this.views);

  final Map<String, ViewQueryDef> views;

  factory QueryDef.fromJson(Map<String, dynamic> json) {
    var views = <String, ViewQueryDef>{};

    for (var entry in json.entries) {
      var type = entry.value['type'];
      switch (type) {
        case 'val':
          views[entry.key] = ValueQueryDef.fromJson(entry.value);
          break;
        case 'cnt':
          views[entry.key] = CounterQueryDef.fromJson(entry.value);
          break;
        case 'ref':
          views[entry.key] = RefQueryDef.fromJson(entry.value);
          break;
        case 'list':
          views[entry.key] = ListQueryDef.fromJson(entry.value);
          break;
        default:
          throw FluirError('unknown query def type: $type');
      }
    }

    return QueryDef(views);
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{};

    for (var entry in views.entries) {
      json[entry.key] = entry.value.toJson();
    }

    return json;
  }
}

abstract class ViewQueryDef {
  ViewQueryDef({this.subscribe = false});

  final bool subscribe;

  Map<String, dynamic> toJson();
}

class ValueQueryDef extends ViewQueryDef {
  ValueQueryDef({super.subscribe});

  factory ValueQueryDef.fromJson(Map<String, dynamic> json) {
    assert(json['type'] == 'val');

    return ValueQueryDef();
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'val',
    };
  }
}

class CounterQueryDef extends ViewQueryDef {
  CounterQueryDef({super.subscribe});

  factory CounterQueryDef.fromJson(Map<String, dynamic> json) {
    assert(json['type'] == 'cnt');

    return CounterQueryDef();
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'cnt',
    };
  }
}

class RefQueryDef extends ViewQueryDef {
  RefQueryDef({
    required this.query,
    required this.attrs,
    super.subscribe,
  });

  final QueryDef query;

  List<String> attrs;

  factory RefQueryDef.fromJson(Map<String, dynamic> json) {
    assert(json['type'] == 'ref');

    Map<String, dynamic> queryJson = json['query'];
    final query = QueryDef.fromJson(queryJson);
    List<String> attrs = List.from(json['attrs'] ?? []);

    return RefQueryDef(
      query: query,
      attrs: attrs,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'ref',
      'query': query.toJson(),
      if (attrs.isNotEmpty) 'attrs': attrs,
    };
  }
}

class ListQueryDef extends ViewQueryDef {
  ListQueryDef({
    required this.query,
    required this.attrs,
    super.subscribe,
    required this.startAt,
    required this.length,
  });

  QueryDef query;

  List<String> attrs;

  final int startAt;

  final int length;

  factory ListQueryDef.fromJson(Map<String, dynamic> json) {
    assert(json['type'] == 'list');

    Map<String, dynamic> queryJson = json['query'];
    List<String> attrs = List.from(json['attrs'] ?? []);
    int start = json['start'] ?? 0;
    int len = json['len'] ?? 0;

    return ListQueryDef(
      query: QueryDef.fromJson(queryJson),
      attrs: attrs,
      startAt: start,
      length: len,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'list',
      'query': query.toJson(),
      if (attrs.isNotEmpty) 'attrs': attrs,
      if (startAt != 0) 'start': startAt,
      if (length != 0) 'len': length,
    };
  }
}

// query definition builder

class QueryDefBuilder {
  void add(ViewQueryDefBuilder qb) {
    _queryViewBuilders.add(qb);
  }

  QueryDef build() {
    var subqueryViews = <String, ViewQueryDef>{};

    for (var b in _queryViewBuilders) {
      subqueryViews[b.name] = b.build();
    }

    return QueryDef(subqueryViews);
  }

  final _queryViewBuilders = <ViewQueryDefBuilder>[];
}

abstract class ViewQueryDefBuilder {
  ViewQueryDefBuilder(this.name, {this.subscribe = false});

  final String name;

  final bool subscribe;

  ViewQueryDef build();
}

class ValueQueryDefBuilder extends ViewQueryDefBuilder {
  ValueQueryDefBuilder(super.name, {super.subscribe});

  @override
  ViewQueryDef build() {
    return ValueQueryDef(subscribe: subscribe);
  }
}

class RefQueryDefBuilder extends ViewQueryDefBuilder {
  RefQueryDefBuilder(
    super.name,
    this.attrs, {
    super.subscribe = false,
  });

  final List<String> attrs;

  void add(ViewQueryDefBuilder qb) {
    _subqueryViewBuilders.add(qb);
  }

  @override
  ViewQueryDef build() {
    var subqueryViews = <String, ViewQueryDef>{};

    for (var b in _subqueryViewBuilders) {
      subqueryViews[b.name] = b.build();
    }

    return RefQueryDef(
      query: QueryDef(subqueryViews),
      subscribe: subscribe,
      attrs: attrs,
    );
  }

  final _subqueryViewBuilders = <ViewQueryDefBuilder>[];
}

class ListQueryDefBuilder extends ViewQueryDefBuilder {
  ListQueryDefBuilder(
    super.name,
    this.attrs, {
    super.subscribe = false,
    this.startAt = 0,
    this.length = 0,
  });

  final List<String> attrs;

  final int startAt;

  final int length;

  void add(ViewQueryDefBuilder qb) {
    _subqueryViewBuilders.add(qb);
  }

  @override
  ViewQueryDef build() {
    var queryViews = <String, ViewQueryDef>{};

    for (var b in _subqueryViewBuilders) {
      queryViews[b.name] = b.build();
    }

    return ListQueryDef(
      query: QueryDef(queryViews),
      attrs: attrs,
      subscribe: subscribe,
      startAt: startAt,
      length: length,
    );
  }

  final _subqueryViewBuilders = <ViewQueryDefBuilder>[];
}

// query definition builder extensions

extension QueryDefBuilderManual on QueryDefBuilder {
  void val(String name) {
    add(ValueQueryDefBuilder(name));
  }

  void ref(
    String name,
    List<String> attrs,
    void Function(RefQueryDefBuilder qb) fun,
  ) {
    var qb = RefQueryDefBuilder(name, attrs);
    fun(qb);
    add(qb);
  }

  void list(String name, List<String> attrs,
      void Function(ListQueryDefBuilder qb) fun) {
    var qb = ListQueryDefBuilder(name, attrs);
    fun(qb);
    add(qb);
  }
}

extension RefQueryDefBuilderManual on RefQueryDefBuilder {
  void val(String name) {
    add(ValueQueryDefBuilder(name));
  }
}

extension ListQueryDefBuilderManual on ListQueryDefBuilder {
  void val(String name) {
    add(ValueQueryDefBuilder(name));
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
  ViewQueryResult(this.value, this.version);

  final dynamic value;

  final int version;

  Map<String, dynamic> toJson();
}

class ValueQueryResult extends ViewQueryResult {
  ValueQueryResult(super.value, super.version);

  factory ValueQueryResult.fromJson(Map<String, dynamic> json) {
    assert(json['type'] == 'val');

    dynamic val = json['val'];
    int ver = json['ver'];

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
      'ver': version,
    };
  }
}

class CounterQueryResult extends ViewQueryResult {
  CounterQueryResult(super.value, super.version);

  factory CounterQueryResult.fromJson(Map<String, dynamic> json) {
    assert(json['type'] == 'cnt');

    dynamic val = json['val']!;
    int ver = json['ver'];

    return CounterQueryResult(val, ver);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'cnt',
      'val': value,
      'ver': version,
    };
  }
}

class RefQueryResult extends ViewQueryResult {
  RefQueryResult(super.value, this.attrs, super.version, this.query);

  @override
  ActorId? get value => super.value;

  final QueryResult? query;

  final Map<String, dynamic> attrs;

  factory RefQueryResult.fromJson(Map<String, dynamic> json) {
    assert(json['type'] == 'ref');

    ActorId? val = json['val'];
    Map<String, dynamic> attrs = Map.from(json['attrs'] ?? {});
    Map<String, dynamic>? refJson = json['ref'];
    int ver = json['ver'];

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
      'ver': version,
      'ref': query?.toJson(),
    };
  }
}

class ListQueryResult extends ViewQueryResult {
  ListQueryResult(
    super.value,
    this.attrs,
    super.version,
    this.items,
  );

  @override
  Iterable<ActorId> get value => super.value;

  final Iterable<QueryResult> items;

  // maps itemId to {'attrName': attrValue}
  final Map<String, Map<String, dynamic>> attrs;

  factory ListQueryResult.fromJson(Map<String, dynamic> json) {
    assert(json['type'] == 'list');

    List<ActorId> val = List.from(json['val']);
    Map<String, Map<String, dynamic>> attrs = Map.from(json['attrs'] ?? {});
    List<Map<String, dynamic>> itemsJson = List.from(json['items']);
    int ver = json['ver'];

    var value = <ActorId>[];
    var items = <QueryResult>[];

    for (var pair in IterableZip([val, itemsJson])) {
      value.add(pair[0] as ActorId);
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
      'ver': version,
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
    return ValueQueryResult(snap.value, snap.version);
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
      snap.version,
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
      snap.version,
      items.map((i) => i.build()),
    );
  }
}

// query result builder extensions

extension QueryResultBuilderManual on QueryResultBuilder {
  void val(String name, dynamic value, int version) {
    add(
      ValueQueryResultBuilder(
        name,
        ViewSnapshot(value, version),
      ),
    );
  }

  void ref(
    String name,
    ActorId value,
    Map<String, dynamic> attrs,
    int version,
    void Function(QueryResultBuilder rb) fun,
  ) {
    var subquery = QueryResultBuilder();
    fun(subquery);
    add(
      RefQueryResultBuilder(
        name,
        ViewSnapshot(value, version),
        attrs,
        subquery,
      ),
    );
  }

  void list(
    String name,
    Map<RefIdNamePair, dynamic> attrs,
    int version,
    void Function(Map<ActorId, QueryResultBuilder> items) fun,
  ) {
    final attrsMap = <String, Map<String, dynamic>>{};

    for (final kv in attrs.entries) {
      final attr = attrsMap.putIfAbsent(kv.key.itemId, () => {});
      attr[kv.key.name] = kv.value;
    }

    var items = <ActorId, QueryResultBuilder>{};
    fun(items);
    add(ListQueryResultBuilder(
      name,
      attrsMap,
      ViewSnapshot(items.keys, version),
      items.values.toList(),
    ));
  }
}

extension ListQueryResultBuilderManual on Map<ActorId, QueryResultBuilder> {
  void item(ActorId actorId, void Function(QueryResultBuilder rb) fun) {
    var qrb = QueryResultBuilder();
    fun(qrb);
    this[actorId] = qrb;
  }
}
