import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/recipe_controller.dart';
import '../services/api_services/recipe_api_services.dart';
import '../model/recipe.dart';

final apiServiceProvider = Provider((ref) => ApiService());
final recipeControllerProvider = StateNotifierProvider<RecipeController, AsyncValue<List<Recipe>>>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return RecipeController(apiService);
});
