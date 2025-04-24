import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clima - Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _cityController = TextEditingController();
  String _city = '';
  double? _temperature;
  String? _description;
  String? _icon;

  final String _url = 'https://api.openweathermap.org/data/2.5/weather';

  final String _apiKey = '7a2237174c84890f1fefff48058ca951';

  // Function to fetch weather data
  Future<void> _getWeather() async {
    final city = _cityController.text;
    if (city.isEmpty) return;

    final url = Uri.parse(
        '$_url?q=$city&appid=$_apiKey&units=metric'); // API Request URL
    print("Making API call to: $url");

    try {
      final response = await http.get(url);
      print("Response status: ${response.statusCode}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _temperature = data['main']['temp'];
          _description = data['weather'][0]['description'];
          _icon = data['weather'][0]['icon'];
        });
      } else {
        setState(() {
          _temperature = null;
          _description = 'City not found or error fetching data';
          _icon = null;
        });
      }
    } catch (e) {
      setState(() {
        _temperature = null;
        _description = 'Error: $e';
        _icon = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clima - Weather App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'Enter City',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _getWeather,
              child: const Text('Get Weather'),
            ),
            const SizedBox(height: 20.0),
            if (_temperature != null)
              Column(
                children: [
                  Text(
                    '${_temperature?.toStringAsFixed(1)}°C',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    _description ?? '',
                    style: const TextStyle(fontSize: 20.0),
                  ),
                  if (_icon != null)
                    Image.network(
                      'https://openweathermap.org/img/wn/$_icon@2x.png',
                      height: 100.0,
                    ),
                ],
              )
            else
              Text(
                _description ?? 'Enter a city to get weather info',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20.0),
              ),
          ],
        ),
      ),
    );
  }
}
