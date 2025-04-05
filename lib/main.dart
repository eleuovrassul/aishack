import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'db.dart';
import 'package:intl/intl.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter(); // Инициализация Hive
  await _initializeData(); // Заполнение тестовых данных
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

class _ScheduleScreenState extends State<ScheduleScreen> {
  List<Map<String, dynamic>> schedule = [];

  // Метод для загрузки расписания из базы данных
  Future<void> _fetchSchedule() async {
    var box = await Hive.openBox('schoolBox');
    setState(() {
      schedule = List<Map<String, dynamic>>.from(box.get('lessons', defaultValue: []));
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchSchedule(); // Загружаем расписание при инициализации
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Расписание на сегодня'),
      ),
      body: schedule.isEmpty
          ? const Center(child: CircularProgressIndicator()) // Показать индикатор загрузки
          : ListView.builder(
              itemCount: schedule.length,
              itemBuilder: (context, index) {
                final lesson = schedule[index];
                final lessonId = lesson['id'] ?? -1; // Устанавливаем -1, если lessonId равен null
                return ListTile(
                  title: Text('${lesson['subject']} (${lesson['className']})'),
                  subtitle: Text('${lesson['day']} | Кабинет: ${lesson['room']}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StudentListScreen(
                          subject: lesson['subject'] ?? 'Unknown Subject',
                          className: lesson['className'] ?? 'Unknown Class',
                          lessonId: lessonId, // Передаем lessonId
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class StudentListScreen extends StatefulWidget {
  final String subject;
  final String className;
  final int lessonId; // Добавляем поле lessonId

  const StudentListScreen({
    super.key,
    required this.subject,
    required this.className,
    required this.lessonId, // Передаем lessonId через конструктор
  });

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  List<Map<String, dynamic>> students = [];

  Future<void> _fetchStudents() async {
    var box = await Hive.openBox('schoolBox');
    final allStudents = List<Map<String, dynamic>>.from(box.get('students', defaultValue: []));
    setState(() {
      students = allStudents.where((student) => student['lessonId'] == widget.lessonId).toList();
    });
  }

  Future<void> _updateStudentStatus(int studentId, bool isPresent) async {
    var box = await Hive.openBox('schoolBox');
    final allStudents = List<Map<String, dynamic>>.from(box.get('students', defaultValue: []));
    final updatedStudents = allStudents.map((student) {
      if (student['id'] == studentId) {
        return {
          ...student,
          'isPresent': isPresent ? 1 : 0,
          'arrivalTime': isPresent ? student['arrivalTime'] ?? DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()) : null,
        };
      }
      return student;
    }).toList();
    await box.put('students', updatedStudents);
    _fetchStudents();
  }

  Future<void> _updateArrivalTime() async {
    var box = await Hive.openBox('schoolBox');
    final allStudents = List<Map<String, dynamic>>.from(box.get('students', defaultValue: []));
    final updatedStudents = allStudents.map((student) {
      if (student['isPresent'] == 1) {
        final now = DateTime.now();
        final formattedTime = DateFormat('yyyy-MM-dd HH:mm').format(now); // Форматируем дату и время
        return {
          ...student,
          'arrivalTime': formattedTime,
        };
      }
      return student;
    }).toList();
    await box.put('students', updatedStudents);
    _fetchStudents();
  }

  Future<void> _updateShowButtons() async {
    var box = await Hive.openBox('schoolBox');
    final allStudents = List<Map<String, dynamic>>.from(box.get('students', defaultValue: []));
    final lessons = List<Map<String, dynamic>>.from(box.get('lessons', defaultValue: []));

    final updatedStudents = allStudents.map((student) {
      final lesson = lessons.firstWhere((lesson) => lesson['id'] == student['lessonId']);
      final startTime = lesson['startTime'];

      // Проверяем, прошло ли время начала урока
      if (_isExplanationRequired(startTime) && student['isPresent'] == 0) {
        return {
          ...student,
          'showButtons': true,
        };
      }
      return student;
    }).toList();

    await box.put('students', updatedStudents);
    _fetchStudents(); // Обновляем список студентов
  }

  bool _isExplanationRequired(String startTime) {
    final now = DateTime.now();
    final lessonStartTime = DateFormat('HH:mm').parse(startTime);
    final lessonStartDateTime = DateTime(now.year, now.month, now.day, lessonStartTime.hour, lessonStartTime.minute);
    return now.difference(lessonStartDateTime).inMinutes > 10;
  }

  @override
  void initState() {
    super.initState();
    _fetchStudents();

    // Запускаем таймер для проверки времени каждую минуту
    Timer.periodic(const Duration(minutes: 1), (timer) {
      _updateShowButtons();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.subject} (${widget.className})'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 20.0,
          columns: const [
            DataColumn(
              label: Text(
                'Имя',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Присутствует',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Время прибытия',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Потребовать объяснительную?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: students.map((student) {
            final lesson = Hive.box('schoolBox').get('lessons').firstWhere((lesson) => lesson['id'] == widget.lessonId);
            final startTime = lesson['startTime'];
            final showButtons = _isExplanationRequired(startTime) && student['isPresent'] == 0 && student['showButtons'] == true;

            return DataRow(cells: [
              DataCell(
                Text(
                  student['name'],
                  style: TextStyle(
                    fontSize: 14,
                    color: student['isPresent'] == 1 ? Colors.green : Colors.grey,
                  ),
                ),
              ),
              DataCell(Checkbox(
                value: student['isPresent'] == 1,
                activeColor: Colors.green,
                onChanged: (value) {
                  _updateStudentStatus(student['id'], value!);
                  setState(() {
                    // Скрыть кнопки, если галочка установлена
                  });
                },
              )),
              DataCell(
                Text(student['arrivalTime'] ?? 'Не прибыл'),
              ),
              DataCell(
                student['showButtons']
                    ? Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Запрос отправлен')),
                              );
                            },
                            child: const Text('Да'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                // Скрыть кнопки, но не ставить галочку
                                student['showButtons'] = false;

                                // Обновляем данные в Hive
                                var box = Hive.box('schoolBox');
                                final allStudents = List<Map<String, dynamic>>.from(box.get('students', defaultValue: []));
                                final updatedStudents = allStudents.map((s) {
                                  if (s['id'] == student['id']) {
                                    return {
                                      ...s,
                                      'showButtons': false,
                                    };
                                  }
                                  return s;
                                }).toList();
                                box.put('students', updatedStudents);
                              });
                            },
                            child: const Text('Нет'),
                          ),
                        ],
                      )
                    : const Text(''),
              ),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}

Future<void> _initializeData() async {
  var box = await Hive.openBox('schoolBox');

  // Добавление уроков
  box.put('lessons', [
    {'id': 0, 'day': 'Saturday', 'subject': 'Math', 'className': '10A', 'room': '101', 'startTime': '12:15'},
    {'id': 1, 'day': 'Monday', 'subject': 'Physics', 'className': '11B', 'room': '202', 'startTime': '09:00'},
  ]);

  // Добавление студентов
  box.put('students', [
    {'id': 1, 'name': 'Иван Иванов', 'status': 'near_turnstile', 'lessonId': 0, 'isPresent': 0, 'arrivalTime': null, 'showButtons': false},
    {'id': 2, 'name': 'Петр Петров', 'status': 'absent', 'lessonId': 0, 'isPresent': 0, 'arrivalTime': null, 'showButtons': false},
    {'id': 3, 'name': 'Анна Смирнова', 'status': 'in_class', 'lessonId': 1, 'isPresent': 0, 'arrivalTime': null, 'showButtons': false},
  ]);
}
