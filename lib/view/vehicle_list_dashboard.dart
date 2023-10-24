import 'package:autotelematic_new_app/cubit/home_cubit.dart';
import 'package:autotelematic_new_app/model/devicedatamodalforhistoryandreport.dart';
import 'package:autotelematic_new_app/model/devicedatamodel.dart';
import 'package:autotelematic_new_app/res/apptheme.dart';
import 'package:autotelematic_new_app/utils/routes/routes_names.dart';
import 'package:autotelematic_new_app/view/customreportandhistory.dart';
import 'package:autotelematic_new_app/view/devicecommands.dart';
import 'package:autotelematic_new_app/widgets/circular_image_widget.dart';
import 'package:autotelematic_new_app/widgets/decive_card_style.dart';
import 'package:autotelematic_new_app/widgets/filter_option.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class VehicleListDashBoardScreen extends StatefulWidget {
  const VehicleListDashBoardScreen({super.key});

  @override
  State<VehicleListDashBoardScreen> createState() =>
      _VehicleListDashBoardScreenState();
}

class _VehicleListDashBoardScreenState
    extends State<VehicleListDashBoardScreen> {
  List<DeviceData> deviceDataListResult = [];
  List<DeviceData> searchResult = [];
  String filterStatus = 'all';
  bool isSearchResult = false;
  late String vehicleCurrentStatusFromAPI;
  late Color mainBoxbgColor;
  late Color vehicleStatuscColor;
  late String vehicleStatus;
  List<dynamic>? sensorsData;
  Color keyColor = Colors.grey;
  String? batteryVoltage;
  Color batteruChargingColor = Colors.grey;
  bool immobilizerValue = false;
  DateFormat dateFormat = DateFormat("yy-MM-dd");
  DateTime dateTimeNow = DateTime.now();

  void runSearchFilter(String enteredKeyword, List<DeviceData> devicesList) {
    List<DeviceData> results = [];

    searchResult.clear();

    if (enteredKeyword.isEmpty) {
      isSearchResult = false;
      // if the search field is empty or only contains white-space, we'll display all vehciles
      searchResult.addAll(devicesList);
    } else {
      results = devicesList
          .where((vehcile) =>
              vehcile.deviceData["name"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              vehcile.groupTitle!
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    searchResult.addAll(results);

    isSearchResult = true;
  }

  deviceListFilters(String filterVal, List<DeviceData> devicesList) async {
    searchResult.clear();

    if (filterVal == "all") {
      searchResult.addAll(devicesList);
      return;
    }
    for (var device in devicesList) {
      var deviceStatus = device.deviceData['online'];

      if (filterVal == "stopped") {
        if (deviceStatus.toLowerCase() == 'ack') {
          searchResult.add(device);
        }
      } else if (filterVal == "running") {
        if (deviceStatus.toLowerCase() == 'online') {
          searchResult.add(device);
        }
      } else if (filterVal == "idle") {
        if (deviceStatus.toLowerCase() == 'engine') {
          searchResult.add(device);
        }
      } else if (filterVal == "offline") {
        if (device.deviceData['online'] == "offline" &&
            device.deviceData['time'] != "Not connected" &&
            device.deviceData['time'] != "Expired") {
          searchResult.add(device);
        }
      } else if (filterVal == "nodata") {
        if (device.deviceData['online'] == "offline" &&
            device.deviceData['time'] == "Not connected") {
          searchResult.add(device);
        }
      } else if (filterVal == "expired") {
        if (device.deviceData['time'].toString().toLowerCase() == "expired") {
          searchResult.add(device);
        }
      }
    }
  }

  setFilterBarStatus(String status, BuildContext context) {
    filterStatus = status;
    isSearchResult = false;
    context.read<HomeCubit>().refreshHomeCubit();
  }

  void processSensorData(List<dynamic>? sensorsData) {
    if (sensorsData != null) {
      if (sensorsData.isNotEmpty) {
        for (var element in sensorsData) {
          if (element['name'] == 'Ignition' || element['name'] == 'IGNITION') {
            switch (element['value']) {
              case 'Off':
                keyColor = Colors.red;
                break;
              case 'On':
                keyColor = Colors.green;
                break;
              default:
                keyColor = Colors.grey;
            }
          }
          if (element['type'].toString().toLowerCase() == 'battery') {
            batteryVoltage = element['value'];
          }
          if (element['name'].toString().toLowerCase() == 'charging') {
            if (element['value'].toString().toLowerCase() == 'on') {
              batteruChargingColor = Colors.green;
            } else if (element['value'].toString().toLowerCase() == 'off') {
              batteruChargingColor = Colors.red;
            } else if (element['value'].toString().toLowerCase() == '') {
              batteruChargingColor = Colors.grey;
            }
          }
          if (element['name'].toString().trim() == 'Immobiliser' ||
              element['name'].toString().trim() == 'Immobilizer') {
            if (element['value'].toString().toLowerCase() == 'off') {
              immobilizerValue = false;
              // 'Immobiliser is off'; // This line does not do anything, so it's commented out.
            } else if (element['value'].toString().toLowerCase() == 'on') {
              immobilizerValue = true;
            } else {
              immobilizerValue = false;
            }
          }
        }
      }
    }
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

  Future<void> showDatePickerDialog(BuildContext context, String screenRout,
      String deviceName, int deviceID) {
    return showDialog(
      useSafeArea: true,
      barrierDismissible: false,
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomeHistoryDateTimePicker(deviceName, deviceID, screenRout),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> showDeciveCommandsPicker(int deviceID) {
    return showDialog(
      context: context,
      builder: (context) => Dialog(
        child: DeviceCommandsScreen(deviceID: deviceID),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    HomeCubit homeCubit = context.read<HomeCubit>();
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Vehicles List'),
      //   elevation: 0,
      //   centerTitle: true,
      // ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 15, 5, 5),
            child: TextField(
              onChanged: (searchKeyword) {
                runSearchFilter(searchKeyword,
                    homeCubit.deviceDataListwithGroupAndDeviceIndex);
                context.read<HomeCubit>().refreshHomeCubit();
              },
              decoration: const InputDecoration(
                  labelText: 'Search Vehicle or Group',
                  suffixIcon: Icon(Icons.search)),
            ),
          ),
          const SizedBox(
            height: 4,
          ),
          BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              if (state is HomeLoadingComplete || state is HomeLoadingRefresh) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FilterOption(
                      statusCount: context.read<HomeCubit>().allDevicesCount,
                      status: 'all',
                      onTap: (status) => setFilterBarStatus(status, context),
                    ),
                    FilterOption(
                      statusCount: context.read<HomeCubit>().runningCount,
                      status: 'running',
                      onTap: (status) => setFilterBarStatus(status, context),
                    ),
                    FilterOption(
                      statusCount: context.read<HomeCubit>().stoppedCount,
                      status: 'stopped',
                      onTap: (status) => setFilterBarStatus(status, context),
                    ),
                    FilterOption(
                      statusCount: context.read<HomeCubit>().idleCount,
                      status: 'idle',
                      onTap: (status) => setFilterBarStatus(status, context),
                    ),
                    FilterOption(
                      statusCount: context.read<HomeCubit>().offlineCount,
                      status: 'offline',
                      onTap: (status) => setFilterBarStatus(status, context),
                    ),
                    FilterOption(
                      statusCount: context.read<HomeCubit>().noDataCount,
                      status: 'nodata',
                      onTap: (status) => setFilterBarStatus(status, context),
                    ),
                    FilterOption(
                      statusCount: context.read<HomeCubit>().expiredCount,
                      status: 'expired',
                      onTap: (status) => setFilterBarStatus(status, context),
                    ),
                  ],
                );
              }
              return Container();
            },
          ),
          const SizedBox(
            height: 4,
          ),
          BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              if (state is HomeLoading) {
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
              if (state is HomeLoadingComplete || state is HomeLoadingRefresh) {
                if (!isSearchResult) {
                  deviceListFilters(filterStatus,
                      homeCubit.deviceDataListwithGroupAndDeviceIndex);
                }

                deviceDataListResult.clear();
                for (var device in searchResult) {
                  deviceDataListResult.add(device);
                }
                return Expanded(
                  child: ListView.builder(
                    itemCount: deviceDataListResult.length,
                    itemBuilder: (context, index) {
                      vehicleCurrentStatusFromAPI = deviceDataListResult[index]
                          .deviceData['online']
                          .toString()
                          .toLowerCase();
                      sensorsData =
                          deviceDataListResult[index].deviceData['sensors'];
                      processSensorData(sensorsData);
                      setVehicleStatusAndColors(vehicleCurrentStatusFromAPI);
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                        child: InkWell(
                          onTap: () {
                            showModalBottomSheet(
                              useSafeArea: true,
                              backgroundColor: Colors.black26,
                              enableDrag: true,
                              context: context,
                              builder: (context) {
                                return SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize
                                          .min, // Adjust the height based on content
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.directions_car,
                                                color: Colors.white, size: 18),
                                            const VerticalDivider(width: 2),
                                            Text(
                                              deviceDataListResult[index]
                                                  .deviceData['name'],
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(
                                          height: 15,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Column(
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    Navigator.pushNamed(
                                                        context,
                                                        RoutesName
                                                            .vehicleLiveTracking,
                                                        arguments: {
                                                          'groupID':
                                                              deviceDataListResult[
                                                                      index]
                                                                  .groupID,
                                                          'deviceID':
                                                              deviceDataListResult[
                                                                      index]
                                                                  .deviceIndexInGroup,
                                                        });
                                                  },
                                                  child:
                                                      const CircularImageWidget(
                                                    imagePath:
                                                        'assets/images/TrackOrder_48px.png',
                                                    imageSize: 35,
                                                    containerSize: 53,
                                                    containerColor:
                                                        Colors.white,
                                                    borderColor: Colors.amber,
                                                    borderWidth: 3.0,
                                                  ),
                                                ),
                                                const Text(
                                                  'Tracking',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10),
                                                ),
                                              ],
                                            ),
                                            const VerticalDivider(),
                                            Column(
                                              children: [
                                                PopupMenuButton(
                                                  onSelected: ((value) {
                                                    String toDate;
                                                    String fromDate;
                                                    String fromTime =
                                                        '00:00:01';
                                                    String toTime = '23:59:00';
                                                    DateTime dt;
                                                    DateFormat newFormat;
                                                    dt = DateTime.now();
                                                    newFormat =
                                                        DateFormat("yy-MM-dd");
                                                    toDate =
                                                        newFormat.format(dt);
                                                    switch (value) {
                                                      case 0:
                                                        toDate = newFormat
                                                            .format(dt);
                                                        fromDate = newFormat
                                                            .format(dt);
                                                        toDate = newFormat
                                                            .format(dt.add(
                                                                const Duration(
                                                                    days: 1)));
                                                        Navigator.pushNamed(
                                                          context,
                                                          RoutesName
                                                              .viewHistory,
                                                          arguments: DeviceDataForReportsAndHistory(
                                                              deviceId: deviceDataListResult[
                                                                          index]
                                                                      .deviceData[
                                                                  'id'],
                                                              deviceTitle:
                                                                  deviceDataListResult[
                                                                              index]
                                                                          .deviceData[
                                                                      'name'],
                                                              fromDate:
                                                                  fromDate,
                                                              toDate: toDate,
                                                              fromTime:
                                                                  fromTime,
                                                              toTime: toTime),
                                                        );
                                                        break;

                                                      case 1:
                                                        fromDate = newFormat
                                                            .format(dt.subtract(
                                                                const Duration(
                                                                    days: 1)));
                                                        toDate = newFormat
                                                            .format(dt);
                                                        Navigator.pushNamed(
                                                          context,
                                                          RoutesName
                                                              .viewHistory,
                                                          arguments: DeviceDataForReportsAndHistory(
                                                              deviceId: deviceDataListResult[
                                                                          index]
                                                                      .deviceData[
                                                                  'id'],
                                                              deviceTitle:
                                                                  deviceDataListResult[
                                                                              index]
                                                                          .deviceData[
                                                                      'name'],
                                                              fromDate:
                                                                  fromDate,
                                                              toDate: toDate,
                                                              fromTime:
                                                                  fromTime,
                                                              toTime: toTime),
                                                        );
                                                        break;
                                                      case 7:
                                                        toDate = newFormat
                                                            .format(dt);
                                                        fromDate = newFormat
                                                            .format(dt.subtract(
                                                                const Duration(
                                                                    days: 7)));
                                                        Navigator.pushNamed(
                                                          context,
                                                          RoutesName
                                                              .viewHistory,
                                                          arguments: DeviceDataForReportsAndHistory(
                                                              deviceId: deviceDataListResult[
                                                                          index]
                                                                      .deviceData[
                                                                  'id'],
                                                              deviceTitle:
                                                                  deviceDataListResult[
                                                                              index]
                                                                          .deviceData[
                                                                      'name'],
                                                              fromDate:
                                                                  fromDate,
                                                              toDate: toDate,
                                                              fromTime:
                                                                  fromTime,
                                                              toTime: toTime),
                                                        );
                                                        break;
                                                      case 30:
                                                        toDate = newFormat
                                                            .format(dt);
                                                        fromDate = newFormat
                                                            .format(dt.subtract(
                                                                const Duration(
                                                                    days: 30)));
                                                        Navigator.pushNamed(
                                                          context,
                                                          RoutesName
                                                              .viewHistory,
                                                          arguments: DeviceDataForReportsAndHistory(
                                                              deviceId: deviceDataListResult[
                                                                          index]
                                                                      .deviceData[
                                                                  'id'],
                                                              deviceTitle:
                                                                  deviceDataListResult[
                                                                              index]
                                                                          .deviceData[
                                                                      'name'],
                                                              fromDate:
                                                                  fromDate,
                                                              toDate: toDate,
                                                              fromTime:
                                                                  fromTime,
                                                              toTime: toTime),
                                                        );
                                                        break;
                                                      case 2:
                                                        showDatePickerDialog(
                                                            context,
                                                            'playroutonmap',
                                                            deviceDataListResult[
                                                                    index]
                                                                .deviceData[
                                                                    'name']
                                                                .toString(),
                                                            int.parse(
                                                                deviceDataListResult[
                                                                        index]
                                                                    .deviceData[
                                                                        'id']
                                                                    .toString()));
                                                        break;

                                                      default:
                                                        toDate = newFormat
                                                            .format(dt);
                                                        fromDate = newFormat
                                                            .format(dt);
                                                        Navigator.pushNamed(
                                                          context,
                                                          RoutesName
                                                              .viewHistory,
                                                          arguments: DeviceDataForReportsAndHistory(
                                                              deviceId: deviceDataListResult[
                                                                          index]
                                                                      .deviceData[
                                                                  'id'],
                                                              deviceTitle:
                                                                  deviceDataListResult[
                                                                              index]
                                                                          .deviceData[
                                                                      'name'],
                                                              fromDate:
                                                                  fromDate,
                                                              toDate: toDate,
                                                              fromTime:
                                                                  fromTime,
                                                              toTime: toTime),
                                                        );
                                                    }
                                                  }),
                                                  padding:
                                                      const EdgeInsets.all(0.0),
                                                  icon:
                                                      const CircularImageWidget(
                                                    imagePath:
                                                        'assets/images/TimeMachine_50px.png',
                                                    imageSize: 30,
                                                    containerSize: 53,
                                                    containerColor:
                                                        Colors.white,
                                                    borderColor: Colors.amber,
                                                    borderWidth: 3.0,
                                                  ),
                                                  itemBuilder: (context) {
                                                    return const [
                                                      PopupMenuItem(
                                                        value: 0,
                                                        child: Text('Today'),
                                                      ),
                                                      PopupMenuItem(
                                                        value: 1,
                                                        child:
                                                            Text('yesterday'),
                                                      ),
                                                      PopupMenuItem(
                                                        value: 7,
                                                        child: Text('7 Days'),
                                                      ),
                                                      PopupMenuItem(
                                                        value: 30,
                                                        child: Text('30 Days'),
                                                      ),
                                                      PopupMenuItem(
                                                        value: 2,
                                                        child:
                                                            Text('Custom Date'),
                                                      ),
                                                    ];
                                                  },
                                                ),
                                                const Text(
                                                  'History',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10),
                                                ),
                                              ],
                                            ),
                                            const VerticalDivider(),
                                            Column(
                                              children: [
                                                PopupMenuButton(
                                                  onSelected: ((value) {
                                                    String toDate;
                                                    String fromDate;
                                                    String fromTime =
                                                        '00:00:01';
                                                    String toTime = '23:59:00';
                                                    DateTime dt;
                                                    DateFormat newFormat;
                                                    dt = DateTime.now();
                                                    newFormat =
                                                        DateFormat("yy-MM-dd");
                                                    toDate =
                                                        newFormat.format(dt);
                                                    switch (value) {
                                                      case 0:
                                                        print(
                                                            'today Selected ${deviceDataListResult[index].deviceData['name']}');
                                                        toDate = newFormat
                                                            .format(dt);
                                                        fromDate = newFormat
                                                            .format(dt);
                                                        toDate = newFormat
                                                            .format(dt.add(
                                                                const Duration(
                                                                    days: 1)));
                                                        Navigator.pushNamed(
                                                          context,
                                                          RoutesName
                                                              .reportTypes,
                                                          arguments: DeviceDataForReportsAndHistory(
                                                              deviceId: deviceDataListResult[
                                                                          index]
                                                                      .deviceData[
                                                                  'id'],
                                                              deviceTitle:
                                                                  deviceDataListResult[
                                                                              index]
                                                                          .deviceData[
                                                                      'name'],
                                                              fromDate:
                                                                  fromDate,
                                                              toDate: toDate,
                                                              fromTime:
                                                                  fromTime,
                                                              toTime: toTime),
                                                        );
                                                        break;

                                                      case 1:
                                                        fromDate = newFormat
                                                            .format(dt.subtract(
                                                                const Duration(
                                                                    days: 1)));
                                                        toDate = newFormat
                                                            .format(dt);
                                                        Navigator.pushNamed(
                                                          context,
                                                          RoutesName
                                                              .reportTypes,
                                                          arguments: DeviceDataForReportsAndHistory(
                                                              deviceId: deviceDataListResult[
                                                                          index]
                                                                      .deviceData[
                                                                  'id'],
                                                              deviceTitle:
                                                                  deviceDataListResult[
                                                                              index]
                                                                          .deviceData[
                                                                      'name'],
                                                              fromDate:
                                                                  fromDate,
                                                              toDate: toDate,
                                                              fromTime:
                                                                  fromTime,
                                                              toTime: toTime),
                                                        );
                                                        break;
                                                      case 7:
                                                        toDate = newFormat
                                                            .format(dt);
                                                        fromDate = newFormat
                                                            .format(dt.subtract(
                                                                const Duration(
                                                                    days: 7)));
                                                        Navigator.pushNamed(
                                                          context,
                                                          RoutesName
                                                              .reportTypes,
                                                          arguments: DeviceDataForReportsAndHistory(
                                                              deviceId: deviceDataListResult[
                                                                          index]
                                                                      .deviceData[
                                                                  'id'],
                                                              deviceTitle:
                                                                  deviceDataListResult[
                                                                              index]
                                                                          .deviceData[
                                                                      'name'],
                                                              fromDate:
                                                                  fromDate,
                                                              toDate: toDate,
                                                              fromTime:
                                                                  fromTime,
                                                              toTime: toTime),
                                                        );
                                                        break;
                                                      case 30:
                                                        toDate = newFormat
                                                            .format(dt);
                                                        fromDate = newFormat
                                                            .format(dt.subtract(
                                                                const Duration(
                                                                    days: 30)));
                                                        Navigator.pushNamed(
                                                          context,
                                                          RoutesName
                                                              .reportTypes,
                                                          arguments: DeviceDataForReportsAndHistory(
                                                              deviceId: deviceDataListResult[
                                                                          index]
                                                                      .deviceData[
                                                                  'id'],
                                                              deviceTitle:
                                                                  deviceDataListResult[
                                                                              index]
                                                                          .deviceData[
                                                                      'name'],
                                                              fromDate:
                                                                  fromDate,
                                                              toDate: toDate,
                                                              fromTime:
                                                                  fromTime,
                                                              toTime: toTime),
                                                        );
                                                        break;
                                                      case 2:
                                                        showDatePickerDialog(
                                                            context,
                                                            'reporttype',
                                                            deviceDataListResult[
                                                                    index]
                                                                .deviceData[
                                                                    'name']
                                                                .toString(),
                                                            int.parse(
                                                                deviceDataListResult[
                                                                        index]
                                                                    .deviceData[
                                                                        'id']
                                                                    .toString()));
                                                        break;

                                                      default:
                                                        toDate = newFormat
                                                            .format(dt);
                                                        fromDate = newFormat
                                                            .format(dt);
                                                        Navigator.pushNamed(
                                                          context,
                                                          RoutesName
                                                              .reportTypes,
                                                          arguments: DeviceDataForReportsAndHistory(
                                                              deviceId: deviceDataListResult[
                                                                          index]
                                                                      .deviceData[
                                                                  'id'],
                                                              deviceTitle:
                                                                  deviceDataListResult[
                                                                              index]
                                                                          .deviceData[
                                                                      'name'],
                                                              fromDate:
                                                                  fromDate,
                                                              toDate: toDate,
                                                              fromTime:
                                                                  fromTime,
                                                              toTime: toTime),
                                                        );
                                                    }
                                                  }),
                                                  padding:
                                                      const EdgeInsets.all(0.0),
                                                  icon:
                                                      const CircularImageWidget(
                                                    imagePath:
                                                        'assets/images/ComboChart_48px.png',
                                                    imageSize: 30,
                                                    containerSize: 53,
                                                    containerColor:
                                                        Colors.white,
                                                    borderColor: Colors.amber,
                                                    borderWidth: 3.0,
                                                  ),
                                                  itemBuilder: (context) {
                                                    return const [
                                                      PopupMenuItem(
                                                        value: 0,
                                                        child: Text('Today'),
                                                      ),
                                                      PopupMenuItem(
                                                        value: 1,
                                                        child:
                                                            Text('yesterday'),
                                                      ),
                                                      PopupMenuItem(
                                                        value: 7,
                                                        child: Text('7 Days'),
                                                      ),
                                                      PopupMenuItem(
                                                        value: 30,
                                                        child: Text('30 Days'),
                                                      ),
                                                      PopupMenuItem(
                                                        value: 2,
                                                        child:
                                                            Text('Custom Date'),
                                                      ),
                                                    ];
                                                  },
                                                ),
                                                const Text(
                                                  'Reports',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 15),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            InkWell(
                                              onTap: () =>
                                                  showDeciveCommandsPicker(
                                                      int.parse(
                                                          deviceDataListResult[
                                                                  index]
                                                              .deviceData['id']
                                                              .toString())),
                                              child: Column(
                                                children: const [
                                                  CircularImageWidget(
                                                    imagePath:
                                                        'assets/images/Lock_48px.png',
                                                    imageSize: 30,
                                                    containerSize: 53,
                                                    containerColor:
                                                        Colors.white,
                                                    borderColor: Colors.amber,
                                                    borderWidth: 3.0,
                                                  ),
                                                  Text(
                                                    'Imobilizer',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const VerticalDivider(),
                                            Column(
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    Navigator.pushNamed(
                                                      context,
                                                      RoutesName
                                                          .vehicleSensorData,
                                                      arguments: {
                                                        'vehicleSensorsData':
                                                            deviceDataListResult[
                                                                        index]
                                                                    .deviceData[
                                                                'sensors'],
                                                        'vehicleName':
                                                            deviceDataListResult[
                                                                        index]
                                                                    .deviceData[
                                                                'name'],
                                                      },
                                                    );
                                                  },
                                                  child:
                                                      const CircularImageWidget(
                                                    imagePath:
                                                        'assets/images/Pressure_40px.png',
                                                    imageSize: 30,
                                                    containerSize: 53,
                                                    containerColor:
                                                        Colors.white,
                                                    borderColor: Colors.amber,
                                                    borderWidth: 3.0,
                                                  ),
                                                ),
                                                const Text(
                                                  'Sensors',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10),
                                                ),
                                              ],
                                            ),
                                            const VerticalDivider(),
                                            Column(
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    Share.share(
                                                        'https://www.google.com/maps/search/?api=1&map_action=pano&query=${deviceDataListResult[index].deviceData['lat']},${deviceDataListResult[index].deviceData['lng']}');
                                                  },
                                                  child:
                                                      const CircularImageWidget(
                                                    imagePath:
                                                        'assets/images/Share_48px.png',
                                                    imageSize: 30,
                                                    containerSize: 53,
                                                    containerColor:
                                                        Colors.white,
                                                    borderColor: Colors.amber,
                                                    borderWidth: 3.0,
                                                  ),
                                                ),
                                                const Text(
                                                  'Share',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),

                                        // Add more widgets here if needed
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: DeviceInfoCardStyle(
                            name:
                                deviceDataListResult[index].deviceData['name'],
                            groupTitle: deviceDataListResult[index].groupTitle!,
                            speed: deviceDataListResult[index]
                                .deviceData['speed']
                                .toString(),
                            vehicleStatus: vehicleStatus,
                            stopTime: deviceDataListResult[index]
                                .deviceData['stop_duration'],
                            lastUpdateTime:
                                deviceDataListResult[index].deviceData['time'],
                            iconPathfromApi: deviceDataListResult[index]
                                .deviceData['icon']['path'],
                            immobilizerValue: immobilizerValue,
                            batteryVoltage: batteryVoltage ?? '0%',
                            backgroundColor: mainBoxbgColor,
                            vehicleStatusColor: vehicleStatuscColor,
                            keyColor: keyColor,
                            batteryChargingColor: batteruChargingColor,
                            deviceLat: double.parse(deviceDataListResult[index]
                                .deviceData['lat']
                                .toString()),
                            deviceLng: double.parse(deviceDataListResult[index]
                                .deviceData['lng']
                                .toString()),
                            osmaddressCubit:
                                homeCubit.osmAddressCubitList[index],
                          ),
                        ),
                      );
                    },
                  ),
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
        ],
      ),
    );
  }
}
