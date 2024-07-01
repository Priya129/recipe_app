import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../global/app_colors.dart';

class SearchUserScreen extends StatefulWidget {
  @override
  _SearchUserScreenState createState() => _SearchUserScreenState();
}

class _SearchUserScreenState extends State<SearchUserScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _searchResults = [];
  bool _isLoading = false;
  String _errorMessage = '';

  void _searchUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      String searchText = _searchController.text;
      print('Searching for: $searchText'); // Debugging information

      QuerySnapshot querySnapshot = await _firestore.collection('user')
          .where('username', isGreaterThanOrEqualTo: searchText)
          .where('username', isLessThanOrEqualTo: searchText + '\uf8ff')
          .get();

      print('Query results: ${querySnapshot.docs}'); // Debugging information

      setState(() {
        _searchResults = querySnapshot.docs;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred while searching: $e';
      });
      print('Error: $e'); // Debugging information
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _followUnfollowUser(String followeeUid) async {
    String currentUserUid = FirebaseAuth.instance.currentUser!.uid;

    await _firestore.runTransaction((transaction) async {
      DocumentReference currentUserRef = _firestore.collection('user').doc(currentUserUid);
      DocumentReference followeeRef = _firestore.collection('user').doc(followeeUid);

      DocumentSnapshot currentUserSnapshot = await transaction.get(currentUserRef);
      DocumentSnapshot followeeSnapshot = await transaction.get(followeeRef);

      if (!currentUserSnapshot.exists || !followeeSnapshot.exists) {
        throw Exception('User data not found');
      }

      List<String> currentFollowings = List<String>.from(currentUserSnapshot['following']);
      List<String> followeeFollowers = List<String>.from(followeeSnapshot['followers']);

      if (currentFollowings.contains(followeeUid)) {
        currentFollowings.remove(followeeUid);
        followeeFollowers.remove(currentUserUid);
      } else {
        currentFollowings.add(followeeUid);
        followeeFollowers.add(currentUserUid);
      }

      transaction.update(currentUserRef, {'following': currentFollowings});
      transaction.update(followeeRef, {'followers': followeeFollowers});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search users...',
            border: InputBorder.none,
          ),
          onChanged: (value) {
            _searchUsers();
          },
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(child: Text(_errorMessage))
          : ListView.builder(
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          var userData = _searchResults[index].data() as Map<String, dynamic>;
          String userId = _searchResults[index].id;
          String username = userData['username'] ?? 'Unknown';
          String imageUrl = userData['imageUrl'] ?? '';
          bool isFollowing = (userData['followers'] as List<dynamic>)
              .contains(FirebaseAuth.instance.currentUser!.uid);

          return ListTile(
            leading: CircleAvatar(
              backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
              child: imageUrl.isEmpty ? Icon(Icons.person) : null,
            ),
            title: Text(username),
            trailing: Container(
              height: 40,
              width: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.mainColor,
              ),
              child: GestureDetector(
                onTap: (){
                  _followUnfollowUser(userId);
                },
                  child: Center(
                    child: Text(isFollowing ? 'Unfollow' : 'Follow', style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                        fontSize: 12,
                    ),),
                  ), ),
            ),
          );
        },
      ),
    );
  }
}
