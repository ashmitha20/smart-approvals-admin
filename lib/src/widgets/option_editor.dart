import 'package:flutter/material.dart';

class OptionEditor extends StatefulWidget {
  final List<String> options;
  final void Function(List<String>) onChanged;
  const OptionEditor({super.key, required this.options, required this.onChanged});

  @override
  State<OptionEditor> createState() => _OptionEditorState();
}

class _OptionEditorState extends State<OptionEditor> {
  late List<TextEditingController> ctrls;

  @override
  void initState() {
    super.initState();
    ctrls = widget.options.map((o) => TextEditingController(text: o)).toList();
    if (ctrls.isEmpty) {
      ctrls.add(TextEditingController());
    }
  }

  void _pushUpdates() {
    final list = ctrls.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList();
    widget.onChanged(list);
  }

  @override
  void dispose() {
    for (final c in ctrls) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < ctrls.length; i++)
          Row(
            children: [
              Expanded(child: TextField(controller: ctrls[i], decoration: InputDecoration(labelText: 'Option ${i + 1}'))),
              IconButton(
                  onPressed: () {
                    setState(() {
                      ctrls.removeAt(i).dispose();
                      if (ctrls.isEmpty) ctrls.add(TextEditingController());
                      _pushUpdates();
                    });
                  },
                  icon: Icon(Icons.delete))
            ],
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            icon: Icon(Icons.add),
            label: Text('Add option'),
            onPressed: () {
              setState(() {
                ctrls.add(TextEditingController());
              });
            },
          ),
        ),
        ElevatedButton(
          onPressed: _pushUpdates,
          child: const Text('Save options'),
        )
      ],
    );
  }
}
