class StudyDocument {
  final String id;
  final String title;
  final String? description;
  final String fileUrl;
  final String type; // e.g., 'pdf', 'ppt', 'doc'
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? createdAt;

  StudyDocument({
    required this.id,
    required this.title,
    this.description,
    required this.fileUrl,
    required this.type,
    this.startDate,
    this.endDate,
    this.createdAt,
  });

  factory StudyDocument.fromMap(Map<String, dynamic> map) {
    return StudyDocument(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      fileUrl: map['file_url'],
      type: map['type'] ?? 'document',
      startDate: map['start_date'] != null ? DateTime.parse(map['start_date']) : null,
      endDate: map['end_date'] != null ? DateTime.parse(map['end_date']) : null,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'file_url': fileUrl,
      'type': type,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
    };
  }
}
