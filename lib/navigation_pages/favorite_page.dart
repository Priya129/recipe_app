import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../model/recipe.dart';

class ShoppingCartPage extends StatefulWidget {
  const ShoppingCartPage({Key? key}) : super(key: key);

  @override
  State<ShoppingCartPage> createState() => _ShoppingCartPage();
}

class _ShoppingCartPage extends State<ShoppingCartPage> {
  List<Recipe> recipes = [];
  late Dio dio;

  @override
  void initState() {
    super.initState();
    dio = Dio();
    fetchRecipes();
  }

  Future<void> fetchRecipes() async {
    final apiKey = '4078200b5bb10eb177d25a7066150966';
    final apiId = '43033629';
    final query = 'food';

    try {
      final encodedQuery = Uri.encodeComponent(query);
      final url =
          'https://api.edamam.com/search?q=$encodedQuery&app_id=$apiId&app_key=$apiKey';

      final response = await dio.get(url);

      if (response.statusCode == 200) {
        final jsonData = response.data;
        setState(() {
          recipes = (jsonData['hits'] as List)
              .map((hit) => Recipe.fromJson(hit['recipe']))
              .toList();
        });
      } else {
        throw Exception('Failed to load recipes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching recipes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(recipes[index].label),
            leading: recipes[index].image.isNotEmpty
                ? Image.network(recipes[index].image)
                : Placeholder(), // Placeholder image if no image is available
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 4),
                Text('Ingredients:'),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: recipes[index].ingredients.map((ingredient) {
                    return Text('- ${ingredient.text} (${ingredient.weight}g)');
                  }).toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
