class Post {
  final String id;
  final String content;
  final String? imageUrl;
  final String type;
  final int likesCount;
  final int commentsCount;
  final int shareCount;
  final DateTime createdAt;
  final String authorName;
  final String? authorAvatar;
  final String? authorId;

  Post({
    required this.id,
    required this.content,
    this.imageUrl,
    required this.type,
    required this.likesCount,
    required this.commentsCount,
    required this.shareCount,
    required this.createdAt,
    required this.authorName,
    this.authorAvatar,
    this.authorId,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'].toString(),
      content: json['content'] ?? '',
      imageUrl: json['image_url'],
      type: json['type'] ?? 'Update',
      likesCount: int.tryParse(json['likes_count'].toString()) ?? 0,
      commentsCount: int.tryParse(json['comments_count'].toString()) ?? 0,
      shareCount: int.tryParse(json['share_count'].toString()) ?? 0,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      authorName: json['full_name'] ?? 'Unknown',
      authorAvatar: json['avatar_url'],
      authorId: json['author_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'image_url': imageUrl,
      'type': type,
    };
  }
}
