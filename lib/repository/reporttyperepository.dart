import 'package:autotelematic_new_app/data/API/api.dart';
import 'package:autotelematic_new_app/model/reporttypemodel.dart';
import 'package:autotelematic_new_app/res/api_endpoints.dart';
import 'package:dio/dio.dart';

class ReportTypeRepository {
  NetworkAPI networkAPI = NetworkAPI();
  Future<ReportTypeModel> getReportsTypeFromAPI(String userApiHashKey) async {
    try {
      Response response = await networkAPI.sendRequest.get(
          '${ApiEndpointUrls.baseURL}${ApiEndpointUrls.generateReportType}$userApiHashKey');

      return ReportTypeModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
