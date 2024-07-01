import 'package:flutter/material.dart';
import 'package:recipe_app/screens/upload_recipe_screen.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:recipe_app/screens/video_feed_screen.dart';
import 'package:recipe_app/screens/favorite_page.dart';
import 'package:recipe_app/screens/profile_screen.dart';
import '../global/app_colors.dart';
import '../screens/home_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedIndex = 0;
  final List<Widget> screens = [
    HomePage(),
    VideoFeedScreen(),
    UploadRecipeScreen(),
    FavoritesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: screens[selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: AppColors.mainColor,
        color: AppColors.mainColor,
        animationDuration: const Duration(milliseconds: 300),
        index: selectedIndex,
        onTap: (int index) {
          setState(() {
            selectedIndex = index;
          });
        },
        items: const <Widget>[
          Icon(Icons.home, size: 26, color: Colors.white),
          ImageIcon(AssetImage('assets/Images/reels.png'),
            size: 26,
            color: Colors.white,),
          ImageIcon(AssetImage('assets/Images/sign.png'),
            size: 26,
            color: Colors.white,),
          Icon(Icons.favorite, size: 26, color: Colors.white),
          Icon(Icons.person, size: 26, color: Colors.white),
        ],
      ),
    );
  }
}
