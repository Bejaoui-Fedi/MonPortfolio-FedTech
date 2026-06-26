class WorkService {
  final String id;
  final String title;
  final String description;
  final String iconName;

  WorkService({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon_name': iconName,
    };
  }

  factory WorkService.fromMap(Map<String, dynamic> map) {
    return WorkService(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      iconName: map['icon_name'],
    );
  }
}
