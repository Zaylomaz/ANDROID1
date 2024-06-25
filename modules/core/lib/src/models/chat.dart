import 'package:core/core.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:json_reader/json_reader.dart';

/*
* Модели для чата
*/

/// Чат в списке чатов
class AppChatChannel {
  const AppChatChannel({
    required this.id,
    required this.name,
    required this.image,
    this.lastMessage,
  });

  factory AppChatChannel.fromJson(JsonReader json) => AppChatChannel(
        id: json['id'].asInt(),
        name: json['name'].asString(),
        image: Environment<AppConfig>.instance()
            .config
            .apiUrl
            .replace(path: json['image'].asString()),
        lastMessage: json.containsKey('last_message')
            ? AppChatPreviewMessage.fromJson(json['last_message'])
            : null,
      );

  final int id;
  final String name;
  final Uri? image;
  final AppChatPreviewMessage? lastMessage;
}

/// Превью сообщения
class AppChatPreviewMessage {
  const AppChatPreviewMessage({
    required this.text,
    required this.authorName,
    required this.date,
  });

  factory AppChatPreviewMessage.fromJson(JsonReader json) =>
      AppChatPreviewMessage(
        text: json['text'].asString(),
        authorName: json['author_name'].asString(),
        date: json['date'].asString(),
      );

  final String text;
  final String authorName;
  final String date;
}

/// Сообщение в чате
class AppChatMessage {
  const AppChatMessage({
    required this.author,
    required this.createdAt,
    required this.id,
    required this.status,
    required this.text,
    required this.type,
    this.uri,
    this.name,
    this.size,
  });

  factory AppChatMessage.fromJson(JsonReader json) => AppChatMessage(
        author: AppChatMessageAuthor.fromJson(json['author']),
        createdAt: json['createdAt'].asDateTime(),
        id: json['id'].asString(),
        status: json['status'].asString(),
        text: json['text'].asString(),
        type: json['type'].asString(defaultValue: 'unsupported'),
        uri: Uri.tryParse(json['uri'].asString()),
        name: json['name'].asString(),
        size: json['size'].asIntOrNull(),
      );

  types.Message get chatMessage => types.Message.fromJson(toJson());

  Map<String, dynamic> toJson() => {
        'author': author.toJson(),
        'createdAt': createdAt.millisecondsSinceEpoch,
        'id': id,
        'status': status,
        'text': text,
        'type': type,
        if (uri != null) 'uri': uri.toString(),
        if (name?.isNotEmpty == true) 'name': name,
        if (size != null) 'size': size,
      };

  final AppChatMessageAuthor author;
  final DateTime createdAt;
  final String id;
  final String status;
  final String text;
  final String type;
  final Uri? uri;
  final String? name;
  final int? size;
}

/// Автор сообщения
class AppChatMessageAuthor {
  const AppChatMessageAuthor({
    required this.firstName,
    required this.id,
    this.imageUrl,
  });

  factory AppChatMessageAuthor.fromJson(JsonReader json) =>
      AppChatMessageAuthor(
        firstName: json['firstName'].asString(),
        id: json['id'].asString(),
        imageUrl: Uri.tryParse(json['imageUrl'].asString()),
      );

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'id': id,
        'imageUrl': imageUrl.toString(),
      };

  final String firstName;
  final String id;
  final Uri? imageUrl;
}
