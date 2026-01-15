class ChatMessage {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'].toString(),
      senderId: json['sender_id'].toString(),
      receiverId: json['receiver_id'].toString(),
      content: json['content'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }
}

class Conversation {
  final String id;
  final String content;
  final DateTime createdAt;
  final String otherId;
  final String otherName;
  final String? otherAvatar;

  Conversation({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.otherId,
    required this.otherName,
    this.otherAvatar,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'].toString(),
      content: json['content'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      otherId: json['other_id'].toString(),
      otherName: json['other_name'] ?? 'Unknown',
      otherAvatar: json['other_avatar'],
    );
  }
}
