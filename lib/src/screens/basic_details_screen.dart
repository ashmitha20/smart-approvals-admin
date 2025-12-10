import 'package:flutter/material.dart';

typedef BasicNext = void Function(Map<String, dynamic> state);

class BasicDetailsScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final BasicNext? onNext;
  const BasicDetailsScreen({super.key, this.initialData, this.onNext});

  @override
  State<BasicDetailsScreen> createState() => _BasicDetailsScreenState();
}

class _BasicDetailsScreenState extends State<BasicDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _idCtrl;
  late TextEditingController _descCtrl;
  int _requestFormat = 0;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialData ?? {};
    _nameCtrl = TextEditingController(text: initial['procedureName'] ?? '');
    _idCtrl = TextEditingController(text: initial['procedureId'] ?? '');
    _descCtrl = TextEditingController(text: initial['procedureDesc'] ?? '');
    _requestFormat = initial['requestFormat'] ?? 0;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _idCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (!_formKey.currentState!.validate()) return;
    final map = {
      'procedureId': _idCtrl.text.trim(),
      'procedureName': _nameCtrl.text.trim(),
      'procedureDesc': _descCtrl.text.trim(),
      'requestFormat': _requestFormat,
      'form': widget.initialData?['form'] ?? [],
      'levels': widget.initialData?['levels'] ?? []
    };
    widget.onNext?.call(map);
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Define New Request Type', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 6),
      Text('Configure the details, form fields, and approval workflow for this request.', style: Theme.of(context).textTheme.bodyMedium),
      const SizedBox(height: 18),
      Form(
        key: _formKey,
        child: Column(children: [
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Basic Details', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Request Type Name', hintText: 'Enter name'), validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter request type name' : null),
                const SizedBox(height: 12),
                TextFormField(controller: _idCtrl, decoration: const InputDecoration(labelText: 'Request Type ID (optional)', hintText: 'leave blank to auto-generate')),
                const SizedBox(height: 12),
                TextFormField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'Description (optional)', hintText: 'Describe purpose'), maxLines: 3),
                const SizedBox(height: 12),
                Text('Request Format'),
                const SizedBox(height: 6),
                Row(children: [
                  ChoiceChip(label: const Text('Submission Form'), selected: _requestFormat == 0, onSelected: (_) => setState(() => _requestFormat = 0)),
                  const SizedBox(width: 8),
                  ChoiceChip(label: const Text('Document Upload'), selected: _requestFormat == 1, onSelected: (_) => setState(() => _requestFormat = 1)),
                ]),
              ]),
            ),
          ),
          const SizedBox(height: 18),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            ElevatedButton(onPressed: _handleNext, child: const Text('Next: Design Submission Form')),
          ])
        ]),
      )
    ]);
  }
}

// import 'package:flutter/material.dart';
// import 'package:uuid/uuid.dart';
// import '../models/request_type.dart';
// import 'design_form_screen.dart';

// class BasicDetailsScreen extends StatefulWidget {
//   const BasicDetailsScreen({super.key});
//   @override
//   State<BasicDetailsScreen> createState() => _BasicDetailsScreenState();
// }

// class _BasicDetailsScreenState extends State<BasicDetailsScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameCtrl = TextEditingController();
//   final _idCtrl = TextEditingController();
//   final _descCtrl = TextEditingController();
//   int _requestFormat = 0; // default to Submission Form

//   @override
//   void dispose() {
//     _nameCtrl.dispose();
//     _idCtrl.dispose();
//     _descCtrl.dispose();
//     super.dispose();
//   }

//   void _next() {
//     if (!_formKey.currentState!.validate()) return;

//     // If admin leaves ID blank, we will set a UUID later when saving. For navigation we can keep current value.
//     final model = RequestTypeModel(
//       procedureId: _idCtrl.text.trim().isEmpty ? '' : _idCtrl.text.trim(),
//       procedureName: _nameCtrl.text.trim(),
//       procedureDesc: _descCtrl.text.trim(),
//       requestFormat: _requestFormat,
//     );

//     Navigator.push(context, MaterialPageRoute(builder: (_) => DesignFormScreen(requestType: model)));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Define New Request Type')),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Form(
//           key: _formKey,
//           child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Text('Basic Details', style: Theme.of(context).textTheme.titleLarge),
//             const SizedBox(height: 12),
//             TextFormField(
//               controller: _nameCtrl,
//               decoration: const InputDecoration(labelText: 'Request Type Name', hintText: 'e.g., Sick Leave'),
//               validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a request type name' : null,
//             ),
//             const SizedBox(height: 12),
//             TextFormField(
//               controller: _idCtrl,
//               decoration: const InputDecoration(
//                 labelText: 'Request Type ID (optional)',
//                 hintText: 'leave_0001 (or leave blank to auto-generate)',
//               ),
//             ),
//             const SizedBox(height: 12),
//             TextFormField(
//               controller: _descCtrl,
//               decoration: const InputDecoration(labelText: 'Description (optional)', hintText: 'Describe this request type'),
//               maxLines: 3,
//             ),
//             const SizedBox(height: 12),
//             Text('Request Format'),
//             Row(
//               children: [
//                 ChoiceChip(
//                   label: const Text('Submission Form'),
//                   selected: _requestFormat == 0,
//                   onSelected: (_) => setState(() => _requestFormat = 0),
//                 ),
//                 const SizedBox(width: 8),
//                 ChoiceChip(
//                   label: const Text('Document Upload'),
//                   selected: _requestFormat == 1,
//                   onSelected: (_) => setState(() => _requestFormat = 1),
//                 ),
//               ],
//             ),
//             const Spacer(),
//             Row(mainAxisAlignment: MainAxisAlignment.end, children: [
//               ElevatedButton(
//                 child: const Text('Next: Design Submission Form'),
//                 onPressed: _next,
//               )
//             ])
//           ]),
//         ),
//       ),
//     );
//   }
// }
