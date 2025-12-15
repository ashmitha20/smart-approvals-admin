// import 'package:flutter/material.dart';
// import 'screens/basic_details_screen.dart';
// import 'screens/design_form_screen.dart';
// import 'screens/approval_levels_screen.dart';

// class AppShell extends StatefulWidget {
//   const AppShell({super.key});
//   @override
//   State<AppShell> createState() => _AppShellState();
// }

// class _AppShellState extends State<AppShell> {
//   int _selectedIndex = 0; // 0 = Dashboard, 1 = Admin
//   // internal step inside admin flow: 0=basic,1=design,2=approval
//   int _adminStep = 0;

//   // a single shared object to pass between admin screens (simple map)
//   Map<String, dynamic> adminState = {
//     'requestType': {
//       'procedureId': '',
//       'procedureName': '',
//       'procedureDesc': '',
//       'requestFormat': 0,
//       'form': [],
//       'levels': []
//     }
//   };

//   void _onSelect(int idx) {
//     setState(() {
//       _selectedIndex = idx;
//       if (idx != 1) _adminStep = 0;
//     });
//   }

//   // move admin step forward/backward
//   void _adminNext() {
//     setState(() => _adminStep = (_adminStep + 1).clamp(0, 2));
//   }

//   void _adminBack() {
//     setState(() => _adminStep = (_adminStep - 1).clamp(0, 2));
//   }

//   @override
//   Widget build(BuildContext context) {
//     const sidebarWidth = 240.0;

//     return Scaffold(
//       body: Row(children: [
//         // Sidebar
//         Container(
//           width: sidebarWidth,
//           color: Colors.white,
//           child: SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
//               child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                 Text('Smart Approval', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.blueAccent)),
//                 const SizedBox(height: 20),
//                 _sidebarItem(Icons.dashboard_outlined, 'Dashboard', 0),
//                 const SizedBox(height: 10),
//                 _sidebarItem(Icons.admin_panel_settings_outlined, 'Admin', 1),
//                 const Spacer(),
//                 InkWell(onTap: () {}, child: Row(children: const [Icon(Icons.logout, color: Colors.red), SizedBox(width: 8), Text('Logout', style: TextStyle(color: Colors.red))])),
//                 const SizedBox(height: 8),
//               ]),
//             ),
//           ),
//         ),

//         // Main area
//         Expanded(
//           child: Column(children: [
//             // Top header
//             Container(
//               height: 64,
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
//               child: Row(children: [
//                 Expanded(
//                   child: Text(
//                     _selectedIndex == 0 ? 'Dashboard' : 'Admin',
//                     style: Theme.of(context).textTheme.titleLarge,
//                   ),
//                 ),
//                 IconButton(
//                   onPressed: () {},
//                   icon: Stack(children: [const Icon(Icons.notifications_outlined), Positioned(right: 0, top: 0, child: Container(width: 8, height: 8, decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle)))]),
//                 ),
//                 const SizedBox(width: 8),
//                 PopupMenuButton<String>(
//                   onSelected: (v) {},
//                   itemBuilder: (c) => [
//                     const PopupMenuItem(value: 'Profile', child: ListTile(leading: Icon(Icons.person_outline), title: Text('Profile'))),
//                     const PopupMenuItem(value: 'Notifications', child: ListTile(leading: Icon(Icons.notifications_outlined), title: Text('Notifications'))),
//                     const PopupMenuItem(value: 'Settings', child: ListTile(leading: Icon(Icons.settings_outlined), title: Text('Settings'))),
//                     const PopupMenuDivider(),
//                     const PopupMenuItem(value: 'Logout', child: ListTile(leading: Icon(Icons.logout), title: Text('Logout', style: TextStyle(color: Colors.red)))),
//                   ],
//                   child: Row(children: [CircleAvatar(backgroundColor: Colors.blueAccent, child: const Text('JD')), const SizedBox(width: 8)]),
//                 )
//               ]),
//             ),

//             // Body
//             Expanded(
//               child: Container(
//                 color: Colors.grey.shade50,
//                 padding: const EdgeInsets.all(22),
//                 child: _selectedIndex == 0
//                     ? Center(child: Text('Dashboard (empty for now)', style: Theme.of(context).textTheme.bodyLarge))
//                     : _adminArea(),
//               ),
//             )
//           ]),
//         )
//       ]),
//     );
//   }

//   Widget _sidebarItem(IconData icon, String label, int idx) {
//     final selected = _selectedIndex == idx;
//     return InkWell(
//       onTap: () => _onSelect(idx),
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
//         decoration: BoxDecoration(color: selected ? Colors.blue.shade50 : Colors.transparent, borderRadius: BorderRadius.circular(8)),
//         child: Row(children: [Icon(icon, color: selected ? Colors.blueAccent : Colors.black54), const SizedBox(width: 12), Text(label, style: TextStyle(color: selected ? Colors.blueAccent : Colors.black87))]),
//       ),
//     );
//   }

//   // The admin area shows the three screens inline, switching by _adminStep
//   Widget _adminArea() {
//     Widget content;
//     switch (_adminStep) {
//       case 0:
//         content = BasicDetailsScreen(
//           initialData: adminState['requestType'],
//           onNext: (map) {
//             adminState['requestType'] = map;
//             _adminNext();
//           },
//         );
//         break;
//       case 1:
//         content = DesignFormScreen(
//           initialData: adminState['requestType'],
//           onNext: (map) {
//             adminState['requestType'] = map;
//             _adminNext();
//           },
//           onBack: () => _adminBack(),
//         );
//         break;
//       default:
//         content = ApprovalLevelsScreen(
//           initialData: adminState['requestType'],
//           onSave: (map) {
//             adminState['requestType'] = map;
//             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved (check definition.json file)')));
//           },
//           onBack: () => _adminBack(),
//         );
//     }

//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       elevation: 0,
//       child: Padding(padding: const EdgeInsets.all(18), child: content),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'screens/basic_details_screen.dart';
import 'screens/design_form_screen.dart';
import 'screens/approval_levels_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/all_procedures_screen.dart'; // <-- added
import 'services/file_service.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0; // 0 = Dashboard, 1 = Admin
  int _adminStep = 0;

  final FileService _fileService = FileService(); // <-- FileService instance

  Map<String, dynamic> adminState = {
    'requestType': {
      'procedureId': '',
      'procedureName': '',
      'procedureDesc': '',
      'requestFormat': 0,
      'form': [],
      'levels': []
    }
  };

  void _onSelect(int idx) {
    setState(() {
      _selectedIndex = idx;
      if (idx != 1) _adminStep = 0;
    });
  }

  void _adminNext() => setState(() => _adminStep = (_adminStep + 1).clamp(0, 2));
  void _adminBack() => setState(() => _adminStep = (_adminStep - 1).clamp(0, 2));

  @override
  Widget build(BuildContext context) {
    const sidebarWidth = 240.0;

    return Scaffold(
      body: Row(children: [
        // Sidebar
        Container(
          width: sidebarWidth,
          color: Colors.white,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Smart Approval', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.blueAccent)),
                const SizedBox(height: 20),
                _sidebarItem(Icons.dashboard_outlined, 'Dashboard', 0),
                const SizedBox(height: 10),
                _sidebarItem(Icons.list_alt_outlined, 'Procedures', 2), // Index 2 for All Procedures
                const SizedBox(height: 10),
                _sidebarItem(Icons.admin_panel_settings_outlined, 'Admin', 1),
                const Spacer(),
                InkWell(onTap: () {}, child: Row(children: const [Icon(Icons.logout, color: Colors.red), SizedBox(width: 8), Text('Logout', style: TextStyle(color: Colors.red))])),
                const SizedBox(height: 8),
              ]),
            ),
          ),
        ),

        // Main area
        Expanded(
          child: Column(children: [
            // Top header
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
              child: Row(children: [
                Expanded(
                  child: Text(
                    _selectedIndex == 0
                        ? 'Dashboard'
                        : _selectedIndex == 2
                            ? 'Procedures'
                            : 'Admin',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Stack(children: [const Icon(Icons.notifications_outlined), Positioned(right: 0, top: 0, child: Container(width: 8, height: 8, decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle)))]),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  onSelected: (v) {},
                  itemBuilder: (c) => [
                    const PopupMenuItem(value: 'Profile', child: ListTile(leading: Icon(Icons.person_outline), title: Text('Profile'))),
                    const PopupMenuItem(value: 'Notifications', child: ListTile(leading: Icon(Icons.notifications_outlined), title: Text('Notifications'))),
                    const PopupMenuItem(value: 'Settings', child: ListTile(leading: Icon(Icons.settings_outlined), title: Text('Settings'))),
                    const PopupMenuDivider(),
                    const PopupMenuItem(value: 'Logout', child: ListTile(leading: Icon(Icons.logout), title: Text('Logout', style: TextStyle(color: Colors.red)))),

                  ],
                  child: Row(children: [CircleAvatar(backgroundColor: Colors.blueAccent, child: const Text('JD')), const SizedBox(width: 8)]),
                )
              ]),
            ),

            // Body
            Expanded(
              child: Container(
                color: Colors.grey.shade50,
                padding: const EdgeInsets.all(22),
                child: _selectedIndex == 0
                    ? const DashboardScreen()
                    : _selectedIndex == 2
                        ? const AllProceduresScreen()
                        : _adminArea(),
              ),
            )
          ]),
        )
      ]),
    );
  }

  Widget _sidebarItem(IconData icon, String label, int idx) {
    final selected = _selectedIndex == idx;
    return InkWell(
      onTap: () => _onSelect(idx),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(color: selected ? Colors.blue.shade50 : Colors.transparent, borderRadius: BorderRadius.circular(8)),
        child: Row(children: [Icon(icon, color: selected ? Colors.blueAccent : Colors.black54), const SizedBox(width: 12), Text(label, style: TextStyle(color: selected ? Colors.blueAccent : Colors.black87))]),
      ),
    );
  }

  Widget _adminArea() {
    Widget content;
    switch (_adminStep) {
      case 0:
        content = BasicDetailsScreen(
          initialData: adminState['requestType'],
          onNext: (map) {
            adminState['requestType'] = map;
            _adminNext();
          },
        );
        break;
      case 1:
        content = DesignFormScreen(
          initialData: adminState['requestType'],
          onNext: (map) {
            adminState['requestType'] = map;
            _adminNext();
          },
          onBack: () => _adminBack(),
        );
        break;
      default:
        // IMPORTANT: On save, write definition.json and instance.json using FileService
        content = ApprovalLevelsScreen(
          initialData: adminState['requestType'],
          onSave: (map) async {
            // update in-memory adminState
            adminState['requestType'] = map;

            // prepare definition array (we keep it as a single-item array for now)
            final definitionArray = [map];

            try {
              await _fileService.writeJson('definition.json', definitionArray);

              // create a basic instance placeholder (you can customize)
              final instance = {
                "request_id": "0001",
                "procedure_id": map['procedureId'] ?? 'proc_' + DateTime.now().millisecondsSinceEpoch.toString(),
                "procedure_desc": map['procedureDesc'] ?? '',
                "procedure name": map['procedureName'] ?? '',
                "created_by": "",
                "timestamp": DateTime.now().toIso8601String(),
                "request_format": (map['requestFormat'] ?? 0).toString(),
                "status": "0",
                "form": (map['form'] as List? ?? []).map((f) {
                  // map field to [type,label,placeholder] to keep backward compatibility
                  return [f['type'] ?? f['type'], f['label'] ?? f['label'], f['placeholder'] ?? ''];
                }).toList(),
                "response history": "",
                "letter body/pdf": "",
                "levels": (map['levels'] as List? ?? []).map((l) {
                  return {
                    "users": ((l['approvers'] ?? []) as List).map((u) => {"uid": u, "status": [], "comment": []}).toList(),
                    "role": l['type'] ?? '',
                    "net_status": "0"
                  };
                }).toList()
              };

              await _fileService.writeJson('instance.json', [instance]);

              // FileService.writeJson prints path 'Wrote <path>' already
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved definition.json and instance.json')));
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving files: $e')));
              }
            }
          },
          onBack: () => _adminBack(),
        );
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: Padding(padding: const EdgeInsets.all(18), child: content),
    );
  }
}
