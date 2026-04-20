class Lesson {
  final String id;
  final String title;
  final String description;
  final String contentType; // 'video', 'pdf', or 'image'
  final String contentUrl;
  final String thumbnailUrl;
  final DateTime createdAt;
  final String createdBy;
  final String course;
  final int views;

  Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.contentType,
    required this.contentUrl,
    required this.thumbnailUrl,
    required this.createdAt,
    required this.createdBy,
    required this.course,
    this.views = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'contentType': contentType,
      'contentUrl': contentUrl,
      'thumbnailUrl': thumbnailUrl,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'course': course,
      'views': views,
    };
  }

  factory Lesson.fromMap(Map<String, dynamic> map) {
    return Lesson(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      contentType: map['contentType'] ?? 'video',
      contentUrl: map['contentUrl'] ?? '',
      thumbnailUrl: map['thumbnailUrl'] ?? '',
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      createdBy: map['createdBy'] ?? '',
      course: map['course'] ?? '',
      views: map['views'] ?? 0,
    );
  }
}