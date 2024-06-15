import 'package:flutter/material.dart';
import '../model/recipe.dart';

class RecipeDetailPage extends StatelessWidget {
  final Recipe recipe;

  RecipeDetailPage({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.label),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            recipe.image.isNotEmpty
                ? Image.network(recipe.image)
                : Placeholder(fallbackHeight: 200,
                fallbackWidth: double.infinity),
            SizedBox(height: 16),
            Text(
              'Source: ${recipe.source}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('Ingredients:', style: TextStyle(fontSize: 16,
                fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: recipe.ingredients.map((ingredient) {
                  return Text('- ${ingredient.text} (${ingredient.weight}g)');
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
