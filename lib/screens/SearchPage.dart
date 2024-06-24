import 'package:flutter/material.dart';
import 'package:recipe_app/global/app_colors.dart';
import '../Api_Services/services_api.dart';
import '../model/ReceipeGrid.dart';
import '../model/recipe.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {


  final List<String> diets = [
    'Vegetarian', 'Vegan', 'Paleo', 'High-Fiber', 'High-Protein', 'Low-Carb',
    'Low-Fat', 'Low-Sodium', 'Low-Sugar', 'Alcohol-Free', 'Balanced', 'Immunity'
  ];
  final List<String> allergies = [
    'Gluten', 'Dairy', 'Eggs', 'Soy', 'Wheat', 'Fish', 'Shellfish', 'Tree Nuts', 'Peanuts'
  ];

  Map<String, bool> selectedDiets = {};
  Map<String, bool> selectedAllergies = {};
  TextEditingController searchController = TextEditingController();

  List<Recipe> searchResults = [];

  @override
  void initState() {
    super.initState();
    diets.forEach((diet) => selectedDiets[diet] = false);
    allergies.forEach((allergy) => selectedAllergies[allergy] = false);
  }

  Future<void> fetchRecipes() async {
    String query = searchController.text;
    List<String> selectedDietsList = selectedDiets.keys.where((key) => selectedDiets[key]!).toList();
    List<String> selectedAllergiesList = selectedAllergies.keys.where((key) => selectedAllergies[key]!).toList();

    try {
      List<Recipe> recipes = await ApiService().fetchRecipess(query, selectedDietsList, selectedAllergiesList);
      setState(() {
        searchResults = recipes;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.transparentColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Search your Recipes',
          style: TextStyle(
            fontSize: 20,
          fontFamily: 'Poppins',
          color: AppColors.mainColor
        ),),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.only(left: 10.0, right:10.0),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              backgroundColor:  AppColors.transparentColor,
              toolbarHeight: 500,
              snap: true,
              floating: true,
              title:Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                            ),
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: searchController,
                                      onSubmitted: (value) {
                                        fetchRecipes();
                                      },
                                      decoration: const InputDecoration(
                                        hintText: 'Search ',
                                        border: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: fetchRecipes,
                                    child: Center(
                                      child: Container(
                                        height: 60,
                                        width: 60,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(6),
                                          color: AppColors.mainColor,
                                        ),
                                        child: const Icon(
                                          Icons.search_rounded,
                                          size: 30,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Filters', style:
                        TextStyle(fontSize: 16,
                                fontFamily: 'Poppins',
                                color: AppColors.mainColor,
                            fontWeight: FontWeight.bold)),
                        Wrap(
                          spacing: 10.0,
                          runSpacing: 5.0,
                          children: diets.map((diet) {
                            return FilterChip(
                              selectedColor: Colors.deepOrange.shade50,
                              label: Text(diet),
                              selected: selectedDiets[diet]!,
                              onSelected: (bool selected) {
                                setState(() {
                                  selectedDiets[diet] = selected;
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                        const Text('Allergies', style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          color: AppColors.mainColor,
                        ),),
                        Wrap(
                          spacing: 10.0,
                          runSpacing: 5.0,
                          children: allergies.map((allergy) {
                            return FilterChip(
                              label: Text(allergy),
                              selectedColor: Colors.deepOrange.shade50,
                              selected: selectedAllergies[allergy]!,
                              onSelected: (bool selected) {
                                setState(() {
                                  selectedAllergies[allergy] = selected;
                                });
                              },
                            );
                          }).toList(),
                        ),

                      ],
                    ),
                  ),
                ],
              ) ,
            ),

            RecipeGrid(recipes: searchResults),
          ],
        ),
      ),
    );
  }
}
