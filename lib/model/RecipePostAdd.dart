import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import '../global/app_colors.dart';

class RecipePost extends StatefulWidget {
  const RecipePost({Key? key}) : super(key: key);

  @override
  State<RecipePost> createState() => _RecipePostState();
}

class _RecipePostState extends State<RecipePost> {
  bool islike = false;
  Future<Map<String, dynamic>?> _getUserData(String userId) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('user').doc(userId).get();
      return userSnapshot.data() as Map<String, dynamic>?;
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
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
        iconTheme: IconThemeData(color: AppColors.mainColor),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('recipes').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
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

              return FutureBuilder<Map<String, dynamic>?>(
                future: _getUserData(userId),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                   return Center(child: CircularProgressIndicator());
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
                                SizedBox(width: 12),
                                Text(
                                  username,
                                  style: TextStyle(
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
                        Image.network(
                          recipe['imageUrl'] ?? "https://via.placeholder.com/300",
                          height: 300,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: (){
                                islike = true;
                              },
                                child: Icon(
                                  islike ? Icons.favorite : Icons.favorite_border,
                                  color: islike? Colors.red : Colors.deepOrange,
                                  size: 25
                                ),
                            ),
                            SizedBox(width: 10),
                            ImageIcon(
                              AssetImage('assets/Images/chat-bubble.png'),
                              size: 20,
                              color: Colors.black,
                            ),
                          ],
                        ),
                        Text('1 Likes'),
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
