import 'package:flutter/material.dart';

import '../global/app_colors.dart';

class CommentBottomSheet extends StatefulWidget {
  final List<Map<String, dynamic>> comments;

  const CommentBottomSheet({
    Key? key,
    required this.comments,
  }) : super(key: key);

  @override
  _CommentBottomSheetState createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  late TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.comments.length,
              itemBuilder: (context, index) {
                final comment = widget.comments[index];
                return CommentCard(
                  username: comment['username'],
                  comment: comment['comment'],
                );
              },
            ),
          ),
          Divider(),
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(
                    "https://www.upwork.com/resources/how-to-guide-perfect-profile-picture"),
              ),
              SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: 'Add a comment...',
                    border: InputBorder.none,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.arrow_upward_outlined, color: AppColors.mainColor,),
                onPressed: () {
                  _submitComment(_commentController.text);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _submitComment(String commentText) {
    if (commentText.isNotEmpty) {
      widget.comments.add({
        'username': 'Current User', // Replace with actual username
        'comment': commentText,
      });
      _commentController.clear();
      setState(() {}); // Refresh the UI to reflect new comment
    }
  }
}

class CommentCard extends StatelessWidget {
  final String username;
  final String comment;

  const CommentCard({
    Key? key,
    required this.username,
    required this.comment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(
                "https://www.upwork.com/resources/how-to-guide-perfect-profile-picture"),
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                username,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 10),
              Text(
                comment,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
