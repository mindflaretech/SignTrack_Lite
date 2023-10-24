import 'package:autotelematic_new_app/cubit/home_cubit.dart';
import 'package:autotelematic_new_app/res/apptheme.dart';
import 'package:autotelematic_new_app/utils/routes/routes_names.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapForAllVehiclesScreen extends StatefulWidget {
  const MapForAllVehiclesScreen({super.key});

  @override
  State<MapForAllVehiclesScreen> createState() =>
      _MapForAllVehiclesScreenState();
}

class _MapForAllVehiclesScreenState extends State<MapForAllVehiclesScreen> {
  late GoogleMapController controller;
  MapType currentMapType = MapType.normal;
  bool enableTraffic = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicles Map'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              if (state is HomeLoading) {
                Center(
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
              if (state is HomeError) {
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Text(state.message)],
                  ),
                );
              }
              if (state is HomeNavigateToDeviceTracking) {
                Future.delayed(const Duration(milliseconds: 10), () {
                  context.read<HomeCubit>().refreshHomeCubit();
                  Navigator.pushNamed(context, RoutesName.vehicleLiveTracking,
                      arguments: {
                        'groupID': state.groupID,
                        'deviceID': state.deviceID,
                      });
                });
              } else if (state is HomeLoadingComplete ||
                  state is HomeLoadingRefresh) {
                return GoogleMap(
                  minMaxZoomPreference: const MinMaxZoomPreference(1, 21),
                  initialCameraPosition: const CameraPosition(
                      target: LatLng(30.229696, 69.982138), zoom: 5),
                  onCameraMove: (position) {},
                  mapType: currentMapType,
                  trafficEnabled: enableTraffic,
                  mapToolbarEnabled: true,
                  markers: Set<Marker>.of(
                      context.read<HomeCubit>().deviceMarkersList),
                  // markers: context.read<HomeCubit>().markers,
                  onMapCreated: (GoogleMapController controller) {
                    controller = controller;
                  },
                  padding: const EdgeInsets.only(bottom: 70, right: 7),
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
                    const Text('Loading...')
                  ],
                ),
              );
            },
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
                      // backgroundColor: Colors.purple[100],
                      onPressed: () {
                        currentMapType = currentMapType == MapType.normal
                            ? MapType.hybrid
                            : MapType.normal;
                        context.read<HomeCubit>().refreshHomeCubit();
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
                      // backgroundColor: enableTraffic == false
                      //     ? Colors.purple[100]
                      //     : Colors.green,
                      mini: true,
                      child: const Icon(
                        Icons.traffic,
                        color: Colors.black54,
                      ),
                      onPressed: () {
                        enableTraffic = !enableTraffic;
                        //context.read<HomeCubit>().refreshHomeCubit();
                        setState(() {});
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FloatingActionButton(
                      // backgroundColor: Colors.purple[100],
                      mini: true,
                      child: Icon(
                        context.read<HomeCubit>().showMarkerLables
                            ? Icons.label_outline
                            : Icons.label_off_outlined,
                        color: Colors.black54,
                      ),
                      onPressed: () {
                        context.read<HomeCubit>().markerLabelsToggel();
                        //context.read<HomeCubit>().refreshHomeCubit();
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
