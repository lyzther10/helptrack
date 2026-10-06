import 'package:cloud_firestore/cloud_firestore.dart';

import 'message.dart';

class Ticket {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String category;
  final String description;
  final String status;
  final String priority;
  final DateTime createdAt;
  final List<Message> messages;

  Ticket({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.category,
    required this.description,
    required this.status,
    required this.priority,
    required this.createdAt,
    List<Message>? messages,
  }) : messages = messages ?? [];

  Ticket copyWith({String? status, String? priority, List<Message>? messages}) {
    return Ticket(
      id: id,
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      category: category,
      description: description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt,
      messages: messages ?? this.messages,
    );
  }

  // ⭐ Used when saving ticket TO Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'category': category,
      'description': description,
      'status': status,
      'priority': priority,
      'createdAt': Timestamp.fromDate(createdAt),
      'messages': messages.map((m) => m.toMap()).toList(),
    };
  }

  // ⭐ Used when reading ticket FROM Firestore
  factory Ticket.fromFirestore(String docId, Map<String, dynamic> data) {
    return Ticket(
      id: data['id'] ?? docId,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Unknown',
      userEmail: data['userEmail'] ?? '',
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      status: data['status'] ?? 'Pending',
      priority: data['priority'] ?? 'Medium',
      createdAt: (data['createdAt'] is Timestamp)
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      messages:
          (data['messages'] as List<dynamic>?)
              ?.map((m) => Message.fromMap(m as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
