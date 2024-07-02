import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:like_button/like_button.dart';
import '../global/app_colors.dart';
import '../shimmer/shimmer_recipe_post.dart';
import 'comment_screen.dart';

class RecipePost extends StatefulWidget {
  const RecipePost({super.key});

  @override
  State<RecipePost> createState() => _RecipePostState();
}

class _RecipePostState extends State<RecipePost> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  Map<String, bool> showDetailsMap = {};


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

  Future<void> _deletePost(String recipeId) async {
    final currentUserId = _firebaseAuth.currentUser?.uid;
    final recipeRef =
    FirebaseFirestore.instance.collection('recipes').doc(recipeId);
    final recipeSnapshot = await recipeRef.get();
    if (recipeSnapshot.exists) {
      final recipeData = recipeSnapshot.data();
      final String? postUserId = recipeData?['userId'];
      if (currentUserId != null && postUserId == currentUserId) {
        await recipeRef.delete();
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Unauthorized'),
            content: Text('You are not authorized to delete this post.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    }
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
        iconTheme: const IconThemeData(color: AppColors.mainColor),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('recipes').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              itemCount: 5, // Show a few placeholders
              itemBuilder: (context, index) => ShimmerRecipePost(), // Use shimmer widget here
            );
          }
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
              final recipeId = recipe.id;
              return FutureBuilder<Map<String, dynamic>?>(
                future: _getUserData(userId),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState ==
                      ConnectionState.waiting) {
                  }
                  if (userSnapshot.hasError) {
                    return const ListTile(
                      title: Text('Error fetching user data'),
                    );
                  }
                  final userData = userSnapshot.data;
                  final profilePicUrl = userData?['imageUrl'] ??
                      "https://via.placeholder.com/300";
                  final username = userData?['username'] ?? "Unknown";
                  final likes = List<String>.from(recipe['likes'] ?? []);
                  final currentUserId = _firebaseAuth.currentUser?.uid;
                  final isLiked = currentUserId != null &&
                      likes.contains(currentUserId);
                  final showDetails = showDetailsMap[recipeId] ?? false; // Default to true

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
                                const SizedBox(width: 12),
                                Text(
                                  username,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                            PopupMenuButton(
                              icon: Icon(Icons.more_vert),
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete Post'),
                                ),
                              ],
                              onSelected: (value) {
                                if (value == 'delete') {
                                  _deletePost(recipe.id);
                                }
                              },
                            ),
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
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (context) =>
                                          DraggableScrollableSheet(
                                            expand: false,
                                            initialChildSize: 0.8,
                                            minChildSize: 0.3,
                                            maxChildSize: 0.9,
                                            builder: (context, scrollController) =>
                                                CommentSection(recipeId: recipe.id),
                                          ),
                                    );
                                  },
                                  child: const ImageIcon(
                                    AssetImage(
                                        'assets/Images/chat-bubble.png'),
                                    size: 25,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
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
                                fontSize: 12,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            if (showDetails)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(recipe['description'] ?? "No description", style: const TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                  ),),
                                  const SizedBox(height: 5),
                                  const Text(
                                    "Ingredients:",
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  ...(recipe['subIngredients']
                                  as List<dynamic>? ??
                                      [])
                                      .map((ingredient) =>
                                      Text("• $ingredient", style: const TextStyle(
                                        fontSize: 12,
                                        fontFamily: 'Poppins'
                                      ),))
                                      .toList(),
                                  const SizedBox(height: 5),
                                ],
                              ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  showDetailsMap[recipeId] = !(showDetailsMap[recipeId] ?? false);
                                });
                              },
                              child: Text(
                                showDetails ? "show less" : "show more",
                                style: const TextStyle(
                                    color: AppColors.mainColor,
                                    fontSize: 12,// Adjust color as needed
                                    fontFamily: 'Poppins'),
                              ),
                            ),
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
