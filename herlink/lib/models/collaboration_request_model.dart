class CollaborationRequest {
  final String id;
  final String? collaborationId;
  final String senderId;
  final String receiverId;
  final String message;
  final String status;
  final DateTime createdAt;
  final String senderName;
  final String? senderAvatar;
  final String? collaborationTitle;

  CollaborationRequest({
    required this.id,
    this.collaborationId,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.status,
    required this.createdAt,
    required this.senderName,
    this.senderAvatar,
    this.collaborationTitle,
  });

  factory CollaborationRequest.fromJson(Map<String, dynamic> json) {
    return CollaborationRequest(
      id: json['id'].toString(),
      collaborationId: json['collaboration_id']?.toString(),
      senderId: json['sender_id'].toString(),
      receiverId: json['receiver_id'].toString(),
      message: json['message'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      senderName: json['sender_name'] ?? 'Unknown',
      senderAvatar: json['sender_avatar'],
      collaborationTitle: json['collaboration_title'],
    );
  }
}
