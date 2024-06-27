import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
class ImageRecognition extends StatefulWidget {
  @override
  _ImageRecognitionState createState() => _ImageRecognitionState();
}

class _ImageRecognitionState extends State<ImageRecognition> {
  File? _imageFile;
  List<Map<String, dynamic>>? _recognizedFoods;
  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    final String apiUrl = 'https://api.logmeal.com/v2/image/recognition/complete/v1.0';
    final String apiKey = 'dd626acb8da05e6f9ff33cef4f3d8d38fbfd6ca8';

    final uri = Uri.parse(apiUrl);
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $apiKey'
      ..files.add(await http.MultipartFile.fromPath('image', _imageFile!.path));

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final Map<String, dynamic> jsonResponse = json.decode(responseBody);

      if (jsonResponse['recognition_results'] != null) {
        setState(() {
          _recognizedFoods = List<Map<String, dynamic>>.from(jsonResponse['recognition_results']);
        });
      } else {
        setState(() {
          _recognizedFoods = [];
        });
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food Image Recognition'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: _uploadImage,
                child: Text('Recognize Image'),
              ),
              SizedBox(height: 20.0),
              if (_recognizedFoods != null) _buildFoodGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFoodGrid() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10.0,
          crossAxisSpacing: 10.0,
        ),
        itemCount: _recognizedFoods!.length,
        itemBuilder: (context, index) {
          final food = _recognizedFoods![index];
          final double probability = food['prob'];

          return Card(
            color: Colors.deepOrange.shade50,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    food['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 10,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: LinearProgressIndicator(
                      value: probability,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text('Probability: ${(probability * 100).toStringAsFixed(2)}%'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
