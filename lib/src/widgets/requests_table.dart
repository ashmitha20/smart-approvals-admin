import 'package:flutter/material.dart';

class RequestsTable extends StatelessWidget {
  final bool isAuthority;

  const RequestsTable({super.key, this.isAuthority = false});

  @override
  Widget build(BuildContext context) {
    // Mock Data
    final requests = [
      {
        'type': 'Leave Request',
        'date': '2023-12-10',
        'status': 'Pending',
        'approver': 'HOD',
        'id': 'REQ-001',
      },
      {
        'type': 'Budget Approval',
        'date': '2023-12-08',
        'status': 'Approved',
        'approver': 'Principal',
        'id': 'REQ-002',
      },
      {
        'type': 'Event Proposal',
        'date': '2023-12-05',
        'status': 'Rejected',
        'approver': 'Dean',
        'id': 'REQ-003',
      },
      {
        'type': 'Lab Equipment',
        'date': '2023-12-12',
        'status': 'Pending',
        'approver': 'Lab In-charge',
        'id': 'REQ-004',
      },
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isAuthority
                      ? 'Recent Pending Requests'
                      : 'Your Recent Requests',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(onPressed: () {}, child: const Text('View All')),
              ],
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Request Type')),
                  DataColumn(label: Text('Submitted Date')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Current Approver')),
                  DataColumn(label: Text('Action')),
                ],
                rows: requests.map((item) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          item['type'] as String,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      DataCell(Text(item['date'] as String)),
                      DataCell(_statusChip(context, item['status'] as String)),
                      DataCell(Text(item['approver'] as String)),
                      DataCell(
                        IconButton(
                          icon: const Icon(
                            Icons.visibility_outlined,
                            color: Colors.blueGrey,
                          ),
                          onPressed: () {},
                          tooltip: 'View Details',
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(BuildContext context, String status) {
    Color color;
    Color textColor;
    switch (status) {
      case 'Approved':
        color = Colors.green.shade100;
        textColor = Colors.green.shade800;
        break;
      case 'Rejected':
        color = Colors.red.shade100;
        textColor = Colors.red.shade800;
        break;
      case 'Pending':
      default:
        color = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
