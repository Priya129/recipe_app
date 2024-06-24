import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recipe_app/global/app_colors.dart';

class UploadRecipeScreen extends StatefulWidget {
  @override
  State<UploadRecipeScreen> createState() => _UploadRecipeScreenState();
}

class _UploadRecipeScreenState extends State<UploadRecipeScreen> {
  Uint8List? file;
  double _cookingTime = 49;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _subIngredientsController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _caloriesController = TextEditingController();

  List<String> _subIngredients = [];
  String selectedCuisine = 'Chinese';

  @override
  void dispose() {
    _subIngredientsController.dispose();
    _descriptionController.dispose();
    _nameController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        Uint8List pickedImage = await pickedFile.readAsBytes();
        setState(() {
          file = pickedImage;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _uploadRecipe() async {
    if (file == null) {
      print('Please select an image');
      return;
    }

    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = FirebaseStorage.instance.ref().child('recipes/$fileName');
      UploadTask uploadTask = storageRef.putData(file!);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('recipes').add({
        'name': _nameController.text,
        'description': _descriptionController.text,
        'cookingTime': _cookingTime,
        'cuisine': selectedCuisine,
        'subIngredients': _subIngredients,
        'calories': _caloriesController.text,
        'imageUrl': downloadUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('Recipe uploaded successfully');
    } catch (e) {
      print('Error uploading recipe: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload new recipe'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // handle back button press
          },
        ),
        actions: [
          GestureDetector(
            onTap: _uploadRecipe,
            child: Padding(
              padding: const EdgeInsets.only(right: 18.0),
              child: const Text(
                "Post", style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                color: AppColors.mainColor,
              ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.mainColor, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: file != null
                    ? Image.memory(
                  file!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_upload, size: 50, color: AppColors.mainColor),
                    SizedBox(height: 8),
                    Text(
                      'Upload Cover',
                      style: TextStyle(color: AppColors.mainColor, fontSize: 16),
                    ),
                    Text(
                      'Click here for upload cover photo',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              maxLines: 3,
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Time to cook',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  '${_cookingTime.toInt()} min',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            Slider(
              activeColor: AppColors.mainColor,
              value: _cookingTime,
              min: 0,
              max: 120,

              onChanged: (value) {
                setState(() {
                  _cookingTime = value;
                });
              },
            ),
            SizedBox(height: 20),
            Text(
              'Select Cuisine',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 8.0,
              children: [
                ChoiceChip(
                  label: Text('Chinese'),
                  selected: selectedCuisine == 'Chinese',
                  selectedColor: Colors.deepOrange.shade300,
                  onSelected: (bool selected) {
                    setState(() {
                      selectedCuisine = 'Chinese';
                    });
                  },
                ),
                ChoiceChip(
                  label: Text('Bangla'),
                  selected: selectedCuisine == 'Bangla',
                  selectedColor: Colors.deepOrange.shade300,
                  onSelected: (bool selected) {
                    setState(() {
                      selectedCuisine = 'Bangla';
                    });
                  },
                ),
                ChoiceChip(
                  label: Text('Continental'),
                  selected: selectedCuisine == 'Continental',
                  selectedColor: Colors.deepOrange.shade300,
                  onSelected: (bool selected) {
                    setState(() {
                      selectedCuisine = 'Continental';
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            TextField(
              controller: _subIngredientsController,
              decoration: InputDecoration(
                labelText: 'Sub Ingredients',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),

                ),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  setState(() {
                    _subIngredients.add(value);
                    _subIngredientsController.clear();
                  });
                }
              },
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 8.0,
              children: _subIngredients
                  .map((ingredient) => Chip(
                label: Text(ingredient),
                onDeleted: () {
                  setState(() {
                    _subIngredients.remove(ingredient);
                  });
                },
              ))
                  .toList(),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _caloriesController,
              decoration: InputDecoration(
                labelText: 'Calories',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
