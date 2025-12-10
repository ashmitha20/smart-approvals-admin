import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

typedef DesignNext = void Function(Map<String, dynamic> state);
typedef DesignBack = void Function();

enum FieldType { paragraph, singleLine, dropdown, fileUpload, dates, multiple }

extension FieldTypeName on FieldType {
  String get name {
    switch (this) {
      case FieldType.paragraph:
        return 'paragraph';
      case FieldType.singleLine:
        return 'singleLine';
      case FieldType.dropdown:
        return 'dropdown';
      case FieldType.fileUpload:
        return 'fileUpload';
      case FieldType.dates:
        return 'dates';
      case FieldType.multiple:
        return 'multiple';
    }
  }
}

class DesignFormScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final DesignNext? onNext;
  final DesignBack? onBack;
  const DesignFormScreen({super.key, this.initialData, this.onNext, this.onBack});

  @override
  State<DesignFormScreen> createState() => _DesignFormScreenState();
}

class _DesignFormScreenState extends State<DesignFormScreen> {
  // internal representation for a field
  // each field is a Map with keys: id,label,variable,type,placeholder,options (List<String>), dateLabel, sampleDate
  late List<Map<String, dynamic>> _fields;

  @override
  void initState() {
    super.initState();

    // Safely read initial form from incoming map. If missing or null, start empty list.
    final init = widget.initialData ?? {};
    final rawForm = init['form'];

    _fields = <Map<String, dynamic>>[];

    if (rawForm is List) {
      // rawForm could be a legacy format (list of lists) — handle several shapes
      for (final item in rawForm) {
        if (item is Map<String, dynamic>) {
          // already in map form
          _fields.add({
            'id': const Uuid().v4(),
            'label': item['label'] ?? (item['question'] ?? ''),
            'variable': item['variable'] ?? item['key'] ?? '',
            'type': _parseType(item['type']),
            'placeholder': item['placeholder'] ?? '',
            'options': (item['options'] as List?)?.cast<String>() ?? <String>[],
            'dateLabel': item['dateLabel'] ?? '',
            'sampleDate': item['sampleDate'] // may be ISO string or DateTime
          });
        } else if (item is List && item.isNotEmpty) {
          // legacy array format like: ["text","start date"," "]
          final t = (item[0] ?? '').toString().toLowerCase();
          FieldType ft = FieldType.paragraph;
          if (t.contains('drop')) ft = FieldType.dropdown;
          if (t.contains('file')) ft = FieldType.fileUpload;
          if (t.contains('date')) ft = FieldType.dates;
          if (t.contains('multi')) ft = FieldType.multiple;
          _fields.add({
            'id': const Uuid().v4(),
            'label': item.length > 1 ? item[1] ?? '' : '',
            'variable': '',
            'type': ft,
            'placeholder': item.length > 2 ? item[2] ?? '' : '',
            'options': <String>[],
            'dateLabel': '',
            'sampleDate': null
          });
        } else {
          // unknown — skip
        }
      }
    }

    // start with empty if nothing given
  }

  FieldType _parseType(dynamic raw) {
    if (raw == null) return FieldType.paragraph;
    final s = raw.toString().toLowerCase();
    if (s.contains('paragraph')) return FieldType.paragraph;
    if (s.contains('single')) return FieldType.singleLine;
    if (s.contains('drop')) return FieldType.dropdown;
    if (s.contains('file')) return FieldType.fileUpload;
    if (s.contains('date')) return FieldType.dates;
    if (s.contains('multi')) return FieldType.multiple;
    return FieldType.paragraph;
  }

  void _addField() {
    setState(() {
      _fields.add({
        'id': const Uuid().v4(),
        'label': '',
        'variable': '',
        'type': FieldType.paragraph,
        'placeholder': '',
        'options': <String>[],
        'dateLabel': '',
        'sampleDate': null
      });
    });
  }

  void _addOption(Map<String, dynamic> field, String option) {
    if (option.trim().isEmpty) return;
    setState(() {
      final opts = (field['options'] as List<String>?) ?? <String>[];
      opts.add(option);
      field['options'] = opts;
    });
  }

  void _removeOption(Map<String, dynamic> field, String option) {
    setState(() {
      (field['options'] as List<String>).remove(option);
    });
  }

  Future<void> _pickSampleDate(Map<String, dynamic> field) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        field['sampleDate'] = picked.toIso8601String(); // store as ISO so JSON friendly
      });
    }
  }

  bool _validateBeforeNext() {
    if (_fields.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add at least one question')));
      return false;
    }
    for (final f in _fields) {
      if ((f['label'] as String).trim().isEmpty || (f['variable'] as String).trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Each field must have a label and variable name')));
        return false;
      }
      final type = f['type'] as FieldType;
      if ((type == FieldType.dropdown || type == FieldType.multiple) && (f['options'] as List<String>?)!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dropdown/Multiple fields must have at least one option')));
        return false;
      }
      if (type == FieldType.dates && (f['dateLabel'] as String).trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Date fields must have a date label')));
        return false;
      }
    }
    return true;
  }

  void _onNext() {
    if (!_validateBeforeNext()) return;
    final newMap = {
      ...(widget.initialData ?? {}),
      'form': _fields.map((f) {
        return {
          'id': f['id'],
          'label': f['label'],
          'variable': f['variable'],
          'type': (f['type'] as FieldType).name,
          'placeholder': f['placeholder'],
          'options': (f['options'] as List<String>?) ?? [],
          'dateLabel': f['dateLabel'] ?? '',
          'sampleDate': f['sampleDate']
        };
      }).toList()
    };
    widget.onNext?.call(newMap);
  }

  Widget _fieldCard(Map<String, dynamic> f) {
    final FieldType ft = f['type'] as FieldType;
    final TextEditingController _labelCtrl = TextEditingController(text: f['label'] as String? ?? '');
    final TextEditingController _varCtrl = TextEditingController(text: f['variable'] as String? ?? '');
    final TextEditingController _phCtrl = TextEditingController(text: f['placeholder'] as String? ?? '');
    final TextEditingController _optCtrl = TextEditingController();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: TextFormField(
                controller: _labelCtrl,
                decoration: const InputDecoration(labelText: 'Label (what user sees)'),
                onChanged: (v) => f['label'] = v,
              ),
            ),
            const SizedBox(width: 12),
            DropdownButton<FieldType>(
              value: ft,
              items: FieldType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.name))).toList(),
              onChanged: (v) {
                if (v == null) return;
                setState(() {
                  f['type'] = v;
                  // ensure options list exists for dropdown/multiple
                  if ((v == FieldType.dropdown || v == FieldType.multiple) && (f['options'] == null)) {
                    f['options'] = <String>[];
                  }
                });
              },
            )
          ]),
          const SizedBox(height: 10),
          TextFormField(
            controller: _varCtrl,
            decoration: const InputDecoration(labelText: 'Variable Name (system key)', hintText: 'e.g., start_date'),
            onChanged: (v) => f['variable'] = v,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _phCtrl,
            decoration: const InputDecoration(labelText: 'Placeholder / Default Value'),
            onChanged: (v) => f['placeholder'] = v,
          ),
          const SizedBox(height: 10),

          // Special: dropdown / multiple -> options editor
          if (ft == FieldType.dropdown || ft == FieldType.multiple) ...[
            const Text('Options (user will choose from these)'),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                for (final o in (f['options'] as List<String>?) ?? <String>[]) Chip(label: Text(o), onDeleted: () => _removeOption(f, o)),
              ],
            ),
            const SizedBox(height: 6),
            Row(children: [
              Expanded(child: TextField(controller: _optCtrl, decoration: const InputDecoration(hintText: 'Enter option and press +'))),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  final v = _optCtrl.text.trim();
                  if (v.isEmpty) return;
                  _addOption(f, v);
                  _optCtrl.clear();
                },
              )
            ]),
            const SizedBox(height: 10),
          ],

          // Special: dates -> show a date label input and sample date picker preview
          if (ft == FieldType.dates) ...[
            const Text('Date field settings'),
            const SizedBox(height: 6),
            TextFormField(
              initialValue: f['dateLabel'] as String? ?? '',
              decoration: const InputDecoration(labelText: 'Date field label (e.g., Start Date)'),
              onChanged: (v) => f['dateLabel'] = v,
            ),
            const SizedBox(height: 8),
            Row(children: [
              ElevatedButton.icon(
                onPressed: () => _pickSampleDate(f),
                icon: const Icon(Icons.calendar_today),
                label: const Text('Pick sample date'),
              ),
              const SizedBox(width: 12),
              if (f['sampleDate'] != null)
                Text('Selected: ${DateTime.tryParse(f['sampleDate']) != null ? DateTime.parse(f['sampleDate']).toLocal().toString().split(' ').first : f['sampleDate']}', style: const TextStyle(fontSize: 14)),
            ]),
            const SizedBox(height: 10),
          ],

          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => setState(() => _fields.removeWhere((x) => x['id'] == f['id'])),
              icon: const Icon(Icons.delete),
              label: const Text('Remove'),
            ),
          )
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Design the Submission Form', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 6),
      Text('Add and configure the fields that users will fill out.', style: Theme.of(context).textTheme.bodyMedium),
      const SizedBox(height: 12),
      if (_fields.isEmpty)
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('No questions yet. Click "Add Question" to start creating form fields.'),
              const SizedBox(height: 12),
              OutlinedButton.icon(onPressed: _addField, icon: const Icon(Icons.add), label: const Text('Add Question')),
            ]),
          ),
        ),
      for (final f in List.from(_fields)) _fieldCard(f),
      const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        TextButton(onPressed: widget.onBack, child: const Text('Back')),
        ElevatedButton(onPressed: _onNext, child: const Text('Next: Define Approval Levels')),
      ])
    ]);
  }
}

// import 'package:flutter/material.dart';
// import 'package:uuid/uuid.dart';
// import '../models/request_type.dart';
// import '../models/question_field.dart';
// import '../models/approval_level.dart';
// import '../widgets/option_editor.dart';
// import 'approval_levels_screen.dart';

// class DesignFormScreen extends StatefulWidget {
//   final RequestTypeModel requestType;
//   const DesignFormScreen({super.key, required this.requestType});
//   @override
//   State<DesignFormScreen> createState() => _DesignFormScreenState();
// }

// class _DesignFormScreenState extends State<DesignFormScreen> {
//   final List<QuestionField> _fields = [];

//   @override
//   void initState() {
//     super.initState();
//     // DO NOT prefill any fields — start empty so admin can add.
//   }

//   void _addField() {
//     setState(() {
//       _fields.add(QuestionField(
//         id: const Uuid().v4(),
//         label: '',
//         type: FieldType.paragraph,
//         variableName: '',
//       ));
//     });
//   }

//   void _editOptions(QuestionField f) {
//     showModalBottomSheet(
//       context: context,
//       builder: (c) => Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: OptionEditor(
//           options: f.options,
//           onChanged: (opts) {
//             setState(() => f.options = opts);
//             Navigator.pop(c);
//           },
//         ),
//       ),
//     );
//   }

//   Widget _fieldCard(QuestionField f) {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       child: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Row(children: [
//             Expanded(
//               child: TextFormField(
//                 initialValue: f.label,
//                 decoration: const InputDecoration(labelText: 'Label (what user sees)', hintText: 'e.g., Start Date'),
//                 onChanged: (v) => f.label = v,
//               ),
//             ),
//             const SizedBox(width: 12),
//             DropdownButton<FieldType>(
//               value: f.type,
//               items: FieldType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.name))).toList(),
//               onChanged: (v) {
//                 setState(() => f.type = v!);
//               },
//             )
//           ]),
//           const SizedBox(height: 8),
//           TextFormField(
//             initialValue: f.variableName,
//             decoration: const InputDecoration(labelText: 'Variable Name (system key)', hintText: 'e.g., start_date'),
//             onChanged: (v) => f.variableName = v,
//           ),
//           const SizedBox(height: 8),
//           TextFormField(
//             initialValue: f.placeholder,
//             decoration: const InputDecoration(labelText: 'Placeholder / Default Value'),
//             onChanged: (v) => f.placeholder = v,
//           ),
//           const SizedBox(height: 8),
//           if (f.type == FieldType.dropdown || f.type == FieldType.multiple)
//             ElevatedButton.icon(
//               icon: const Icon(Icons.list),
//               label: const Text('Edit options'),
//               onPressed: () => _editOptions(f),
//             ),
//           if (f.type == FieldType.dates)
//             Padding(
//               padding: const EdgeInsets.only(top: 8.0),
//               child: TextFormField(
//                 decoration: const InputDecoration(labelText: 'Date field label (e.g., Start Date)'),
//                 onChanged: (v) => f.label = v,
//               ),
//             ),
//           Align(
//             alignment: Alignment.centerRight,
//             child: TextButton.icon(
//               onPressed: () => setState(() => _fields.removeWhere((x) => x.id == f.id)),
//               icon: const Icon(Icons.delete),
//               label: const Text('Remove'),
//             ),
//           ),
//         ]),
//       ),
//     );
//   }

//   bool _validateBeforeNext() {
//     if (_fields.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add at least one question to the form.')));
//       return false;
//     }
//     for (final f in _fields) {
//       if (f.label.trim().isEmpty || f.variableName.trim().isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All fields must have a label and variable name.')));
//         return false;
//       }
//       if ((f.type == FieldType.dropdown || f.type == FieldType.multiple) && f.options.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dropdown/Multiple fields require at least one option.')));
//         return false;
//       }
//     }
//     return true;
//   }

//   @override
//   Widget build(BuildContext context) {
//     widget.requestType.form.clear();
//     widget.requestType.form.addAll(_fields);

//     return Scaffold(
//       appBar: AppBar(title: const Text('Design the Submission Form')),
//       body: Padding(
//         padding: const EdgeInsets.all(18.0),
//         child: Column(children: [
//           Expanded(
//             child: ListView(
//               children: [
//                 Text('Add and configure the fields that users will fill out', style: Theme.of(context).textTheme.titleMedium),
//                 const SizedBox(height: 12),
//                 if (_fields.isEmpty) const Padding(
//                   padding: EdgeInsets.symmetric(vertical: 24.0),
//                   child: Text('No questions yet. Click "Add Question" to start creating form fields.', style: TextStyle(color: Colors.black54)),
//                 ),
//                 for (final f in _fields) _fieldCard(f),
//                 const SizedBox(height: 12),
//                 Align(
//                   alignment: Alignment.centerLeft,
//                   child: ElevatedButton.icon(icon: const Icon(Icons.add), label: const Text('Add Question'), onPressed: _addField),
//                 )
//               ],
//             ),
//           ),
//           Row(mainAxisAlignment: MainAxisAlignment.end, children: [
//             TextButton(onPressed: () => Navigator.pop(context), child: const Text('Back')),
//             const SizedBox(width: 12),
//             ElevatedButton(
//               onPressed: () {
//                 if (!_validateBeforeNext()) return;
//                 widget.requestType.form = _fields;
//                 Navigator.push(context, MaterialPageRoute(builder: (_) => ApprovalLevelsScreen(requestType: widget.requestType)));
//               },
//               child: const Text('Next: Define Approval Levels'),
//             ),
//           ])
//         ]),
//       ),
//     );
//   }
// }

