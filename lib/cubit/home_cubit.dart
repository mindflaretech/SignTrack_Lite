import 'dart:async';
import 'package:autotelematic_new_app/res/helper/map_marker_design.dart';
import 'package:flutter/foundation.dart';
import 'package:autotelematic_new_app/cubit/osmaddress_cubit.dart';
import 'package:autotelematic_new_app/model/devicedatamodel.dart';
import 'package:autotelematic_new_app/model/devicesmodel.dart';
import 'package:autotelematic_new_app/repository/devices_repository.dart';
import 'package:autotelematic_new_app/res/api_endpoints.dart';
import 'package:autotelematic_new_app/res/usersession.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeLoading()) {
    startPeriodicUpdates();
  }
  GetDevicesReposiory getDevicesReposiory = GetDevicesReposiory();
  List<DevicesModel> devicesModelList = [];
  final List<Marker> deviceMarkersList = [];
  Set<Marker> markers = {};
  late Timer _timer; // Timer for periodic updates
  late List<dynamic> devicesList = [];
  late int allDevicesCount = 0;
  late int stoppedCount = 0;
  late int runningCount = 0;
  late int offlineCount = 0;
  late int noDataCount = 0;
  late int expiredCount = 0;
  late int idleCount = 0;
  bool showMarkerLables = true;
  int groupIndex = 0;
  int deviceIndex = 0;
  List<DeviceData> deviceDataListwithGroupAndDeviceIndex = [];
  late List<OsmaddressCubit> osmAddressCubitList = [];
  int homeCurrentIndex = 0;

  List<ChartData> vehicleStatusCountdata = [
    ChartData('Running', 1, Colors.green),
    ChartData('Stopped', 1, Colors.green),
    ChartData('Idle', 5, Colors.green),
    ChartData('Offline', 1, Colors.green),
    ChartData('No Data', 1, Colors.green),
    ChartData('Expired', 1, Colors.green),
  ];

  void startPeriodicUpdates() {
    // Start the periodic timer that fetches data every 30 seconds
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      fetchDevicesFromApi();
    });
  }

  void setHomeIndex(int index) {
    emit(HomeScreenIndex());
    homeCurrentIndex = index;
    emit(HomeLoadingRefresh());
  }

  void stopPeriodicUpdates() {
    // Cancel the timer when you no longer need periodic updates
    _timer.cancel();
  }

  void fetchDevicesFromApi() async {
    // emit(HomeLoading());

    String? userApiHashKey = await UserSessions.getUserApiHash();

    try {
      devicesModelList =
          await getDevicesReposiory.getDevicesFromAPI(userApiHashKey!);
      await setDeviceCounterandStatus(devicesModelList);
      emit(HomeLoadingComplete());
    } catch (e) {
      emit(HomeError('There is some error....'));
    }
  }

  void refreshHomeCubit() {
    emit(HomeLoadingRefresh());
  }

  void markerLabelsToggel() async {
    showMarkerLables = !showMarkerLables;
    await setDeviceCounterandStatus(devicesModelList);
    emit(HomeLoadingRefresh());
  }

  setDeviceCounterandStatus(List<DevicesModel> devicesModelList) async {
    devicesList.clear();
    deviceMarkersList.clear();
    deviceDataListwithGroupAndDeviceIndex.clear();
    allDevicesCount = 0;
    stoppedCount = 0;
    runningCount = 0;
    idleCount = 0;
    noDataCount = 0;
    expiredCount = 0;
    offlineCount = 0;
    groupIndex = 0;

    for (var group in devicesModelList) {
      deviceIndex = 0;

      devicesList.addAll(group.items!);
      for (var device in group.items!) {
        DeviceData newDeviceData = DeviceData();
        newDeviceData.groupID = devicesModelList.indexOf(group);
        newDeviceData.deviceIndexInGroup = group.items!.indexOf(device);
        newDeviceData.deviceData = device;
        newDeviceData.groupTitle = group.title;
        BitmapDescriptor markerImage = await MapMarkerMaker.getMarkerIcon(
            ApiEndpointUrls.baseImgURL + device['icon']['path'].toString(),
            device['name'].toString(),
            Colors.red,
            double.parse(device['course'].toString()),
            showMarkerLables);
        deviceMarkersList.add(
          Marker(
            markerId: MarkerId(device['id'].toString()),
            rotation: double.parse(device['course'].toString()),
            icon: markerImage,
            position: LatLng(double.parse(device['lat'].toString()),
                double.parse(device['lng'].toString())),
            infoWindow: InfoWindow(
              title: device['name'].toString(),
              snippet: device['speed'].toString(),
            ),
            onTap: () {
              emit(HomeNavigateToDeviceTracking(
                  deviceID: group.items!.indexOf(device),
                  groupID: devicesModelList.indexOf(group)));
            },
          ),
        );

        deviceDataListwithGroupAndDeviceIndex.add(newDeviceData);
        OsmaddressCubit osmaddressCubit = OsmaddressCubit();
        osmAddressCubitList.add(osmaddressCubit);
        deviceIndex = deviceIndex + 1;
      }
      groupIndex = groupIndex + 1;
    }

    for (var device in devicesList) {
      // BitmapDescriptor markerImage = await MapHelper.getMarkerImageFromUrl(
      //     ApiEndpointUrls.baseImgURL + device['icon']['path'].toString());

      allDevicesCount = allDevicesCount + 1;
      var deviceStatus = device['online'];

      if (deviceStatus.toLowerCase() == 'ack') {
        stoppedCount = stoppedCount + 1;
      }
      if (deviceStatus.toLowerCase() == 'online') {
        runningCount = runningCount + 1;
      }
      if (device['online'].toString().toLowerCase() == "offline" &&
          device['time'].toString().toLowerCase() != "Not connected") {
        offlineCount = offlineCount + 1;
      }
      if (device['online'].toString().toLowerCase() == "offline" &&
          device['time'].toString().toLowerCase() == "not connected") {
        noDataCount = noDataCount + 1;
      }
      if (device['time'].toString().toLowerCase() == "expired") {
        expiredCount = expiredCount + 1;
      }
      if (deviceStatus.toLowerCase() == 'engine') {
        idleCount = idleCount + 1;
      }
    }
    vehicleStatusCountdata.clear();
    vehicleStatusCountdata
        .add(ChartData('Running', runningCount.toInt(), Colors.green));
    vehicleStatusCountdata
        .add(ChartData('Stopped', stoppedCount.toInt(), Colors.red));
    vehicleStatusCountdata
        .add(ChartData('Idle', idleCount.toInt(), Colors.yellow));
    vehicleStatusCountdata
        .add(ChartData('Offline', offlineCount.toInt(), Colors.blue));
    vehicleStatusCountdata
        .add(ChartData('No Data', noDataCount.toInt(), Colors.grey));
    vehicleStatusCountdata.add(ChartData('Expired', expiredCount.toInt(),
        const Color.fromARGB(255, 138, 13, 4)));
  }

  @override
  Future<void> close() {
    stopPeriodicUpdates(); // Stop the timer before closing
    return super.close(); // Close the HomeCubit
  }
}

class ChartData {
  ChartData(this.x, this.y, this.color);

  final String x;
  final int y;
  final Color? color;
}
