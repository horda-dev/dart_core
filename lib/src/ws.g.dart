// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ws.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WelcomeWsMsg _$WelcomeWsMsgFromJson(Map<String, dynamic> json) => WelcomeWsMsg(
      json['userId'] as String?,
      json['serverVersion'] as String,
    );

Map<String, dynamic> _$WelcomeWsMsgToJson(WelcomeWsMsg instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'serverVersion': instance.serverVersion,
      'type': instance.type,
    };

QueryWsMsg _$QueryWsMsgFromJson(Map<String, dynamic> json) => QueryWsMsg(
      actorId: json['actorId'] as String,
      name: json['name'] as String,
      def: QueryWsMsg._defFromJson(json['def'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$QueryWsMsgToJson(QueryWsMsg instance) =>
    <String, dynamic>{
      'actorId': instance.actorId,
      'name': instance.name,
      'def': QueryWsMsg._defToJson(instance.def),
    };

QueryResultWsMsg _$QueryResultWsMsgFromJson(Map<String, dynamic> json) =>
    QueryResultWsMsg(
      result:
          QueryResultWsMsg._resFromJson(json['result'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$QueryResultWsMsgToJson(QueryResultWsMsg instance) =>
    <String, dynamic>{
      'result': QueryResultWsMsg._resToJson(instance.result),
    };

ActorViewSub _$ActorViewSubFromJson(Map<String, dynamic> json) => ActorViewSub(
      json['id'] as String,
      json['name'] as String,
      (json['ver'] as num).toInt(),
    );

Map<String, dynamic> _$ActorViewSubToJson(ActorViewSub instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'ver': instance.version,
    };

SubscribeViewsWsMsg _$SubscribeViewsWsMsgFromJson(Map<String, dynamic> json) =>
    SubscribeViewsWsMsg(
      (json['subs'] as List<dynamic>)
          .map((e) => ActorViewSub.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SubscribeViewsWsMsgToJson(
        SubscribeViewsWsMsg instance) =>
    <String, dynamic>{
      'subs': instance.subs,
    };

SubscribeViewsAckWsMsg _$SubscribeViewsAckWsMsgFromJson(
        Map<String, dynamic> json) =>
    SubscribeViewsAckWsMsg();

Map<String, dynamic> _$SubscribeViewsAckWsMsgToJson(
        SubscribeViewsAckWsMsg instance) =>
    <String, dynamic>{};

UnsubscribeViewsWsMsg _$UnsubscribeViewsWsMsgFromJson(
        Map<String, dynamic> json) =>
    UnsubscribeViewsWsMsg(
      (json['subs'] as List<dynamic>)
          .map((e) => ActorViewSub.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UnsubscribeViewsWsMsgToJson(
        UnsubscribeViewsWsMsg instance) =>
    <String, dynamic>{
      'subs': instance.subs,
    };

UnsubscribeViewsResWsMsg _$UnsubscribeViewsResWsMsgFromJson(
        Map<String, dynamic> json) =>
    UnsubscribeViewsResWsMsg();

Map<String, dynamic> _$UnsubscribeViewsResWsMsgToJson(
        UnsubscribeViewsResWsMsg instance) =>
    <String, dynamic>{};

ActorEventWsMsg _$ActorEventWsMsgFromJson(Map<String, dynamic> json) =>
    ActorEventWsMsg(
      EventEnvelop.fromJson(json['env'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ActorEventWsMsgToJson(ActorEventWsMsg instance) =>
    <String, dynamic>{
      'env': instance.env,
    };

ViewChangeWsMsg _$ViewChangeWsMsgFromJson(Map<String, dynamic> json) =>
    ViewChangeWsMsg(
      ChangeEnvelop.fromJson(json['env'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ViewChangeWsMsgToJson(ViewChangeWsMsg instance) =>
    <String, dynamic>{
      'env': instance.env,
    };

SendCommandAckWsMsg _$SendCommandAckWsMsgFromJson(Map<String, dynamic> json) =>
    SendCommandAckWsMsg();

Map<String, dynamic> _$SendCommandAckWsMsgToJson(
        SendCommandAckWsMsg instance) =>
    <String, dynamic>{};

CallCommandResWsMsg _$CallCommandResWsMsgFromJson(Map<String, dynamic> json) =>
    CallCommandResWsMsg(
      EventEnvelop.fromJson(json['env'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CallCommandResWsMsgToJson(
        CallCommandResWsMsg instance) =>
    <String, dynamic>{
      'env': instance.env,
    };

DispatchEventResWsMsg _$DispatchEventResWsMsgFromJson(
        Map<String, dynamic> json) =>
    DispatchEventResWsMsg(
      FlowResultEnvelop.fromJson(json['env'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DispatchEventResWsMsgToJson(
        DispatchEventResWsMsg instance) =>
    <String, dynamic>{
      'env': instance.env,
    };

ErrorWsMsg _$ErrorWsMsgFromJson(Map<String, dynamic> json) => ErrorWsMsg(
      json['text'] as String,
      json['error'],
    );

Map<String, dynamic> _$ErrorWsMsgToJson(ErrorWsMsg instance) =>
    <String, dynamic>{
      'text': instance.text,
      'error': instance.error,
    };
