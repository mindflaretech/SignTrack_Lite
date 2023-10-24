import 'package:autotelematic_new_app/data/API/api.dart';
import 'package:autotelematic_new_app/model/alertypelistmodel.dart';
import 'package:autotelematic_new_app/res/api_endpoints.dart';
import 'package:dio/dio.dart';

class AlertListRepository {
  NetworkAPI networkAPI = NetworkAPI();

  Future<AlertsListModel> alertsTypeListApi(String userApiHashKey) async {
    try {
      Response response = await networkAPI.sendRequest.get(
          '${ApiEndpointUrls.baseURL}${ApiEndpointUrls.getAlertsTypeList}$userApiHashKey');
      print(response.data);
      return AlertsListModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> changeAlertValueApi(
      String userApiHashKey, String alertID, String activationStatus) async {
    try {
      Response response = await networkAPI.sendRequest.get(
          '${ApiEndpointUrls.baseURL}${ApiEndpointUrls.changeAlertValue}$userApiHashKey&id=$alertID&active=$activationStatus');

      print(response.data);
      //return response = AlertsListModel.fromJson(response);
    } catch (e) {
      print('the error is' + e.toString());
      rethrow;
    }
  }
}
