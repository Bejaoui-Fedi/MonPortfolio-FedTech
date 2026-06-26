class Message {
  final String id;
  final String name;
  final String email;
  final String content;
  final DateTime createdAt;
  bool isRead;

  Message({
    required this.id,
    required this.name,
    required this.email,
    required this.content,
    required this.createdAt,
    this.isRead = false,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'].toString(),
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      content: map['content'] ?? '',
      createdAt: DateTime.parse(map['created_at']),
      isRead: map['is_read'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'content': content,
      'is_read': isRead,
    };
  }
}
