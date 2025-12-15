import 'package:flutter/material.dart';
import '../widgets/stats_card.dart';
import '../widgets/requests_table.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Mock Role Switcher for Demo
  // 'Student' or 'Authority'
  String _userRole = 'Student';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 0. Mock Role Switcher (Hidden in prod)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text("View as: ", style: TextStyle(color: Colors.grey)),
              DropdownButton<String>(
                value: _userRole,
                items: const [
                  DropdownMenuItem(value: 'Student', child: Text('Student')),
                  DropdownMenuItem(
                    value: 'Authority',
                    child: Text('Authority'),
                  ),
                ],
                onChanged: (v) => setState(() => _userRole = v!),
                underline: Container(),
                style: const TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 1. Overview Section
          _buildOverviewSection(),
          const SizedBox(height: 24),

          // 2. Actions Section
          _buildActionsSection(),
          const SizedBox(height: 24),

          // 3. Recent Requests Table
          RequestsTable(isAuthority: _userRole == 'Authority'),
          const SizedBox(height: 24),

          // 4. Info Card
          _buildInfoCard(),
        ],
      ),
    );
  }

  Widget _buildOverviewSection() {
    // Layout: responsive grid
    // For simplicity using linear Wrap or Row
    // Stats differ by role
    final List<Widget> cards = [];

    if (_userRole == 'Student') {
      cards.addAll([
        const Expanded(
          child: StatsCard(
            title: 'Total Requests',
            count: '12',
            icon: Icons.folder_copy_outlined,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: StatsCard(
            title: 'Pending',
            count: '3',
            icon: Icons.pending_actions_outlined,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: StatsCard(
            title: 'Approved',
            count: '8',
            icon: Icons.check_circle_outline,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: StatsCard(
            title: 'Rejected',
            count: '1',
            icon: Icons.cancel_outlined,
            color: Colors.red,
          ),
        ),
      ]);
    } else {
      // Authority
      cards.addAll([
        const Expanded(
          child: StatsCard(
            title: 'Pending My Approval',
            count: '5',
            icon: Icons.gavel_outlined,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: StatsCard(
            title: 'Approved by Me',
            count: '42',
            icon: Icons.thumb_up_alt_outlined,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: StatsCard(
            title: 'Rejected by Me',
            count: '6',
            icon: Icons.thumb_down_alt_outlined,
            color: Colors.red,
          ),
        ),
      ]);
    }

    return Row(children: cards);
  }

  Widget _buildActionsSection() {
    if (_userRole == 'Student') {
      return Row(
        children: [
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('Create New Request'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(200, 48)),
          ),
          const SizedBox(width: 16),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(180, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              side: BorderSide(color: Theme.of(context).primaryColor),
            ),
            child: Text(
              'View My Requests',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ),
        ],
      );
    } else {
      // Authority
      return Row(
        children: [
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.assignment_turned_in),
            label: const Text('View Pending Requests'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(220, 48)),
          ),
        ],
      );
    }
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700),
          const SizedBox(width: 12),
          Text(
            "Requests follow a predefined approval flow based on request type.",
            style: TextStyle(color: Colors.blue.shade900),
          ),
        ],
      ),
    );
  }
}
