import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../global/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(
          color: AppColors.mainColor,
        ),
        title: const Text(
          "UserProfile",
          style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              color: AppColors.mainColor),
        ),
        centerTitle: true,
      ),
      body: ListView(children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const CircleAvatar(
                        radius: 46,
                        backgroundImage: NetworkImage(
                            'https://imgs.search.brave.com/HSG3VktHKxqMQ6rsVyaGBSRriTR3deAEHNza2dRl1Ic/rs:fit:500:0:0/g:ce/aHR0cHM6Ly9zaG90/a2l0LmNvbS93cC1j/b250ZW50L3VwbG9h/ZHMvMjAyMS8wNi9D/b29sLXByb2ZpbGUt/cGljdHVyZS1wcm9m/ZXNzaW9uYWwuanBn'),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            buildColumn(12, 'Post'),
                            buildColumn(120, 'Followings'),
                            buildColumn(40, 'Followers'),
                          ],
                        ),
                      ),
                    ]),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Priya Chapagain',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: 3,),
                      Text(
                        'I am very much fond of cooking',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: 20,),
                      Container(
                          height: 40,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.mainColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: Text(
                              'Edit Profile',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ))
                    ],
                  ),
                ),
                SizedBox(height: 10,),
                Container(
                  width: double.infinity,
                  height: 40,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 100.0,right: 100.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        ImageIcon(AssetImage('assets/Images/reels.png'),
                          size: 25,
                          color: Colors.deepOrange.shade400,),
                        ImageIcon(AssetImage('assets/Images/dashboard.png'),
                          size: 20,
                          color: Colors.deepOrange.shade400,),

                      ],
                    ),
                  )

                ),
                Divider(
                  height: 1,
                  color: Colors.deepOrange.shade400,
                ),
              ]),
        ),
      ]),
    );
  }

  Widget buildColumn(int num, String label) {
    return Column(
      children: [
        Text(
          num.toString(),
          style: const TextStyle(
            color: Colors.black,
            fontFamily: 'Poppins',
            fontSize: 14,
          ),
        ),
        const SizedBox(
          height: 3,
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontFamily: 'Poppins',
            fontSize: 14,
          ),
        )
      ],
    );
  }
}


