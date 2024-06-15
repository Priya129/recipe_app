import 'package:flutter/material.dart';
import '../Api_Services/services_api.dart';
import '../model/ReceipeGrid.dart';
import '../model/recipe.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<Recipe> recipes = [];
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    fetchRecipes();
  }

  Future<void> fetchRecipes() async {
    try {
      final fetchedRecipes = await apiService.fetchRecipes('snacks');
      setState(() {
        recipes = fetchedRecipes;
      });
    } catch (e) {
      print('Error fetching recipes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: RecipeGrid(recipes: recipes),
      ),
    );
  }
}
