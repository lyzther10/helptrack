class Message {
  final String id;
  final String ticketId;
  final String sender; // 'user' or 'admin'
  final String text;
  final DateTime sentAt;

  Message({
    required this.id,
    required this.ticketId,
    required this.sender,
    required this.text,
    required this.sentAt,
  });

  // Used when saving a message INTO a ticket's messages array
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ticketId': ticketId,
      'sender': sender,
      'text': text,
      'sentAt': sentAt.toIso8601String(),
    };
  }

  // Used when reading a message FROM Firestore
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] ?? '',
      ticketId: map['ticketId'] ?? '',
      sender: map['sender'] ?? 'user',
      text: map['text'] ?? '',
      sentAt: DateTime.tryParse(map['sentAt'] ?? '') ?? DateTime.now(),
    );
  }
}
