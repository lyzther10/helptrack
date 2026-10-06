import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/ticket.dart';
import '../providers/ticket_provider.dart';
import 'admin_ticket_detail.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TicketProvider>().loadTickets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Consumer<TicketProvider>(
        builder: (context, provider, child) {
          final allTickets = provider.tickets;
          final filtered = _searchQuery.isEmpty
              ? allTickets
              : allTickets.where((t) {
                  final q = _searchQuery.toLowerCase();
                  return t.category.toLowerCase().contains(q) ||
                      t.userName.toLowerCase().contains(q) ||
                      t.id.toLowerCase().contains(q) ||
                      t.description.toLowerCase().contains(q);
                }).toList();

          return SafeArea(
            child: Column(
              children: [
                _buildAppBar(context, provider),
                Expanded(child: _buildBody(provider, filtered, allTickets)),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // App bar
  // ============================================================
  Widget _buildAppBar(BuildContext context, TicketProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E40AF), Color(0xFF2563EB)],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.admin_panel_settings,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin Dashboard',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'HelpTrack IT Support',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                tooltip: 'Refresh',
                onPressed: () => context.read<TicketProvider>().loadTickets(),
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                tooltip: 'Logout',
                onPressed: () => _confirmLogout(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Search
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: const InputDecoration(
                hintText: 'Search by ID, user, category...',
                hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                prefixIcon: Icon(
                  Icons.search,
                  color: Color(0xFF64748B),
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Body — stats + filters + list
  // ============================================================
  Widget _buildBody(
    TicketProvider provider,
    List<Ticket> filtered,
    List<Ticket> allTickets,
  ) {
    return Column(
      children: [
        // Stats
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          color: const Color(0xFFF1F5F9),
          child: Row(
            children: [
              _statCard(
                'Total',
                allTickets.length,
                const Color(0xFF2563EB),
                Icons.confirmation_num,
              ),
              _statCard(
                'Pending',
                provider.countByStatus('Pending'),
                const Color(0xFFF59E0B),
                Icons.schedule,
              ),
              _statCard(
                'In Progress',
                provider.countByStatus('In Progress'),
                const Color(0xFF3B82F6),
                Icons.autorenew,
              ),
              _statCard(
                'Resolved',
                provider.countByStatus('Resolved'),
                const Color(0xFF10B981),
                Icons.check_circle,
              ),
            ],
          ),
        ),

        // Filters
        Container(
          height: 48,
          color: const Color(0xFFF1F5F9),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _filterChip(provider, 'All'),
              _filterChip(provider, 'Pending'),
              _filterChip(provider, 'In Progress'),
              _filterChip(provider, 'Resolved'),
            ],
          ),
        ),

        // List
        Expanded(
          child: filtered.isEmpty
              ? _emptyState()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return _adminTicketCard(filtered[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _statCard(String label, int count, Color color, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 6),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(TicketProvider provider, String label) {
    final isSelected = provider.filterStatus == label;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => provider.setFilter(label),
        backgroundColor: Colors.white,
        selectedColor: const Color(0xFF2563EB).withValues(alpha: 0.15),
        checkmarkColor: const Color(0xFF2563EB),
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isSelected ? const Color(0xFF1E40AF) : const Color(0xFF64748B),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected
                ? const Color(0xFF2563EB)
                : const Color(0xFFE2E8F0),
          ),
        ),
      ),
    );
  }

  Widget _adminTicketCard(Ticket ticket) {
    final statusColor = _statusColor(ticket.status);
    final priorityColor = _priorityColor(ticket.priority);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AdminTicketDetail(ticketId: ticket.id),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: ID + status
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
                const SizedBox(height: 8),

                // Category
                Text(
                  ticket.category,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),

                // Description preview
                Text(
                  ticket.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),

                // Bottom row: user + priority + date
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          ticket.userName.isNotEmpty
                              ? ticket.userName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        ticket.userName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF334155),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: priorityColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        ticket.priority,
                        style: TextStyle(
                          fontSize: 10,
                          color: priorityColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('MMM d').format(ticket.createdAt),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    if (ticket.messages.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.chat_bubble,
                              size: 10,
                              color: Color(0xFF2563EB),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${ticket.messages.length}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF2563EB),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 70, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            _searchQuery.isEmpty
                ? 'No tickets yet'
                : 'No tickets match your search',
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout?'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
