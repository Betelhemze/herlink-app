class Product {
  final String id;
  final String sellerId;
  final String title;
  final String description;
  final String price; // Stored as string in backend, but could be parsed to double
  final String? category;
  final String? imageUrl;
  final DateTime createdAt;
  final String? sellerName;
  final double avgRating;
  final int reviewCount;

  Product({
    required this.id,
    required this.sellerId,
    required this.title,
    required this.description,
    required this.price,
    this.category,
    this.imageUrl,
    required this.createdAt,
    this.sellerName,
    this.avgRating = 0.0,
    this.reviewCount = 0,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      sellerId: json['seller_id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: json['price']?.toString() ?? '0',
      category: json['category'],
      imageUrl: json['image_url'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      sellerName: json['seller_name'],
      avgRating: (json['avg_rating'] != null) 
          ? (json['avg_rating'] is int ? (json['avg_rating'] as int).toDouble() : json['avg_rating']) 
          : 0.0,
      reviewCount: json['review_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seller_id': sellerId,
      'title': title,
      'description': description,
      'price': price,
      'category': category,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
      'seller_name': sellerName,
    };
  }
}
