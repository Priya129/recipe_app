import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:like_button/like_button.dart';
import '../global/app_colors.dart';
import '../navigation_pages/Add_Post/CommentScreen.dart';

class RecipePost extends StatefulWidget {
  const RecipePost({Key? key}) : super(key: key);

  @override
  State<RecipePost> createState() => _RecipePostState();
}

class _RecipePostState extends State<RecipePost> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<Map<String, dynamic>?> _getUserData(String userId) async {
    try {
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('user').doc(userId).get();
      return userSnapshot.data() as Map<String, dynamic>?;
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  Future<void> _toggleLike(String recipeId, List<dynamic> likes) async {
    final currentUserId = _firebaseAuth.currentUser?.uid;
    if (currentUserId == null) return;
    final recipeRef =
        FirebaseFirestore.instance.collection('recipes').doc(recipeId);

    if (likes.contains(currentUserId)) {
      likes.remove(currentUserId);
    } else {
      likes.add(currentUserId);
    }

    await recipeRef.update({'likes': likes});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your Recipes',
          style: TextStyle(
            fontSize: 15,
            color: AppColors.mainColor,
            fontFamily: 'Poppins',
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.mainColor),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('recipes').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {}

          if (snapshot.hasError) {
            return Center(child: Text('Error fetching data'));
          }

          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No recipes found'));
          }

          final recipes = snapshot.data!.docs;

          return ListView.builder(
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              final userId = recipe['userId'] as String?;
              if (userId == null) {
                return ListTile(
                  title: Text('Invalid recipe data'),
                );
              }

              return FutureBuilder<Map<String, dynamic>?>(
                future: _getUserData(userId),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState ==
                      ConnectionState.waiting) {}

                  if (userSnapshot.hasError) {
                    return ListTile(
                      title: Text('Error fetching user data'),
                    );
                  }

                  final userData = userSnapshot.data;
                  final profilePicUrl = userData?['imageUrl'] ??
                      "https://via.placeholder.com/300";
                  final username = userData?['username'] ?? "Unknown";
                  final likes = List<String>.from(recipe['likes'] ?? []);
                  final currentUserId = _firebaseAuth.currentUser?.uid;
                  final isLiked =
                      currentUserId != null && likes.contains(currentUserId);

                  return Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 17,
                                  backgroundImage: NetworkImage(profilePicUrl),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  username,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                            Icon(Icons.more_vert),
                          ],
                        ),
                        SizedBox(height: 10),
                        GestureDetector(
                          onDoubleTap: () {
                            _toggleLike(recipe.id, likes);
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.network(
                                recipe['imageUrl'] ??
                                    "https://via.placeholder.com/300",
                                height: 300,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                              LikeButton(
                                onTap: (isLiked) async {
                                  _toggleLike(recipe.id, likes);
                                  return !isLiked;
                                },
                                isLiked: isLiked,
                                size: 80.0,
                                circleColor: const CircleColor(
                                    start: Colors.red, end: Colors.redAccent),
                                bubblesColor: const BubblesColor(
                                  dotPrimaryColor: Colors.red,
                                  dotSecondaryColor: Colors.redAccent,
                                ),
                                likeBuilder: (bool isLiked) {
                                  return Icon(
                                    Icons.favorite,
                                    color: isLiked
                                        ? Colors.transparent
                                        : Colors.transparent,
                                    size: 80.0,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    isLiked
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    size: 30,
                                    color: isLiked ? Colors.red : null,
                                  ),
                                  onPressed: () =>
                                      _toggleLike(recipe.id, likes),
                                ),
                                SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CommentScreen(recipeId: recipe.id),
                                      ),
                                    );
                                  },
                                  child: ImageIcon(
                                    AssetImage('assets/Images/chat-bubble.png'),
                                    size: 25,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 3,
                            ),
                            Text('${likes.length} likes'),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              recipe['name'] ?? "Recipe Name",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              "Ingredients:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ...(recipe['subIngredients'] as List<dynamic>? ??
                                    [])
                                .map((ingredient) => Text("• $ingredient"))
                                .toList(),
                          ],
                        ),
                        Divider(
                          color: Colors.grey.shade300,
                          thickness: 1,
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
