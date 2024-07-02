import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:recipe_app/global/app_colors.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VideoFeedScreen extends StatefulWidget {
  const VideoFeedScreen({super.key});

  @override
  VideoFeedScreenState createState() => VideoFeedScreenState();
}

class VideoFeedScreenState extends State<VideoFeedScreen> {
  Uint8List? file;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final Map<String, ChewieController> _chewieControllers = {};

  @override
  void dispose() {
    for (var controller in _chewieControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<ChewieController> _initializeChewieController(String videoUrl) async {
    var videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
    await videoPlayerController.initialize();
    return ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: true,
      looping: true,
    );
  }

  Future<Map<String, dynamic>> _fetchUserProfile(String userId) async {
    var userDoc = await FirebaseFirestore.instance.collection('user').doc(userId).get();
    return userDoc.data() ?? {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Video Feed',
          style: TextStyle(fontSize: 15, fontFamily: 'Poppins'),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.mainColor,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.mainColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('videos').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var videoDocs = snapshot.data!.docs;
          return PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: videoDocs.length,
            itemBuilder: (context, index) {
              var videoData = videoDocs[index];
              var videoUrl = videoData['videoUrl'];
              var description = videoData['description'];
              var postId = videoData['postId'];
              var likes = List<String>.from(videoData['likes']);
              var userId = videoData['userId'];
              var currentUserId = _firebaseAuth.currentUser?.uid ?? '';

              return FutureBuilder<ChewieController>(
                future: _chewieControllers.containsKey(postId)
                    ? Future.value(_chewieControllers[postId])
                    : _initializeChewieController(videoUrl).then((controller) {
                  _chewieControllers[postId] = controller;
                  return controller;
                }),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    var chewieController = snapshot.data!;
                    return FutureBuilder<Map<String, dynamic>>(
                      future: _fetchUserProfile(userId),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState == ConnectionState.done) {
                          var userProfile = userSnapshot.data!;
                          return GestureDetector(
                            onTap: () {
                              if (chewieController.isPlaying) {
                                chewieController.pause();
                              } else {
                                chewieController.play();
                              }
                            },
                            child: Stack(
                              children: [
                                Center(
                                  child: Chewie(
                                    controller: chewieController,
                                  ),
                                ),
                                Positioned(
                                  bottom: 20,
                                  left: 20,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundImage: NetworkImage(userProfile['imageUrl']),
                                            radius: 20,
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            userProfile['username'],
                                            style: const TextStyle(color: Colors.white, fontSize: 16),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        description,
                                        style: const TextStyle(color: Colors.white, fontSize: 16),
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              likes.contains(currentUserId) ? Icons.favorite : Icons.favorite_border,
                                              color: likes.contains(currentUserId) ? Colors.red : Colors.white,
                                            ),
                                            onPressed: () => likePost(postId, currentUserId, likes),
                                          ),
                                          Text(
                                            '${likes.length} likes',
                                            style: const TextStyle(color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return const Center(child: CircularProgressIndicator());
                        }
                      },
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> likePost(String postId, String uid, List likes) async {
    try {
      if (likes.contains(uid)) {
        await FirebaseFirestore.instance.collection('videos').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid])
        });
      } else {
        await FirebaseFirestore.instance.collection('videos').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid])
        });
      }
    } catch (err) {
      print('Error liking post: $err');
    }
  }
}
