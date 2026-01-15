class Event {
  final String id;
  final String organizerId;
  final String title;
  final String description;
  final String category;
  final DateTime startTime;
  final DateTime endTime;
  final String locationMode;
  final String locationDetails;
  final String? bannerUrl;
  final String? organizerName;

  Event({
    required this.id,
    required this.organizerId,
    required this.title,
    required this.description,
    required this.category,
    required this.startTime,
    required this.endTime,
    required this.locationMode,
    required this.locationDetails,
    this.bannerUrl,
    this.organizerName,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'].toString(),
      organizerId: json['organizer_id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      startTime: json['start_time'] != null 
          ? DateTime.parse(json['start_time']) 
          : DateTime.now(),
      endTime: json['end_time'] != null 
          ? DateTime.parse(json['end_time']) 
          : DateTime.now(),
      locationMode: json['location_mode'] ?? 'Online',
      locationDetails: json['location_details'] ?? '',
      bannerUrl: json['banner_url'],
      organizerName: json['organizer_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organizer_id': organizerId,
      'title': title,
      'description': description,
      'category': category,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'location_mode': locationMode,
      'location_details': locationDetails,
      'banner_url': bannerUrl,
    };
  }
}
