import sqlite3

# Подключение к базе данных SQLite
conn = sqlite3.connect('lib/school.db')
cursor = conn.cursor()

# Создание таблиц
cursor.execute('''
    CREATE TABLE IF NOT EXISTS lessons (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        day TEXT,
        subject TEXT,
        className TEXT,
        room TEXT
    )
''')

cursor.execute('''
    CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        status TEXT,
        lessonId INTEGER,
        FOREIGN KEY (lessonId) REFERENCES lessons (id)
    )
''')

cursor.execute('''
    CREATE TABLE IF NOT EXISTS schedule (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lessonId INTEGER,
        studentId INTEGER,
        isPresent INTEGER DEFAULT 0,
        FOREIGN KEY (lessonId) REFERENCES lessons (id),
        FOREIGN KEY (studentId) REFERENCES students (id)
    )
''')

# Заполнение таблицы lessons
cursor.executemany('''
    INSERT INTO lessons (day, subject, className, room) VALUES (?, ?, ?, ?)
''', [
    ('Monday', 'Math', '10A', '101'),
    ('Monday', 'Physics', '11B', '202')
])

# Заполнение таблицы students
cursor.executemany('''
    INSERT INTO students (name, status, lessonId) VALUES (?, ?, ?)
''', [
    ('Иван Иванов', 'near_turnstile', 1),
    ('Петр Петров', 'absent', 1),
    ('Анна Смирнова', 'in_class', 2)
])

# Заполнение таблицы schedule
cursor.executemany('''
    INSERT INTO schedule (lessonId, studentId, isPresent) VALUES (?, ?, ?)
''', [
    (1, 1, 0),
    (1, 2, 0),
    (2, 3, 1)
])

# Сохранение изменений и закрытие соединения
conn.commit()
conn.close()

print("Данные успешно добавлены в базу данных.")