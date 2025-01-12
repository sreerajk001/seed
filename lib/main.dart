import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(CropPredictionApp());
}

class CropPredictionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crop Prediction',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: CropPredictionForm(),
    );
  }
}

class CropPredictionForm extends StatefulWidget {
  @override
  _CropPredictionFormState createState() => _CropPredictionFormState();
}

class _CropPredictionFormState extends State<CropPredictionForm> {
  final TextEditingController nitrogenController = TextEditingController();
  final TextEditingController phosphorusController = TextEditingController();
  final TextEditingController potassiumController = TextEditingController();
  final TextEditingController temperatureController = TextEditingController();
  final TextEditingController phController = TextEditingController();
  final TextEditingController humidityController = TextEditingController();
  final TextEditingController rainfallController = TextEditingController();

  List<Map<String, String>> predictions = [];

  Future<void> fetchPredictions() async {
    final url = 'http://192.168.1.3:5000/predict';
    // Replace with your deployed API URL.
    final body = {
      'Nitrogen': int.parse(nitrogenController.text),
      'Phosphorus': int.parse(phosphorusController.text),
      'Potassium': int.parse(potassiumController.text),
      'Temperature': double.parse(temperatureController.text),
      'pH': double.parse(phController.text),
      'Humidity': int.parse(humidityController.text),
      'Rainfall': int.parse(rainfallController.text),
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          predictions = data.map<Map<String, String>>((item) {
            return {
              'crop': item['crop'] as String,
              'probability': item['probability'] as String,
            };
          }).toList();
        });

      } else {
        throw Exception('Failed to load predictions');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Crop Prediction')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nitrogenController,
              decoration: InputDecoration(labelText: 'Nitrogen'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: phosphorusController,
              decoration: InputDecoration(labelText: 'Phosphorus'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: potassiumController,
              decoration: InputDecoration(labelText: 'Potassium'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: temperatureController,
              decoration: InputDecoration(labelText: 'Temperature (°C)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: phController,
              decoration: InputDecoration(labelText: 'pH'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: humidityController,
              decoration: InputDecoration(labelText: 'Humidity (%)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: rainfallController,
              decoration: InputDecoration(labelText: 'Rainfall (mm)'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchPredictions,
              child: Text('Predict Crops'),
            ),
            SizedBox(height: 16),
            predictions.isNotEmpty
                ? Expanded(
              child: ListView.builder(
                itemCount: predictions.length,
                itemBuilder: (context, index) {
                  final crop = predictions[index]['crop']!;
                  final probability = predictions[index]['probability']!;
                  return ListTile(
                    title: Text(crop),
                    subtitle: Text('Probability: $probability'),
                  );
                },
              ),
            )
                : Text('No predictions yet.'),
          ],
        ),
      ),
    );
  }
}
