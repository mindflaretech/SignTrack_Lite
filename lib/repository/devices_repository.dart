import 'package:autotelematic_new_app/data/API/api.dart';
import 'package:autotelematic_new_app/model/devicesmodel.dart';
import 'package:autotelematic_new_app/res/api_endpoints.dart';
import 'package:dio/dio.dart';

class GetDevicesReposiory {
  NetworkAPI networkAPI = NetworkAPI();

  Future<List<DevicesModel>> getDevicesFromAPI(String userApiHashKey) async {
    List<DevicesModel> devicesList = [];
    try {
      Response response = await networkAPI.sendRequest.get(
          ApiEndpointUrls.baseURL +
              ApiEndpointUrls.getDevicesEndPoint +
              userApiHashKey);
      devicesList =
          (response.data as List).map((e) => DevicesModel.fromJson(e)).toList();

      return devicesList;
    } catch (e) {
      rethrow;
    }
  }
}
