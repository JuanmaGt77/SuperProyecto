import 'package:equatable/equatable.dart';

enum MessageType { text, image, system }

extension MessageTypeExt on MessageType {
  String get value {
    switch (this) {
      case MessageType.text: return 'text';
      case MessageType.image: return 'image';
      case MessageType.system: return 'system';
    }
  }

  static MessageType fromString(String value) {
    switch (value) {
      case 'image': return MessageType.image;
      case 'system': return MessageType.system;
      default: return MessageType.text;
    }
  }
}

class MessageModel extends Equatable {
  final String id;
  final String chatId;
  final String senderId;
  final String? content;
  final String? imageUrl;
  final String? imagePublicId;
  final MessageType messageType;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  const MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    this.content,
    this.imageUrl,
    this.imagePublicId,
    this.messageType = MessageType.text,
    this.isRead = false,
    this.readAt,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      chatId: json['chat_id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String?,
      imageUrl: json['image_url'] as String?,
      imagePublicId: json['image_public_id'] as String?,
      messageType: MessageTypeExt.fromString(
        json['message_type'] as String? ?? 'text',
      ),
      isRead: json['is_read'] as bool? ?? false,
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  bool isMine(String currentUserId) => senderId == currentUserId;

  @override
  List<Object?> get props => [id, isRead];
}

class ChatModel extends Equatable {
  final String id;
  final String? requestId;
  final String clientId;
  final String providerId;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int clientUnread;
  final int providerUnread;
  final bool isActive;
  final DateTime createdAt;

  // Joined
  final String? otherUserName;
  final String? otherUserAvatar;

  const ChatModel({
    required this.id,
    this.requestId,
    required this.clientId,
    required this.providerId,
    this.lastMessage,
    this.lastMessageAt,
    this.clientUnread = 0,
    this.providerUnread = 0,
    this.isActive = true,
    required this.createdAt,
    this.otherUserName,
    this.otherUserAvatar,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] as String,
      requestId: json['request_id'] as String?,
      clientId: json['client_id'] as String,
      providerId: json['provider_id'] as String,
      lastMessage: json['last_message'] as String?,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'] as String)
          : null,
      clientUnread: json['client_unread'] as int? ?? 0,
      providerUnread: json['provider_unread'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      otherUserName: json['other_user_name'] as String?,
      otherUserAvatar: json['other_user_avatar'] as String?,
    );
  }

  int unreadFor(String userId) =>
      userId == clientId ? clientUnread : providerUnread;

  @override
  List<Object?> get props => [id, lastMessageAt, clientUnread, providerUnread];
}
