// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListPageItemAdded _$ListPageItemAddedFromJson(Map<String, dynamic> json) =>
    ListPageItemAdded(
      pageId: json['pageId'] as String,
      pos: (json['pos'] as num).toDouble(),
      refId: json['refId'] as String,
    );

Map<String, dynamic> _$ListPageItemAddedToJson(ListPageItemAdded instance) =>
    <String, dynamic>{
      'pageId': instance.pageId,
      'pos': instance.pos,
      'refId': instance.refId,
    };

ListPageItemRemoved _$ListPageItemRemovedFromJson(Map<String, dynamic> json) =>
    ListPageItemRemoved(
      pageId: json['pageId'] as String,
      pos: (json['pos'] as num).toDouble(),
    );

Map<String, dynamic> _$ListPageItemRemovedToJson(
  ListPageItemRemoved instance,
) => <String, dynamic>{'pageId': instance.pageId, 'pos': instance.pos};

ListPageCleared _$ListPageClearedFromJson(Map<String, dynamic> json) =>
    ListPageCleared(pageId: json['pageId'] as String);

Map<String, dynamic> _$ListPageClearedToJson(ListPageCleared instance) =>
    <String, dynamic>{'pageId': instance.pageId};
