import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/ticket.dart';
import '../providers/ticket_provider.dart';
import 'chat_screen.dart';

class MyTicketsScreen extends StatelessWidget {
  final String userEmail;

  const MyTicketsScreen({super.key, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Consumer<TicketProvider>(
      builder: (context, provider, child) {
        final tickets = provider.ticketsForUser(userEmail);

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            title: const Text('My Tickets'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${tickets.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: tickets.isEmpty ? _emptyState(context) : _list(tickets),
        );
      },
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 44,
                color: Color(0xFF93C5FD),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No tickets yet',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Go to Home and submit your first ticket',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _list(List<Ticket> tickets) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: tickets.length,
      itemBuilder: (context, index) {
        final ticket = tickets[index];
        return _ticketCard(context, ticket);
      },
    );
  }

  Widget _ticketCard(BuildContext context, Ticket ticket) {
    final statusColor = _statusColor(ticket.status);
    final hasMessages = ticket.messages.isNotEmpty;
    final lastMessage = hasMessages ? ticket.messages.last : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ChatScreen(ticketId: ticket.id, currentUser: 'user'),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row
                Row(
                  children: [
                    Text(
                      '#${ticket.id}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            ticket.status,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Category
                Text(
                  ticket.category,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),

                // Last message preview OR description
                Text(
                  lastMessage != null
                      ? '${lastMessage.sender == 'admin' ? 'Admin' : 'You'}: ${lastMessage.text}'
                      : ticket.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: lastMessage != null
                        ? const Color(0xFF334155)
                        : const Color(0xFF64748B),
                    height: 1.4,
                    fontStyle: lastMessage != null
                        ? FontStyle.normal
                        : FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 12),

                // Bottom row
                Row(
                  children: [
                    Icon(
                      hasMessages
                          ? Icons.chat_bubble
                          : Icons.chat_bubble_outline,
                      size: 14,
                      color: hasMessages
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      hasMessages
                          ? '${ticket.messages.length} messages'
                          : 'Tap to chat',
                      style: TextStyle(
                        fontSize: 11,
                        color: hasMessages
                            ? const Color(0xFF2563EB)
                            : const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      DateFormat('MMM d').format(ticket.createdAt),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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
}
