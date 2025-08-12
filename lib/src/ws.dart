import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:logging/logging.dart';

import 'error.dart';
import 'message.dart';
import 'query.dart';
import 'worker.dart';

part 'ws.g.dart';

class WsMessageBox {
  final int id;

  final WsMessage msg;

  WsMessageBox({
    required this.id,
    required this.msg,
  });

  factory WsMessageBox.decodeJson(String str, Logger logger) {
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
        'welcome' => WelcomeWsMsg.fromJson,
        'query' => QueryWsMsg.fromJson,
        'query_result' => QueryResultWsMsg.fromJson,
        'send' => SendCommandWsMsg.fromJson,
        'sendack' => SendCommandAckWsMsg.fromJson,
        'call' => CallCommandWsMsg.fromJson,
        'callres' => CallCommandResWsMsg.fromJson,
        'dispatch' => DispatchEventWsMsg.fromJson,
        'dispatchres' => DispatchEventResWsMsg.fromJson,
        'subv' => SubscribeViewsWsMsg.fromJson,
        'subvack' => SubscribeViewsAckWsMsg.fromJson,
        'unsubv' => UnsubscribeViewsWsMsg.fromJson,
        'unsubvres' => UnsubscribeViewsResWsMsg.fromJson,
        'evt' => ActorEventWsMsg.fromJson,
        'chg' => ViewChangeWsMsg.fromJson,
        'error' => ErrorWsMsg.fromJson,
        _ => throw FluirError('unknown type $type'),
      };

      return WsMessageBox(
        id: id,
        msg: fac(json['msg']),
      );
    } catch (e) {
      logger.severe('decode json error: $e');

      return WsMessageBox(
        id: -1,
        msg: ErrorWsMsg(str, e.toString()),
      );
    }
  }

  String encodeJson(Logger logger) {
    try {
      return jsonEncode({
        'id': id,
        'type': msg.type,
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
    return 'WsMessageBox(id: $id, type: ${msg.type})';
  }
}

sealed class WsMessage {
  String get type;

  Map<String, dynamic> toJson();
}

@JsonSerializable()
class WelcomeWsMsg implements WsMessage {
  WelcomeWsMsg(this.userId, this.serverVersion);

  final String? userId;
  final String serverVersion;

  @override
  @JsonKey(includeToJson: true)
  final String type = 'welcome';

  factory WelcomeWsMsg.fromJson(Map<String, dynamic> json) =>
      _$WelcomeWsMsgFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$WelcomeWsMsgToJson(this);

  @override
  String toString() => toJson().toString();
}

@JsonSerializable()
class QueryWsMsg implements WsMessage {
  QueryWsMsg({
    required this.actorId,
    required this.name,
    required this.def,
  });

  @override
  final String type = 'query';

  final String actorId;

  final String name;

  @JsonKey(fromJson: _defFromJson, toJson: _defToJson)
  final QueryDef def;

  factory QueryWsMsg.fromJson(Map<String, dynamic> json) =>
      _$QueryWsMsgFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$QueryWsMsgToJson(this);

  static QueryDef _defFromJson(Map<String, dynamic> json) {
    return QueryDef.fromJson(json);
  }

  static Map<String, dynamic> _defToJson(QueryDef def) {
    return def.toJson();
  }

  @override
  String toString() => 'QueryWsMsg(name: $name, actor: $actorId)';
}

@JsonSerializable()
class QueryResultWsMsg implements WsMessage {
  QueryResultWsMsg({
    required this.result,
  });

  @override
  final String type = 'query_result';

  @JsonKey(fromJson: _resFromJson, toJson: _resToJson)
  final QueryResult result;

  factory QueryResultWsMsg.fromJson(Map<String, dynamic> json) =>
      _$QueryResultWsMsgFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$QueryResultWsMsgToJson(this);

  static QueryResult _resFromJson(Map<String, dynamic> json) {
    return QueryResult.fromJson(json);
  }

  static Map<String, dynamic> _resToJson(QueryResult res) {
    return res.toJson();
  }
}

@JsonSerializable()
class ActorViewSub {
  ActorViewSub(this.id, this.name, this.version);

  /// actor id or attribute id
  @JsonKey(name: 'id')
  final String id;

  /// actor's view name or attribute name
  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'ver')
  final int version;

  factory ActorViewSub.fromJson(Map<String, dynamic> json) =>
      _$ActorViewSubFromJson(json);

  Map<String, dynamic> toJson() => _$ActorViewSubToJson(this);

  @override
  String toString() {
    return '(id: $id, name: $name, ver: $version)';
  }
}

@JsonSerializable()
class SubscribeViewsWsMsg implements WsMessage {
  SubscribeViewsWsMsg(this.subs);

  final List<ActorViewSub> subs;

  @override
  final String type = 'subv';

  factory SubscribeViewsWsMsg.fromJson(Map<String, dynamic> json) =>
      _$SubscribeViewsWsMsgFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SubscribeViewsWsMsgToJson(this);

  @override
  String toString() => 'SubscribeViews(count: ${subs.length})';
}

@JsonSerializable()
class SubscribeViewsAckWsMsg implements WsMessage {
  SubscribeViewsAckWsMsg();

  @override
  final String type = 'subvack';

  factory SubscribeViewsAckWsMsg.fromJson(Map<String, dynamic> json) =>
      _$SubscribeViewsAckWsMsgFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SubscribeViewsAckWsMsgToJson(this);

  @override
  String toString() => 'SubscribeViewsAck()';
}

@JsonSerializable()
class UnsubscribeViewsWsMsg implements WsMessage {
  UnsubscribeViewsWsMsg(this.subs);

  final List<ActorViewSub> subs;

  @override
  final String type = 'unsubv';

  factory UnsubscribeViewsWsMsg.fromJson(Map<String, dynamic> json) =>
      _$UnsubscribeViewsWsMsgFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UnsubscribeViewsWsMsgToJson(this);

  @override
  String toString() => 'UnsubscribeViews(count: ${subs.length})';
}

@JsonSerializable()
class UnsubscribeViewsResWsMsg implements WsMessage {
  UnsubscribeViewsResWsMsg();

  @override
  final String type = 'unsubvres';

  factory UnsubscribeViewsResWsMsg.fromJson(Map<String, dynamic> json) =>
      _$UnsubscribeViewsResWsMsgFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UnsubscribeViewsResWsMsgToJson(this);

  @override
  String toString() => 'UnsubscribeViewsRes()';
}

@JsonSerializable()
class ActorEventWsMsg implements WsMessage {
  ActorEventWsMsg(this.env);

  final EventEnvelop env;

  @override
  final String type = 'evt';

  factory ActorEventWsMsg.fromJson(Map<String, dynamic> json) =>
      _$ActorEventWsMsgFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ActorEventWsMsgToJson(this);

  @override
  String toString() => 'ActorEvent($env)';
}

@JsonSerializable()
class ViewChangeWsMsg implements WsMessage {
  ViewChangeWsMsg(this.env);

  final ChangeEnvelop env;

  @override
  final String type = 'chg';

  factory ViewChangeWsMsg.fromJson(Map<String, dynamic> json) =>
      _$ViewChangeWsMsgFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ViewChangeWsMsgToJson(this);

  @override
  String toString() => 'ViewChange($env)';
}

class SendCommandWsMsg implements WsMessage {
  SendCommandWsMsg(this.to, this.cmd);

  final ActorId to;

  final RemoteCommand cmd;

  @override
  final String type = 'send';

  factory SendCommandWsMsg.fromJson(Map<String, dynamic> json) {
    var type = json['type'] as String;
    var fac = kMsgFromJsonFac[type];
    if (fac == null) {
      throw FluirError('unregistered command type $type in $json');
    }

    return SendCommandWsMsg(
      json['to'],
      fac(json['cmd']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'to': to,
      'type': cmd.runtimeType.toString(),
      'cmd': cmd.toJson(),
    };
  }

  @override
  String toString() => 'SendCmd($cmd)';
}

@JsonSerializable()
class SendCommandAckWsMsg implements WsMessage {
  SendCommandAckWsMsg();

  @override
  final String type = 'sendack';

  factory SendCommandAckWsMsg.fromJson(Map<String, dynamic> json) =>
      _$SendCommandAckWsMsgFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SendCommandAckWsMsgToJson(this);

  @override
  String toString() => 'SendCmdAck()';
}

class CallCommandWsMsg implements WsMessage {
  CallCommandWsMsg(this.to, this.cmd, this.timeout);

  final ActorId to;

  final RemoteCommand cmd;

  final Duration timeout;

  @override
  final String type = 'call';

  factory CallCommandWsMsg.fromJson(Map<String, dynamic> json) {
    var type = json['type'] as String;
    var fac = kMsgFromJsonFac[type];
    if (fac == null) {
      throw FluirError('unregistered command type $type in $json');
    }

    return CallCommandWsMsg(
      json['to'],
      fac(json['cmd']),
      Duration(milliseconds: json['timeout']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'to': to,
      'type': cmd.runtimeType.toString(),
      'cmd': cmd.toJson(),
      'timeout': timeout.inMilliseconds,
    };
  }

  @override
  String toString() => 'CallCmd($cmd)';
}

@JsonSerializable()
class CallCommandResWsMsg implements WsMessage {
  CallCommandResWsMsg(this.env);

  final EventEnvelop env;

  @override
  final String type = 'callres';

  factory CallCommandResWsMsg.fromJson(Map<String, dynamic> json) =>
      _$CallCommandResWsMsgFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CallCommandResWsMsgToJson(this);

  @override
  String toString() => 'CallResCmd($env)';
}

class DispatchEventWsMsg implements WsMessage {
  DispatchEventWsMsg(this.event, this.timeout);

  final RemoteEvent event;
  final Duration timeout;

  @override
  final type = 'dispatch';

  factory DispatchEventWsMsg.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    final fac = kMsgFromJsonFac[type];
    if (fac == null) {
      throw FluirError('unregistered event type $type in $json');
    }

    return DispatchEventWsMsg(
      fac(json['event']),
      Duration(milliseconds: json['timeout']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': event.runtimeType.toString(),
      'event': event.toJson(),
      'timeout': timeout.inMilliseconds,
    };
  }
}

@JsonSerializable()
class DispatchEventResWsMsg implements WsMessage {
  DispatchEventResWsMsg(this.env);

  final FlowResultEnvelop env;

  @override
  final type = 'dispatchres';

  factory DispatchEventResWsMsg.fromJson(Map<String, dynamic> json) {
    return _$DispatchEventResWsMsgFromJson(json);
  }

  @override
  Map<String, dynamic> toJson() {
    return _$DispatchEventResWsMsgToJson(this);
  }
}

@JsonSerializable()
class ErrorWsMsg implements WsMessage {
  ErrorWsMsg(this.text, this.error);

  final String text;

  // TODO: change to string, not all errors can be converted to json
  final dynamic error;

  @override
  final String type = 'error';

  factory ErrorWsMsg.fromJson(Map<String, dynamic> json) =>
      _$ErrorWsMsgFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ErrorWsMsgToJson(this);

  @override
  String toString() => 'ErrorWsMsg(text: $text, e: $error)';
}
