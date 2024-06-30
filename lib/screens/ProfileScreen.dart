import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../global/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;

  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<DocumentSnapshot> userProfileFuture;
  bool isFollowing = false;

  @override
  void initState() {
    super.initState();
    // Fetch the user profile details
    userProfileFuture = _fetchUserProfile();
  }

  Future<DocumentSnapshot> _fetchUserProfile() async {
    String uid = widget.userId ?? _auth.currentUser!.uid;
    DocumentSnapshot userProfile = await _firestore.collection('user').doc(uid).get();
    if (widget.userId != null) {
      // Check if the current user is following this profile
      DocumentSnapshot currentUserProfile = await _firestore.collection('user').doc(_auth.currentUser!.uid).get();
      List<String> followings = List<String>.from(currentUserProfile['followings']);
      setState(() {
        isFollowing = followings.contains(widget.userId);
      });
    }
    return userProfile;
  }

  Future<void> _followUnfollowUser(String followeeUid) async {
    String currentUserUid = _auth.currentUser!.uid;

    await _firestore.runTransaction((transaction) async {
      DocumentReference currentUserRef = _firestore.collection('user').doc(currentUserUid);
      DocumentReference followeeRef = _firestore.collection('user').doc(followeeUid);

      DocumentSnapshot currentUserSnapshot = await transaction.get(currentUserRef);
      DocumentSnapshot followeeSnapshot = await transaction.get(followeeRef);

      if (!currentUserSnapshot.exists || !followeeSnapshot.exists) {
        throw Exception('User data not found');
      }

      List<String> currentFollowings = List<String>.from(currentUserSnapshot['followings']);
      List<String> followeeFollowers = List<String>.from(followeeSnapshot['followers']);

      if (currentFollowings.contains(followeeUid)) {
        currentFollowings.remove(followeeUid);
        followeeFollowers.remove(currentUserUid);
        setState(() {
          isFollowing = false;
        });
      } else {
        currentFollowings.add(followeeUid);
        followeeFollowers.add(currentUserUid);
        setState(() {
          isFollowing = true;
        });
      }

      transaction.update(currentUserRef, {'followings': currentFollowings});
      transaction.update(followeeRef, {'followers': followeeFollowers});
    });
  }

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
      body: FutureBuilder<DocumentSnapshot>(
        future: userProfileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('User profile not found'));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;
          var username = userData['username'] ?? 'Unknown';
          var email = userData['email'] ?? 'Unknown';
          var imageUrl = userData['imageUrl'] ?? '';
          var followings = (userData['followings'] as List<dynamic>).length;
          var followers = (userData['followers'] as List<dynamic>).length;
          var posts = 12; // Replace with the actual post count if available

          return ListView(children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CircleAvatar(
                            radius: 46,
                            backgroundImage: NetworkImage(imageUrl),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                buildColumn(posts, 'Post'),
                                buildColumn(followings, 'Followings'),
                                buildColumn(followers, 'Followers'),
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
                            username,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                            ),
                          ),
                          SizedBox(height: 3,),
                          Text(
                            email,
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
                              child: Center(
                                child: widget.userId == null
                                    ? const Text(
                                  'Edit Profile',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )
                                    : TextButton(
                                  onPressed: () {
                                    _followUnfollowUser(widget.userId!);
                                  },
                                  child: Text(
                                    isFollowing ? 'Unfollow' : 'Follow',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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
          ]);
        },
      ),
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
