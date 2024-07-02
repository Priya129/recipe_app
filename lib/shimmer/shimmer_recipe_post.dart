import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerRecipePost extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        padding: EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 17,
                  backgroundColor: Colors.grey[300],
                ),
                SizedBox(width: 12),
                Container(
                  width: 100,
                  height: 20,
                  color: Colors.grey[300],
                ),
              ],
            ),
            SizedBox(height: 10),
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: Colors.grey[300],
              ),
            ),
            SizedBox(height: 10),
            Container(
              width: 200,
              height: 12,
              color: Colors.grey[300],
            ),
            SizedBox(height: 5),
            Container(
              width: 150,
              height: 12,
              color: Colors.grey[300],
            ),
            SizedBox(height: 5),
            Container(
              width: 100,
              height: 12,
              color: Colors.grey[300],
            ),
            SizedBox(height: 10),
            Divider(
              color: Colors.grey[300],
              thickness: 1,
            ),
          ],
        ),
      ),
    );
  }
}
