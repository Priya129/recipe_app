import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../SocialHandle/CommentCard.dart';
import '../../global/app_colors.dart';

class CommentScreen extends StatefulWidget {
  final String recipeId;

  const CommentScreen({Key? key, required this.recipeId}) : super(key: key);

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  User? currentUser;
  String? profileImageUrl;
  String? username;
  String? userid;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUser = user;
      });

      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('user').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          profileImageUrl = userDoc['imageUrl'];
          username = userDoc['username'];
          userid = user.uid;
        });
      }
    }
  }

  Future<void> _submitComment() async {
    if (_commentController.text.isNotEmpty) {
      String commentId = const Uuid().v1();
      await FirebaseFirestore.instance
          .collection('recipes')
          .doc(widget.recipeId)
          .collection('comments')
          .doc(commentId)
          .set({
        'text': _commentController.text,
        'imageUrl': profileImageUrl,
        'username': username,
        'userid': userid,
        'commentId': commentId,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print("Comment Submitted: ${_commentController.text}");
      _commentController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.transparentColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: const BackButton(
          color: AppColors.mainColor,
        ),
        title: const Text("Comments", style: TextStyle(
          color: AppColors.mainColor,
          fontFamily: 'Poppins',
          fontSize: 16,
        ),),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Stack(
          children: [
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('recipes')
                  .doc(widget.recipeId)
                  .collection('comments')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading comments'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No comments yet'));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var commentData = snapshot.data!.docs[index];
                    return CommentCard(
                      username: commentData['username'],
                      comment: commentData['text'],
                      profileImageUrl: commentData['imageUrl'],
                    );
                  },
                );
              },
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(
                            profileImageUrl ?? "https://www.example.com/valid_default_profile_image.png",
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            decoration: const InputDecoration(
                              hintStyle: TextStyle(color: Colors.black45),
                              hintText: "Leave a comment...",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _submitComment,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(120),
                              color: AppColors.mainColor,
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(3.0),
                              child: Icon(
                                color: Colors.white,
                                Icons.arrow_upward,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
