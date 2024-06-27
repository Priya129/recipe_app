import 'package:flutter/material.dart';
import 'package:recipe_app/global/app_colors.dart';
import '../Api_Services/services_api.dart';
import '../model/ReceipeGrid.dart';
import '../model/recipe.dart';
import '../widget/HowerIconWidget.dart';

class SearchPage extends StatefulWidget {
  final String initialQuery;
  const SearchPage({Key? key, this.initialQuery = ''}) : super(key: key);

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
  bool showFilters = false;

  @override
  void initState() {
    super.initState();

    diets.forEach((diet) => selectedDiets[diet] = false);
    allergies.forEach((allergy) => selectedAllergies[allergy] = false);
    searchController.text = widget.initialQuery;
    if (widget.initialQuery.isNotEmpty) {
      fetchRecipes();
    }
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
        leading: BackButton(
          color: AppColors.mainColor,
        ),
        backgroundColor: Colors.white,
        title: Text('Search your Recipes',
          style: TextStyle(
              fontSize: 15,
              fontFamily: 'Poppins',
              color: AppColors.mainColor
          ),),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
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
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    color: AppColors.mainColor,
                                  ),
                                  child: const Icon(
                                    Icons.search_rounded,
                                    size: 20,
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

                  SizedBox(width: 20,),
                  HoverIconButton(),
                ],
              ),
            ),
            SizedBox(height: 10,),
            GestureDetector(
              onTap: () {
                setState(() {
                  showFilters = !showFilters;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text('Filters & Allergies', style:
                        TextStyle(fontSize: 16,
                            fontFamily: 'Poppins',
                            color: AppColors.mainColor,
                            fontWeight: FontWeight.bold)),
                        Icon(
                          showFilters ? Icons.expand_less : Icons.expand_more,
                          color: AppColors.mainColor,
                        ),
                      ],
                    ),
                    Visibility(
                      visible: showFilters,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          const Text('Diets', style:
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
                ),
              ),
            ),
            Expanded(
              child: RecipeGrid(recipes: searchResults),
            ),
          ],
        ),
      ),
    );
  }
}
