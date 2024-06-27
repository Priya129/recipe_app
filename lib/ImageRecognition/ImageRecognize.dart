import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RecognizeImageButton extends StatelessWidget {
  final Function() onPressed;
  const RecognizeImageButton({required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(Icons.search_rounded) ,
    );
  }
}
