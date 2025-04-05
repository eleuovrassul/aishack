import 'package:flutter/material.dart';
import 'db.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _initializeData();
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

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final schedule = [
      {'time': '08:00 - 08:45', 'subject': 'Math', 'class': '10A', 'room': '101'},
      {'time': '09:00 - 09:45', 'subject': 'Physics', 'class': '11B', 'room': '202'},
      // Добавьте остальные уроки
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Расписание на сегодня'),
      ),
      body: ListView.builder(
        itemCount: schedule.length,
        itemBuilder: (context, index) {
          final lesson = schedule[index];
          return ListTile(
            title: Text('${lesson['subject']} (${lesson['class']})'),
            subtitle: Text('${lesson['time']} | Кабинет: ${lesson['room']}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentListScreen(
                    subject: lesson['subject']!,
                    className: lesson['class']!,
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

  const StudentListScreen({
    super.key,
    required this.subject,
    required this.className,
  });

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  List<Map<String, dynamic>> students = [];

  Future<void> _fetchStudents() async {
    final data = await DBHelper.query('students');
    setState(() {
      students = data;
    });
  }

  Future<void> _updateStudentStatus(int id, String newStatus) async {
    await DBHelper.update(
      'students',
      {'status': newStatus},
      'id = ?',
      [id],
    );
    _fetchStudents();
  }

  @override
  void initState() {
    super.initState();
    _fetchStudents();
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
          ],
          rows: students.map((student) {
            return DataRow(cells: [
              DataCell(
                Text(
                  student['name'],
                  style: TextStyle(
                    fontSize: 14,
                    color: student['status'] == 'near_turnstile' ? Colors.green : Colors.grey,
                  ),
                ),
              ),
              DataCell(Checkbox(
                value: student['status'] == 'in_class',
                activeColor: Colors.green,
                onChanged: (value) {
                  if (value == true) {
                    _updateStudentStatus(student['id'], 'in_class');
                  }
                },
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}

void _initializeData() async {
  await DBHelper.insert('lessons', {
    'day': 'Monday',
    'subject': 'Math',
    'className': '10A',
    'room': '101',
  });

  await DBHelper.insert('students', {
    'name': 'Иван Иванов',
    'status': 'near_turnstile',
    'lessonId': 1,
  });

  await DBHelper.insert('students', {
    'name': 'Петр Петров',
    'status': 'absent',
    'lessonId': 1,
  });
}
