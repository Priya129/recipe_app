import 'package:flutter/material.dart';
import '../model/recipe.dart';
import '../view/recipe_view.dart';
import 'recipe_card.dart';

class RecipesGrid extends StatelessWidget {
  final List<Recipe> recipes;
  const RecipesGrid({Key? key, required this.recipes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: GridView.builder(
        scrollDirection: Axis.vertical,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 5.0,
          mainAxisSpacing: 10.0,
          childAspectRatio: 2/3,
        ),
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecipeDetailPage(recipe: recipes[index]),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: RecipeCard(recipe: recipes[index]),
              ),
            ),
          );
        },
      ),
    );
  }
}