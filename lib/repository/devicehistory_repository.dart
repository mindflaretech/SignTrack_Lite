import 'package:autotelematic_new_app/data/API/api.dart';
import 'package:autotelematic_new_app/model/devicehistorymodel.dart';
import 'package:autotelematic_new_app/res/api_endpoints.dart';
import 'package:dio/dio.dart';

class DeviceHistoryRepository {
  NetworkAPI networkAPI = NetworkAPI();

  Future<DeviceHistoryModel> getDeviceHisFromAPI(
      String userApiHashKey, String deviceHistoryDateTime) async {
    try {
      Response response = await networkAPI.sendRequest.get(
          '${ApiEndpointUrls.baseURL}${ApiEndpointUrls.getDeviceHistoryEndPoint}$userApiHashKey$deviceHistoryDateTime');

      return DeviceHistoryModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
