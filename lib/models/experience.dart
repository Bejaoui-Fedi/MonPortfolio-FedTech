class Experience {
  final String id;
  final String company;
  final String role;
  final String description;
  final DateTime startDate;
  final DateTime? endDate;
  final String location;

  Experience({
    required this.id,
    required this.company,
    required this.role,
    required this.description,
    required this.startDate,
    this.endDate,
    required this.location,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'company': company,
      'role': role,
      'description': description,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'location': location,
    };
  }

  factory Experience.fromMap(Map<String, dynamic> map) {
    return Experience(
      id: map['id'],
      company: map['company'],
      role: map['role'],
      description: map['description'],
      startDate: DateTime.parse(map['start_date']),
      endDate: map['end_date'] != null ? DateTime.parse(map['end_date']) : null,
      location: map['location'],
    );
  }

  bool get isCurrent => endDate == null;
}
