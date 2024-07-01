import 'package:flutter/material.dart';
import 'package:recipe_app/global/app_colors.dart';
import '../../services/api_services/recipe_api_services.dart';
import '../../widget/recipe_grid.dart';
import '../../model/recipe.dart';


class DrinksPage extends StatefulWidget {
  const DrinksPage({Key? key}) : super(key: key);

  @override
  State<DrinksPage> createState() => _DrinksPageState();
}

class _DrinksPageState extends State<DrinksPage> {
  List<Recipe> recipes = [];
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    fetchRecipes();
  }

  Future<void> fetchRecipes() async {
    try {
      final fetchedRecipes = await apiService.fetchRecipes('drinks');
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
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 40.0, left: 30.0),
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
                      text: 'Drinks',
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
