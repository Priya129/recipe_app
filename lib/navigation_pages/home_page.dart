import 'package:flutter/material.dart';
import 'package:recipe_app/navigation_pages/profile_page.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import '../global/app_colors.dart';
import '../sidebar/sidebar_layout.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  List<Widget> screens = [
    ProfilePage(),
    ProfilePage(),
    ProfilePage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: SidebarLayout(
              selectedIndex: selectedIndex,
              onPressed: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
            ),
          ),
          Expanded(child: screens[selectedIndex]),
        ],
      ),
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
          Icon(Icons.shopping_cart_sharp, size: 26, color: Colors.white),
          Icon(Icons.favorite, size: 26, color: Colors.white),
          Icon(Icons.person, size: 26, color: Colors.white),
        ],
      ),
    );
  }
}
