import 'package:autotelematic_new_app/cubit/osmaddress_cubit.dart';
import 'package:autotelematic_new_app/res/api_endpoints.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DeviceInfoCardStyle extends StatelessWidget {
  final String name;
  final String groupTitle;
  final String speed;
  final String vehicleStatus;
  final String stopTime;
  final String lastUpdateTime;
  final String iconPathfromApi;
  final bool immobilizerValue;
  final String batteryVoltage;
  final Color backgroundColor;
  final Color vehicleStatusColor;
  final Color keyColor;
  final Color batteryChargingColor;
  final double deviceLat;
  final double deviceLng;
  final OsmaddressCubit osmaddressCubit;

  const DeviceInfoCardStyle({
    required this.name,
    required this.groupTitle,
    required this.speed,
    required this.vehicleStatus,
    required this.stopTime,
    required this.lastUpdateTime,
    required this.iconPathfromApi,
    required this.immobilizerValue,
    required this.batteryVoltage,
    required this.backgroundColor,
    required this.vehicleStatusColor,
    required this.keyColor,
    required this.batteryChargingColor,
    required this.deviceLat,
    required this.deviceLng,
    required this.osmaddressCubit,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    osmaddressCubit.fetchOSMAddress(deviceLat, deviceLng);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      //color: backgroundColor
      color: vehicleStatusColor,
      child: Padding(
        padding: const EdgeInsets.only(left: 5, top: 2, right: 2, bottom: 2),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
          ),
          //color: Colors.white,
          child: Card(
            margin: EdgeInsets.all(0.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Container(
                            width: 150,
                            decoration: BoxDecoration(
                              // color: Colors.white,
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(7.0),
                              border: Border.all(
                                  color: const Color(0x4d9e9e9e), width: 0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 3, 0, 3),
                                    child: Text(
                                      name,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: vehicleStatusColor,
                                      ),
                                      softWrap: false,
                                      maxLines: 1,
                                      textAlign: TextAlign.left,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Row(
                        children: [
                          const Text(
                            'Group: ',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            groupTitle,
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // const Divider(
                //   height: 10,
                // ),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: Image(
                              image: NetworkImage(
                                ApiEndpointUrls.baseImgURL + iconPathfromApi,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              // const Icon(
                              //   size: 16,
                              //   Icons.speed,
                              // ),
                              // const VerticalDivider(
                              //   width: 4,
                              // ),
                              Text(
                                'Speed:',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              // const Icon(
                              //   Icons.webhook_outlined,
                              //   size: 18,
                              // ),
                              // const VerticalDivider(
                              //   width: 4,
                              // ),
                              Text(
                                'Status:',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              // const Icon(
                              //   Icons.access_time,
                              //   size: 18,
                              // ),
                              // const VerticalDivider(
                              //   width: 4,
                              // ),
                              Text(
                                'Update',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const VerticalDivider(
                                width: 6,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    speed,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const Text(
                                    ' km/h',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const VerticalDivider(
                                width: 6,
                              ),
                              Text(
                                vehicleStatus,
                                style: TextStyle(
                                  color: vehicleStatusColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const VerticalDivider(
                                width: 4,
                              ),
                              Text(
                                stopTime,
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              const VerticalDivider(
                                width: 6,
                              ),
                              Text(
                                lastUpdateTime,
                                style: const TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                // const Divider(indent: 5, endIndent: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 13,
                      child: immobilizerValue
                          ? const Icon(
                              Icons.lock,
                              color: Colors.red,
                              size: 18,
                            )
                          : const Icon(
                              Icons.lock_open,
                              color: Colors.green,
                              size: 18,
                            ),
                    ),
                    const CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 13,
                      child: Icon(
                        Icons.wifi,
                        color: Colors.orange,
                        size: 18,
                      ),
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 13,
                      child: Icon(
                        Icons.key_sharp,
                        color: keyColor,
                        size: 18,
                      ),
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 13,
                      child: Icon(
                        Icons.battery_charging_full_outlined,
                        color: batteryChargingColor,
                        size: 18,
                      ),
                    ),
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 13,
                          child: Icon(
                            Icons.battery_3_bar_sharp,
                            color: Colors.green,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          batteryVoltage,
                          style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                // const Divider(indent: 5, endIndent: 5),
                // You can optionally include the ChangeNotifierProvider here if needed
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BlocProvider<OsmaddressCubit>.value(
                        value: osmaddressCubit,
                        child: BlocBuilder<OsmaddressCubit, OsmaddressState>(
                          builder: (context, state) {
                            if (state is OsmaddressLoading) {
                              return const Text('fetching address...');
                            }
                            if (state is OsmaddressError) {
                              return Text(state.message);
                            }
                            if (state is OsmaddressLoadingComplete) {
                              return Expanded(
                                child: Text(
                                  state.osmAddressModel.features?.first
                                          .properties?.displayName
                                          .toString() ??
                                      'Unknown Address',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              );
                            }
                            return const Text('fetching address....');
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
