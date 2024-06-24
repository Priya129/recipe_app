import 'package:flutter/material.dart';
import 'package:recipe_app/global/app_colors.dart';
import '../../Api_Services/services_api.dart';
import '../../model/RecipeSearchGrid.dart';
import '../../model/recipe.dart';


class FoodPage extends StatefulWidget {
  const FoodPage({Key? key}) : super(key: key);

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  List<Recipe> recipes = [];
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    fetchRecipes();
  }

  Future<void> fetchRecipes() async {
    try {
      final fetchedRecipes = await apiService.fetchRecipes('dinner');
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 30.0, left: 30.0),
              child: RichText(
                text: TextSpan(
                  text: 'Simply Recipe for ',
                  style: const TextStyle(
                    color: Colors.black,
                    fontFamily: 'Poppins',
                    fontSize: 18,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Food',
                      style: TextStyle(
                        color: AppColors.mainColor,
                        fontFamily: 'Poppins',

                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: RecipesGrid(recipes: recipes),
            ),
          ],
        ),
      ),
    );
  }
}
