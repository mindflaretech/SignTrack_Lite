import 'package:autotelematic_new_app/cubit/device_command_list_cubit.dart';
import 'package:autotelematic_new_app/res/apptheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DeviceCommandsScreen extends StatefulWidget {
  final int deviceID;
  const DeviceCommandsScreen({super.key, required this.deviceID});

  @override
  State<DeviceCommandsScreen> createState() => _DeviceCommandsScreenState();
}

class _DeviceCommandsScreenState extends State<DeviceCommandsScreen> {
  DeviceCommandListCubit deviceCommandListCubit = DeviceCommandListCubit();
  int? groupValue;
  String deviceCommand = 'No Command';
  @override
  void initState() {
    deviceCommandListCubit.fetchCommandsList(widget.deviceID);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: BlocProvider.value(
        value: deviceCommandListCubit,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Imobilizer'),
            ),
            BlocBuilder<DeviceCommandListCubit, DeviceCommandListState>(
              builder: (context, state) {
                if (state is DeviceCommandListLoading) {
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
                if (state is DeviceCommandListError) {
                  return Center(
                    child: Text(state.message),
                  );
                }
                if (state is DeviceCommandsendComplete) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [Text('Command has been sent to device.')],
                  );
                }
                if (state is DeviceCommandListLoadingComplete) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemCount: state.deviceCommandsList.length,
                      itemBuilder: (context, index) {
                        if (state.deviceCommandsList[index].type.toString() ==
                                'custom' ||
                            state.deviceCommandsList[index].type.toString() ==
                                'engineResume' ||
                            state.deviceCommandsList[index].type.toString() ==
                                'engineStop') {
                          return Container();
                        }
                        return RadioListTile(
                          title: Text(
                              state.deviceCommandsList[index].title.toString()),
                          value: index,
                          groupValue: groupValue,
                          onChanged: (value) {
                            groupValue = value;
                            deviceCommand =
                                state.deviceCommandsList[index].type.toString();
                            setState(() {});
                          },
                        );
                      },
                    ),
                  );
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [Text('Loading....')],
                );
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.tonal(
                    onPressed: () {
                      deviceCommandListCubit.sendDeviceCommandtoAPI(
                          deviceCommand, widget.deviceID.toString());
                    },
                    child: const Text('Send')),
                const VerticalDivider(),
                FilledButton.tonal(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel')),
              ],
            ),
            const SizedBox(
              height: 5,
            )
          ],
        ),
      ),
    );
  }
}
