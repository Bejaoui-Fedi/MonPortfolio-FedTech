class Project {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String? githubUrl;
  final String? liveUrl;
  final String? videoUrl;
  final List<String> technologies;
  final String? category;
  final DateTime? startDate;
  final DateTime? endDate;

  Project({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.githubUrl,
    this.liveUrl,
    this.videoUrl,
    required this.technologies,
    this.category,
    this.startDate,
    this.endDate,
  });

  /// Returns a human-readable duration string calculated from startDate/endDate.
  String? get computedDuration {
    if (startDate == null) return null;
    final end = endDate ?? DateTime.now();
    final diff = end.difference(startDate!);
    final totalDays = diff.inDays;
    if (totalDays < 0) return null;
    final months = (totalDays / 30).floor();
    final weeks = (totalDays / 7).floor();
    if (months >= 2) return '$months mois';
    if (months == 1) return '1 mois';
    if (weeks >= 1) return '$weeks semaine${weeks > 1 ? 's' : ''}';
    return '$totalDays jour${totalDays > 1 ? 's' : ''}';
  }

  Project copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? githubUrl,
    String? liveUrl,
    String? videoUrl,
    List<String>? technologies,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      githubUrl: githubUrl ?? this.githubUrl,
      liveUrl: liveUrl ?? this.liveUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      technologies: technologies ?? this.technologies,
      category: category ?? this.category,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'github_url': githubUrl,
      'live_url': liveUrl,
      'video_url': videoUrl,
      'technologies': technologies,
      'category': category,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      imageUrl: map['image_url'] ?? '',
      githubUrl: map['github_url'],
      liveUrl: map['live_url'],
      videoUrl: map['video_url'],
      technologies: List<String>.from(map['technologies'] ?? []),
      category: map['category'],
      startDate: map['start_date'] != null ? DateTime.tryParse(map['start_date']) : null,
      endDate: map['end_date'] != null ? DateTime.tryParse(map['end_date']) : null,
    );
  }
}
