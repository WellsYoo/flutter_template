import 'package:xjj_app_base/core/utils/json.dart';

enum MessageType { approval, system, activity }

class Message {
  const Message({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    required this.time,
    this.read = false,
  });

  final String id;
  final MessageType type;
  final String title;
  final String content;
  final DateTime time;
  final bool read;

  Message copyWith({bool? read}) => Message(
    id: id,
    type: type,
    title: title,
    content: content,
    time: time,
    read: read ?? this.read,
  );

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json.str('id'),
    type: MessageType.values.asNameMap()[json.strOrNull('type')] ?? MessageType.system,
    title: json.str('title'),
    content: json.str('content'),
    time: json.date('time') ?? DateTime(1970),
    read: json.boolean('read'),
  );
}
