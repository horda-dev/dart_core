import 'package:collection/collection.dart';

import 'error.dart';
import 'view.dart';
import 'worker.dart';

class ViewSnapshot2 {
  ViewSnapshot2(this.value, this.changeId);

  ViewSnapshot2.fromJson(Map<String, dynamic> json)
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

class QueryResult2 {
  QueryResult2(this.views);

  final Map<String, ViewQueryResult2> views;

  factory QueryResult2.fromJson(Map<String, dynamic> json) {
    var views = <String, ViewQueryResult2>{};

    for (var entry in json.entries) {
      var type = entry.value['type'];
      switch (type) {
        case 'val':
          views[entry.key] = ValueQueryResult2.fromJson(entry.value);
          break;
        case 'cnt':
          views[entry.key] = CounterQueryResult2.fromJson(entry.value);
          break;
        case 'ref':
          views[entry.key] = RefQueryResult2.fromJson(entry.value);
          break;
        case 'list':
          views[entry.key] = ListQueryResult2.fromJson(entry.value);
          break;
        default:
          throw FluirError('unknown query result type: $type');
      }
    }
    return QueryResult2(views);
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{};

    for (var entry in views.entries) {
      json[entry.key] = entry.value.toJson();
    }

    return json;
  }
}

abstract class ViewQueryResult2 {
  ViewQueryResult2(this.value, this.changeId);

  final dynamic value;

  final String changeId;

  Map<String, dynamic> toJson();
}

class ValueQueryResult2 extends ViewQueryResult2 {
  ValueQueryResult2(super.value, super.changeId);

  factory ValueQueryResult2.fromJson(Map<String, dynamic> json) {
    assert(json['type'] == 'val');

    dynamic val = json['val'];
    String ver = json['chid'];

    return ValueQueryResult2(val, ver);
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

class CounterQueryResult2 extends ViewQueryResult2 {
  CounterQueryResult2(super.value, super.changeId);

  factory CounterQueryResult2.fromJson(Map<String, dynamic> json) {
    assert(json['type'] == 'cnt');

    dynamic val = json['val']!;
    String ver = json['chid'];

    return CounterQueryResult2(val, ver);
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

class RefQueryResult2 extends ViewQueryResult2 {
  RefQueryResult2(super.value, this.attrs, super.changeId, this.query);

  @override
  ActorId? get value => super.value;

  final QueryResult2? query;

  final Map<String, dynamic> attrs;

  factory RefQueryResult2.fromJson(Map<String, dynamic> json) {
    assert(json['type'] == 'ref');

    ActorId? val = json['val'];
    Map<String, dynamic> attrs = Map.from(json['attrs'] ?? {});
    Map<String, dynamic>? refJson = json['ref'];
    String ver = json['chid'];

    return RefQueryResult2(
      val,
      attrs,
      ver,
      refJson != null ? QueryResult2.fromJson(refJson) : null,
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

class ListQueryResult2 extends ViewQueryResult2 {
  ListQueryResult2(
    super.value,
    this.attrs,
    super.changeId,
    this.items,
  );

  @override
  Iterable<ActorId> get value => super.value;

  final Iterable<QueryResult2> items;

  // maps itemId to {'attrName': attrValue}
  final Map<String, Map<String, dynamic>> attrs;

  factory ListQueryResult2.fromJson(Map<String, dynamic> json) {
    assert(json['type'] == 'list');

    List<ActorId> val = List<ActorId>.from(json['val']);
    Map<String, Map<String, dynamic>> attrs = Map.from(json['attrs'] ?? {});
    List<Map<String, dynamic>> itemsJson = List.from(json['items']);
    String ver = json['chid'];

    var value = <ActorId>[];
    var items = <QueryResult2>[];

    for (var pair in IterableZip([val, itemsJson])) {
      value.add(pair[0] as ActorId);
      items.add(QueryResult2.fromJson(pair[1] as Map<String, dynamic>));
    }

    return ListQueryResult2(value, attrs, ver, items);
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

class QueryResultBuilder2 {
  void add(ViewQueryResultBuilder2 b) {
    _resultBuilders.add(b);
  }

  QueryResult2 build() {
    var views = <String, ViewQueryResult2>{};

    for (var b in _resultBuilders) {
      var res = b.build();
      views[b.name] = res;
    }

    return QueryResult2(views);
  }

  final _resultBuilders = <ViewQueryResultBuilder2>[];
}

abstract class ViewQueryResultBuilder2 {
  ViewQueryResultBuilder2(this.name, this.snap);

  final String name;

  final ViewSnapshot2 snap;

  ViewQueryResult2 build();
}

class ValueQueryResultBuilder2 extends ViewQueryResultBuilder2 {
  ValueQueryResultBuilder2(super.name, super.snap);

  @override
  ViewQueryResult2 build() {
    return ValueQueryResult2(snap.value, snap.changeId);
  }
}

class RefQueryResultBuilder2 extends ViewQueryResultBuilder2 {
  RefQueryResultBuilder2(super.name, super.snap, this.attrs, this.subquery);

  final Map<String, dynamic> attrs;

  final QueryResultBuilder2? subquery;

  @override
  ViewQueryResult2 build() {
    return RefQueryResult2(
      snap.value,
      attrs,
      snap.changeId,
      subquery?.build(),
    );
  }
}

class ListQueryResultBuilder2 extends ViewQueryResultBuilder2 {
  ListQueryResultBuilder2(
    super.name,
    this.attrs,
    super.snap,
    this.items,
  );

  final List<QueryResultBuilder2> items;

  final Map<String, Map<String, dynamic>> attrs;

  @override
  ViewQueryResult2 build() {
    return ListQueryResult2(
      snap.value,
      attrs,
      snap.changeId,
      items.map((i) => i.build()),
    );
  }
}

// query result builder extensions

extension QueryResultBuilderManual2 on QueryResultBuilder2 {
  void val(String name, dynamic value, String changeId) {
    add(
      ValueQueryResultBuilder2(
        name,
        ViewSnapshot2(value, changeId),
      ),
    );
  }

  void ref(
    String name,
    ActorId value,
    Map<String, dynamic> attrs,
    String changeId,
    void Function(QueryResultBuilder2 rb) fun,
  ) {
    var subquery = QueryResultBuilder2();
    fun(subquery);
    add(
      RefQueryResultBuilder2(
        name,
        ViewSnapshot2(value, changeId),
        attrs,
        subquery,
      ),
    );
  }

  void list(
    String name,
    Map<RefIdNamePair, dynamic> attrs,
    String changeId,
    void Function(Map<ActorId, QueryResultBuilder2> items) fun,
  ) {
    final attrsMap = <String, Map<String, dynamic>>{};

    for (final kv in attrs.entries) {
      final attr = attrsMap.putIfAbsent(kv.key.itemId, () => {});
      attr[kv.key.name] = kv.value;
    }

    var items = <ActorId, QueryResultBuilder2>{};
    fun(items);
    add(ListQueryResultBuilder2(
      name,
      attrsMap,
      ViewSnapshot2(items.keys, changeId),
      items.values.toList(),
    ));
  }
}

extension ListQueryResultBuilderManual2 on Map<ActorId, QueryResultBuilder2> {
  void item(ActorId actorId, void Function(QueryResultBuilder2 rb) fun) {
    var qrb = QueryResultBuilder2();
    fun(qrb);
    this[actorId] = qrb;
  }
}
