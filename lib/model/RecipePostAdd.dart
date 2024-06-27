import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../global/app_colors.dart';

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

    final recipeRef = FirebaseFirestore.instance.collection('recipes').doc(recipeId);

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
          if (snapshot.connectionState == ConnectionState.waiting) {
        //    return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error fetching data'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
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

              final likes = List<String>.from(recipe['likes'] ?? []);
              int likenumber = likes.length;
              final currentUserId = _firebaseAuth.currentUser?.uid;
              final isLiked = currentUserId != null && likes.contains(currentUserId);

              return FutureBuilder<Map<String, dynamic>?>(
                future: _getUserData(userId),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                   // return Center(child: CircularProgressIndicator());
                  }
                  if (userSnapshot.hasError) {
                    return ListTile(
                      title: Text('Error fetching user data'),
                    );
                  }

                  final userData = userSnapshot.data;
                  final profilePicUrl = userData?['imageUrl'] ?? "https://via.placeholder.com/300";
                  final username = userData?['username'] ?? "Unknown";

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
                            const Icon(Icons.more_vert),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Image.network(
                          recipe['imageUrl'] ?? "https://via.placeholder.com/300",
                          height: 300,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                isLiked ? Icons.favorite : Icons.favorite_border,
                                size: 30,
                                color: isLiked ? Colors.red : null,
                              ),
                              onPressed: () => _toggleLike(recipe.id, likes),
                            ),
                            const SizedBox(width: 10),
                            const ImageIcon(
                              AssetImage('assets/Images/chat-bubble.png'),
                              size: 20,
                              color: Colors.black,
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('$likenumber Likes'),

                        ),
                        Text("I love my recipe works"),
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
                            ...(recipe['subIngredients'] as List<dynamic>? ?? [])
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
