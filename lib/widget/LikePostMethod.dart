import 'package:flutter/material.dart';

class CommentWidget extends StatelessWidget {
  const CommentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: const Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(
              "https://firebasestorage.googleapis.com/v0/b/instagram-1368e.appspot.com/o/profilePics%2FyvgekcBjj1eQJWqfjiE5C36TVG62?alt=media&token=dcaf6ad5-2dc8-43ea-8b68-2ca80487ea7a"
            ),
          ),
        SizedBox(width: 20,),
        Text("Love your recipe"),
        ],
      ),

    );
  }
}
