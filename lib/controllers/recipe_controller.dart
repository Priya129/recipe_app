import '../model/recipe.dart';
import '../services/api_services/recipe_api_services.dart';

class RecipeController {
  final ApiService _apiService = ApiService();

  Future<List<Recipe>> fetchRecipes(String query) async {
    return await _apiService.fetchRecipes(query);
  }

  Future<List<Recipe>> fetchRecipess(String query, List<String> diets, List<String> allergies) async {
    return await _apiService.fetchRecipess(query, diets, allergies);
  }
}
