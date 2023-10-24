import 'dart:ffi';

import 'package:autotelematic_new_app/model/devicesmodel.dart';
import 'package:autotelematic_new_app/repository/devices_repository.dart';
import 'package:autotelematic_new_app/res/api_endpoints.dart';
import 'package:autotelematic_new_app/res/helper/map_helper.dart';
import 'package:autotelematic_new_app/res/helper/map_marker_design.dart';
import 'package:autotelematic_new_app/res/usersession.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

part 'vehicletracking_state.dart';

class VehicletrackingCubit extends Cubit<VehicletrackingState> {
  VehicletrackingCubit() : super(VehicletrackingLoading());

  GetDevicesReposiory getDevicesReposiory = GetDevicesReposiory();
  List<DevicesModel> devicesModelList = [];
  BitmapDescriptor markerImage = BitmapDescriptor.defaultMarker;
  dynamic device;
  List<Marker> markers = [];
  double deviceLat = 0.0;
  double deviceLng = 0.0;
  double deviceRotation = 0.0;
  String deviceName = '';
  String deviceLatestUpdate = '';
  String vehicleCurrentStatusFromAPI = '';
  String deviceStopDuration = '';

  int deviceSpeed = 0;

  void fetchDeviceFromApi(int groupID, int deviceID) async {
    // emit(VehicletrackingLoading());
    String? userApiHashKey = await UserSessions.getUserApiHash();

    try {
      devicesModelList =
          await getDevicesReposiory.getDevicesFromAPI(userApiHashKey!);

      device = devicesModelList[groupID].items?[deviceID];
      deviceName = device['name'];
      deviceLat = double.parse(device['lat'].toString());
      deviceLng = double.parse(device['lng'].toString());
      deviceRotation = double.parse(device['course'].toString());
      deviceSpeed = device['speed'];
      deviceLatestUpdate = device['time'];
      vehicleCurrentStatusFromAPI = device['online'].toString().toLowerCase();
      deviceStopDuration = device['stop_duration'];

      await setDeviceMarkerAndPolyLines();
      emit(VehicletrackingLoadingComplete());
    } catch (e) {
      emit(VehicletrackingError('There is some error....'));
    }
  }

  Future<void> setDeviceMarkerAndPolyLines() async {
    // markerImage = await MapHelper.getMarkerImageFromUrl(
    //     ApiEndpointUrls.baseImgURL + device['icon']['path'].toString());
    markerImage = await MapMarkerMaker.getMarkerIcon(
        ApiEndpointUrls.baseImgURL + device['icon']['path'].toString(),
        device['name'].toString(),
        Colors.red,
        double.parse(device['course'].toString()),
        false);
  }

  void refreshVehicleTrackingCubit() {
    emit(RefreshVehicleTracking());
  }
}
