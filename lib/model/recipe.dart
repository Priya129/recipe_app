import 'Nutrient.dart';
import 'ingredient.dart';

class Recipe {
  final String label;
  final String image;
  final double calories;
  final List<Ingredient> ingredients;
  final String url;
  final TotalNutrients? totalNutrients;

  Recipe({
    required this.label,
    required this.image,
    required this.ingredients,
    required this.calories,
    required this.url,
    this.totalNutrients,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    var ingredientsJson = json['ingredients'] as List;
    List<Ingredient> ingredientsList =
    ingredientsJson.map((i) => Ingredient.fromJson(i)).toList();

    return Recipe(
      label: json['label'],
      image: json['image'],
      calories: json['calories'],
      url: json['url'],
      ingredients: ingredientsList,
      totalNutrients: json['totalNutrients'] != null
          ? TotalNutrients.fromJson(json['totalNutrients'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'image': image,
      'calories': calories,
      'url': url,
      'ingredients': ingredients.map((i) => i.toJson()).toList(),
      'totalNutrients': totalNutrients?.toJson(),
    };
  }
}
