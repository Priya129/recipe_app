import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'comment_card.dart';
import '../global/app_colors.dart';

class CommentSection extends StatefulWidget {
  final String recipeId;

  const CommentSection({Key? key, required this.recipeId}) : super(key: key);

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  User? currentUser;
  String? profileImageUrl;
  String? username;
  String? userid;
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

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
      _scrollToBottom(); // Scroll to bottom when new comment is added
    }
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
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
                    // return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading comments'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No comments yet'));
                  }
                  WidgetsBinding.instance!.addPostFrameCallback((_) => _scrollToBottom());
                  return ListView.builder(
                    controller: _scrollController,
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
                alignment: isKeyboardVisible ? Alignment.center : Alignment.bottomCenter,
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
      ),
    );
  }
}
