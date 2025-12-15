import 'package:flutter/material.dart';

class AllProceduresScreen extends StatefulWidget {
  const AllProceduresScreen({super.key});

  @override
  State<AllProceduresScreen> createState() => _AllProceduresScreenState();
}

class _AllProceduresScreenState extends State<AllProceduresScreen> {
  bool _isLoading = true;
  String _error = '';
  List<List<dynamic>> _procedures = [];
  List<List<dynamic>> _filteredProcedures = [];
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProcedures();
  }

  Future<void> _fetchProcedures() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      // PROMPT: Simulate API call: GET /procedures
      // Response format: [[id, name, division], ...]
      await Future.delayed(const Duration(milliseconds: 800)); // Network delay

      // Mock Data
      final mockData = [
        ['P001', 'Hostel Leave Request', 'Hostel'],
        ['P002', 'Bonafide Certificate', 'Administration'],
        ['P003', 'Event Hall Booking', 'Facilities'],
        ['P004', 'Lab Equipment Requisition', 'Academics'],
        ['P005', 'On-Duty Form', 'HR'],
        ['P006', 'Scholarship Application', 'Finance'],
      ];

      if (mounted) {
        setState(() {
          _procedures = mockData;
          _filteredProcedures = mockData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load procedures. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  void _onSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProcedures = _procedures;
      } else {
        final lower = query.toLowerCase();
        _filteredProcedures = _procedures.where((p) {
          final name = (p[1] as String).toLowerCase();
          final div = (p[2] as String).toLowerCase();
          return name.contains(lower) || div.contains(lower);
        }).toList();
      }
    });
    // Reuse admin logic (client-side filter)
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. Header (Reusing Admin Header style internally for this page section if needed,
        //    but sidebar/appbar is handled by AppShell. This detailed header is for the page content.)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'All Procedures',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'List of all request procedures configured in the system',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              // Search Bar
              SizedBox(
                width: 280,
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: _onSearch,
                  decoration: InputDecoration(
                    hintText: 'Search procedures...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Filter/Refresh
              IconButton(
                onPressed: _fetchProcedures,
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh List',
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // 2. Body
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error.isNotEmpty
              ? Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      _error,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                )
              : _filteredProcedures.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 64,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No procedures found',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Card(
                    elevation: 0.5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Table(
                      columnWidths: const {
                        0: FixedColumnWidth(100), // ID
                        1: FlexColumnWidth(2), // Name
                        2: FlexColumnWidth(1), // Division
                        3: FixedColumnWidth(120), // Action
                      },
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      children: [
                        // Header
                        const TableRow(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.black12),
                            ),
                          ),
                          children: [
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'ID',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'Procedure Name',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'Division',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'Action',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        // Rows
                        ..._filteredProcedures.map((proc) {
                          return TableRow(
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.black12),
                              ),
                            ), // subtle separator
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  proc[0] as String,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontFamily: 'Monospace',
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      proc[1] as String,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    // Simulated "short desc" if we had it, or status
                                    // Text('Active', style: TextStyle(fontSize: 12, color: Colors.green)),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    proc[2] as String,
                                    style: TextStyle(
                                      color: Colors.blue.shade800,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: OutlinedButton(
                                  onPressed: () {
                                    // View Action
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Viewing procedure: ${proc[1]}',
                                        ),
                                      ),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  child: const Text('View'),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
