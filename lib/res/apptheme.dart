import 'package:flutter/material.dart';

class AppTheme {
  static const String logoPath = 'assets/images/splashsceen.png';
  static const String notConnectedPath = 'assets/images/notconnected.png';

  static double loginTextFieldWidth(BuildContext context) {
    return MediaQuery.of(context).size.width * 0.85;
  }

  static InputDecoration textFieldInputDecoration(String labelText, Icon icon) {
    return InputDecoration(
      isDense: true,
      prefixIcon: icon,
      labelStyle: const TextStyle(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
        fontSize: 14,
        color: Color(0xff000000),
      ),
      labelText: labelText,
      filled: true,
      border: InputBorder.none,
      disabledBorder: InputBorder.none,
    );
  }

  static TextStyle headTextStyle =
      const TextStyle(fontWeight: FontWeight.bold, fontSize: 14);
  static Image loadingImage = const Image(
      image: AssetImage('assets/images/loading.gif'), width: 100, height: 100);
}
