import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/ticket_provider.dart';
import '../providers/user_provider.dart';
import 'my_tickets_screen.dart';

class SubmitTicketScreen extends StatefulWidget {
  const SubmitTicketScreen({super.key});

  @override
  State<SubmitTicketScreen> createState() => _SubmitTicketScreenState();
}

class _SubmitTicketScreenState extends State<SubmitTicketScreen> {
  final List<Map<String, dynamic>> _categories = const [
    {'name': 'Slow Internet', 'icon': Icons.wifi, 'color': Color(0xFFF59E0B)},
    {
      'name': 'Computer Issue',
      'icon': Icons.computer,
      'color': Color(0xFF3B82F6),
    },
    {
      'name': 'System Error',
      'icon': Icons.error_outline,
      'color': Color(0xFFEF4444),
    },
    {
      'name': 'Printer Problem',
      'icon': Icons.print,
      'color': Color(0xFF8B5CF6),
    },
    {'name': 'Network Issue', 'icon': Icons.router, 'color': Color(0xFF14B8A6)},
    {'name': 'Other', 'icon': Icons.help_outline, 'color': Color(0xFF64748B)},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: const Text('Submit a Ticket')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFDBEAFE)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF2563EB), size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Choose the type of problem you are experiencing.',
                      style: TextStyle(
                        color: Color(0xFF1E40AF),
                        fontSize: 13,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'What kind of problem?',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),

            // Category grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                return _categoryCard(_categories[index]);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryCard(Map<String, dynamic> cat) {
    final color = cat['color'] as Color;
    return Container(
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
                builder: (_) => _TicketFormScreen(
                  category: cat['name'] as String,
                  categoryColor: color,
                  categoryIcon: cat['icon'] as IconData,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(cat['icon'] as IconData, size: 28, color: color),
                ),
                const SizedBox(height: 12),
                Text(
                  cat['name'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// TICKET FORM (after picking a category)
// ============================================================
class _TicketFormScreen extends StatefulWidget {
  final String category;
  final Color categoryColor;
  final IconData categoryIcon;

  const _TicketFormScreen({
    required this.category,
    required this.categoryColor,
    required this.categoryIcon,
  });

  @override
  State<_TicketFormScreen> createState() => _TicketFormScreenState();
}

class _TicketFormScreenState extends State<_TicketFormScreen> {
  final _descController = TextEditingController();
  String _urgency = 'Medium';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final user = context.read<UserProvider>().currentUser;
    if (user == null) {
      _showError('You must be logged in');
      return;
    }

    if (_descController.text.trim().isEmpty) {
      _showError('Please describe the problem');
      return;
    }

    setState(() => _isSubmitting = true);

    final ticket = await context.read<TicketProvider>().addTicket(
      userId: user.email,
      userName: user.name,
      userEmail: user.email,
      category: widget.category,
      description: _descController.text.trim(),
      priority: _urgency,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Color(0xFF10B981),
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Ticket Submitted!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your ${widget.category} ticket has been sent to the admin.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ),
        ],
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: Text(widget.category)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: widget.categoryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.categoryIcon,
                    size: 16,
                    color: widget.categoryColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.category,
                    style: TextStyle(
                      color: widget.categoryColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Urgency
            const Text(
              'Urgency Level',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _urgency,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.priority_high, size: 20),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF2563EB),
                    width: 1.5,
                  ),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'Low', child: Text('Low')),
                DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                DropdownMenuItem(value: 'High', child: Text('High')),
                DropdownMenuItem(value: 'Critical', child: Text('Critical')),
              ],
              onChanged: (v) => setState(() => _urgency = v!),
            ),
            const SizedBox(height: 18),

            // Description
            const Text(
              'Describe the problem',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Describe what happened, when it started, any error messages...',
                hintStyle: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 13,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF2563EB),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Submit
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Submit Ticket',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
