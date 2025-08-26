import 'error.dart';

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
