import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:recipe_app/screens/SplashScreen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(

      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

/*
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe Search',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RecipeSearchPage(),
    );
  }
}

class RecipeSearchPage extends StatefulWidget {
  @override
  _RecipeSearchPageState createState() => _RecipeSearchPageState();
}

class _RecipeSearchPageState extends State<RecipeSearchPage> {
  final _formKey = GlobalKey<FormState>();
  String? _ingredientRange;
  List<String> _dietLabels = [];
  List<String> _healthLabels = [];
  String? _cuisineType;
  String? _mealType;

  final List<String> dietOptions = ['high-protein', 'low-carb', 'low-fat', 'low-sodium'];
  final List<String> healthOptions = ['egg-free', 'fish-free', 'fodmap-free', 'gluten-free'];
  final List<String> cuisineOptions = ['American', 'Asian', 'British'];
  final List<String> mealOptions = ['Dinner', 'Lunch', 'Snack', 'Teatime'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipe Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Ingredient Range (e.g., 5-8)'),
                onSaved: (value) {
                  _ingredientRange = value;
                },
              ),
              SizedBox(height: 16),
              Text('Diet Labels'),
              ...dietOptions.map((option) {
                return CheckboxListTile(
                  title: Text(option),
                  value: _dietLabels.contains(option),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _dietLabels.add(option);
                      } else {
                        _dietLabels.remove(option);
                      }
                    });
                  },
                );
              }).toList(),
              SizedBox(height: 16),
              Text('Health Labels'),
              ...healthOptions.map((option) {
                return CheckboxListTile(
                  title: Text(option),
                  value: _healthLabels.contains(option),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _healthLabels.add(option);
                      } else {
                        _healthLabels.remove(option);
                      }
                    });
                  },
                );
              }).toList(),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Cuisine Type'),
                items: cuisineOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _cuisineType = newValue;
                  });
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Meal Type'),
                items: mealOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _mealType = newValue;
                  });
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _searchRecipes,
                child: Text('Search'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _searchRecipes() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String apiUrl = 'https://api.edamam.com/search';
      String appId = '43033629';
      String appKey = '4078200b5bb10eb177d25a7066150966';
      Map<String, String> queryParameters = {
        'q': 'recipe',
        'app_id': appId,
        'app_key': appKey,
        'from': '0',
        'to': '10',
        if (_ingredientRange != null) 'ingr': _ingredientRange!,
        if (_dietLabels.isNotEmpty) 'diet': _dietLabels.join(','),
        if (_healthLabels.isNotEmpty) 'health': _healthLabels.join(','),
        if (_cuisineType != null) 'cuisineType': _cuisineType!,
        if (_mealType != null) 'mealType': _mealType!,
      };

      try {
        Dio dio = Dio();
        Response response = await dio.get(apiUrl,
            queryParameters: queryParameters);

        if (response.statusCode == 200) {
          print(response.data);
        } else {
          print('Error: ${response.statusCode}');
        }
      } catch (e) {
        print('Error: $e');
      }
    }
  }
}
*/
