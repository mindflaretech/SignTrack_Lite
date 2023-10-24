import 'package:autotelematic_new_app/model/user_signin_model.dart';
import 'package:autotelematic_new_app/repository/fcmtoken_repository.dart';
import 'package:autotelematic_new_app/utils/routes/routes_names.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class UserSessions {
  FcmTokenRepository fcmTokenRepository = FcmTokenRepository();
  void saveUserSession(UserLoginData userLogindata, String userID) async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString('status', userLogindata.status.toString());
    sp.setString('userid', userID);
    sp.setBool('notifications', true);
    sp.setString('userApiHash', userLogindata.userApiHash.toString());
  }

  void checkUserSession(BuildContext context) async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    final String? userAPIHashKey = sp.getString('userApiHash');

    if (userAPIHashKey == null || userAPIHashKey.isEmpty) {
      _navigateToLogin(context); // Call a private method to handle navigation
    } else {
      String? userApiHashKey = await UserSessions.getUserApiHash();
      FirebaseMessaging.instance.getToken().then((fcmToken) {
        fcmTokenRepository
            .fcmTokenSubmmissionApi(
                userApiHashKey.toString(), fcmToken.toString())
            .then((value) => print('Token Submitted ' + fcmToken.toString()));
      });
      _navigateToHome(context); // Call a private method to handle navigation
    }
  }

  static void removeSession() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    FirebaseMessaging.instance.deleteToken();
    sp.remove('userApiHash');
    sp.clear();
  }

  static Future<String?> getUserApiHash() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userApiHash');
  }

  // Private methods for navigation
  void _navigateToLogin(BuildContext context) {
    Navigator.pushReplacementNamed(context, RoutesName.login);
  }

  void _navigateToHome(BuildContext context) {
    Navigator.pushReplacementNamed(context, RoutesName.home);
  }
}
