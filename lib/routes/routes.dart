import 'package:flutter/material.dart';
import '../auth/signin_screen.dart';
import '../auth/signup_screen.dart';
import '../navigation_pages/home_page.dart';

class Routes {


  void navigateToSignUpScreen(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => SignUpScreen()),
    );
  }


  void navigateToHomePages(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  void navigateToSignInScreen(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
  }


  }




