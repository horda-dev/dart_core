import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:logging/logging.dart';

import 'error.dart';
import 'message.dart';
import 'query_def.dart';
import 'query_res.dart';
import 'worker.dart';

part 'ws.g.dart';

class WsMessageBox2 {
  final int id;

  final WsMessage2 msg;

  WsMessageBox2({
    required this.id,
    required this.msg,
  });

  factory WsMessageBox2.decodeJson(String str, Logger logger) {
    try {
      var json = jsonDecode(str);

      var id = json['id'];
      if (id is! int) {
        throw FluirError('no "id" field found');
      }

      var type = json['type'];
      if (type is! String) {
        throw FluirError('no "type" field found');
      }

      var fac = switch (type) {
        'welcome' => WelcomeWsMsg2.fromJson,
        'query' => QueryWsMsg2.fromJson,
        'query_result' => QueryResultWsMsg2.fromJson,
        'send' => SendCommandWsMsg2.fromJson,
        'sendack' => SendCommandAckWsMsg2.fromJson,
        'call' => CallCommandWsMsg2.fromJson,
        'callres' => CallCommandResWsMsg2.fromJson,
        'dispatch' => DispatchEventWsMsg2.fromJson,
        'dispatchres' => DispatchEventResWsMsg2.fromJson,
        'subv' => SubscribeViewsWsMsg2.fromJson,
        'subvack' => SubscribeViewsAckWsMsg2.fromJson,
        'suba' => SubscribeActorWsMsg2.fromJson,
        'subares' => SubscribeActorResWsMsg2.fromJson,
        'unsuba' => UnsubscribeActorWsMsg2.fromJson,
        'unsubares' => UnsubscribeActorResWsMsg2.fromJson,
        'unsubv' => UnsubscribeViewsWsMsg2.fromJson,
        'unsubvres' => UnsubscribeViewsResWsMsg2.fromJson,
        'evt' => ActorEventWsMsg2.fromJson,
        'chg' => ViewChangeWsMsg2.fromJson,
        'error' => ErrorWsMsg2.fromJson,
        _ => throw FluirError('unknown type $type'),
      };

      return WsMessageBox2(
        id: id,
        msg: fac(json['msg']),
      );
    } catch (e) {
      logger.severe('decode json error: $e');

      return WsMessageBox2(
        id: -1,
        msg: ErrorWsMsg2(str, e.toString()),
      );
    }
  }

  String encodeJson(Logger logger) {
    try {
      return jsonEncode({
        'id': id,
        'type': msg.messageType,
        'msg': msg.toJson(),
      });
    } catch (e) {
      final msg = '$id jsonEncode() error: $e';
      logger.severe(msg);

      return jsonEncode({
        'id': id,
        'type': 'error',
        'msg': msg,
      });
    }
  }

  @override
  String toString() {
    return 'WsMessageBox2(id: $id, type: ${msg.messageType})';
  }
}

sealed class WsMessage2 {
  String get messageType;

  Map<String, dynamic> toJson();
}

@JsonSerializable()
class WelcomeWsMsg2 implements WsMessage2 {
  WelcomeWsMsg2(this.userId, this.serverVersion);

  final String? userId;
  final String serverVersion;

  @override
  String get messageType => 'welcome';

  factory WelcomeWsMsg2.fromJson(Map<String, dynamic> json) =>
      _$WelcomeWsMsg2FromJson(json);

  @override
  Map<String, dynamic> toJson() => _$WelcomeWsMsg2ToJson(this);

  @override
  String toString() => toJson().toString();
}

@JsonSerializable()
class QueryWsMsg2 implements WsMessage2 {
  QueryWsMsg2({
    required this.actorId,
    required this.def,
  });

  @override
  String get messageType => 'query';

  final String actorId;

  @JsonKey(fromJson: _defFromJson, toJson: _defToJson)
  final QueryDef def;

  factory QueryWsMsg2.fromJson(Map<String, dynamic> json) =>
      _$QueryWsMsg2FromJson(json);

  @override
  Map<String, dynamic> toJson() => _$QueryWsMsg2ToJson(this);

  static QueryDef _defFromJson(Map<String, dynamic> json) {
    return QueryDef.fromJson(json);
  }

  static Map<String, dynamic> _defToJson(QueryDef def) {
    return def.toJson();
  }

  @override
  String toString() => 'QueryWsMsg2(actor: $actorId)';
}

@JsonSerializable()
class QueryResultWsMsg2 implements WsMessage2 {
  QueryResultWsMsg2({
    required this.result,
  });

  @override
  String get messageType => 'query_result';

  @JsonKey(fromJson: _resFromJson, toJson: _resToJson)
  final QueryResult2 result;

  factory QueryResultWsMsg2.fromJson(Map<String, dynamic> json) =>
      _$QueryResultWsMsg2FromJson(json);

  @override
  Map<String, dynamic> toJson() => _$QueryResultWsMsg2ToJson(this);

  static QueryResult2 _resFromJson(Map<String, dynamic> json) {
    return QueryResult2.fromJson(json);
  }

  static Map<String, dynamic> _resToJson(QueryResult2 res) {
    return res.toJson();
  }
}

@JsonSerializable()
class ActorViewSub2 {
  ActorViewSub2(this.id, this.name, this.changeId);

  /// actor id or attribute id
  @JsonKey(name: 'id')
  final String id;

  /// actor's view name or attribute name
  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'ver')
  final String changeId;

  factory ActorViewSub2.fromJson(Map<String, dynamic> json) =>
      _$ActorViewSub2FromJson(json);

  Map<String, dynamic> toJson() => _$ActorViewSub2ToJson(this);

  @override
  String toString() {
    return '(id: $id, name: $name, ver: $changeId)';
  }
}

@JsonSerializable()
class SubscribeViewsWsMsg2 implements WsMessage2 {
  SubscribeViewsWsMsg2(this.subs);

  final List<ActorViewSub2> subs;

  @override
  String get messageType => 'subv';

  factory SubscribeViewsWsMsg2.fromJson(Map<String, dynamic> json) =>
      _$SubscribeViewsWsMsg2FromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SubscribeViewsWsMsg2ToJson(this);

  @override
  String toString() => 'SubscribeViews(count: ${subs.length})';
}

@JsonSerializable()
class SubscribeViewsAckWsMsg2 implements WsMessage2 {
  SubscribeViewsAckWsMsg2();

  @override
  String get messageType => 'subvack';

  factory SubscribeViewsAckWsMsg2.fromJson(Map<String, dynamic> json) =>
      _$SubscribeViewsAckWsMsg2FromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SubscribeViewsAckWsMsg2ToJson(this);

  @override
  String toString() => 'SubscribeViewsAck()';
}

@JsonSerializable()
class SubscribeActorWsMsg2 implements WsMessage2 {
  SubscribeActorWsMsg2(this.actorId);

  final ActorId actorId;

  @override
  String get messageType => 'suba';

  factory SubscribeActorWsMsg2.fromJson(Map<String, dynamic> json) =>
      _$SubscribeActorWsMsg2FromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SubscribeActorWsMsg2ToJson(this);

  @override
  String toString() => 'SubscribeActor($actorId)';
}

@JsonSerializable()
class SubscribeActorResWsMsg2 implements WsMessage2 {
  SubscribeActorResWsMsg2();

  @override
  String get messageType => 'subares';

  factory SubscribeActorResWsMsg2.fromJson(Map<String, dynamic> json) =>
      _$SubscribeActorResWsMsg2FromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SubscribeActorResWsMsg2ToJson(this);

  @override
  String toString() => 'SubscribeActorRes()';
}

@JsonSerializable()
class UnsubscribeActorWsMsg2 implements WsMessage2 {
  UnsubscribeActorWsMsg2(this.actorId);

  final ActorId actorId;

  @override
  String get messageType => 'unsuba';

  factory UnsubscribeActorWsMsg2.fromJson(Map<String, dynamic> json) =>
      _$UnsubscribeActorWsMsg2FromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UnsubscribeActorWsMsg2ToJson(this);

  @override
  String toString() => 'UnsubscribeActor($actorId)';
}

@JsonSerializable()
class UnsubscribeActorResWsMsg2 implements WsMessage2 {
  UnsubscribeActorResWsMsg2();

  @override
  String get messageType => 'unsubares';

  factory UnsubscribeActorResWsMsg2.fromJson(Map<String, dynamic> json) =>
      _$UnsubscribeActorResWsMsg2FromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UnsubscribeActorResWsMsg2ToJson(this);

  @override
  String toString() => 'UnsubscribeActorRes()';
}

@JsonSerializable()
class UnsubscribeViewsWsMsg2 implements WsMessage2 {
  UnsubscribeViewsWsMsg2(this.subs);

  final List<ActorViewSub2> subs;

  @override
  String get messageType => 'unsubv';

  factory UnsubscribeViewsWsMsg2.fromJson(Map<String, dynamic> json) =>
      _$UnsubscribeViewsWsMsg2FromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UnsubscribeViewsWsMsg2ToJson(this);

  @override
  String toString() => 'UnsubscribeViews(count: ${subs.length})';
}

@JsonSerializable()
class UnsubscribeViewsResWsMsg2 implements WsMessage2 {
  UnsubscribeViewsResWsMsg2();

  @override
  String get messageType => 'unsubvres';

  factory UnsubscribeViewsResWsMsg2.fromJson(Map<String, dynamic> json) =>
      _$UnsubscribeViewsResWsMsg2FromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UnsubscribeViewsResWsMsg2ToJson(this);

  @override
  String toString() => 'UnsubscribeViewsRes()';
}

@JsonSerializable()
class ActorEventWsMsg2 implements WsMessage2 {
  ActorEventWsMsg2(this.env);

  final EventEnvelop2 env;

  @override
  String get messageType => 'evt';

  factory ActorEventWsMsg2.fromJson(Map<String, dynamic> json) =>
      _$ActorEventWsMsg2FromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ActorEventWsMsg2ToJson(this);

  @override
  String toString() => 'ActorEvent(${env.toJson()})';
}

@JsonSerializable()
class ViewChangeWsMsg2 implements WsMessage2 {
  ViewChangeWsMsg2(this.env);

  final ChangeEnvelop2 env;

  @override
  String get messageType => 'chg';

  factory ViewChangeWsMsg2.fromJson(Map<String, dynamic> json) =>
      _$ViewChangeWsMsg2FromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ViewChangeWsMsg2ToJson(this);

  @override
  String toString() => 'ViewChange($env)';
}

class SendCommandWsMsg2 implements WsMessage2 {
  SendCommandWsMsg2(this.actorName, this.to, this.cmd);

  final String actorName;

  final ActorId to;

  final RemoteCommand cmd;

  @override
  String get messageType => 'send';

  factory SendCommandWsMsg2.fromJson(Map<String, dynamic> json) {
    var type = json['type'] as String;
    var fac = kMsgFromJsonFac[type];
    if (fac == null) {
      throw FluirError('unregistered command type $type in $json');
    }

    return SendCommandWsMsg2(
      json['actorName'],
      json['to'],
      fac(json['cmd']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'actorName': actorName,
      'to': to,
      'type': cmd.runtimeType.toString(),
      'cmd': cmd.toJson(),
    };
  }

  @override
  String toString() => 'SendCmd(${toJson()})';
}

@JsonSerializable()
class SendCommandAckWsMsg2 implements WsMessage2 {
  SendCommandAckWsMsg2();

  @override
  String get messageType => 'sendack';

  factory SendCommandAckWsMsg2.fromJson(Map<String, dynamic> json) =>
      _$SendCommandAckWsMsg2FromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SendCommandAckWsMsg2ToJson(this);

  @override
  String toString() => 'SendCmdAck()';
}

class CallCommandWsMsg2 implements WsMessage2 {
  CallCommandWsMsg2(this.actorName, this.to, this.cmd);

  final String actorName;

  final ActorId to;

  final RemoteCommand cmd;

  @override
  String get messageType => 'call';

  factory CallCommandWsMsg2.fromJson(Map<String, dynamic> json) {
    var type = json['type'] as String;
    var fac = kMsgFromJsonFac[type];
    if (fac == null) {
      throw FluirError('unregistered command type $type in $json');
    }

    return CallCommandWsMsg2(
      json['actorName'],
      json['to'],
      fac(json['cmd']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'actorName': actorName,
      'to': to,
      'type': cmd.runtimeType.toString(),
      'cmd': cmd.toJson(),
    };
  }

  @override
  String toString() => 'CallCmd(${toJson()})';
}

@JsonSerializable()
class CallCommandResWsMsg2 implements WsMessage2 {
  CallCommandResWsMsg2(this.isOk, this.reply);

  final bool isOk;

  final Map<String, dynamic> reply;

  @override
  String get messageType => 'callres';

  factory CallCommandResWsMsg2.fromJson(Map<String, dynamic> json) =>
      _$CallCommandResWsMsg2FromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CallCommandResWsMsg2ToJson(this);

  @override
  String toString() => 'CallResCmd(${toJson()})';
}

class DispatchEventWsMsg2 implements WsMessage2 {
  DispatchEventWsMsg2(this.event);

  final RemoteEvent event;

  @override
  final messageType = 'dispatch';

  factory DispatchEventWsMsg2.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    final fac = kMsgFromJsonFac[type];
    if (fac == null) {
      throw FluirError('unregistered event type $type in $json');
    }

    return DispatchEventWsMsg2(
      fac(json['event']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': event.runtimeType.toString(),
      'event': event.toJson(),
    };
  }

  @override
  String toString() =>
      'DispatchEvent(${event.runtimeType} | ${event.toJson()})';
}

@JsonSerializable()
class DispatchEventResWsMsg2 implements WsMessage2 {
  DispatchEventResWsMsg2(this.result);

  @JsonKey(name: 'flowResult')
  final FlowResult result;

  @override
  final messageType = 'dispatchres';

  factory DispatchEventResWsMsg2.fromJson(Map<String, dynamic> json) {
    return _$DispatchEventResWsMsg2FromJson(json);
  }

  @override
  Map<String, dynamic> toJson() {
    return _$DispatchEventResWsMsg2ToJson(this);
  }

  @override
  String toString() => 'DispatchEventRes(${result.value} | ${result.isError})';
}

@JsonSerializable()
class ErrorWsMsg2 implements WsMessage2 {
  ErrorWsMsg2(this.type, this.error);

  final String type;

  final String error;

  @override
  String get messageType => 'error';

  factory ErrorWsMsg2.fromJson(Map<String, dynamic> json) =>
      _$ErrorWsMsg2FromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ErrorWsMsg2ToJson(this);

  @override
  String toString() => 'ErrorWsMsg2(type: $type, e: $error)';
}
