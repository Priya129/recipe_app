import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recipe_app/screens/user_search_screen.dart';
import 'package:recipe_app/shimmer/shimmer_profile_screen.dart';
import '../Firebase_services/signin_screen.dart';
import '../global/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;
  final String currentUserId;

  const ProfileScreen({
    Key? key,
    this.userId,
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<DocumentSnapshot> userProfileFuture;
  bool isFollowing = false;
  bool showReels = true;
  bool showPhotos = false;
  List<String> userThumbnailVideos = [];
  List<String> userThumbnailPhotos = [];
  String? _username;
  String? _imageUrl;
  File? _pickedImageFile;

  @override
  void initState() {
    super.initState();
    userProfileFuture = _fetchUserProfile();
    _fetchUserVideosthumbnail();
    _fetchUserPostthumbnail();
  }

  Future<DocumentSnapshot> _fetchUserProfile() async {
    String uid = widget.userId ?? _auth.currentUser!.uid;
    DocumentSnapshot userProfile =
        await _firestore.collection('user').doc(uid).get();
    if (widget.userId != null) {
      DocumentSnapshot currentUserProfile =
          await _firestore.collection('user').doc(_auth.currentUser!.uid).get();
      List<String> followings =
          List<String>.from(currentUserProfile['followings']);
      setState(() {
        isFollowing = followings.contains(widget.userId);
      });
    }
    return userProfile;
  }

  Future<void> _fetchUserPostthumbnail() async {
    String uid = widget.userId ?? _auth.currentUser!.uid;
    QuerySnapshot querySnapshot = await _firestore
        .collection('recipes')
        .where('userId', isEqualTo: uid)
        .get();

    setState(() {
      userThumbnailPhotos =
          querySnapshot.docs.map((doc) => doc['imageUrl'] as String).toList();
    });
  }

  Future<void> _fetchUserVideosthumbnail() async {
    String uid = widget.userId ?? _auth.currentUser!.uid;
    QuerySnapshot querySnapshot = await _firestore
        .collection('videos')
        .where('userId', isEqualTo: uid)
        .get();

    setState(() {
      userThumbnailVideos = querySnapshot.docs
          .map((doc) => doc['thumbnailUrl'] as String)
          .toList();
    });
  }

  Future<void> _followUnfollowUser(String followeeUid) async {
    String currentUserUid = _auth.currentUser!.uid;

    await _firestore.runTransaction((transaction) async {
      DocumentReference currentUserRef =
          _firestore.collection('user').doc(currentUserUid);
      DocumentReference followeeRef =
          _firestore.collection('user').doc(followeeUid);

      DocumentSnapshot currentUserSnapshot =
          await transaction.get(currentUserRef);
      DocumentSnapshot followeeSnapshot = await transaction.get(followeeRef);

      if (!currentUserSnapshot.exists || !followeeSnapshot.exists) {
        throw Exception('User data not found');
      }

      List<String> currentFollowings =
          List<String>.from(currentUserSnapshot['followings']);
      List<String> followeeFollowers =
          List<String>.from(followeeSnapshot['followers']);

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

  Future<void> _signOut() async {
    await _auth.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    String uid = _auth.currentUser!.uid;

    if (_pickedImageFile != null) {
      final storageRef =
          FirebaseStorage.instance.ref().child('user_profiles/$uid.jpg');
      await storageRef.putFile(_pickedImageFile!);
      _imageUrl = await storageRef.getDownloadURL();
    }

    await _firestore.collection('user').doc(uid).update({
      'username': _username,
      'imageUrl': _imageUrl,
    }).then((_) {
      setState(() {
        userProfileFuture = _fetchUserProfile(); // Reload the profile data
      });
      Navigator.of(context).pop(); // Close the dialog
    }).catchError((error) {
      print("Error updating profile: $error");
    });
  }

  void _showEditProfileDialog(String currentUsername, String currentImageUrl) {
    _username = currentUsername; // Set the initial username
    _imageUrl = currentImageUrl; // Set the initial image URL

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Center(
                child: Text(
                  'Edit Profile',
                  style: TextStyle(
                      color: AppColors.mainColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins'),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      height: 40,
                      width: 400,
                      decoration: BoxDecoration(
                        color: AppColors.transparentColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: TextFormField(
                          initialValue: currentUsername,
                          decoration: const InputDecoration(
                              hintText: 'Username', border: InputBorder.none),
                          onChanged: (value) {
                            _username = value;
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _pickedImageFile != null
                      ? Image.file(_pickedImageFile!, height: 400, width: 400)
                      : currentImageUrl.isNotEmpty
                          ? Image.network(currentImageUrl,
                              height: 400, width: 400)
                          : Container(),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () async {
                      await _pickImage();
                      setState(() {});
                    },
                    child: Container(
                      height: 40,
                      width: 200,
                      decoration: BoxDecoration(
                        color: AppColors.mainColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(child:  Text('Change Profile Picture',
                        style:TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Poppins'
                        ) ,)),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel', style: TextStyle(
                    color: AppColors.mainColor,
                  ),),
                ),
                GestureDetector(
                  onTap: _updateProfile,
                  child: Container(
                    height: 30,
                    width: 60,
                    decoration: BoxDecoration(
                      color: AppColors.mainColor,
                      borderRadius: BorderRadius.circular(8)
                    ),
                    child: const Center(
                      child: Text('Save', style: TextStyle(
                        fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          color: Colors.white),),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
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
            fontSize: 16,
            color: AppColors.mainColor,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.search,
              color: AppColors.mainColor,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchUserScreen()),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert,
              color: AppColors.mainColor,
            ),
            onSelected: (String result) {
              if (result == 'Sign Out') {
                _signOut();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Sign Out',
                child: Text('Sign Out'),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: userProfileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
             return ShimmerProfileScreen();
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
          var numPosts =
              userThumbnailPhotos.length + userThumbnailVideos.length;

          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 46,
                          backgroundImage: NetworkImage(imageUrl),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              buildColumn(numPosts, 'Post'),
                              buildColumn(followings, 'Followings'),
                              buildColumn(followers, 'Followers'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            username,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            email,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            height: 40,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.mainColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: widget.userId == null ||
                                      widget.userId == widget.currentUserId
                                  ? TextButton(
                                      onPressed: () => _showEditProfileDialog(
                                          username, imageUrl),
                                      child: const Text(
                                        'Edit Profile',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
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
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      height: 40,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 100),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  showReels = true;
                                  showPhotos = false;
                                });
                              },
                              child: ImageIcon(
                                const AssetImage('assets/Images/reels.png'),
                                size: 25,
                                color: showReels
                                    ? Colors.deepOrange.shade400
                                    : Colors.grey,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  showPhotos = true;
                                  showReels = false;
                                });
                              },
                              child: ImageIcon(
                                const AssetImage('assets/Images/dashboard.png'),
                                size: 20,
                                color: showPhotos
                                    ? Colors.deepOrange.shade400
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Divider(
                      height: 1,
                      color: Colors.deepOrange.shade400,
                    ),
                    if (showReels)
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: _buildReelsGrid(),
                      ),
                    if (showPhotos)
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: _buildPostGrid(),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReelsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: userThumbnailVideos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemBuilder: (context, index) {
        return _buildThumbnailItem(userThumbnailVideos[index]);
      },
    );
  }

  Widget _buildThumbnailItem(String thumbnailUrl) {
    return GridTile(
      child: Stack(
        children: [
          Image.network(
            thumbnailUrl,
            fit: BoxFit.cover,
          ),
        ],
      ),
    );
  }

  Widget _buildPostGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: userThumbnailPhotos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemBuilder: (context, index) {
        return _buildPostThumbnailItem(userThumbnailPhotos[index]);
      },
    );
  }

  Widget _buildPostThumbnailItem(String thumbnailUrl) {
    return GridTile(
      child: Stack(
        children: [
          Image.network(
            thumbnailUrl,
            fit: BoxFit.cover,
          ),
        ],
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
        const SizedBox(height: 3),
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
