// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReplyFlow _$ReplyFlowFromJson(Map json) => ReplyFlow(
  actorName: json['actorName'] as String,
  flowName: json['flowName'] as String,
  flowId: json['flowId'] as String,
  callId: json['callId'] as String,
);

Map<String, dynamic> _$ReplyFlowToJson(ReplyFlow instance) => <String, dynamic>{
  'actorName': instance.actorName,
  'flowName': instance.flowName,
  'flowId': instance.flowId,
  'callId': instance.callId,
};

ReplyClient _$ReplyClientFromJson(Map json) => ReplyClient(
  serverId: json['serverId'] as String,
  sessionId: json['sid'] as String,
  callId: json['callId'] as String,
);

Map<String, dynamic> _$ReplyClientToJson(ReplyClient instance) =>
    <String, dynamic>{
      'serverId': instance.serverId,
      'sid': instance.sessionId,
      'callId': instance.callId,
    };

FlowCallReplyEnvelop _$FlowCallReplyEnvelopFromJson(Map json) =>
    FlowCallReplyEnvelop(
      replyId: json['replyId'] as String,
      flowId: json['flowId'] as String,
      flowName: json['flowName'] as String,
      callId: json['callId'] as String,
      isOk: json['isOk'] as bool,
      reply: Map<String, dynamic>.from(json['reply'] as Map),
    );

FlowCallReplyOk _$FlowCallReplyOkFromJson(Map json) => FlowCallReplyOk(
  eventType: json['eventType'] as String,
  event: Map<String, dynamic>.from(json['event'] as Map),
);

FlowCallReplyErr _$FlowCallReplyErrFromJson(Map json) => FlowCallReplyErr(
  errorType: json['errorType'] as String,
  message: json['message'] as String,
);
