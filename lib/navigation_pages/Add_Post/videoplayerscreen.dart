import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recipe_app/global/app_colors.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

class UploadRecipeVideoScreen extends StatefulWidget {
  @override
  State<UploadRecipeVideoScreen> createState() => _UploadRecipeVideoScreenState();
}

class _UploadRecipeVideoScreenState extends State<UploadRecipeVideoScreen> {
  Uint8List? file;
  TextEditingController _descriptionController = TextEditingController();
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  VideoPlayerController? _videoPlayerController;

  @override
  void dispose() {
    _descriptionController.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    try {
      final pickedFile = await ImagePicker().pickVideo(
          source: ImageSource.gallery);
      if (pickedFile != null) {
        Uint8List pickedVideo = await pickedFile.readAsBytes();
        setState(() {
          file = pickedVideo;
          _videoPlayerController = VideoPlayerController.file(
              File(pickedFile.path))
            ..initialize().then((_) {
              setState(() {});
              _videoPlayerController?.play();
            });
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _uploadRecipe() async {
    if (file == null) {
      print('Please select a video');
      return;
    }

    try {
      String fileName = DateTime
          .now()
          .millisecondsSinceEpoch
          .toString();
      Reference storageRef = FirebaseStorage.instance.ref().child(
          'videos/$fileName');
      UploadTask uploadTask = storageRef.putData(file!);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      String uid = _firebaseAuth.currentUser?.uid ?? '';
      String postId = const Uuid().v1();

      await FirebaseFirestore.instance.collection('videos').doc(postId).set({
        'postId': postId,
        'description': _descriptionController.text,
        'videoUrl': downloadUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'userId': uid,
        'likes': [],
      });

      print('Video uploaded successfully');
    } catch (e) {
      print('Error uploading recipe: $e');
    }
  }

  Future<void> likePost(String postId, String uid, List likes) async {
    try {
      if (likes.contains(uid)) {
        await FirebaseFirestore.instance.collection('videos')
            .doc(postId)
            .update({
          'likes': FieldValue.arrayRemove([uid])
        });
      } else {
        await FirebaseFirestore.instance.collection('videos')
            .doc(postId)
            .update({
          'likes': FieldValue.arrayUnion([uid])
        });
      }
    } catch (err) {
      print('Error liking post: $err');
      throw err;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Upload new Video Recipe',
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
          GestureDetector(
            onTap: _uploadRecipe,
            child: const Padding(
              padding: EdgeInsets.only(right: 25.0),
              child: Text(
                "Post",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  color: AppColors.mainColor,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GestureDetector(
                onTap: _pickVideo,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.mainColor, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: file != null
                      ? _videoPlayerController != null &&
                      _videoPlayerController!.value.isInitialized
                      ? AspectRatio(
                    aspectRatio:
                    _videoPlayerController!.value.aspectRatio,
                    child: VideoPlayer(_videoPlayerController!),
                  )
                      : const Center(child: CircularProgressIndicator())
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_upload,
                          size: 50, color: AppColors.mainColor),
                      SizedBox(height: 8),
                      Text(
                        'Upload Video',
                        style: TextStyle(
                            color: AppColors.mainColor, fontSize: 16),
                      ),
                      Text(
                        'Click here to upload a video',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              maxLines: 3,
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
