import 'ingredient.dart';

class Recipe {
  final String label;
  final String image;
  final String source;
  final List<Ingredient> ingredients;

  Recipe({
    required this.label,
    required this.image,
    required this.source,
    required this.ingredients,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    var ingredientsJson = json['ingredients'] as List;
    List<Ingredient> ingredientsList =
    ingredientsJson.map((i) => Ingredient.fromJson(i)).toList();

    return Recipe(
      label: json['label'],
      image: json['image'],
      source: json['source'],
      ingredients: ingredientsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'image': image,
      'source': source,
      'ingredients': ingredients.map((i) => i.toJson()).toList(),
    };
  }
}
