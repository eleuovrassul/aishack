import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StudentUI extends StatefulWidget {
  const StudentUI({super.key});

  @override
  State<StudentUI> createState() => _StudentUIState();
}

class _StudentUIState extends State<StudentUI> {
  String? weatherSummary; // Саммари от Gemini
  String? weatherDetails; // Детали погоды
  bool isLoading = true; // Индикатор загрузки

  @override
  void initState() {
    super.initState();
    _fetchWeatherAndGenerateSummary();
  }

  // Метод для получения данных о погоде и генерации саммари
  Future<void> _fetchWeatherAndGenerateSummary() async {
    const apiKey = '6f0b1a2e24ab49fe994115916240804'; // Замените на ваш API-ключ
    const city = 'Aktobe'; // Укажите город
    final weatherUrl = Uri.parse('https://api.weatherapi.com/v1/current.json?key=$apiKey&q=$city');

    try {
      // Получение данных о погоде
      final weatherResponse = await http.get(weatherUrl);
      if (weatherResponse.statusCode == 200) {
        final weatherData = json.decode(weatherResponse.body);
        final condition = weatherData['current']['condition']['text'];
        final tempC = weatherData['current']['temp_c'];
        final windKph = weatherData['current']['wind_kph'];

        // Формируем текст для передачи в Gemini
        final weatherDetailsText =
            'Погода в $city: $condition, температура $tempC°C, скорость ветра $windKph км/ч.';
        setState(() {
          weatherDetails = weatherDetailsText;
        });

        // Генерация саммари через Gemini
        final summary = await generateSummary();
        setState(() {
          weatherSummary = summary;
          isLoading = false;
        });
      } else {
        setState(() {
          weatherDetails = 'Ошибка при получении данных о погоде.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        weatherDetails = 'Ошибка: $e';
        isLoading = false;
      });
    }
  }

  // Метод для генерации саммари с помощью Gemini API
  Future<String> generateSummary() async {
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
                'text':
                    'Ты помощник по опозданиям. Не задавай дополнительных вопросов. $weatherDetails Проанализируй погоду и напиши рекомендации по опозданиям. Например: если зима, то стоит выйти пораньше, если дождь, то стоит выйти пораньше. Не пиши ничего лишнего. Не выделяй текст жирным шрифтом.',
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Прогноз погоды и саммари',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple.shade700,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (weatherSummary != null)
                      Card(
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
                              const Text(
                                'Отчет:',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                weatherSummary!,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (weatherDetails != null)
                      Card(
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
                              const Text(
                                'Детали погоды:',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                weatherDetails!,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}