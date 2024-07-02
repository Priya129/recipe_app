import 'package:dio/dio.dart';
import '../../model/recipe.dart';

class ApiService {
  final Dio _dio = Dio();
  final String apiKey = '3929a7e39517cf6fbd96edd5f3c109fb';
  final String apiId = '6a592252';

  Future<List<Recipe>> fetchRecipess(String query, List<String> diets, List<String> allergies) async {
    String dietParams = diets.map((diet) => diet.toLowerCase()).join(',');
    String allergyParams = allergies.map((allergy) => allergy.toLowerCase().replaceAll('-', '_')).join(',');

    String apiUrl = 'https://api.edamam.com/api/recipes/v2?q=$query&app_id=$apiId&app_key=$apiKey&type=any&healthLabels=$dietParams';

    try {
      Response response = await _dio.get(apiUrl);
      if (response.statusCode == 200) {
        final jsonData = response.data;
        if (jsonData != null && jsonData['hits'] != null) {
          return (jsonData['hits'] as List).map((hit) => Recipe.fromJson(hit['recipe'])).toList();
        } else {
          throw Exception('Invalid response data');
        }
      } else {
        throw Exception('Failed to load recipes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching recipes: $e');
      throw Exception('Error fetching recipes: $e');
    }
  }

  Future<List<Recipe>> fetchRecipes(String query) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      final url = 'https://api.edamam.com/search?q=$encodedQuery&app_id=$apiId&app_key=$apiKey';

      final response = await _dio.get(url);
      if (response.statusCode == 200) {
        final jsonData = response.data;
        return (jsonData['hits'] as List).map((hit) => Recipe.fromJson(hit['recipe'])).toList();
      } else {
        throw Exception('Failed to load recipes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching recipes: $e');
      throw e;
    }
  }
}
