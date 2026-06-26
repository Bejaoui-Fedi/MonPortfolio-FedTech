import 'package:supabase_flutter/supabase_flutter.dart';

class IoTDesign {
  final String id;
  final String title;
  final String description;
  final String proteusUrl;
  final String codeUrl;
  final String thumbnailUrl;
  final DateTime createdAt;

  IoTDesign({
    required this.id,
    required this.title,
    required this.description,
    required this.proteusUrl,
    required this.codeUrl,
    required this.thumbnailUrl,
    required this.createdAt,
  });

  factory IoTDesign.fromMap(Map<String, dynamic> map) {
    return IoTDesign(
      id: map['id']?.toString() ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      proteusUrl: map['proteus_url'] ?? '',
      codeUrl: map['code_url'] ?? '',
      thumbnailUrl: map['thumbnail_url'] ?? '',
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'proteus_url': proteusUrl,
      'code_url': codeUrl,
      'thumbnail_url': thumbnailUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
