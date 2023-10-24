import 'package:autotelematic_new_app/model/osmmodel.dart';
import 'package:autotelematic_new_app/repository/osmaddress_repository.dart';
import 'package:bloc/bloc.dart';

part 'osmaddress_state.dart';

class OsmaddressCubit extends Cubit<OsmaddressState> {
  OsmaddressCubit() : super(OsmaddressLoading());

  OsmAddressRepository osmAddressRepository = OsmAddressRepository();
  OsmAddressModel osmAddressModel = OsmAddressModel();

  Future<OsmAddressModel> fetchOSMAddress(double lat, double lng) async {
    String latlngEndPoint = '&lat=$lat&lon=$lng';

    try {
      osmAddressModel =
          await osmAddressRepository.getOsmAddressApi(latlngEndPoint);
      emit(OsmaddressLoadingComplete(osmAddressModel));
      return osmAddressModel;
    } catch (e) {
      emit(OsmaddressError('Error while fetching address....'));
      rethrow;
    }
  }
}
