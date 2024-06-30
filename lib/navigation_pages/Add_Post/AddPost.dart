import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recipe_app/global/app_colors.dart';
import 'package:recipe_app/navigation_pages/Add_Post/videoplayerscreen.dart';
import 'package:uuid/uuid.dart';

class UploadRecipeScreen extends StatefulWidget {
  @override
  State<UploadRecipeScreen> createState() => _UploadRecipeScreenState();
}

class _UploadRecipeScreenState extends State<UploadRecipeScreen> {
  Uint8List? file;
  double _cookingTime = 49;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _subIngredientsController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final List<String> _subIngredients = [];
  String selectedCuisine = 'Asian';
  List<String> cuisines = ['American', 'Asian', 'British', 'Caribbean', 'Central Europe', 'Chinese', 'Eastern Europe', 'French', 'Indian', 'Italian', 'Japanese', 'Kosher', 'Mediterranean', 'Mexican', 'Middle Eastern', 'Nordic', 'South American', 'South East Asian'];

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
      final pickedFile =
      await ImagePicker().pickImage(source: ImageSource.gallery);
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
      Reference storageRef =
      FirebaseStorage.instance.ref().child('recipes/$fileName');
      UploadTask uploadTask = storageRef.putData(file!);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      String uid = _firebaseAuth.currentUser?.uid ?? '';
      String postId = const Uuid().v1();

      await FirebaseFirestore.instance.collection('recipes').doc(postId).set({
        'postId': postId,
        'name': _nameController.text,
        'description': _descriptionController.text,
        'cookingTime': _cookingTime,
        'cuisine': selectedCuisine,
        'subIngredients': _subIngredients,
        'calories': _caloriesController.text,
        'imageUrl': downloadUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'userId': uid,
        'likes': [],
      });

      print('Recipe uploaded successfully');
    } catch (e) {
      print('Error uploading recipe: $e');
    }
  }

  Future<void> likePost(String postId, String uid, List likes) async {
    try {
      if (likes.contains(uid)) {
        await FirebaseFirestore.instance.collection('recipes').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid])
        });
      } else {
        await FirebaseFirestore.instance.collection('recipes').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid])
        });
      }
    } catch (err) {
      print('Error liking post: $err');
      throw err;
    }
  }

  void _navigateToAddVideo() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>  UploadRecipeVideoScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Upload new recipe',
          style: TextStyle(fontSize: 15, fontFamily: 'Poppins'),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.mainColor,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.mainColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Upload Recipe') {
                _uploadRecipe();
              } else if (value == 'Add Video') {
                _navigateToAddVideo();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'Upload Recipe',
                  child: Text(
                    'Post',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      color: AppColors.mainColor,
                    ),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'Add Video',
                  child: Text(
                    'Add New Video',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      color: AppColors.mainColor,
                    ),
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 300,
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
                      Icon(Icons.cloud_upload,
                          size: 50, color: AppColors.mainColor),
                      SizedBox(height: 8),
                      Text(
                        'Upload Cover',
                        style: TextStyle(
                            color: AppColors.mainColor, fontSize: 16),
                      ),
                      Text(
                        'Click here to upload cover photo',
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
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Select Cuisine',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    DropdownButton<String>(
                      value: selectedCuisine,
                      onChanged: (newValue) {
                        setState(() {
                          selectedCuisine = newValue!;
                        });
                      },
                      items: cuisines.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
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
                    .map(
                      (ingredient) => Chip(
                    label: Text(ingredient),
                    onDeleted: () {
                      setState(() {
                        _subIngredients.remove(ingredient);
                      });
                    },
                  ),
                )
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
      ),
    );
  }
}


