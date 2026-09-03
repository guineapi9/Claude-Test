import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/word.dart';
import '../providers/word_provider.dart';

/// Add/edit form for a single word. Pass [word] to edit an existing entry,
/// or omit it to create a new one.
class WordFormScreen extends StatefulWidget {
  const WordFormScreen({super.key, this.word});

  final Word? word;

  @override
  State<WordFormScreen> createState() => _WordFormScreenState();
}

class _WordFormScreenState extends State<WordFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _termController;
  late final TextEditingController _meaningController;
  late final TextEditingController _exampleController;
  String? _categoryId;

  bool get _isEditing => widget.word != null;

  @override
  void initState() {
    super.initState();
    _termController = TextEditingController(text: widget.word?.term ?? '');
    _meaningController = TextEditingController(text: widget.word?.meaning ?? '');
    _exampleController = TextEditingController(text: widget.word?.example ?? '');
    _categoryId = widget.word?.categoryId;
  }

  @override
  void dispose() {
    _termController.dispose();
    _meaningController.dispose();
    _exampleController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<WordProvider>();

    if (_isEditing) {
      await provider.updateWord(
        widget.word!,
        term: _termController.text,
        meaning: _meaningController.text,
        example: _exampleController.text,
        categoryId: _categoryId,
      );
    } else {
      await provider.addWord(
        term: _termController.text,
        meaning: _meaningController.text,
        example: _exampleController.text,
        categoryId: _categoryId,
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<WordProvider>().categories;

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? '단어 수정' : '단어 추가')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _termController,
              decoration: const InputDecoration(labelText: '단어 *'),
              textInputAction: TextInputAction.next,
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? '단어를 입력해주세요' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _meaningController,
              decoration: const InputDecoration(labelText: '뜻 *'),
              textInputAction: TextInputAction.next,
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? '뜻을 입력해주세요' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _exampleController,
              decoration: const InputDecoration(labelText: '예문 (선택)'),
              minLines: 2,
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: _categoryId,
              decoration: const InputDecoration(labelText: '카테고리 (선택)'),
              items: [
                const DropdownMenuItem<String?>(value: null, child: Text('없음')),
                for (final category in categories)
                  DropdownMenuItem<String?>(
                    value: category.id,
                    child: Text(category.name),
                  ),
              ],
              onChanged: (value) => setState(() => _categoryId = value),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: Text(_isEditing ? '저장' : '추가'),
            ),
          ],
        ),
      ),
    );
  }
}
