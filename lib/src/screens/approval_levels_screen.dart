import 'package:flutter/material.dart';

typedef ApprovalSave = void Function(Map<String, dynamic> state);
typedef ApprovalBack = void Function();

class ApprovalLevelsScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final ApprovalSave? onSave;
  final ApprovalBack? onBack;
  const ApprovalLevelsScreen({super.key, this.initialData, this.onSave, this.onBack});

  @override
  State<ApprovalLevelsScreen> createState() => _ApprovalLevelsScreenState();
}

class _ApprovalLevelsScreenState extends State<ApprovalLevelsScreen> {
  late List<Map<String, dynamic>> _levels;
  List<String> _approvalTypes = [];
  final List<String> _mockUsers = ['Jane Smith', 'John Doe', 'Finance Role', 'IT Dept'];

  @override
  void initState() {
    super.initState();
    final init = widget.initialData ?? {};
    // Load existing levels safely
    final rawLevels = init['levels'] as List? ?? [];
    _levels = rawLevels.map((lv) {
      if (lv is Map<String, dynamic>) {
        return {
          'id': lv['id'] ?? UniqueKey().toString(),
          'name': lv['name'] ?? '',
          'type': lv['type'] ?? '',
          'approvers': List<String>.from(lv['approvers'] ?? []),
        };
      } else {
        return {
          'id': UniqueKey().toString(),
          'name': '',
          'type': '',
          'approvers': <String>[],
        };
      }
    }).toList();

    // If there are saved approval types in definition, load them (optional)
    final savedTypes = init['approvalTypes'] as List? ?? [];
    _approvalTypes = savedTypes.map((e) => e.toString()).toList();
  }

  void _addLevel() {
    setState(() {
      _levels.add({
        'id': UniqueKey().toString(),
        'name': '',
        'type': _approvalTypes.isNotEmpty ? _approvalTypes.first : '',
        'approvers': <String>[],
      });
    });
  }

  void _removeLevel(int index) {
    setState(() {
      _levels.removeAt(index);
    });
  }

  void _reorderLevels(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _levels.removeAt(oldIndex);
      _levels.insert(newIndex, item);
    });
  }

  void _addApprovalTypeDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Add Approval Type'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: 'e.g., Requester\'s Manager')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final v = ctrl.text.trim();
              if (v.isEmpty) return;
              setState(() {
                if (!_approvalTypes.contains(v)) _approvalTypes.add(v);
              });
              Navigator.pop(c);
            },
            child: const Text('Add'),
          )
        ],
      ),
    );
  }

  // bottomsheet to pick approver or add custom
  void _pickApprover(Map<String, dynamic> level) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final manualCtrl = TextEditingController();
        List<String> filtered = List.from(_mockUsers);
        return StatefulBuilder(builder: (context, setLocal) {
          void _refresh(String q) {
            setLocal(() {
              filtered = _mockUsers.where((u) => u.toLowerCase().contains(q.toLowerCase()) || q.isEmpty).toList();
            });
          }

          return Padding(
            padding: MediaQuery.of(context).viewInsets.add(const EdgeInsets.all(12)),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(onChanged: _refresh, decoration: const InputDecoration(labelText: 'Search users or roles')),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: TextField(controller: manualCtrl, decoration: const InputDecoration(hintText: 'Add custom approver'))),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    final v = manualCtrl.text.trim();
                    if (v.isEmpty) return;
                    setState(() => level['approvers'].add(v));
                    manualCtrl.clear();
                  },
                )
              ]),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: filtered.length,
                  itemBuilder: (c, i) {
                    final u = filtered[i];
                    return ListTile(
                      title: Text(u),
                      onTap: () {
                        setState(() => level['approvers'].add(u));
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))
            ]),
          );
        });
      },
    );
  }

  void _saveDefinition() {
    // validation: at least one level and each level must have a name
    if (_levels.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add at least one approval level')));
      return;
    }
    for (final l in _levels) {
      if ((l['name'] as String).trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Each level must have a Level Name')));
        return;
      }
    }

    final map = {
      ...(widget.initialData ?? {}),
      'levels': _levels,
      'approvalTypes': _approvalTypes,
    };

    widget.onSave?.call(map);
  }

  Widget _levelTile(BuildContext context, int index) {
    final level = _levels[index];
    final approvers = (level['approvers'] as List).cast<String>();
    return Card(
      key: ValueKey(level['id']),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // drag handle
            const Padding(
              padding: EdgeInsets.only(right: 8.0, top: 4),
              child: Icon(Icons.drag_handle, color: Colors.black45),
            ),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                TextFormField(
                  initialValue: level['name'],
                  decoration: const InputDecoration(labelText: 'Level Name', hintText: 'e.g., Manager Approval'),
                  onChanged: (v) => level['name'] = v,
                ),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: (level['type'] as String).isEmpty && _approvalTypes.isNotEmpty ? _approvalTypes.first : (level['type'] as String).isEmpty ? null : (level['type'] as String),
                      items: _approvalTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (v) => level['type'] = v ?? '',
                      decoration: const InputDecoration(labelText: 'Approval Type'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(onPressed: _addApprovalTypeDialog, icon: const Icon(Icons.add), label: const Text('Add Approval Type'))
                ]),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final a in approvers)
                      Chip(
                        label: Text(a),
                        onDeleted: () => setState(() => approvers.remove(a)),
                      ),
                    ActionChip(label: const Text('Add Approver'), onPressed: () => _pickApprover(level)),
                  ],
                ),
              ]),
            ),
            // remove icon to the far right
            Column(children: [
              IconButton(onPressed: () => _removeLevel(index), icon: const Icon(Icons.delete_outline, color: Colors.red)),
            ])
          ]),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Define Approval Levels', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 6),
      Text('Set up the sequence of approvals required for this request. Drag to reorder levels.', style: Theme.of(context).textTheme.bodyMedium),
      const SizedBox(height: 12),

      // Reorderable list
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          child: _levels.isEmpty
              ? Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('No approval levels yet'),
                      const SizedBox(height: 12),
                      FilledButton.icon(onPressed: _addLevel, icon: const Icon(Icons.add), label: const Text('Add Level')),
                    ]),
                  ),
                )
              : ReorderableListView.builder(
                  onReorder: _reorderLevels,
                  itemCount: _levels.length,
                  buildDefaultDragHandles: false,
                  itemBuilder: (ctx, index) {
                    return Row(
                      key: ValueKey(_levels[index]['id']),
                      children: [
                        Expanded(child: _levelTile(ctx, index)),
                      ],
                    );
                  },
                ),
        ),
      ),

      // actions row
      Row(children: [
        FilledButton.icon(onPressed: _addLevel, icon: const Icon(Icons.add), label: const Text('Add Level')),
        const SizedBox(width: 12),
        TextButton(onPressed: widget.onBack, child: const Text('Back')),
        const Spacer(),
        ElevatedButton(onPressed: _saveDefinition, child: const Text('Save Definition (to file)')),
      ])
    ]);
  }
}


// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:uuid/uuid.dart';
// import '../models/request_type.dart';
// import '../models/approval_level.dart';
// import '../models/question_field.dart';
// import '../services/file_service.dart';

// class ApprovalLevelsScreen extends StatefulWidget {
//   final RequestTypeModel requestType;
//   const ApprovalLevelsScreen({super.key, required this.requestType});
//   @override
//   State<ApprovalLevelsScreen> createState() => _ApprovalLevelsScreenState();
// }

// class _ApprovalLevelsScreenState extends State<ApprovalLevelsScreen> {
//   final List<ApprovalLevel> _levels = [];
//   // Start with no pre-defined approval types — admin will add.
//   final List<String> _approvalTypes = [];

//   // Mock user suggestions (you will replace with real users later).
//   final List<String> _mockUsers = ['Jane Smith', 'John Doe', 'Finance Role', 'IT Dept'];

//   final FileService _fileService = FileService();

//   @override
//   void initState() {
//     super.initState();
//     // Do NOT pre-populate _levels or _approvalTypes. Start empty.
//   }

//   void _addLevel() {
//     setState(() {
//       _levels.add(ApprovalLevel(id: const Uuid().v4(), name: '', approvalType: ''));
//     });
//   }

//   void _addApprovalTypeDialog() {
//     final ctrl = TextEditingController();
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('Add Approval Type'),
//         content: TextField(
//           controller: ctrl,
//           decoration: const InputDecoration(hintText: 'e.g., Requester\'s Manager'),
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
//           ElevatedButton(
//             onPressed: () {
//               final val = ctrl.text.trim();
//               if (val.isEmpty) return;
//               setState(() {
//                 if (!_approvalTypes.contains(val)) _approvalTypes.add(val);
//               });
//               Navigator.pop(ctx);
//             },
//             child: const Text('Add'),
//           )
//         ],
//       ),
//     );
//   }

//   Future<void> _saveDefinition() async {
//     // Basic validation: require name and at least one field and at least one level
//     if (widget.requestType.procedureName.trim().isEmpty) {
//       _showMsg('Please enter Request Type Name in Basic Details.');
//       return;
//     }
//     if (widget.requestType.form.isEmpty) {
//       _showMsg('Please add at least one form field.');
//       return;
//     }
//     if (_levels.isEmpty) {
//       _showMsg('Please add at least one approval level.');
//       return;
//     }
//     // Validate each level has a name
//     for (final l in _levels) {
//       if (l.name.trim().isEmpty) {
//         _showMsg('Each approval level must have a level name.');
//         return;
//       }
//     }

//     // Ensure procedureId exists (generate if empty)
//     final procId = widget.requestType.procedureId.isEmpty ? 'proc_${const Uuid().v4().split('-').first}' : widget.requestType.procedureId;
//     widget.requestType.procedureId = procId;

//     widget.requestType.levels.clear();
//     widget.requestType.levels.addAll(_levels);

//     final defJson = widget.requestType.toJson();
//     await _fileService.writeJson('definition.json', [defJson]);

//     final instance = {
//       "request_id": "0001",
//       "procedure_id": widget.requestType.procedureId,
//       "procedure_desc": widget.requestType.procedureDesc,
//       "procedure name": widget.requestType.procedureName,
//       "created_by": "",
//       "timestamp": DateTime.now().toIso8601String(),
//       "request_format": widget.requestType.requestFormat.toString(),
//       "status": "0",
//       "form": widget.requestType.form.map((f) => [f.type.name, f.label, f.placeholder.isEmpty ? '' : f.placeholder]).toList(),
//       "response history": "",
//       "letter body/pdf": "",
//       "levels": _levels.map((l) => {
//             'users': l.approvers.map((u) => {'uid': u, 'status': [], 'comment': []}).toList(),
//             'role': '',
//             'net_status': '0'
//           }).toList()
//     };
//     await _fileService.writeJson('instance.json', [instance]);

//     _showMsg('Saved definition.json and instance.json (check app documents directory).');
//   }

//   void _showMsg(String m) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
//   }

//   void _showUserPicker(ApprovalLevel level) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       builder: (c) {
//         final searchCtrl = TextEditingController();
//         final TextEditingController manualCtrl = TextEditingController();
//         List<String> filtered = [..._mockUsers];

//         return StatefulBuilder(builder: (context, setLocal) {
//           void _refreshFiltered() {
//             final q = searchCtrl.text.trim().toLowerCase();
//             setLocal(() {
//               filtered = _mockUsers.where((u) => u.toLowerCase().contains(q) || q.isEmpty).toList();
//             });
//           }

//           return Padding(
//             padding: MediaQuery.of(context).viewInsets.add(const EdgeInsets.all(12.0)),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextField(
//                   controller: searchCtrl,
//                   decoration: const InputDecoration(labelText: 'Search users or roles'),
//                   onChanged: (_) => _refreshFiltered(),
//                 ),
//                 const SizedBox(height: 8),
//                 // manual add row
//                 Row(children: [
//                   Expanded(child: TextField(controller: manualCtrl, decoration: const InputDecoration(hintText: 'Add custom approver (type and press +)'))),
//                   IconButton(
//                     icon: const Icon(Icons.add),
//                     onPressed: () {
//                       final txt = manualCtrl.text.trim();
//                       if (txt.isEmpty) return;
//                       setState(() => level.approvers.add(txt));
//                       manualCtrl.clear();
//                     },
//                   )
//                 ]),
//                 const SizedBox(height: 8),
//                 // results
//                 ConstrainedBox(
//                   constraints: const BoxConstraints(maxHeight: 300),
//                   child: ListView.builder(
//                     shrinkWrap: true,
//                     itemCount: filtered.length,
//                     itemBuilder: (context, i) {
//                       final u = filtered[i];
//                       return ListTile(
//                         title: Text(u),
//                         onTap: () {
//                           setState(() => level.approvers.add(u));
//                           Navigator.pop(c);
//                         },
//                       );
//                     },
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 TextButton(onPressed: () => Navigator.pop(c), child: const Text('Close'))
//               ],
//             ),
//           );
//         });
//       },
//     );
//   }

//   Widget _levelCard(ApprovalLevel l) {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       child: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           // Level name - intentionally empty placeholder (admin must enter)
//           TextFormField(
//             initialValue: l.name,
//             decoration: const InputDecoration(labelText: 'Level Name', hintText: 'e.g., HOD Approval'),
//             onChanged: (v) => l.name = v,
//           ),
//           const SizedBox(height: 12),
//           // Approval Type - dropdown built from admin-added types
//           Row(children: [
//             Expanded(
//               child: DropdownButtonFormField<String>(
//                 value: l.approvalType.isEmpty && _approvalTypes.isNotEmpty ? _approvalTypes.first : (l.approvalType.isEmpty ? null : l.approvalType),
//                 items: _approvalTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
//                 onChanged: (v) => setState(() => l.approvalType = v ?? ''),
//                 decoration: const InputDecoration(labelText: 'Approval Type'),
//               ),
//             ),
//             const SizedBox(width: 8),
//             // Add approval type quick button
//             FilledButton.icon(
//               onPressed: _addApprovalTypeDialog,
//               icon: const Icon(Icons.add),
//               label: const Text('Add Approval Type'),
//             )
//           ]),
//           const SizedBox(height: 12),
//           Wrap(
//             spacing: 8,
//             runSpacing: 8,
//             children: [
//               for (final u in l.approvers)
//                 Chip(
//                   label: Text(u),
//                   onDeleted: () => setState(() => l.approvers.remove(u)),
//                 ),
//               ActionChip(
//                 label: const Text('Add Approver'),
//                 onPressed: () => _showUserPicker(l),
//               )
//             ],
//           ),
//           const SizedBox(height: 8),
//           Align(
//             alignment: Alignment.centerRight,
//             child: TextButton.icon(onPressed: () => setState(() => _levels.remove(l)), icon: const Icon(Icons.delete), label: const Text('Remove')),
//           ),
//         ]),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     widget.requestType.levels.clear();
//     widget.requestType.levels.addAll(_levels);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Define Approval Levels'),
//         leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(18.0),
//         child: Column(children: [
//           Expanded(
//             child: ListView(
//               children: [
//                 Text(
//                   'Set up the sequence of approvals required for this request. Add levels and configure approvers.',
//                   style: Theme.of(context).textTheme.titleMedium,
//                 ),
//                 const SizedBox(height: 12),
//                 if (_levels.isEmpty)
//                   Card(
//                     color: Theme.of(context).colorScheme.surfaceVariant,
//                     child: Padding(
//                       padding: const EdgeInsets.all(12.0),
//                       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                         const Text('No approval levels yet.'),
//                         const SizedBox(height: 8),
//                         FilledButton.icon(onPressed: _addLevel, icon: const Icon(Icons.add), label: const Text('Add Level')),
//                         const SizedBox(height: 8),
//                         const Text('You can also add custom approval types first and then select them per level.'),
//                         const SizedBox(height: 8),
//                         if (_approvalTypes.isNotEmpty)
//                           Wrap(spacing: 8, children: _approvalTypes.map((t) => Chip(label: Text(t))).toList())
//                       ]),
//                     ),
//                   ),
//                 for (final l in _levels) _levelCard(l),
//                 const SizedBox(height: 12),
//                 Align(alignment: Alignment.centerLeft, child: FilledButton.icon(icon: const Icon(Icons.add), label: const Text('Add Level'), onPressed: _addLevel)),
//                 const SizedBox(height: 16),
//                 Text('Request Preview', style: Theme.of(context).textTheme.titleSmall),
//                 const SizedBox(height: 8),
//                 Card(
//                   child: Padding(
//                     padding: const EdgeInsets.all(12.0),
//                     child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                       Text('Procedure name: ${widget.requestType.procedureName.isEmpty ? "<unnamed>" : widget.requestType.procedureName}'),
//                       const SizedBox(height: 6),
//                       Text('Fields:'),
//                       for (final f in widget.requestType.form) Text('- ${f.label}  (${f.type.name})'),
//                       const SizedBox(height: 6),
//                       Text('Levels: ${_levels.map((e) => e.name.isEmpty ? "<unnamed>" : e.name).join(' > ')}'),
//                     ]),
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 // Section to manage approval types globally for this request type
//                 Card(
//                   color: Theme.of(context).colorScheme.surfaceVariant,
//                   child: Padding(
//                     padding: const EdgeInsets.all(12.0),
//                     child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                       const Text('Approval Types (global for this Request Type)'),
//                       const SizedBox(height: 8),
//                       Wrap(spacing: 8, children: [
//                         for (final t in _approvalTypes)
//                           InputChip(
//                             label: Text(t),
//                             onDeleted: () => setState(() => _approvalTypes.remove(t)),
//                           ),
//                         ActionChip(label: const Text('Add Approval Type'), onPressed: _addApprovalTypeDialog),
//                       ]),
//                       const SizedBox(height: 8),
//                       const Text('Tip: add approval types that admins/approvers will select when configuring each level.'),
//                     ]),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Row(mainAxisAlignment: MainAxisAlignment.end, children: [
//             TextButton(onPressed: () => Navigator.pop(context), child: const Text('Back')),
//             const SizedBox(width: 12),
//             ElevatedButton(onPressed: _saveDefinition, child: const Text('Save Definition (to file)')),
//           ])
//         ]),
//       ),
//     );
//   }
// }
