import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:recipe_app/global/app_colors.dart';
import 'package:video_player/video_player.dart';

class VideoFeedScreen extends StatefulWidget {
  @override
  _VideoFeedScreenState createState() => _VideoFeedScreenState();
}

class _VideoFeedScreenState extends State<VideoFeedScreen> {
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  Map<String, VideoPlayerController> _videoControllers = {};

  @override
  void dispose() {
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<VideoPlayerController> _initializeVideoController(String videoUrl) async {
    var videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
    await videoController.initialize();
    return videoController;
  }

  void _playController(VideoPlayerController controller) {
    if (controller.value.isInitialized) {
      controller.play();
    }
  }

  void _pauseController(VideoPlayerController controller) {
    if (controller.value.isInitialized) {
      controller.pause();
    }
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
              var userId = _firebaseAuth.currentUser?.uid ?? '';

              return FutureBuilder<VideoPlayerController>(
                future: _videoControllers.containsKey(postId)
                    ? Future.value(_videoControllers[postId])
                    : _initializeVideoController(videoUrl).then((controller) {
                  _videoControllers[postId] = controller;
                  return controller;
                }),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    var videoController = snapshot.data!;
                    _playController(videoController);
                    return GestureDetector(
                      onTap: () {
                        if (videoController.value.isPlaying) {
                          _pauseController(videoController);
                        } else {
                          _playController(videoController);
                        }
                      },
                      child: Stack(
                        children: [
                          Center(
                            child: AspectRatio(
                              aspectRatio: videoController.value.aspectRatio,
                              child: VideoPlayer(videoController),
                            ),
                          ),
                          Positioned(
                            bottom: 20,
                            left: 10,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  description,
                                  style: const TextStyle(color: Colors.white, fontSize: 16),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        likes.contains(userId) ? Icons.favorite : Icons.favorite_border,
                                        color: likes.contains(userId) ? Colors.red : Colors.white,
                                      ),
                                      onPressed: () => likePost(postId, userId, likes),
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
