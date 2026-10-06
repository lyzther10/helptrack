import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/ticket_provider.dart';
import 'chat_screen.dart';

class AdminTicketDetail extends StatelessWidget {
  final String ticketId;

  const AdminTicketDetail({super.key, required this.ticketId});

  @override
  Widget build(BuildContext context) {
    return Consumer<TicketProvider>(
      builder: (context, provider, child) {
        final ticket = provider.getTicketById(ticketId);
        if (ticket == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Ticket')),
            body: const Center(child: Text('Ticket not found')),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            title: Text('Ticket #${ticket.id}'),
            actions: [
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline),
                tooltip: 'Chat with user',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ChatScreen(ticketId: ticket.id, currentUser: 'admin'),
                    ),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status pills
                Row(
                  children: [
                    _pill(
                      'Status: ${ticket.status}',
                      _statusColor(ticket.status),
                    ),
                    const SizedBox(width: 8),
                    _pill(
                      'Priority: ${ticket.priority}',
                      _priorityColor(ticket.priority),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // User info card
                _card(
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Center(
                          child: Text(
                            ticket.userName.isNotEmpty
                                ? ticket.userName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ticket.userName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              ticket.userEmail,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'User',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Category + date
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Category',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF94A3B8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ticket.category,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 14,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Submitted ${DateFormat('MMM d, y • h:mm a').format(ticket.createdAt)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Description
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                _card(
                  child: Text(
                    ticket.description,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: Color(0xFF334155),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Chat button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            ticketId: ticket.id,
                            currentUser: 'admin',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat_bubble_outline, size: 20),
                    label: Text(
                      ticket.messages.isEmpty
                          ? 'Open Chat with User'
                          : 'Open Chat (${ticket.messages.length})',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Update status
                const Text(
                  'Update Status',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _statusButton(
                      context,
                      provider,
                      ticket.id,
                      'Pending',
                      const Color(0xFFF59E0B),
                    ),
                    _statusButton(
                      context,
                      provider,
                      ticket.id,
                      'In Progress',
                      const Color(0xFF3B82F6),
                    ),
                    _statusButton(
                      context,
                      provider,
                      ticket.id,
                      'Resolved',
                      const Color(0xFF10B981),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: child,
    );
  }

  Widget _pill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _statusButton(
    BuildContext context,
    TicketProvider provider,
    String ticketId,
    String status,
    Color color,
  ) {
    return ElevatedButton(
      onPressed: () {
        provider.updateStatus(ticketId, status);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated to "$status"'),
            backgroundColor: color,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        status,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Pending':
        return const Color(0xFFF59E0B);
      case 'In Progress':
        return const Color(0xFF3B82F6);
      case 'Resolved':
        return const Color(0xFF10B981);
      default:
        return Colors.grey;
    }
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'Critical':
        return const Color(0xFFEF4444);
      case 'High':
        return const Color(0xFFF97316);
      case 'Medium':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF64748B);
    }
  }
}
