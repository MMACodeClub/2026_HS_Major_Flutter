import 'package:flutter/material.dart';

Future<String?> showTextEditor(
  BuildContext context, {
  required String title,
  required String label,
  required String? Function(String?) validator,
  required int maxLength,
  String initialValue = '',
  bool multiline = false,
}) => showDialog<String>(
  context: context,
  builder: (_) => _TextEditor(
    title: title,
    label: label,
    validator: validator,
    maxLength: maxLength,
    initialValue: initialValue,
    multiline: multiline,
  ),
);

class _TextEditor extends StatefulWidget {
  const _TextEditor({
    required this.title,
    required this.label,
    required this.validator,
    required this.maxLength,
    required this.initialValue,
    required this.multiline,
  });
  final String title;
  final String label;
  final String? Function(String?) validator;
  final int maxLength;
  final String initialValue;
  final bool multiline;
  @override
  State<_TextEditor> createState() => _TextEditorState();
}

class _TextEditorState extends State<_TextEditor> {
  final _form = GlobalKey<FormState>();
  late final _controller = TextEditingController(text: widget.initialValue);
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    if (_form.currentState!.validate()) {
      Navigator.pop(context, _controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: SizedBox(
      width: 420,
      child: Form(
        key: _form,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(labelText: widget.label),
          validator: widget.validator,
          maxLength: widget.maxLength,
          minLines: widget.multiline ? 3 : 1,
          maxLines: widget.multiline ? 6 : 1,
          textInputAction: widget.multiline
              ? TextInputAction.newline
              : TextInputAction.done,
          onFieldSubmitted: widget.multiline ? null : (_) => _save(),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Abbrechen'),
      ),
      FilledButton(onPressed: _save, child: const Text('Speichern')),
    ],
  );
}

Future<bool> confirmDelete(
  BuildContext context, {
  required String title,
  required String description,
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(description),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    ) ??
    false;
