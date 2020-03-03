// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tweet_reply_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TweetReplyMessage _$TweetReplyMessageFromJson(Map<String, dynamic> json) {
  return TweetReplyMessage()
    ..sentTime = json['sentTime'] == null
        ? null
        : DateTime.parse(json['sentTime'] as String)
    ..receiver = json['receiver'] == null
        ? null
        : Account.fromJson(json['receiver'] as Map<String, dynamic>)
    ..readStatus = _$enumDecodeNullable(_$ReadStatusEnumMap, json['readStatus'])
    ..messageType =
        _$enumDecodeNullable(_$MessageTypeEnumMap, json['messageType'])
    ..id = json['id'] as int
    ..gmtCreated = json['gmtCreated'] == null
        ? null
        : DateTime.parse(json['gmtCreated'] as String)
    ..gmtModified = json['gmtModified'] == null
        ? null
        : DateTime.parse(json['gmtModified'] as String)
    ..tweetId = json['tweetId'] as int
    ..mainReplyId = json['mainReplyId'] as int
    ..tweetBody = json['tweetBody'] as String
    ..coverUrl = json['coverUrl'] as String
    ..replyContent = json['replyContent'] as String
    ..replier = json['replier'] == null
        ? null
        : Account.fromJson(json['replier'] as Map<String, dynamic>)
    ..anonymous = json['anonymous'] as bool;
}

Map<String, dynamic> _$TweetReplyMessageToJson(TweetReplyMessage instance) =>
    <String, dynamic>{
      'sentTime': instance.sentTime?.toIso8601String(),
      'receiver': instance.receiver,
      'readStatus': _$ReadStatusEnumMap[instance.readStatus],
      'messageType': _$MessageTypeEnumMap[instance.messageType],
      'id': instance.id,
      'gmtCreated': instance.gmtCreated?.toIso8601String(),
      'gmtModified': instance.gmtModified?.toIso8601String(),
      'tweetId': instance.tweetId,
      'mainReplyId': instance.mainReplyId,
      'tweetBody': instance.tweetBody,
      'coverUrl': instance.coverUrl,
      'replyContent': instance.replyContent,
      'replier': instance.replier,
      'anonymous': instance.anonymous
    };

T _$enumDecode<T>(Map<T, dynamic> enumValues, dynamic source) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }
  return enumValues.entries
      .singleWhere((e) => e.value == source,
          orElse: () => throw ArgumentError(
              '`$source` is not one of the supported values: '
              '${enumValues.values.join(', ')}'))
      .key;
}

T _$enumDecodeNullable<T>(Map<T, dynamic> enumValues, dynamic source) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source);
}

const _$ReadStatusEnumMap = <ReadStatus, dynamic>{
  ReadStatus.READ: 'READ',
  ReadStatus.UNREAD: 'UNREAD',
  ReadStatus.IGNORED: 'IGNORED'
};

const _$MessageTypeEnumMap = <MessageType, dynamic>{
  MessageType.TWEET_PRAISE: 'TWEET_PRAISE',
  MessageType.TWEET_REPLY: 'TWEET_REPLY',
  MessageType.TOPIC_REPLY: 'TOPIC_REPLY',
  MessageType.POPULAR: 'POPULAR',
  MessageType.PLAIN_SYSTEM: 'PLAIN_SYSTEM',
  MessageType.REPORT: 'REPORT'
};
