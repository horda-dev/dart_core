import 'view.dart';
import 'worker.dart';

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
