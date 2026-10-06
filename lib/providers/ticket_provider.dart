import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/message.dart';
import '../models/ticket.dart';

class TicketProvider extends ChangeNotifier {
  final CollectionReference _ticketsCollection = FirebaseFirestore.instance
      .collection('tickets');

  List<Ticket> _tickets = [];
  String _filterStatus = 'All';
  bool _listening = false;

  List<Ticket> get tickets {
    if (_filterStatus == 'All') return _tickets;
    return _tickets.where((t) => t.status == _filterStatus).toList();
  }

  List<Ticket> get allTickets => _tickets;

  String get filterStatus => _filterStatus;

  // ───────────── Real-time listener ─────────────
  // Instead of loading once, we LISTEN to Firestore.
  // Whenever any device adds/updates a ticket, this fires.
  void loadTickets() {
    if (_listening) return;
    _listening = true;

    _ticketsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
          _tickets = snapshot.docs
              .map(
                (doc) => Ticket.fromFirestore(
                  doc.id,
                  doc.data() as Map<String, dynamic>,
                ),
              )
              .toList();
          notifyListeners();
        });
  }

  // ───────────── User-scoped queries ─────────────
  List<Ticket> ticketsForUser(String userEmail) {
    return _tickets
        .where((t) => t.userEmail.toLowerCase() == userEmail.toLowerCase())
        .toList();
  }

  Ticket? getTicketById(String id) {
    try {
      return _tickets.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  int countByStatus(String status) {
    return _tickets.where((t) => t.status == status).length;
  }

  // ───────────── Mutations ─────────────
  Future<Ticket> addTicket({
    required String userId,
    required String userName,
    required String userEmail,
    required String category,
    required String description,
    required String priority,
  }) async {
    final newId =
        'TKT-${(DateTime.now().millisecondsSinceEpoch % 100000).toString().padLeft(5, '0')}';

    final ticket = Ticket(
      id: newId,
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      category: category,
      description: description,
      status: 'Pending',
      priority: priority,
      createdAt: DateTime.now(),
    );

    await _ticketsCollection.doc(newId).set(ticket.toFirestore());
    return ticket;
  }

  Future<void> updateStatus(String ticketId, String newStatus) async {
    await _ticketsCollection.doc(ticketId).update({'status': newStatus});
  }

  void setFilter(String status) {
    _filterStatus = status;
    notifyListeners();
  }

  Future<void> sendMessage({
    required String ticketId,
    required String sender,
    required String text,
  }) async {
    final message = Message(
      id: 'MSG-${DateTime.now().millisecondsSinceEpoch}',
      ticketId: ticketId,
      sender: sender,
      text: text,
      sentAt: DateTime.now(),
    );

    await _ticketsCollection.doc(ticketId).update({
      'messages': FieldValue.arrayUnion([message.toMap()]),
    });
  }

  Future<void> clearAll() async {
    final snapshot = await _ticketsCollection.get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
