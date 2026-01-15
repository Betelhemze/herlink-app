class Collaboration {
  final String id;
  final String title;
  final String description;
  final String type;
  final String status;
  final int viewCount;
  final String? initiatorId;
  final DateTime createdAt;

  Collaboration({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.viewCount,
    this.initiatorId,
    required this.createdAt,
  });

  factory Collaboration.fromJson(Map<String, dynamic> json) {
    return Collaboration(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      status: json['status'] ?? 'open',
      viewCount: int.tryParse(json['view_count'].toString()) ?? 0,
      initiatorId: json['initiator_id']?.toString(),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'type': type,
    };
  }
}
