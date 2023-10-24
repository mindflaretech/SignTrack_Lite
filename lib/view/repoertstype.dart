import 'package:autotelematic_new_app/model/viewreportinitialdata.dart';
import 'package:autotelematic_new_app/utils/routes/routes_names.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:autotelematic_new_app/cubit/reportstype_cubit.dart';
import 'package:autotelematic_new_app/model/devicedatamodalforhistoryandreport.dart';
import 'package:autotelematic_new_app/res/apptheme.dart';

class ReportTypesScreen extends StatefulWidget {
  final DeviceDataForReportsAndHistory deviceDataForReportsAndHistory;

  const ReportTypesScreen({
    Key? key,
    required this.deviceDataForReportsAndHistory,
  }) : super(key: key);

  @override
  State<ReportTypesScreen> createState() => _ReportTypesScreenState();
}

class _ReportTypesScreenState extends State<ReportTypesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.directions_car_filled_outlined, size: 20),
                    Text(
                      widget.deviceDataForReportsAndHistory.deviceTitle
                          .toString(),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text('To:', style: Theme.of(context).textTheme.labelSmall),
                    const Icon(Icons.calendar_month_outlined, size: 20),
                    Text(
                        widget.deviceDataForReportsAndHistory.fromDate
                            .toString(),
                        style: Theme.of(context).textTheme.labelSmall),
                  ],
                ),
                Row(
                  children: [
                    Text('From:',
                        style: Theme.of(context).textTheme.labelSmall),
                    const Icon(Icons.calendar_month_outlined, size: 20),
                    Text(
                        widget.deviceDataForReportsAndHistory.toDate.toString(),
                        style: Theme.of(context).textTheme.labelSmall),
                  ],
                ),
              ],
            ),
          ),
          BlocBuilder<ReportstypeCubit, ReportstypeState>(
            builder: (context, state) {
              if (state is ReportstypeLoading) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppTheme.loadingImage,
                      const SizedBox(
                        height: 5,
                      ),
                      const Text('Loading...'),
                    ],
                  ),
                );
              }
              if (state is ReportstypeError) {
                return Center(
                  child: Text(state.message),
                );
              }

              if (state is ReportstypeLoadingComplete) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: state.reportTypeModel.items?.length ?? 0,
                    itemBuilder: (context, index) {
                      final item =
                          state.reportTypeModel.items![index].name.toString();
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, RoutesName.viewReport,
                                arguments: ViewReportIntialData(
                                    widget.deviceDataForReportsAndHistory
                                        .fromDate,
                                    widget
                                        .deviceDataForReportsAndHistory.toDate,
                                    widget.deviceDataForReportsAndHistory
                                        .deviceId,
                                    'pdf',
                                    state.reportTypeModel.items![index].type));
                          },
                          child: Card(
                            child: ListTile(
                              leading: Text(item),
                              trailing: const Icon(Icons.arrow_forward),
                            ),
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
                    const Text('Loading...'),
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
