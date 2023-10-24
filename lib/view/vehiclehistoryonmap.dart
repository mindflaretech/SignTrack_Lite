import 'dart:async';

import 'package:autotelematic_new_app/cubit/device_history_cubit.dart';
import 'package:autotelematic_new_app/model/devicedatamodalforhistoryandreport.dart';
import 'package:autotelematic_new_app/model/playbackroutemodel.dart';
import 'package:autotelematic_new_app/res/apptheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class VehicleHistoryOnMapScreen extends StatefulWidget {
  final DeviceDataForReportsAndHistory deviceDataForReportsAndHistory;
  const VehicleHistoryOnMapScreen(
      {super.key, required this.deviceDataForReportsAndHistory});

  @override
  State<VehicleHistoryOnMapScreen> createState() =>
      _VehicleHistoryOnMapScreenState();
}

class _VehicleHistoryOnMapScreenState extends State<VehicleHistoryOnMapScreen> {
  DeviceHistoryCubit deviceHistoryCubit = DeviceHistoryCubit();
  double currentZoom = 12;
  int tripSliderIndex = 0;
  bool isPlaying = false;
  MapType currentMapType = MapType.normal;
  late String fromDateStr;
  late String toDateStr;
  var isPlayingIcon = Icons.play_circle_outline;
  double sliderValue = 0;
  int stopCount = 0;
  int tripCount = 0;
  int playbackTime = 100;
  late Timer _timer;
  late LatLngBounds tripLatLngBounds;
  late Timer timerPlayBack = _timer;
  final PanelController panelController = PanelController();

  final animationController = Completer<GoogleMapController>();

  List<String> move_duration_split = [];
  List<String> stop_duration_split = [];

  Timer interval(Duration duration, func) {
    Timer function() {
      Timer timer = Timer(duration, function);
      func(timer);
      return timer;
    }

    return Timer(duration, function);
  }

  void playRoute(DeviceHistoryCubit deviceHistoryCubit) {
    interval(
        Duration(
            milliseconds: deviceHistoryCubit
                .playBackTimeSpeed[deviceHistoryCubit.selectedPlayBackSpeed]),
        (timer) {
      timerPlayBack = timer;
      if ((deviceHistoryCubit.routeList.length - 1) >
          deviceHistoryCubit.currentSliderValue) {
        deviceHistoryCubit
            .playUsingSlider(deviceHistoryCubit.currentSliderValue + 1);
        moveCamera(deviceHistoryCubit
            .routeList[deviceHistoryCubit.currentSliderValue.toInt()]);
      } else if ((deviceHistoryCubit.routeList.length - 1) ==
          deviceHistoryCubit.currentSliderValue) {
        timerPlayBack.cancel();
        deviceHistoryCubit.playUsingSlider(0);
        moveCamera(deviceHistoryCubit.routeList[0]);
        playPausePressed(deviceHistoryCubit);
      } else {
        timerPlayBack.cancel();
      }
      print('this is timer');
    });
  }

  void playPausePressed(DeviceHistoryCubit deviceHistoryCubit) {
    isPlaying = isPlaying == false ? true : false;
    if (isPlaying) {
      playRoute(deviceHistoryCubit);
    } else if (!isPlaying) {
      timerPlayBack.cancel();
    }
    isPlayingIcon = isPlaying == false
        ? Icons.play_circle_outline
        : Icons.pause_circle_outline;
  }

  void moveCamera(PlayBackRoute pos) async {
    CameraPosition cPosition = CameraPosition(
      target: LatLng(double.parse(pos.latitude.toString()),
          double.parse(pos.longitude.toString())),
      zoom: currentZoom,
    );
    final GoogleMapController controller = await animationController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
    Future.delayed(const Duration(milliseconds: 200), () {
      controller
          .animateCamera(CameraUpdate.newLatLngBounds(tripLatLngBounds, 50));
    });
  }

  void boundCamera(LatLngBounds tripLatLngBounds) async {
    final GoogleMapController controller = await animationController.future;

    Future.delayed(const Duration(milliseconds: 200), () {
      controller
          .animateCamera(CameraUpdate.newLatLngBounds(tripLatLngBounds, 50));
    });
  }

  void googleMapCameraBond(List<LatLng> tripsLatLng) async {
    LatLngBounds newLatLngBounds = LatLngBounds(
      southwest:
          LatLng(tripsLatLng.first.latitude, tripsLatLng.first.longitude),
      northeast: LatLng(tripsLatLng.last.latitude, tripsLatLng.last.longitude),
    );
    final GoogleMapController controller = await animationController.future;
    controller
        .animateCamera(CameraUpdate.newLatLngBounds(newLatLngBounds, 100));
  }

  currentMapStatus(CameraPosition position) {
    currentZoom = position.zoom;
  }

  void initState() {
    deviceHistoryCubit.fetchDeviceRoutHisotyFromApi(
        widget.deviceDataForReportsAndHistory.deviceId!.toString(),
        widget.deviceDataForReportsAndHistory.fromDate!,
        widget.deviceDataForReportsAndHistory.toDate!,
        widget.deviceDataForReportsAndHistory.fromTime!,
        widget.deviceDataForReportsAndHistory.toTime!);

    DateFormat format = DateFormat("yy-MM-dd");
    DateTime date =
        format.parse(widget.deviceDataForReportsAndHistory.fromDate!);

    fromDateStr = DateFormat("dd-MM-yy").format(date);
    date = format.parse(widget.deviceDataForReportsAndHistory.toDate!);
    toDateStr = DateFormat("dd-MM-yy").format(date);
    super.initState();
  }

  @override
  void dispose() {
    if (timerPlayBack.isActive) {
      timerPlayBack.cancel();
    }
    // _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          BlocProvider<DeviceHistoryCubit>(
            create: (context) => deviceHistoryCubit,
            child: BlocBuilder<DeviceHistoryCubit, DeviceHistoryState>(
              builder: (context, state) {
                if (state is DeviceHistoryLoading) {
                  return Expanded(
                    child: Center(
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
                    ),
                  );
                }
                if (state is DeviceHistoryError) {
                  return Center(
                    child: Text(state.message),
                  );
                }
                if (state is DeviceHistoryLoadingComplete ||
                    state is DeviceHistoryRefresh) {
                  if (deviceHistoryCubit.routeList.isEmpty) {
                    return Expanded(
                      child: Stack(
                        children: [
                          GoogleMap(
                            initialCameraPosition: const CameraPosition(
                              target: LatLng(0.0, 0.0),
                              zoom: 5,
                            ),
                            markers:
                                Set<Marker>.of(deviceHistoryCubit.mapMarkers),
                            onMapCreated: (GoogleMapController controller) {
                              animationController.complete(controller);
                            },
                            onCameraMove: currentMapStatus,
                            polylines: deviceHistoryCubit.routPolyLine,
                          ),
                          Center(
                            child: Container(
                              width: MediaQuery.of(context).size.width - 30,
                              height: MediaQuery.of(context).size.height * 0.20,
                              padding:
                                  const EdgeInsets.fromLTRB(10, 10, 10, 10),
                              margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(180, 0, 0, 0),
                                borderRadius: BorderRadius.circular(10.0),
                                //border: Border.all(width: 6, color: Colors.red),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.warning,
                                    size: 35,
                                    color: Colors.amber,
                                  ),
                                  const Text(
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                      'No record found for specific date and time range...'),
                                  ElevatedButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Close'))
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  }
                  return Expanded(
                    child: Stack(
                      children: [
                        GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: deviceHistoryCubit.polyLatLng.first,
                            zoom: currentZoom,
                          ),
                          markers:
                              Set<Marker>.of(deviceHistoryCubit.mapMarkers),
                          onMapCreated: (GoogleMapController controller) {
                            animationController.complete(controller);
                            Future.delayed(const Duration(milliseconds: 200),
                                () {
                              controller.animateCamera(
                                  CameraUpdate.newLatLngBounds(
                                      deviceHistoryCubit.intialLatLngBond, 50));
                            });
                          },
                          myLocationEnabled: false,
                          onCameraMove: currentMapStatus,
                          mapType: currentMapType,
                          polylines: deviceHistoryCubit.routPolyLine,
                          padding: EdgeInsets.only(
                              bottom:
                                  MediaQuery.of(context).size.height * 0.35),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Column(
                              children: [
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.34,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: FloatingActionButton(
                                    mini: true,
                                    //  backgroundColor: AppColors.buttonColor,
                                    onPressed: () {
                                      currentMapType =
                                          currentMapType == MapType.normal
                                              ? MapType.hybrid
                                              : MapType.normal;
                                      deviceHistoryCubit.resetGoogleMap();
                                    },
                                    child: const Icon(
                                      Icons.map,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: FloatingActionButton(
                                    heroTag: UniqueKey(),
                                    mini: true,
                                    //backgroundColor: AppColors.buttonColor,
                                    onPressed: () async {
                                      await Future.delayed(
                                          const Duration(milliseconds: 300));
                                      Navigator.of(context).pop();
                                    },
                                    child: const Icon(Icons.arrow_back),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SlidingUpPanel(
                          minHeight: MediaQuery.of(context).size.height * 0.35,
                          controller: panelController,
                          maxHeight: MediaQuery.of(context).size.height * 1,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(15.0),
                            topRight: Radius.circular(15.0),
                          ),
                          padding: const EdgeInsets.fromLTRB(15, 5, 15, 0),
                          color: const Color.fromARGB(166, 255, 255, 255),
                          panelBuilder: (ScrollController sc) => _scrollingList(
                              sc, panelController, deviceHistoryCubit),
                        ),
                      ],
                    ),
                  );
                }
                return Container();
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _scrollingList(ScrollController sc, PanelController panelController,
      DeviceHistoryCubit value) {
    return ListView(
      controller: sc,
      children: [
        InkWell(
          child: Center(
            child: Container(
              height: 5,
              width: 30,
              decoration: const BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
          ),
          onTap: () {
            if (panelController.isPanelOpen) {
              panelController.close();
            } else {
              panelController.open();
            }
          },
        ),
        Row(
          children: [
            Container(
              width: MediaQuery.of(context).size.width - 30,
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.0),
                  //border: Border.all(width: 6, color: Colors.red),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 2,
                      color: Color.fromARGB(255, 155, 150, 150),
                      offset: Offset.zero,
                      blurStyle: BlurStyle.normal,
                    ),
                  ]),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.amber[700],
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(7.0),
                      border:
                          Border.all(color: const Color(0x4d9e9e9e), width: 0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(15, 3, 15, 3),
                      child: Text(
                        value.deviceName,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_month_outlined,
                            color: Colors.grey,
                            size: 17,
                          ),
                          const VerticalDivider(
                            width: 2,
                          ),
                          Text.rich(
                            TextSpan(
                              text: 'From : ',
                              children: [
                                TextSpan(
                                  text: fromDateStr,
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12),
                                )
                              ],
                              style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_month_outlined,
                            color: Colors.grey,
                            size: 17,
                          ),
                          Text.rich(
                            TextSpan(
                              text: 'To : ',
                              children: [
                                TextSpan(
                                  text: toDateStr,
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12),
                                )
                              ],
                              style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.speed,
                            color: Colors.grey,
                            size: 17,
                          ),
                          const VerticalDivider(
                            width: 2,
                          ),
                          RichText(
                            text: TextSpan(
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                                text:
                                    '${value.routeList[value.currentSliderValue].speed.toString()} ',
                                children: const <TextSpan>[
                                  TextSpan(
                                    text: 'km/h',
                                    style: TextStyle(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 12),
                                  )
                                ]),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_alarm,
                            color: Colors.grey,
                            size: 17,
                          ),
                          const VerticalDivider(
                            width: 2,
                          ),
                          RichText(
                            text: TextSpan(
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                                text:
                                    '${value.routeList[value.currentSliderValue].time.toString().split(' ')[1]} ${value.routeList[value.currentSliderValue].time.toString().split(' ')[2].toLowerCase()} ',
                                children: <TextSpan>[
                                  TextSpan(
                                    text: value
                                        .routeList[value.currentSliderValue]
                                        .time
                                        .toString()
                                        .split(' ')[0],
                                    style: const TextStyle(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 12),
                                  )
                                ]),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.directions_run_outlined,
                            color: Colors.grey,
                            size: 17,
                          ),
                          const VerticalDivider(
                            width: 2,
                          ),
                          RichText(
                            text: TextSpan(
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                                text:
                                    '${double.parse(value.routeList[value.currentSliderValue].distance!.toString()).toStringAsFixed(2)} ',
                                children: const [
                                  TextSpan(
                                    text: 'km',
                                    style: TextStyle(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 12),
                                  )
                                ]),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            playPausePressed(value);
                            value.playUsingSlider(
                                (value.currentSliderValue + 1));
                            moveCamera(value
                                .routeList[value.currentSliderValue.toInt()]);
                          },
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(1),
                            backgroundColor: Colors.grey[200],
                          ),
                          child: Icon(
                            isPlayingIcon,
                            size: 34,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: Slider(
                          activeColor: Colors.grey[400],
                          thumbColor: Colors.grey[400],
                          label:
                              '${value.routeList[value.currentSliderValue.toInt()].rawTime}',
                          divisions: value.sliderValueMax,
                          min: 0,
                          max: value.sliderValueMax.toDouble(),
                          value: value.currentSliderValue.toDouble(),
                          onChanged: (sliderValue) {
                            if (value.routeList.length - 1 !=
                                value.currentSliderValue) {
                              moveCamera(value
                                  .routeList[value.currentSliderValue.toInt()]);
                              value
                                  .playUsingSlider(sliderValue.round().toInt());
                            } else if (value.routeList.length - 1 ==
                                value.currentSliderValue) {
                              value.playUsingSlider(0);
                            }
                          },
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // if (timerPlayBack.isActive) {
                            //   timerPlayBack.cancel();
                            // }
                            // isPlaying = false;
                            value.setPlayBackSpeed();

                            // playPausePressed(value);
                            //  playRoute(value);
                          },
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(1),
                            backgroundColor: Colors.grey[200],
                          ),
                          child: Text(
                            '${value.selectedPlayBackSpeed + 1}x',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black54),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                            style: const TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.normal,
                                fontSize: 12),
                            text: 'Total Travel: ',
                            children: [
                              TextSpan(
                                text: '${value.deviceHistoryModel.distanceSum}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ]),
                      ),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.normal,
                              fontSize: 12),
                          text: 'Maximum Speed: ',
                          children: [
                            TextSpan(
                              text: '${value.deviceHistoryModel.topSpeed}',
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Travel (Trips :${value.tripCount})',
                                style: const TextStyle(
                                    color: Colors.black87, fontSize: 10),
                              ),
                              GFProgressBar(
                                margin: const EdgeInsets.all(3),
                                percentage: 0.23,
                                lineHeight: 5,
                                backgroundColor: Colors.black26,
                                progressBarColor: Colors.green,
                              ),
                              Text(
                                  value.deviceHistoryModel.moveDuration
                                      .toString(),
                                  style: const TextStyle(
                                      color: Colors.black87, fontSize: 10))
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Stop hours (Stops :${value.stopCount})',
                                style: const TextStyle(
                                    color: Colors.black87, fontSize: 10),
                              ),
                              GFProgressBar(
                                margin: const EdgeInsets.all(3),
                                percentage: 0.77,
                                lineHeight: 5,
                                backgroundColor: Colors.black26,
                                progressBarColor: Colors.red,
                              ),
                              Text(
                                value.deviceHistoryModel.stopDuration
                                    .toString(),
                                style: const TextStyle(
                                    color: Colors.black87, fontSize: 10),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          itemCount: value.tripsList.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                panelController.close();
                //  playRoutOnMapViewModel.resetRoutPolyLine();

                if (value.tripsList[index].status == 2) {
                  currentZoom = 21;
                  moveCamera(value.tripsList[index].tripPlayBackRout[0]);
                }
                if (value.tripsList[index].status == 1) {
                  currentZoom = 17;
                  value.removeSingleRoutPolyLineLatLng();
                  value.setSingleRoutPolyLineLatLng(
                      value.tripsList[index].tripRoutLatLng);
                  tripLatLngBounds = value.calculatePolylineBounds(
                      value.tripsList[index].tripRoutLatLng);

                  //googleMapCameraBond(value.tripsList[index].tripRoutLatLng);

                  // moveCamera(value.tripsList[index].tripPlayBackRout.first);
                  // tripLatLngBounds = deviceHistoryCubit.calculatePolylineBounds(
                  //     value.tripsList[index].tripRoutLatLng);
                  boundCamera(tripLatLngBounds);
                  tripSliderIndex = value.routeList.indexWhere((route) =>
                      (route.latitude ==
                          value.tripsList[index].tripRoutLatLng.first.latitude
                              .toString()) &&
                      (route.longitude ==
                          value.tripsList[index].tripRoutLatLng.first.longitude
                              .toString()));

                  value.playUsingSlider(tripSliderIndex);
                }
              },
              child: Card(
                // shape: AppColors.cardBorderShape,
                child: Container(
                  // decoration: BoxDecoration(
                  //   color: value.tripsList[index].status == 1
                  //       ? Colors.green[50]
                  //       : Colors.red[50],
                  //   shape: BoxShape.rectangle,
                  //   borderRadius: BorderRadius.circular(15.0),
                  //   border: Border.all(color: const Color(0x4d9e9e9e), width: 0),
                  // ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.directions_run_outlined,
                                  size: 17,
                                  color: Colors.grey,
                                ),
                                const VerticalDivider(width: 3),
                                RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 12),
                                    text: 'Distance: ',
                                    children: [
                                      TextSpan(
                                        text:
                                            '${value.tripsList[index].distance}',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const TextSpan(
                                        text: ' Km',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: value.tripsList[index].status == 1
                                    ? Colors.green
                                    : Colors.red,
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(7.0),
                                border: Border.all(
                                    color: const Color(0x4d9e9e9e), width: 0),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(15, 3, 15, 3),
                                child: value.tripsList[index].status == 1
                                    ? const Text(
                                        'Trip ',
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      )
                                    : const Text(
                                        'Stop ',
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.speed,
                                  size: 17,
                                  color: Colors.grey,
                                ),
                                const VerticalDivider(width: 3),
                                RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 12),
                                    text: 'Max.Speed: ',
                                    children: [
                                      TextSpan(
                                        text:
                                            '${value.tripsList[index].topSpeed}',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const TextSpan(
                                        text: ' kph',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.play_circle_outline_outlined,
                                  size: 17,
                                  color: Colors.grey,
                                ),
                                VerticalDivider(width: 3),
                                Text(
                                  'Start:',
                                  style: TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                            Text(
                              value.tripsList[index].tripStart.toString(),
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.alarm,
                                  size: 17,
                                  color: Colors.grey,
                                ),
                                VerticalDivider(width: 3),
                                Text(
                                  'Duration:',
                                  style: TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                            Text(
                              value.tripsList[index].totalTripDuration
                                  .toString(),
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.stop_circle_outlined,
                                  size: 17,
                                  color: Colors.grey,
                                ),
                                VerticalDivider(width: 3),
                                Text(
                                  'End:',
                                  style: TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                            Text(
                              value.tripsList[index].tripEnd.toString(),
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(
          height: 10,
        ),
        const SizedBox(
          height: 20,
        )
      ],
    );
  }
}
