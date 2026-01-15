class Review {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final double rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'].toString(),
      authorId: json['author_id'].toString(),
      authorName: json['full_name'] ?? 'Unknown',
      authorAvatar: json['avatar_url'],
      rating: (json['rating'] is int) 
          ? (json['rating'] as int).toDouble() 
          : (json['rating'] as double),
      comment: json['comment'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
