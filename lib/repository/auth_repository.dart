import 'package:autotelematic_new_app/data/API/api.dart';
import 'package:autotelematic_new_app/model/user_signin_model.dart';
import 'package:autotelematic_new_app/res/api_endpoints.dart';

import 'package:dio/dio.dart';

class AuthRepository {
  NetworkAPI networkAPI = NetworkAPI();

  Future<UserLoginData> signinAPI(Map<String, dynamic> data) async {
    try {
      UserLoginData userLoginData = UserLoginData();
      Response response = await networkAPI.sendRequest.post(
          ApiEndpointUrls.baseURL + ApiEndpointUrls.loginEndPoint,
          data: data);

      userLoginData = UserLoginData.fromJson(response.data);
      return userLoginData;
    } catch (e) {
      rethrow;
    }
  }
}
