import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../global/app_colors.dart';
import '../screens/SearchPage.dart';
import '../widget/Image_Picker_Dialog.dart';

class ImageRecognition extends StatefulWidget {
  @override
  _ImageRecognitionState createState() => _ImageRecognitionState();
}

class _ImageRecognitionState extends State<ImageRecognition> {
  File? _imageFile;
  List<Map<String, dynamic>>? _recognizedFoods;

  Future<void> _getImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    final String apiUrl = 'https://api.logmeal.com/v2/image/recognition/complete/v1.0';
    final String apiKey = 'c27aa9ccd21d4f7dabe9f4fbfe30eac8468ebc37';

    try {
      FormData formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(_imageFile!.path),
      });

      Dio dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $apiKey';

      final response = await dio.post(apiUrl, data: formData);
      final Map<String, dynamic> jsonResponse = response.data;

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

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ImagePickerDialog(
          onCamera: () {
            _getImage(ImageSource.camera);
            Navigator.of(context).pop();
          },
          onGallery: () {
            _getImage(ImageSource.gallery);
            Navigator.of(context).pop();
          },
          onCancel: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.transparentColor,
      appBar: AppBar(
        leading: BackButton(
          color: AppColors.mainColor,
        ),
        title: Text(
          'Food Image Recognition',
          style: TextStyle(
            color: AppColors.mainColor,
            fontSize: 15,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              if (_imageFile != null)
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    height: 400,
                    width: 500,
                    alignment: Alignment.center,
                    child: Image.file(_imageFile!),
                  ),
                ),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 20.0),
                  Container(
                    height: 40,
                    width: 60,
                    decoration: BoxDecoration(
                      color: AppColors.mainColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      onPressed: _showImagePickerDialog,
                      icon: Icon(Icons.camera_enhance_sharp, color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 10.0),
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.mainColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      onPressed: _uploadImage,
                      icon: const Text(
                        'Recognize Image',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              if (_recognizedFoods != null) _buildFoodList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFoodList() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: _recognizedFoods!.length,
        itemBuilder: (context, index) {
          final food = _recognizedFoods![index];
          final double probability = food['prob'];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchPage(
                    initialQuery: food['name'],
                  ),
                ),
              );
            },
            child: Card(
              color: Colors.deepOrange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food['name'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
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
                    Text(
                      'Probability: ${(probability * 100).toStringAsFixed(2)}%',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
