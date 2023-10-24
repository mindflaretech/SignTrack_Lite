import 'dart:io';

import 'package:autotelematic_new_app/model/devicehistorymodel.dart';
import 'package:autotelematic_new_app/model/playbackroutemodel.dart';
import 'package:autotelematic_new_app/model/tripsroutmodel.dart';
import 'package:autotelematic_new_app/repository/devicehistory_repository.dart';
import 'package:autotelematic_new_app/res/usersession.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

part 'device_history_state.dart';

class DeviceHistoryCubit extends Cubit<DeviceHistoryState> {
  DeviceHistoryCubit() : super(DeviceHistoryInitial());

  DeviceHistoryRepository deviceHistoryRepository = DeviceHistoryRepository();
  DeviceHistoryModel deviceHistoryModel = DeviceHistoryModel();
  List<Marker> mapMarkers = [];
  List<LatLng> polyLatLng = [];
  List<LatLng> tripsLatLng = [];
  List<LatLng> parkedLatLngs = [];
  List<LatLng> eventsLatLngs = [];
  List<int> playBackTimeSpeed = [800, 600, 400, 200]; //in milliseconds
  int selectedPlayBackSpeed = 0;
  late LatLngBounds intialLatLngBond;
  late LatLngBounds tripLatLngBond;
  List<PlayBackRoute> routeList = [];
  List<PlayBackRoute> tripsPlayBackList = [];
  List<TripsRoutModel> tripsList = [];
  BitmapDescriptor startIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor endIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor parkingIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor eventsIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor carIcon = BitmapDescriptor.defaultMarker;
  String IconPathAndroid = 'assets/images/';
  String IconPathIOS = 'assets/images/ios/';
  var carIconPath = "car_icon6.png";

  int sliderValueMax = 0;
  int currentSliderValue = 0;
  int tripCount = 0;
  int stopCount = 0;
  int routIndex = 0;
  late DateTime previousDate;
  double intermidateDistance = 0;
  double tripIntermidateDistance = 0;
  String deviceName = '';
  final Set<Polyline> routPolyLine = {};

  Future<void> fetchDeviceRoutHisotyFromApi(String deviceID, String fromDate,
      String toDate, String fromTime, String toTime) async {
    emit(DeviceHistoryLoading());
    String? userApiHashKey = await UserSessions.getUserApiHash();

    try {
      String deviceHistoryDateTime =
          '&device_id=$deviceID&from_date=$fromDate&from_time=$fromTime&to_date=$toDate&to_time=$toTime';
      deviceHistoryModel = await deviceHistoryRepository.getDeviceHisFromAPI(
          userApiHashKey.toString(), deviceHistoryDateTime);
      deviceName = deviceHistoryModel.device?.name;
      for (var element in deviceHistoryModel.items!) {
        if (element.status == 2) {
          tripsPlayBackList.clear();
          tripsLatLng.clear();
          TripsRoutModel newTrip = TripsRoutModel();
          newTrip.status = element.status;
          newTrip.totalTripDuration = element.time;
          newTrip.tripStart = element.show;
          newTrip.tripEnd = element.left;
          newTrip.distance = element.distance;
          newTrip.topSpeed = element.topSpeed;
          newTrip.avgSpeed = element.avgSpeed;

          element.statusItems.forEach((elementInStatus) async {
            if (elementInStatus['latitude'] != null &&
                elementInStatus['longitude'] != null) {
              PlayBackRoute tripsPlayBackListRout = PlayBackRoute();

              tripsPlayBackListRout.deviceId =
                  elementInStatus['device_id'].toString();
              tripsPlayBackListRout.longitude =
                  elementInStatus['longitude'].toString();
              tripsPlayBackListRout.latitude =
                  elementInStatus['latitude'].toString();
              tripsPlayBackListRout.speed = elementInStatus['speed'];
              tripsPlayBackListRout.course =
                  elementInStatus['course'].toString();
              tripsPlayBackListRout.rawTime =
                  elementInStatus['raw_time'].toString();
              tripsPlayBackListRout.time = elementInStatus['time'].toString();
              tripsLatLng.add(LatLng(
                  double.parse(elementInStatus['latitude'].toString()),
                  double.parse(elementInStatus['longitude'].toString())));
              previousDate =
                  DateTime.parse(elementInStatus['raw_time'].toString());
              tripsPlayBackListRout.distance =
                  tripIntermidateDistance.toString();

              tripsPlayBackList.add(tripsPlayBackListRout);

              tripIntermidateDistance =
                  tripIntermidateDistance + elementInStatus['distance'];
            }
          });
          newTrip.tripRoutLatLng = tripsLatLng.toList();
          newTrip.tripPlayBackRout = tripsPlayBackList.toList();
          print(
              'tripplayback length is stops ${newTrip.tripPlayBackRout.length}');
          tripsList.add(newTrip);
          stopCount++;
          //Add parkisng Positions in list when vehicle stops

          parkedLatLngs.add(LatLng(
              element.statusItems[0]['lat'], element.statusItems[0]['lng']));
        }
        if (element.status == 5) {
          //Add events Positions in list when vehicle stops
          eventsLatLngs.add(LatLng(
              double.parse(element.statusItems[0]['lat'].toString()),
              double.parse(element.statusItems[0]['lng'].toString())));
        }
        // Create Trip List
        if (element.status == 1) {
          tripsPlayBackList.clear();
          TripsRoutModel newTrip = TripsRoutModel();
          newTrip.status = element.status;
          newTrip.totalTripDuration = element.time;
          newTrip.tripStart = element.show;
          newTrip.tripEnd = element.left;
          newTrip.distance = element.distance;
          newTrip.topSpeed = element.topSpeed;
          newTrip.avgSpeed = element.avgSpeed;

          element.statusItems.forEach((elementInStatus) async {
            if (elementInStatus['latitude'] != null &&
                elementInStatus['longitude'] != null) {
              PlayBackRoute tripsPlayBackListRout = PlayBackRoute();

              tripsPlayBackListRout.deviceId =
                  elementInStatus['device_id'].toString();
              tripsPlayBackListRout.longitude =
                  elementInStatus['longitude'].toString();
              tripsPlayBackListRout.latitude =
                  elementInStatus['latitude'].toString();
              tripsPlayBackListRout.speed = elementInStatus['speed'];
              tripsPlayBackListRout.course =
                  elementInStatus['course'].toString();
              tripsPlayBackListRout.rawTime =
                  elementInStatus['raw_time'].toString();
              tripsLatLng.add(LatLng(
                  double.parse(elementInStatus['latitude'].toString()),
                  double.parse(elementInStatus['longitude'].toString())));
              tripsPlayBackListRout.time = elementInStatus['time'].toString();
              previousDate =
                  DateTime.parse(elementInStatus['raw_time'].toString());
              tripsPlayBackListRout.distance =
                  tripIntermidateDistance.toString();

              tripsPlayBackList.add(tripsPlayBackListRout);

              tripIntermidateDistance =
                  tripIntermidateDistance + elementInStatus['distance'];
            }
          });
          newTrip.tripRoutLatLng = tripsLatLng.toList();
          newTrip.tripPlayBackRout = tripsPlayBackList.toList();

          tripsList.add(newTrip);
          tripCount++;
        }
        // Create complete rout list
        element.statusItems.forEach((element) async {
          // Add polyline Coordinates
          if (element['latitude'] != null && element['longitude'] != null) {
            PlayBackRoute completePlayBackRout = PlayBackRoute();
            // address =
            //     await getOSMAddress(element['latitude'], element['longitude']);
            completePlayBackRout.deviceId = element['device_id'].toString();
            completePlayBackRout.longitude = element['longitude'].toString();
            completePlayBackRout.latitude = element['latitude'].toString();
            completePlayBackRout.speed = element['speed'];
            completePlayBackRout.course = element['course'].toString();
            completePlayBackRout.rawTime = element['raw_time'].toString();
            completePlayBackRout.time = element['time'].toString();
            previousDate = DateTime.parse(element['raw_time'].toString());
            completePlayBackRout.distance = intermidateDistance.toString();

            // Create Route list for Slider
            routeList.add(completePlayBackRout);
            polyLatLng.add(LatLng(double.parse(element['latitude'].toString()),
                double.parse(element['longitude'].toString())));
            intermidateDistance = intermidateDistance + element['distance'];
          }
        });
      }
      sliderValueMax = polyLatLng.length - 1;
      if (routeList.isNotEmpty) {
        setInitialCarMarker();
        setCompleteRoutPolyLineLatLng(polyLatLng);
        intialLatLngBond = calculatePolylineBounds(polyLatLng);
        setStartAndEndPointMarkers();
        setParkingPointsMarkers();
        //setEventsPointsMarkers();
      }
      // setEventsPointsMarkers();
      emit(DeviceHistoryLoadingComplete(deviceHistoryModel));
    } catch (e) {
      emit(DeviceHistoryError('Error while fetching history...'));
    }
  }

  void resetAllListData() {
    mapMarkers.clear();
    polyLatLng.clear();
    parkedLatLngs.clear();
    eventsLatLngs.clear();
    routeList.clear();
    tripsPlayBackList.clear();
    currentSliderValue = 0;
    sliderValueMax = 0;
    intermidateDistance = 0;
    tripIntermidateDistance = 0;
    selectedPlayBackSpeed = 0;
  }

  setPlayBackSpeed() {
    if (selectedPlayBackSpeed < 3) {
      selectedPlayBackSpeed++;
    } else if (selectedPlayBackSpeed == 3) {
      selectedPlayBackSpeed = 0;
    }
    emit(DeviceHistoryRefresh());
  }

  playUsingSlider(int sliderValue) {
    currentSliderValue = sliderValue;
    // print('Current Slider Value is ' + currentSliderValue.toString());
    var m = mapMarkers.firstWhere((p) => p.markerId == const MarkerId("0"));
    mapMarkers.remove(m);
    mapMarkers.add(
      Marker(
        markerId: const MarkerId('0'),
        position: LatLng(
            double.parse(routeList[currentSliderValue].latitude.toString()),
            double.parse(routeList[currentSliderValue].longitude.toString())),
        infoWindow: InfoWindow(title: currentSliderValue.toString()),
        icon: carIcon,
        rotation: double.parse(routeList[currentSliderValue].course.toString()),
      ),
    );

    emit(DeviceHistoryRefresh());
  }

  setCompleteRoutPolyLineLatLng(List<LatLng> poltlatlng) {
    routPolyLine.add(
      Polyline(
          polylineId: const PolylineId('1'),
          points: poltlatlng,
          color: Colors.deepOrange,
          width: 2,
          zIndex: 0),
    );
    emit(DeviceHistoryRefresh());
  }

  void removeSingleRoutPolyLineLatLng() {
    routPolyLine.removeWhere((polyline) => polyline.polylineId.value == '2');
    // notifyListeners();
    emit(DeviceHistoryRefresh());
  }

  resetCompleteRoutPolyLineLatLng() {
    routPolyLine.clear();

    emit(DeviceHistoryRefresh());
  }

  setParkingPointsMarkers() async {
    if (Platform.isAndroid) {
      var iconPath = "${IconPathAndroid}stops.png";
      parkingIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(32, 32)),
        iconPath,
      );
    } else if (Platform.isIOS) {
      var iconPath = "${IconPathIOS}stops.png";
      parkingIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(32, 32)),
        iconPath,
      );
    }

    for (var element in parkedLatLngs) {
      mapMarkers.add(
        Marker(
          markerId: MarkerId(('Parking ${element.latitude}').toString()),
          anchor: const Offset(0.5, 0.5),
          position: element,
          draggable: true,
          // rotation: double.parse(routeList[0].course),

          icon: parkingIcon,
        ),
      );
    }
  }

  setEventsPointsMarkers() async {
    if (Platform.isAndroid) {
      var iconPath = "${IconPathAndroid}alert.png";
      parkingIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(32, 32)),
        iconPath,
      );
    } else if (Platform.isIOS) {
      var iconPath = "${IconPathIOS}alert.png";
      parkingIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(32, 32)),
        iconPath,
      );
    }

    int i = 0;
    for (var element in eventsLatLngs) {
      i++;
      mapMarkers.add(
        Marker(
          markerId: MarkerId(('Events$i')),
          anchor: const Offset(0.5, 0.5),
          position: element,
          draggable: true,
          // rotation: double.parse(routeList[0].course),

          icon: eventsIcon,
        ),
      );
    }
  }

  setInitialCarMarker() async {
    if (Platform.isAndroid) {
      var iconPath = IconPathAndroid + carIconPath;
      carIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(),
        iconPath,
      );
    } else if (Platform.isIOS) {
      var iconPath = IconPathIOS + carIconPath;
      carIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(),
        iconPath,
      );
    }

    mapMarkers.add(
      Marker(
          markerId: const MarkerId('0'),
          anchor: const Offset(0.5, 0.5),
          position: LatLng(double.parse(routeList[0].latitude.toString()),
              double.parse(routeList[0].longitude.toString())),
          // updated position
          // rotation: double.parse(routeList[0].course),
          rotation: double.parse(routeList[0].course.toString()),
          draggable: true,
          icon: carIcon,
          infoWindow: const InfoWindow(title: 'Car')),
    );
  }

  resetGoogleMap() {
    emit(DeviceHistoryRefresh());
  }

  setStartAndEndPointMarkers() async {
    var iconStart = "start.png";
    var iconEnd = "end.png";
    if (Platform.isAndroid) {
      var iconPath = IconPathAndroid + iconStart;
      var iconPathEnd = IconPathAndroid + iconEnd;
      startIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(100, 100)),
        iconPath,
      );
      endIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(100, 100)),
        iconPathEnd,
      );
    } else if (Platform.isIOS) {
      var iconPath = IconPathIOS + iconStart;
      var iconPathEnd = IconPathIOS + iconEnd;
      startIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(100, 100)),
        iconPath,
      );
      endIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(100, 100)),
        iconPathEnd,
      );
    }

    mapMarkers.add(
      Marker(
        markerId: MarkerId((routeList.length + 2).toString()),
        anchor: const Offset(0.5, 0.5),
        position: LatLng(double.parse(routeList[0].latitude.toString()),
            double.parse(routeList[0].longitude.toString())),
        // updated position
        // rotation: double.parse(routeList[0].course),
        draggable: true,
        icon: startIcon,
      ),
    );
    mapMarkers.add(
      Marker(
        markerId: MarkerId((routeList.length + 2).toString()),
        anchor: const Offset(0.5, 0.5),
        position: LatLng(
            double.parse(routeList[routeList.length - 1].latitude.toString()),
            double.parse(routeList[routeList.length - 1].longitude.toString())),
        // updated position
        // rotation: double.parse(routeList[0].course),
        draggable: true,
        icon: endIcon,
      ),
    );

    // notifyListeners();
  }

  setSingleRoutPolyLineLatLng(List<LatLng> poltlatlng) {
    routPolyLine.add(
      Polyline(
          polylineId: const PolylineId('2'),
          points: poltlatlng,
          color: Colors.green,
          width: 6,
          startCap: Cap.buttCap,
          zIndex: 1),
    );
    emit(DeviceHistoryRefresh());
  }

  LatLngBounds calculatePolylineBounds(List<LatLng> points) {
    double minLat = points[0].latitude;
    double maxLat = points[0].latitude;
    double minLng = points[0].longitude;
    double maxLng = points[0].longitude;

    for (LatLng point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return LatLngBounds(
      northeast: LatLng(maxLat, maxLng),
      southwest: LatLng(minLat, minLng),
    );
  }
}
