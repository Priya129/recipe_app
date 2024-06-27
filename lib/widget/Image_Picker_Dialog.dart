import 'package:flutter/material.dart';
import '../global/app_colors.dart';

class ImagePickerDialog extends StatelessWidget {
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback onCancel;

  ImagePickerDialog({
    required this.onCamera,
    required this.onGallery,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.mainColor,
      shadowColor: AppColors.transparentColor,
      title: Text('Pick image of recipe', style: TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: Colors.white,

      ),),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.camera_alt, color: Colors.white,),
            title: Text('Camera', style: TextStyle(
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),),
            onTap: onCamera,
          ),
          ListTile(
            leading: Icon(Icons.photo_library, color: Colors.white,),
            title: Text('Gallery', style: TextStyle(
    fontSize: 16,
    fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
    color: Colors.white,) ),
            onTap: onGallery,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: Text('Cancel', style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            fontFamily: 'Poppins',
            color: Colors.white,),
        ),
        ),
      ],
    );
  }
}
