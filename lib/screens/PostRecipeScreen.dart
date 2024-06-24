import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/PostRecipe.dart';

class RecipeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipes'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('recipes').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No recipes found'));
          }
          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot doc) {
              Recipe recipe = Recipe.fromFirestore(doc);
              return ListTile(
                title: Text(recipe.name),
                subtitle: Text(recipe.description),
                trailing: Text(recipe.cuisine),
                onTap: () {
                  // Navigate to a detailed recipe view
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
