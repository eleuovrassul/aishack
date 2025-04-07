import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class StudentsExplanationListScreen extends StatefulWidget {
  const StudentsExplanationListScreen({super.key});

  @override
  State<StudentsExplanationListScreen> createState() => _StudentsExplanationListScreenState();
}

class _StudentsExplanationListScreenState extends State<StudentsExplanationListScreen> {
  List<Map<String, dynamic>> studentsWithExplanations = [];

  Future<void> _fetchExplanations() async {
    final firestore = FirebaseFirestore.instance;

    // Получаем записи посещаемости с объяснительными
    final attendanceSnapshot = await firestore.collection('attendence').get();

    setState(() {
      studentsWithExplanations = attendanceSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'studentId': data['studentId'],
          'reason': data['reason'] ?? 'Объяснительная отсутствует',
          'reasonShort': data['reasonShort'] ?? 'Не сгенерировано',
        };
      }).toList();
    });
  }

  Future<void> processExplanations() async {
    final firestore = FirebaseFirestore.instance;

    // Получаем все записи с объяснительными
    final attendanceSnapshot = await firestore.collection('attendence').get();

    for (var doc in attendanceSnapshot.docs) {
      final data = doc.data();
      final explanation = data['reason'];

      if (explanation != null && explanation.isNotEmpty) {
        try {
          // Генерируем краткое резюме
          final summary = await generateSummary(explanation);

          // Сохраняем краткое резюме в Firestore
          await firestore.collection('attendence').doc(doc.id).update({
            'reasonShort': summary,
          });

          print('Краткое резюме сохранено для документа ${doc.id}');
        } catch (e) {
          print('Ошибка при обработке документа ${doc.id}: $e');
        }
      }
    }

    // Обновляем список после генерации
    _fetchExplanations();
  }

  // Метод для генерации краткого резюме с помощью Gemini API
  Future<String> generateSummary(String explanation) async {
    const apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=AIzaSyBZ2Y8qKk5xOvzAAGOLhlUFc-tyGRnqRjU';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {
                'text': 'Классифицируй следующую объяснительную опоздания: "$explanation". Напиши уважительная/не уважительная, а также краткое содержание (1 предложение). Не пиши ничего лишнего. Не выделяй текст ничем.'
              }
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Проверяем, есть ли поле candidates и не пустое ли оно
      if (data['candidates'] != null && data['candidates'].isNotEmpty) {
        final candidate = data['candidates'][0];
        if (candidate['content'] != null &&
            candidate['content']['parts'] != null &&
            candidate['content']['parts'].isNotEmpty) {
          return candidate['content']['parts'][0]['text'].trim();
        } else {
          throw Exception('Ответ от API не содержит ожидаемых данных');
        }
      } else {
        throw Exception('Ответ от API не содержит ожидаемых данных');
      }
    } else {
      throw Exception('Ошибка при генерации саммари: ${response.body}');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchExplanations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Список объяснительных'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              try {
                await processExplanations();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Краткие резюме успешно сгенерированы')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ошибка: $e')),
                );
              }
            },
            child: const Text('Сгенерировать краткие резюме'),
          ),
          Expanded(
            child: studentsWithExplanations.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: studentsWithExplanations.length,
                    itemBuilder: (context, index) {
                      final student = studentsWithExplanations[index];
                      return ListTile(
                        title: Text('Ученик ID: ${student['studentId']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Объяснительная: ${student['reason']}'),
                            Text('Краткое резюме: ${student['reasonShort']}'),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}