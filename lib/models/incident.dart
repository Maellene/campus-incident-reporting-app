import 'package:cloud_firestore/cloud_firestore.dart';

class Incident {
  final String id;
  final String title;
  final String description;
  final String category;
  final String location;
  final String status;
  final String? imageUrl;
  final String reporterId;
  final String reporterName;
  final DateTime createdAt;
  final DateTime? inProgressAt;
  final DateTime? resolvedAt;
  final String? updatedBy;

  const Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.status,
    required this.reporterId,
    required this.reporterName,
    required this.createdAt,
    this.imageUrl,
    this.inProgressAt,
    this.resolvedAt,
    this.updatedBy,
  });

  factory Incident.fromMap(Map<String, dynamic> map, String id) {
    return Incident(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      location: map['location'] ?? '',
      status: map['status'] ?? 'submitted',
      imageUrl: map['imageUrl'],
      reporterId: map['reporterId'] ?? '',
      reporterName: map['reporterName'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      inProgressAt: (map['inProgressAt'] as Timestamp?)?.toDate(),
      resolvedAt: (map['resolvedAt'] as Timestamp?)?.toDate(),
      updatedBy: map['updatedBy'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'location': location,
      'status': status,
      'imageUrl': imageUrl,
      'reporterId': reporterId,
      'reporterName': reporterName,
    };
  }
}