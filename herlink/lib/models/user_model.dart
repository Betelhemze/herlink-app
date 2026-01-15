class User {
  final String id; // ID might be a string (from Render/Postgres)
  final String email;
  final String? fullName;
  final String? businessName;
  final String? role;
  final String? industry;
  final String? location;
  final String? bio;
  final String? avatarUrl;
  final double? ratingAvg;
  final int? followersCount;
  final String? interests;
  final String? lookFor;

  User({
    required this.id,
    required this.email,
    this.fullName,
    this.businessName,
    this.role,
    this.industry,
    this.location,
    this.bio,
    this.avatarUrl,
    this.ratingAvg,
    this.followersCount,
    this.interests,
    this.lookFor,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      email: json['email']?.toString() ?? '',
      fullName: json['full_name']?.toString(),
      businessName: json['business_name']?.toString(),
      role: json['role']?.toString(),
      industry: json['industry']?.toString(),
      location: json['location']?.toString(),
      bio: json['bio']?.toString(),
      avatarUrl: json['avatar_url']?.toString(),
      ratingAvg: json['rating_avg'] != null ? double.tryParse(json['rating_avg'].toString()) : null,
      followersCount: json['followers_count'] != null ? int.tryParse(json['followers_count'].toString()) : null,
      interests: json['interests']?.toString(),
      lookFor: json['look_for']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'business_name': businessName,
      'role': role,
      'industry': industry,
      'location': location,
      'bio': bio,
      'avatar_url': avatarUrl,
      'rating_avg': ratingAvg,
      'followers_count': followersCount,
      'interests': interests,
      'look_for': lookFor,
    };
  }
}
