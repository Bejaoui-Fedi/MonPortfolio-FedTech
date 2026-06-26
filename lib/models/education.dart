class Education {
  final String id;
  final String school;
  final String degree;
  final String period;
  final String description;

  Education({
    required this.id,
    required this.school,
    required this.degree,
    required this.period,
    required this.description,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'school': school,
      'degree': degree,
      'period': period,
      'description': description,
    };
  }

  factory Education.fromMap(Map<String, dynamic> map) {
    return Education(
      id: map['id'],
      school: map['school'],
      degree: map['degree'],
      period: map['period'],
      description: map['description'],
    );
  }
}
