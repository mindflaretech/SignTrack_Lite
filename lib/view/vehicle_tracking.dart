import 'dart:async';

import 'package:autotelematic_new_app/cubit/osmaddress_cubit.dart';
import 'package:autotelematic_new_app/cubit/vehicletracking_cubit.dart';
import 'package:autotelematic_new_app/res/apptheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_map_marker_animation/widgets/animarker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:share_plus/share_plus.dart';

class VehicleTrackingOnMapScreen extends StatefulWidget {
  final int groupID;
  final int deviceID;
  const VehicleTrackingOnMapScreen({
    Key? key,
    required this.groupID,
    required this.deviceID,
  }) : super(key: key);

  @override
  State<VehicleTrackingOnMapScreen> createState() =>
      _VehicleTrackingOnMapScreenState();
}

class _VehicleTrackingOnMapScreenState
    extends State<VehicleTrackingOnMapScreen> {
  late GoogleMapController _controller;
  late GoogleMapController myController;
  final animationController = Completer<GoogleMapController>();
  VehicletrackingCubit vehicletrackingCubit = VehicletrackingCubit();
  OsmaddressCubit osmaddressCubit = OsmaddressCubit();
  late Timer timer;
  List<Marker> markers = [];
  bool isMapLoaded = false;
  double currentZoom = 17;
  late Color mainBoxbgColor;
  late Color vehicleStatuscColor;
  late String vehicleStatus;
  MapType currentMapType = MapType.normal;
  bool enableTraffic = false;
  int animationCounter = 0;
  late double zoomlatestlat;
  late double zoomlatestlng;
  final animationMarkers = <MarkerId, Marker>{};
  MarkerId kMarkerId = const MarkerId('MarkerId1');
  Duration kDuration = const Duration(seconds: 5);

  // Function to animate the camera to a specified location.
  void animateCameraToLocation(LatLng targetLocation, double zoom) {
    CameraPosition cameraPosition = CameraPosition(
      target: targetLocation, // The location you want to move the camera to.
      zoom: zoom, // The desired zoom level.
    );

    // Animate the camera to the specified position.
    _controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  currentMapStatus(CameraPosition position) {
    currentZoom = position.zoom;
  }

  void setVehicleStatusAndColors(String vehicleCurrentStatusFromAPI) {
    switch (vehicleCurrentStatusFromAPI) {
      case 'ack':
        mainBoxbgColor = const Color.fromARGB(255, 250, 208, 208);
        vehicleStatus = 'Stop';
        vehicleStatuscColor = Colors.red[800]!;
        break;

      case 'online':
        mainBoxbgColor = const Color.fromRGBO(206, 248, 205, 1);
        vehicleStatus = 'Driving';
        vehicleStatuscColor = Colors.green[800]!;
        break;

      case 'offline':
        mainBoxbgColor = const Color.fromARGB(255, 213, 238, 255);
        vehicleStatus = 'Offline';
        vehicleStatuscColor = Colors.blue[800]!;
        break;

      case 'engine':
        mainBoxbgColor = const Color.fromARGB(255, 255, 242, 174);
        vehicleStatus = 'Idle';
        vehicleStatuscColor = Colors.orange[800]!;
        break;

      case 'black':
        mainBoxbgColor = const Color.fromARGB(255, 255, 242, 174);
        vehicleStatus = 'Parked';
        vehicleStatuscColor = Colors.orange;
        break;

      default:
        mainBoxbgColor = const Color.fromARGB(255, 213, 216, 218);
        vehicleStatus = 'Not connected or Offline';
        vehicleStatuscColor = Colors.black87;
    }
  }

  @override
  void initState() {
    super.initState();
    vehicletrackingCubit.fetchDeviceFromApi(widget.groupID, widget.deviceID);

    timer = Timer.periodic(const Duration(seconds: 10), (_) {
      vehicletrackingCubit.fetchDeviceFromApi(widget.groupID, widget.deviceID);
    });
  }

  @override
  void dispose() {
    // Cancel the timer when the screen is disposed.
    vehicletrackingCubit.close();
    osmaddressCubit.close();
    timer.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Tracking'),
      ),
      body: BlocProvider(
        create: (context) => vehicletrackingCubit,
        child: BlocBuilder<VehicletrackingCubit, VehicletrackingState>(
          builder: (context, state) {
            markers.clear();
            markers.add(Marker(
              markerId: const MarkerId('1'),
              position: LatLng(
                vehicletrackingCubit.deviceLat,
                vehicletrackingCubit.deviceLng,
              ),
              rotation: vehicletrackingCubit.deviceRotation,
              // infoWindow: InfoWindow(title: vehicletrackingCubit.deviceName),
              icon: vehicletrackingCubit.markerImage,
            ));
            var marker = Marker(
              markerId: MarkerId(widget.deviceID.toString()),
              position: LatLng(
                vehicletrackingCubit.deviceLat,
                vehicletrackingCubit.deviceLng,
              ),
              anchor: const Offset(0.5, 0.5),
              rotation: vehicletrackingCubit.deviceRotation,
              // infoWindow: InfoWindow(title: vehicletrackingCubit.deviceName),
              icon: vehicletrackingCubit.markerImage,
            );
            animationMarkers[kMarkerId] = marker;
            print('data updates');
            setVehicleStatusAndColors(
                vehicletrackingCubit.vehicleCurrentStatusFromAPI);

            if (state is VehicletrackingLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppTheme.loadingImage,
                    const SizedBox(
                      height: 5,
                    ),
                    const Text('Loading...')
                  ],
                ),
              );
            }
            if (state is VehicletrackingError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppTheme.loadingImage,
                    const SizedBox(
                      height: 5,
                    ),
                    const Text('Loading...')
                  ],
                ),
              );
            }
            if (state is VehicletrackingLoadingComplete ||
                state is RefreshVehicleTracking) {
              osmaddressCubit.fetchOSMAddress(vehicletrackingCubit.deviceLat,
                  vehicletrackingCubit.deviceLng);
              if (isMapLoaded) {
                animateCameraToLocation(
                  LatLng(
                      vehicletrackingCubit.deviceLat,
                      vehicletrackingCubit
                          .deviceLng), // Example latitude and longitude.
                  currentZoom, // Example zoom level.
                );
              }
              return Stack(
                children: [
                  Animarker(
                    shouldAnimateCamera: true,
                    //angleThreshold: 10,

                    //zoom: (currentZoom > 16) ? 16 : currentZoom,
                    useRotation: true,
                    runExpressAfter: 3,

                    //curve: Curves.ease,
                    duration: const Duration(milliseconds: 10000),

                    onMarkerAnimationListener: (p0) async {
                      animationCounter = animationCounter + 1;
                      if (animationCounter == 200) {
                        CameraPosition myCameraPosition = CameraPosition(
                            target: LatLng(
                                p0.position.latitude, p0.position.longitude),
                            zoom: currentZoom);
                        zoomlatestlat = p0.position.latitude;
                        zoomlatestlng = p0.position.longitude;
                        myController = await animationController.future;

                        myController.animateCamera(
                          CameraUpdate.newCameraPosition(myCameraPosition),
                        );
                        animationCounter = 0;
                      }
                    },

                    mapId: animationController.future
                        .then<int>((value) => value.mapId), //Grab Google Map Id
                    markers: animationMarkers.values.toSet(),
                    child: GoogleMap(
                      buildingsEnabled: false,
                      indoorViewEnabled: false,

                      minMaxZoomPreference: const MinMaxZoomPreference(1, 21),
                      mapType: currentMapType,
                      trafficEnabled: enableTraffic,
                      // markers: animationMarkers.values.toSet(),
                      zoomControlsEnabled: true,
                      // polylines: _polyLine,
                      // initialCameraPosition: CameraPosition(
                      //     target: _poluLatLng.first, zoom: 15),
                      initialCameraPosition: CameraPosition(
                          target: LatLng(vehicletrackingCubit.deviceLat,
                              vehicletrackingCubit.deviceLng),
                          zoom: 15),
                      onCameraMove: currentMapStatus,
                      onMapCreated: (gController) =>
                          animationController.complete(gController),
                      padding: const EdgeInsets.only(bottom: 150, right: 7),

                      //Complete the future GoogleMapController
                    ),
                  ),
                  // GoogleMap(
                  //   minMaxZoomPreference: const MinMaxZoomPreference(1, 21),
                  //   initialCameraPosition: CameraPosition(
                  //     target: LatLng(
                  //       vehicletrackingCubit.deviceLat,
                  //       vehicletrackingCubit.deviceLng,
                  //     ),
                  //     zoom: 15,
                  //   ),
                  //   compassEnabled: true,
                  //   trafficEnabled: enableTraffic,
                  //   mapType: currentMapType,
                  //   onCameraMove: (position) {
                  //     currentZoom = position.zoom;
                  //   },
                  //   markers: Set<Marker>.of(markers),
                  //   onMapCreated: (GoogleMapController controller) {
                  //     _controller = controller;
                  //     isMapLoaded = true;
                  //     // _controller.showMarkerInfoWindow(const MarkerId('1'));
                  //   },
                  //   padding: const EdgeInsets.only(bottom: 150, right: 7),
                  // ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Center(
                        child: Card(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              // color: Colors.white,
                              width: MediaQuery.of(context).size.width * 0.90,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        vehicletrackingCubit.deviceName,
                                        style: TextStyle(
                                            color: vehicleStatuscColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const Divider(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.webhook_outlined,
                                        size: 20,
                                      ),
                                      const VerticalDivider(),
                                      Text(
                                        vehicleStatus,
                                        style: TextStyle(
                                            color: vehicleStatuscColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        ' since ${vehicletrackingCubit.deviceStopDuration}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.speed,
                                        size: 20,
                                      ),
                                      const VerticalDivider(),
                                      Text(
                                        vehicletrackingCubit.deviceSpeed
                                            .toString(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                      Text(
                                        ' km/h',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.update,
                                        size: 20,
                                      ),
                                      const VerticalDivider(),
                                      Text(
                                        vehicletrackingCubit.deviceLatestUpdate,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.pin_drop_outlined,
                                        size: 20,
                                      ),
                                      const VerticalDivider(),
                                      BlocProvider<OsmaddressCubit>.value(
                                        value: osmaddressCubit,
                                        // create: (context) => osmaddressCubit,
                                        child: BlocBuilder<OsmaddressCubit,
                                            OsmaddressState>(
                                          builder: (context, state) {
                                            if (state is OsmaddressLoading) {
                                              return const Text(
                                                  'fetching address');
                                            }
                                            if (state is OsmaddressError) {
                                              return Text(state.message);
                                            }
                                            if (state
                                                is OsmaddressLoadingComplete) {
                                              return Expanded(
                                                child: Text(
                                                  state
                                                          .osmAddressModel
                                                          .features
                                                          ?.first
                                                          .properties
                                                          ?.displayName
                                                          .toString() ??
                                                      'Unknowm Address',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall,
                                                ),
                                              );
                                            }
                                            return Text('Loading...',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall);
                                          },
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Column(
                        children: [
                          const SizedBox(
                            height: 150,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FloatingActionButton(
                              mini: true,
                              // backgroundColor: AppColors.buttonColor,
                              onPressed: () {
                                currentMapType =
                                    currentMapType == MapType.normal
                                        ? MapType.hybrid
                                        : MapType.normal;
                                vehicletrackingCubit
                                    .refreshVehicleTrackingCubit();
                              },
                              child: const Icon(
                                Icons.map,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FloatingActionButton(
                              // backgroundColor:
                              //     enableTraffic == false ? Colors.amber : Colors.green,
                              mini: true,
                              child: const Icon(
                                Icons.traffic,
                                color: Colors.black54,
                              ),
                              onPressed: () {
                                enableTraffic =
                                    enableTraffic == false ? true : false;
                                vehicletrackingCubit
                                    .refreshVehicleTrackingCubit();
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: FloatingActionButton(
                              heroTag: UniqueKey(),
                              mini: true,
                              child: const Icon(Icons.streetview,
                                  color: Colors.black54),
                              onPressed: () {
                                MapsLauncher.launchCoordinates(
                                    vehicletrackingCubit.deviceLat,
                                    vehicletrackingCubit.deviceLng);
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: FloatingActionButton(
                              heroTag: UniqueKey(),
                              mini: true,
                              child: const Icon(Icons.share,
                                  color: Colors.black54),
                              onPressed: () {
                                Share.share(
                                    'https://www.google.com/maps/search/?api=1&map_action=pano&query=${vehicletrackingCubit.deviceLat},${vehicletrackingCubit.deviceLng}');
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: FloatingActionButton(
                              heroTag: UniqueKey(),
                              mini: true,
                              onPressed: () async {
                                Navigator.of(context).pop();
                              },
                              child: const Icon(Icons.arrow_back),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              );
            }

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppTheme.loadingImage,
                  const SizedBox(
                    height: 5,
                  ),
                  const Text('initial state')
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
