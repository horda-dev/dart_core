// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ws2.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WelcomeWsMsg2 _$WelcomeWsMsg2FromJson(Map<String, dynamic> json) =>
    WelcomeWsMsg2(
      json['userId'] as String?,
      json['serverVersion'] as String,
    );

Map<String, dynamic> _$WelcomeWsMsg2ToJson(WelcomeWsMsg2 instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'serverVersion': instance.serverVersion,
    };

QueryWsMsg2 _$QueryWsMsg2FromJson(Map<String, dynamic> json) => QueryWsMsg2(
      actorId: json['actorId'] as String,
      def: QueryWsMsg2._defFromJson(json['def'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$QueryWsMsg2ToJson(QueryWsMsg2 instance) =>
    <String, dynamic>{
      'actorId': instance.actorId,
      'def': QueryWsMsg2._defToJson(instance.def),
    };

QueryResultWsMsg2 _$QueryResultWsMsg2FromJson(Map<String, dynamic> json) =>
    QueryResultWsMsg2(
      result: QueryResultWsMsg2._resFromJson(
          json['result'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$QueryResultWsMsg2ToJson(QueryResultWsMsg2 instance) =>
    <String, dynamic>{
      'result': QueryResultWsMsg2._resToJson(instance.result),
    };

ActorViewSub2 _$ActorViewSub2FromJson(Map<String, dynamic> json) =>
    ActorViewSub2(
      json['id'] as String,
      json['name'] as String,
      json['ver'] as String,
    );

Map<String, dynamic> _$ActorViewSub2ToJson(ActorViewSub2 instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'ver': instance.changeId,
    };

SubscribeViewsWsMsg2 _$SubscribeViewsWsMsg2FromJson(
        Map<String, dynamic> json) =>
    SubscribeViewsWsMsg2(
      (json['subs'] as List<dynamic>)
          .map((e) => ActorViewSub2.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SubscribeViewsWsMsg2ToJson(
        SubscribeViewsWsMsg2 instance) =>
    <String, dynamic>{
      'subs': instance.subs,
    };

SubscribeViewsAckWsMsg2 _$SubscribeViewsAckWsMsg2FromJson(
        Map<String, dynamic> json) =>
    SubscribeViewsAckWsMsg2();

Map<String, dynamic> _$SubscribeViewsAckWsMsg2ToJson(
        SubscribeViewsAckWsMsg2 instance) =>
    <String, dynamic>{};

SubscribeActorWsMsg2 _$SubscribeActorWsMsg2FromJson(
        Map<String, dynamic> json) =>
    SubscribeActorWsMsg2(
      json['actorId'] as String,
    );

Map<String, dynamic> _$SubscribeActorWsMsg2ToJson(
        SubscribeActorWsMsg2 instance) =>
    <String, dynamic>{
      'actorId': instance.actorId,
    };

SubscribeActorResWsMsg2 _$SubscribeActorResWsMsg2FromJson(
        Map<String, dynamic> json) =>
    SubscribeActorResWsMsg2();

Map<String, dynamic> _$SubscribeActorResWsMsg2ToJson(
        SubscribeActorResWsMsg2 instance) =>
    <String, dynamic>{};

UnsubscribeActorWsMsg2 _$UnsubscribeActorWsMsg2FromJson(
        Map<String, dynamic> json) =>
    UnsubscribeActorWsMsg2(
      json['actorId'] as String,
    );

Map<String, dynamic> _$UnsubscribeActorWsMsg2ToJson(
        UnsubscribeActorWsMsg2 instance) =>
    <String, dynamic>{
      'actorId': instance.actorId,
    };

UnsubscribeActorResWsMsg2 _$UnsubscribeActorResWsMsg2FromJson(
        Map<String, dynamic> json) =>
    UnsubscribeActorResWsMsg2();

Map<String, dynamic> _$UnsubscribeActorResWsMsg2ToJson(
        UnsubscribeActorResWsMsg2 instance) =>
    <String, dynamic>{};

UnsubscribeViewsWsMsg2 _$UnsubscribeViewsWsMsg2FromJson(
        Map<String, dynamic> json) =>
    UnsubscribeViewsWsMsg2(
      (json['subs'] as List<dynamic>)
          .map((e) => ActorViewSub2.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UnsubscribeViewsWsMsg2ToJson(
        UnsubscribeViewsWsMsg2 instance) =>
    <String, dynamic>{
      'subs': instance.subs,
    };

UnsubscribeViewsResWsMsg2 _$UnsubscribeViewsResWsMsg2FromJson(
        Map<String, dynamic> json) =>
    UnsubscribeViewsResWsMsg2();

Map<String, dynamic> _$UnsubscribeViewsResWsMsg2ToJson(
        UnsubscribeViewsResWsMsg2 instance) =>
    <String, dynamic>{};

ActorEventWsMsg2 _$ActorEventWsMsg2FromJson(Map<String, dynamic> json) =>
    ActorEventWsMsg2(
      EventEnvelop2.fromJson(json['env'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ActorEventWsMsg2ToJson(ActorEventWsMsg2 instance) =>
    <String, dynamic>{
      'env': instance.env,
    };

ViewChangeWsMsg2 _$ViewChangeWsMsg2FromJson(Map<String, dynamic> json) =>
    ViewChangeWsMsg2(
      ChangeEnvelop2.fromJson(json['env'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ViewChangeWsMsg2ToJson(ViewChangeWsMsg2 instance) =>
    <String, dynamic>{
      'env': instance.env,
    };

SendCommandAckWsMsg2 _$SendCommandAckWsMsg2FromJson(
        Map<String, dynamic> json) =>
    SendCommandAckWsMsg2();

Map<String, dynamic> _$SendCommandAckWsMsg2ToJson(
        SendCommandAckWsMsg2 instance) =>
    <String, dynamic>{};

CallCommandResWsMsg2 _$CallCommandResWsMsg2FromJson(
        Map<String, dynamic> json) =>
    CallCommandResWsMsg2(
      json['isOk'] as bool,
      json['reply'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$CallCommandResWsMsg2ToJson(
        CallCommandResWsMsg2 instance) =>
    <String, dynamic>{
      'isOk': instance.isOk,
      'reply': instance.reply,
    };

DispatchEventResWsMsg2 _$DispatchEventResWsMsg2FromJson(
        Map<String, dynamic> json) =>
    DispatchEventResWsMsg2(
      FlowResult2.fromJson(json['flowResult'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DispatchEventResWsMsg2ToJson(
        DispatchEventResWsMsg2 instance) =>
    <String, dynamic>{
      'flowResult': instance.result,
    };

ErrorWsMsg2 _$ErrorWsMsg2FromJson(Map<String, dynamic> json) => ErrorWsMsg2(
      json['type'] as String,
      json['error'] as String,
    );

Map<String, dynamic> _$ErrorWsMsg2ToJson(ErrorWsMsg2 instance) =>
    <String, dynamic>{
      'type': instance.type,
      'error': instance.error,
    };
