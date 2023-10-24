import 'package:autotelematic_new_app/data/API/api.dart';
import 'package:autotelematic_new_app/model/osmmodel.dart';
import 'package:autotelematic_new_app/res/api_endpoints.dart';

class OsmAddressRepository {
  NetworkAPI networkAPI = NetworkAPI();

  Future<OsmAddressModel> getOsmAddressApi(String latlngEndPoint) async {
    try {
      dynamic response = await networkAPI.sendRequest.get(
          ApiEndpointUrls.osmbaseURL +
              ApiEndpointUrls.osmAddressEndPoint +
              latlngEndPoint);
      //  print(AppUrl.osmbaseURL + AppUrl.osmAddressEndPoint + latlngEndPoint);
      return response = OsmAddressModel.fromJson(response.data);
    } catch (e) {
      // print('Eroor is ' + e.toString());
      rethrow;
    }
  }
}
