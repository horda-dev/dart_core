// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListPageItemAdded _$ListPageItemAddedFromJson(Map<String, dynamic> json) =>
    ListPageItemAdded(
      pageId: json['pageId'] as String,
      key: json['key'] as String,
      value: json['value'] as String,
      toBeginning: json['toBeginning'] as bool,
    );

Map<String, dynamic> _$ListPageItemAddedToJson(ListPageItemAdded instance) =>
    <String, dynamic>{
      'pageId': instance.pageId,
      'key': instance.key,
      'value': instance.value,
      'toBeginning': instance.toBeginning,
    };

ListPageItemRemoved _$ListPageItemRemovedFromJson(Map<String, dynamic> json) =>
    ListPageItemRemoved(
      pageId: json['pageId'] as String,
      key: json['key'] as String,
    );

Map<String, dynamic> _$ListPageItemRemovedToJson(
  ListPageItemRemoved instance,
) => <String, dynamic>{'pageId': instance.pageId, 'key': instance.key};

ListPageCleared _$ListPageClearedFromJson(Map<String, dynamic> json) =>
    ListPageCleared(pageId: json['pageId'] as String);

Map<String, dynamic> _$ListPageClearedToJson(ListPageCleared instance) =>
    <String, dynamic>{'pageId': instance.pageId};
