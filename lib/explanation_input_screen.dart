import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';

class ExplanationInputScreen extends StatefulWidget {
  final String studentId;

  const ExplanationInputScreen({super.key, required this.studentId});

  @override
  State<ExplanationInputScreen> createState() => _ExplanationInputScreenState();
}

/*
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░         ░░░░░░░░░░░░░░░░░░░░   ░░░░░░░   ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░   ░░
▒   ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒   ▒▒▒▒▒▒▒   ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒   ▒▒
▒   ▒▒▒▒▒▒▒   ▒▒▒   ▒  ▒   ▒▒▒   ▒▒▒▒▒▒▒   ▒   ▒   ▒▒▒  ▒   ▒▒▒   ▒▒   ▒    ▒  
▓       ▓▓▓▓▓  ▓   ▓▓  ▓▓   ▓▓   ▓▓▓▓▓▓▓   ▓▓   ▓▓   ▓  ▓▓   ▓▓   ▓▓   ▓▓▓   ▓▓
▓   ▓▓▓▓▓▓▓▓▓▓  ▓▓▓▓▓  ▓▓▓   ▓   ▓▓▓▓▓▓▓   ▓▓   ▓▓   ▓  ▓▓▓   ▓   ▓▓   ▓▓▓   ▓▓
▓   ▓▓▓▓▓▓▓▓  ▓▓   ▓▓   ▓   ▓▓   ▓▓▓▓▓▓▓   ▓▓   ▓▓   ▓   ▓   ▓▓   ▓▓   ▓▓▓   ▓ 
█         █   ███   █   ██████   ███████   █    ██   █   ████████      ████   █
█████████████████████   ██████████████████████████████   ██████████████████████
*/

class _ExplanationInputScreenState extends State<ExplanationInputScreen> {
  final TextEditingController explanationController = TextEditingController();
  String? selectedFileName;

  Future<void> _pickFile() async {
    if (kIsWeb) {
      await _pickFileForWeb();
    } else {
      final result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          selectedFileName = result.files.single.name;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Файлы успешно загружены')),
        );
      }
    }
  }

  Future<void> _pickFileForWeb() async {
    final input = html.FileUploadInputElement();
    input.accept = '*/*'; // Укажите типы файлов, которые можно выбрать
    input.click();

    input.onChange.listen((event) {
      final file = input.files?.first;
      if (file != null) {
        setState(() {
          selectedFileName = file.name;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Файлы успешно загружены')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Введите объяснительную'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Введите объяснительную для студента ID: ${widget.studentId}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: explanationController,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Введите текст объяснительной...',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickFile,
              child: const Text('Прикрепить файл'),
            ),
            if (selectedFileName != null) ...[
              const SizedBox(height: 8),
              Text('Выбранный файл: $selectedFileName'),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final explanation = explanationController.text.trim();
                if (explanation.isNotEmpty) {
                  Navigator.pop(context, explanation); // Передаём строку напрямую
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Объяснительная обязательна')),
                  );
                }
              },
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }
}