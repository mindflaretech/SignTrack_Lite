import 'package:autotelematic_new_app/cubit/home_cubit.dart';
import 'package:autotelematic_new_app/model/devicedatamodalforhistoryandreport.dart';
import 'package:autotelematic_new_app/model/devicedatamodel.dart';
import 'package:autotelematic_new_app/res/api_endpoints.dart';
import 'package:autotelematic_new_app/res/apptheme.dart';
import 'package:autotelematic_new_app/utils/routes/routes_names.dart';
import 'package:autotelematic_new_app/view/customreportandhistory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class VehicleListForReprots extends StatefulWidget {
  const VehicleListForReprots({super.key});

  @override
  State<VehicleListForReprots> createState() => _VehicleListForReprotsState();
}

class _VehicleListForReprotsState extends State<VehicleListForReprots> {
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

  @override
  Widget build(BuildContext context) {
    HomeCubit homeCubit = context.read<HomeCubit>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
            child: TextField(
              onChanged: (searchKeyword) {
                runSearchFilter(searchKeyword,
                    homeCubit.deviceDataListwithGroupAndDeviceIndex);
                context.read<HomeCubit>().refreshHomeCubit();
              },
              decoration: const InputDecoration(
                  labelText: 'Search Vehicle', suffixIcon: Icon(Icons.search)),
            ),
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
              if (state is HomeError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppTheme.loadingImage,
                      const SizedBox(
                        height: 5,
                      ),
                      const Text('Error while loading data...')
                    ],
                  ),
                );
              }
              if (state is HomeLoadingComplete || state is HomeLoadingRefresh) {
                if (!isSearchResult) {
                  searchResult.clear();
                  searchResult
                      .addAll(homeCubit.deviceDataListwithGroupAndDeviceIndex);
                }
                deviceDataListResult.clear();
                for (var device in searchResult) {
                  deviceDataListResult.add(device);
                }
                return Expanded(
                    child: ListView.builder(
                  itemCount: deviceDataListResult.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                          trailing: PopupMenuButton(
                            onSelected: ((value) {
                              String toDate;
                              String fromDate;
                              String fromTime = '00:00:01';
                              String toTime = '23:59:00';
                              DateTime dt;
                              DateFormat newFormat;
                              dt = DateTime.now();
                              newFormat = DateFormat("yy-MM-dd");
                              toDate = newFormat.format(dt);
                              switch (value) {
                                case 0:
                                  print(
                                      'today Selected ${deviceDataListResult[index].deviceData['name']}');
                                  toDate = newFormat.format(dt);
                                  fromDate = newFormat.format(dt);
                                  toDate = newFormat
                                      .format(dt.add(const Duration(days: 1)));
                                  Navigator.pushNamed(
                                    context,
                                    RoutesName.reportTypes,
                                    arguments: DeviceDataForReportsAndHistory(
                                        deviceId: deviceDataListResult[index]
                                            .deviceData['id'],
                                        deviceTitle: deviceDataListResult[index]
                                            .deviceData['name'],
                                        fromDate: fromDate,
                                        toDate: toDate,
                                        fromTime: fromTime,
                                        toTime: toTime),
                                  );
                                  break;

                                case 1:
                                  fromDate = newFormat.format(
                                      dt.subtract(const Duration(days: 1)));
                                  toDate = newFormat.format(dt);
                                  Navigator.pushNamed(
                                    context,
                                    RoutesName.reportTypes,
                                    arguments: DeviceDataForReportsAndHistory(
                                        deviceId: deviceDataListResult[index]
                                            .deviceData['id'],
                                        deviceTitle: deviceDataListResult[index]
                                            .deviceData['name'],
                                        fromDate: fromDate,
                                        toDate: toDate,
                                        fromTime: fromTime,
                                        toTime: toTime),
                                  );
                                  break;
                                case 7:
                                  toDate = newFormat.format(dt);
                                  fromDate = newFormat.format(
                                      dt.subtract(const Duration(days: 7)));
                                  Navigator.pushNamed(
                                    context,
                                    RoutesName.reportTypes,
                                    arguments: DeviceDataForReportsAndHistory(
                                        deviceId: deviceDataListResult[index]
                                            .deviceData['id'],
                                        deviceTitle: deviceDataListResult[index]
                                            .deviceData['name'],
                                        fromDate: fromDate,
                                        toDate: toDate,
                                        fromTime: fromTime,
                                        toTime: toTime),
                                  );
                                  break;
                                case 30:
                                  toDate = newFormat.format(dt);
                                  fromDate = newFormat.format(
                                      dt.subtract(const Duration(days: 30)));
                                  Navigator.pushNamed(
                                    context,
                                    RoutesName.reportTypes,
                                    arguments: DeviceDataForReportsAndHistory(
                                        deviceId: deviceDataListResult[index]
                                            .deviceData['id'],
                                        deviceTitle: deviceDataListResult[index]
                                            .deviceData['name'],
                                        fromDate: fromDate,
                                        toDate: toDate,
                                        fromTime: fromTime,
                                        toTime: toTime),
                                  );
                                  break;
                                case 2:
                                  showDatePickerDialog(
                                      context,
                                      'reporttype',
                                      deviceDataListResult[index]
                                          .deviceData['name']
                                          .toString(),
                                      int.parse(deviceDataListResult[index]
                                          .deviceData['id']
                                          .toString()));
                                  break;

                                default:
                                  toDate = newFormat.format(dt);
                                  fromDate = newFormat.format(dt);
                                  Navigator.pushNamed(
                                    context,
                                    RoutesName.reportTypes,
                                    arguments: DeviceDataForReportsAndHistory(
                                        deviceId: deviceDataListResult[index]
                                            .deviceData['id'],
                                        deviceTitle: deviceDataListResult[index]
                                            .deviceData['name'],
                                        fromDate: fromDate,
                                        toDate: toDate,
                                        fromTime: fromTime,
                                        toTime: toTime),
                                  );
                              }
                            }),
                            itemBuilder: (context) {
                              return const [
                                PopupMenuItem(
                                  value: 0,
                                  child: Text('Today'),
                                ),
                                PopupMenuItem(
                                  value: 1,
                                  child: Text('yesterday'),
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
                                  child: Text('Custom Date'),
                                ),
                              ];
                            },
                          ),
                          title: Text(
                            deviceDataListResult[index].deviceData['name'],
                          ),
                          leading: Image.network(ApiEndpointUrls.baseImgURL +
                              deviceDataListResult[index].deviceData['icon']
                                  ['path'])),
                    );
                  },
                ));
              }
              return Container();
            },
          )
        ],
      ),
    );
  }
}
