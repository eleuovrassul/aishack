import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'students_explanation_list_screen.dart';
import 'explanation_input_screen.dart';
import 'student_ui.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const TeacherApp());
}

class TeacherApp extends StatelessWidget {
  const TeacherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teacher App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ScheduleScreen(),
    );
  }
}

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

/*
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░   ░░░░░░░   ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░        ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
▒  ▒   ▒▒▒    ▒▒▒▒▒▒▒▒▒▒▒▒▒  ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒   ▒▒▒▒   ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
▒   ▒   ▒ ▒   ▒▒▒▒   ▒▒▒▒▒▒▒▒▒   ▒   ▒▒▒▒▒▒▒▒▒   ▒▒▒▒   ▒▒▒▒   ▒▒▒▒▒▒     ▒▒▒▒▒▒   ▒▒▒▒
▓   ▓▓   ▓▓   ▓▓   ▓▓   ▓▓   ▓▓   ▓▓   ▓▓▓▓▓▓▓        ▓▓▓▓   ▓▓   ▓▓   ▓▓   ▓▓  ▓▓▓   ▓
▓   ▓▓▓  ▓▓   ▓   ▓▓▓   ▓▓   ▓▓   ▓▓   ▓▓▓▓▓▓▓   ▓▓▓▓▓▓▓▓   ▓▓▓   ▓▓  ▓▓▓   ▓         ▓
▓   ▓▓▓▓▓▓▓   ▓   ▓▓▓   ▓▓   ▓▓   ▓▓   ▓▓▓▓▓▓▓   ▓▓▓▓▓▓▓▓   ▓▓▓   ▓▓    ▓   ▓  ▓▓▓▓▓▓▓▓
█   ███████   ███   █    █   █    ██   ███████   ██████████   █    █████   ████     ███
██████████████████████████████████████████████████████████████████████    █████████████

*/

class _ScheduleScreenState extends State<ScheduleScreen> {
  List<Map<String, dynamic>> schedule = [];

  Future<void> _fetchSchedule() async {
    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore.collection('lessons').get();

    setState(() {
      schedule = snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchSchedule(); // Получаем расписание при инициализации
  }

/*
▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
█▄ ▄█ ▄▄▀█▄ ▄█ ▄▄█ ▄▄▀█ ▄▄█ ▄▄▀█▀▄▀█ ▄▄
██ ██ ██ ██ ██ ▄▄█ ▀▀▄█ ▄██ ▀▀ █ █▀█ ▄▄
█▀ ▀█▄██▄██▄██▄▄▄█▄█▄▄█▄███▄██▄██▄██▄▄▄
▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Расписание',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple.shade700,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StudentsExplanationListScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
                child: const Text(
                  'Просмотр объяснительных',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StudentUI(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
                child: const Text(
                  'Student UI',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
              child: schedule.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: schedule.length,
                      itemBuilder: (context, index) {
                        final lesson = schedule[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          elevation: 4,
                          margin: const EdgeInsets.only(bottom: 16.0),
                          child: ListTile(
                            leading: const Icon(Icons.book, color: Colors.purple),
                            title: Text(
                              '${lesson['subject']} (${lesson['className']})',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'День: ${lesson['day']} | Кабинет: ${lesson['room']} | Время: ${lesson['startTime']}',
                              style: const TextStyle(fontSize: 14, color: Colors.black54),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StudentListScreen(
                                    subject: lesson['subject'] ?? 'Unknown Subject',
                                    className: lesson['className'] ?? 'Unknown Class',
                                    lessonId: lesson['id'] ?? -1,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class StudentListScreen extends StatefulWidget {
  final String subject;
  final String className;
  final int lessonId;

  const StudentListScreen({
    super.key,
    required this.subject,
    required this.className,
    required this.lessonId,
  });

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

/*
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░░      ░░░░░   ░░░░░░░░░░░░░░░░░   ░░░░░░░░░░░░░░░░░░░░░░░░░   ░░░░░░░░░░░░░░░░░   ░░░░░░░░░░░░░░░░░░░░░░   ░░
▒   ▒▒▒▒   ▒▒▒   ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒   ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒   ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒   ▒▒▒▒▒▒▒▒▒  ▒▒▒▒▒▒▒▒▒▒▒   ▒▒
▒▒   ▒▒▒▒▒▒▒    ▒  ▒   ▒▒   ▒▒▒▒▒▒   ▒▒▒▒▒   ▒▒▒▒▒   ▒   ▒▒▒    ▒  ▒▒     ▒▒▒▒▒▒▒▒   ▒▒▒▒▒▒▒▒▒▒▒▒▒     ▒▒    ▒  
▓▓▓▓   ▓▓▓▓▓▓▓   ▓▓▓   ▓▓   ▓▓   ▓   ▓▓▓  ▓▓▓   ▓▓▓   ▓▓   ▓▓▓   ▓▓▓   ▓▓▓▓▓▓▓▓▓▓▓   ▓▓▓▓▓▓▓▓   ▓   ▓▓▓▓▓▓▓   ▓▓
▓▓▓▓▓▓▓   ▓▓▓▓   ▓▓▓   ▓▓   ▓  ▓▓▓   ▓▓         ▓▓▓   ▓▓   ▓▓▓   ▓▓▓▓▓    ▓▓▓▓▓▓▓▓   ▓▓▓▓▓▓▓▓   ▓▓▓    ▓▓▓▓   ▓▓
▓   ▓▓▓▓   ▓▓▓   ▓ ▓   ▓▓   ▓  ▓▓▓   ▓▓  ▓▓▓▓▓▓▓▓▓▓   ▓▓   ▓▓▓   ▓ ▓▓▓▓▓   ▓▓▓▓▓▓▓   ▓▓▓▓▓▓▓▓   ▓▓▓▓▓   ▓▓▓   ▓ 
███      ██████   ████      ██   █   ████     ████    ██   ████   ██      ████████          █   █      █████   █
████████████████████████████████████████████████████████████████████████████████████████████████████████████████

*/

class _StudentListScreenState extends State<StudentListScreen> {
  List<Map<String, dynamic>> students = [];

  Future<void> _fetchStudents() async {
    final firestore = FirebaseFirestore.instance;

    // Получаем записи посещаемости для текущего урока
    final attendanceSnapshot = await firestore
        .collection('attendence')
        .where('lessonId', isEqualTo: widget.lessonId)
        .get();

    // Получаем данные студентов
    final studentIds = attendanceSnapshot.docs.map((doc) => doc['studentId']).toList();
    final studentsSnapshot = await firestore
        .collection('students')
        .where('id', whereIn: studentIds)
        .get();

    // Объединяем данные студентов и посещаемости
    setState(() {
      students = attendanceSnapshot.docs.map((attendanceDoc) {
        final student = studentsSnapshot.docs.firstWhere(
          (studentDoc) => studentDoc['id'] == attendanceDoc['studentId'],
        );
        return {
          'id': attendanceDoc.id,
          'name': student['name'],
          'isPresent': attendanceDoc['isPresent'],
          'arrivalTime': attendanceDoc['arrivalTime'],
          'showButtons': attendanceDoc['showButtons'],
        };
      }).toList();
    });
  }

  // Метод для обновления статуса студента (присутствует/отсутствует)
  Future<void> _updateStudentStatus(String attendanceId, bool isPresent) async {
    final firestore = FirebaseFirestore.instance;
    final now = DateTime.now();
    final formattedTime = DateFormat('yyyy-MM-dd HH:mm').format(now);

    try {
      await firestore.collection('attendence').doc(attendanceId).update({
        'isPresent': isPresent,
        'arrivalTime': isPresent ? formattedTime : null,
      });

      _fetchStudents();
    } catch (e) {
      print('Ошибка при обновлении статуса студента: $e');
    }
  }

  // Метод для отображения диалога с вводом причины отказа
  Future<void> _showTeacherReasonDialog(String attendanceId) async {
    final TextEditingController reasonController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Введите причину отказа'),
          content: TextField(
            controller: reasonController,
            decoration: const InputDecoration(
              hintText: 'Причина отказа',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Закрываем диалог без сохранения
              },
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () async {
                final reason = reasonController.text.trim();
                if (reason.isNotEmpty) {
                  await _updateteacherReason(attendanceId, reason);
                  Navigator.of(context).pop(); // Закрываем диалог после сохранения
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Причина не может быть пустой')),
                  );
                }
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }

  // Метод для обновления причины отказа
  // и скрытия кнопок после сохранения
  Future<void> _updateteacherReason(String attendanceId, String teacherReason) async {
    final firestore = FirebaseFirestore.instance;

    try {
      await firestore.collection('attendence').doc(attendanceId).update({
        'teacherReason': teacherReason,
        'showButtons': false, // Скрываем кнопки после сохранения причины
      });

      _fetchStudents();
    } catch (e) {
      print('Ошибка при обновлении причины: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

/*
▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
█▄ ▄█ ▄▄▀█▄ ▄█ ▄▄█ ▄▄▀█ ▄▄█ ▄▄▀█▀▄▀█ ▄▄
██ ██ ██ ██ ██ ▄▄█ ▀▀▄█ ▄██ ▀▀ █ █▀█ ▄▄
█▀ ▀█▄██▄██▄██▄▄▄█▄█▄▄█▄███▄██▄██▄██▄▄▄
▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.subject} (${widget.className})',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple.shade700,
      ),
      body: students.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                final isPresent = student['isPresent'] == true;

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text(
                              student['name'],
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Checkbox(
                              value: isPresent,
                              onChanged: (value) {
                                _updateStudentStatus(student['id'], value!);
                              },
                            ),
                            Text(
                              isPresent ? 'Присутствует' : 'Отсутствует',
                              style: TextStyle(
                                fontSize: 16,
                                color: isPresent ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.access_time, color: Colors.orange),
                            const SizedBox(width: 8),
                            Text(
                              student['arrivalTime'] ?? 'Не прибыл',
                              style: const TextStyle(fontSize: 16, color: Colors.black54),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (!isPresent)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Писать объяснительную?',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      final explanation = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ExplanationInputScreen(studentId: student['id']),
                                        ),
                                      );

                                      if (explanation != null) {
                                        // Сохраняем объяснительную в Firestore
                                        final firestore = FirebaseFirestore.instance;
                                        await firestore.collection('attendence').doc(student['id']).update({
                                          'reason': explanation,
                                        });

                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Объяснительная сохранена')),
                                        );

                                        _fetchStudents(); // Обновляем список студентов
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      'Да',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      _showTeacherReasonDialog(student['id']);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      'Нет',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}