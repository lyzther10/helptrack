import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/message.dart';
import '../providers/ticket_provider.dart';

class ChatScreen extends StatefulWidget {
  final String ticketId;
  final String currentUser; // 'user' or 'admin'

  const ChatScreen({
    super.key,
    required this.ticketId,
    required this.currentUser,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();
    await context.read<TicketProvider>().sendMessage(
      ticketId: widget.ticketId,
      sender: widget.currentUser,
      text: text,
    );

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TicketProvider>(
      builder: (context, provider, child) {
        final ticket = provider.getTicketById(widget.ticketId);
        if (ticket == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Chat')),
            body: const Center(child: Text('Ticket not found')),
          );
        }

        // Auto-scroll when new messages arrive
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(
              _scrollController.position.maxScrollExtent,
            );
          }
        });

        return Scaffold(
          backgroundColor: const Color(0xFFF1F5F9),
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticket.category,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Ticket #${ticket.id} • with ${widget.currentUser == 'admin' ? ticket.userName : 'Admin'}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              // Ticket info banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                color: Colors.white,
                child: Row(
                  children: [
                    _statusDot(ticket.status),
                    const SizedBox(width: 6),
                    Text(
                      ticket.status,
                      style: TextStyle(
                        fontSize: 12,
                        color: _statusColor(ticket.status),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Icon(
                      Icons.description_outlined,
                      size: 14,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        ticket.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Messages
              Expanded(
                child: ticket.messages.isEmpty
                    ? _emptyChat()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: ticket.messages.length,
                        itemBuilder: (context, index) {
                          final msg = ticket.messages[index];
                          final isMine = msg.sender == widget.currentUser;
                          return _messageBubble(msg, isMine);
                        },
                      ),
              ),

              // Input bar
              _inputBar(),
            ],
          ),
        );
      },
    );
  }

  Widget _emptyChat() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              size: 34,
              color: Color(0xFF93C5FD),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            widget.currentUser == 'admin'
                ? 'Reply to the user below'
                : 'Ask the admin a question below',
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Messages are saved with this ticket',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _messageBubble(Message msg, bool isMine) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 260),
        decoration: BoxDecoration(
          color: isMine ? const Color(0xFF2563EB) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMine ? 16 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              msg.sender == 'admin' ? 'Admin' : 'User',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isMine ? Colors.white70 : const Color(0xFF2563EB),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              msg.text,
              style: TextStyle(
                color: isMine ? Colors.white : const Color(0xFF0F172A),
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('h:mm a').format(msg.sentAt),
              style: TextStyle(
                fontSize: 10,
                color: isMine ? Colors.white60 : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                maxLines: 4,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: const Color(0xFF2563EB),
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: _send,
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusDot(String status) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: _statusColor(status),
        shape: BoxShape.circle,
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
