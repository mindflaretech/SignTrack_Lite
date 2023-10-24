import 'package:autotelematic_new_app/cubit/home_cubit.dart';
import 'package:autotelematic_new_app/res/apptheme.dart';
import 'package:autotelematic_new_app/utils/routes/routes_names.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:video_player/video_player.dart';

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({super.key});

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  Legend legendProperties = Legend(
      alignment: ChartAlignment.center,
      overflowMode: LegendItemOverflowMode.wrap,
      isVisible: true,
      position: LegendPosition.bottom,
      isResponsive: true,
      width: '100%',
      orientation: LegendItemOrientation.auto);

  DataLabelSettings vehicleStatusGraphLableSettings = const DataLabelSettings(
      isVisible: true,
      labelPosition: ChartDataLabelPosition.inside,
      showZeroValue: false,
      useSeriesColor: true);
  late VideoPlayerController _videoPlayerController;
  List<Color> sfgPaletteColor = [
    Colors.green,
    Colors.red,
    Colors.yellow,
    Colors.blue,
    Colors.grey,
    const Color.fromARGB(255, 138, 13, 4)
  ];
  Future<bool> _onWillPop(context) async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Are you sure?'),
            content: const Text('Do you want to exit the App'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  final TooltipBehavior _tooltip = TooltipBehavior(enable: true);
  @override
  void initState() {
    _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse('https://world.autotel.pk/images/appvideo.mp4'))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {
          _videoPlayerController.setLooping(true);
          _videoPlayerController.play();
        });
      });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final homeCubit = BlocProvider.of<HomeCubit>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard'), centerTitle: true),
      body: BlocBuilder<HomeCubit, HomeState>(
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
            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Center(
                  //   child: SizedBox(
                  //     width: MediaQuery.of(context).size.width * 0.95,
                  //     child: SfCircularChart(
                  //       margin: const EdgeInsets.all(0),
                  //       // title: ChartTitle(text: 'Vehicle Status'),
                  //       tooltipBehavior: _tooltip,
                  //       annotations: <CircularChartAnnotation>[
                  //         CircularChartAnnotation(
                  //           widget: CircleAvatar(
                  //             backgroundColor: Colors.black,
                  //             radius: 21,
                  //             child: CircleAvatar(
                  //               backgroundColor: Colors.white,
                  //               radius: 20,
                  //               child: Text(
                  //                 homeCubit.devicesList.length.toString(),
                  //                 style: const TextStyle(
                  //                   color: Colors.black54,
                  //                   fontSize: 15,
                  //                 ),
                  //               ),
                  //             ),
                  //           ),
                  //         )
                  //       ],
                  //       legend: legendProperties,
                  //       // palette: sfgPaletteColor,
                  //       series: <CircularSeries>[
                  //         PieSeries<ChartData, String>(
                  //           onPointTap: (ChartPointDetails details) {
                  //             homeCubit.setHomeIndex(1);
                  //           },
                  //           dataLabelSettings: vehicleStatusGraphLableSettings,
                  //           dataSource: homeCubit.vehicleStatusCountdata,
                  //           xValueMapper: (ChartData data, _) => data.x,
                  //           yValueMapper: (ChartData data, _) => data.y,
                  //         )
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  // const SizedBox(
                  //   height: 7,
                  // ),
                  SfCartesianChart(
                    margin: const EdgeInsets.all(15),
                    primaryXAxis: CategoryAxis(),
                    primaryYAxis: NumericAxis(
                        minimum: 0,
                        maximum: double.parse(
                            homeCubit.devicesList.length.toString()),
                        interval: 1),
                    tooltipBehavior: _tooltip,
                    legend: legendProperties,
                    //   palette: sfgPaletteColor,
                    series: <ChartSeries<ChartData, String>>[
                      ColumnSeries<ChartData, String>(
                          dataSource: homeCubit.vehicleStatusCountdata,
                          xValueMapper: (ChartData data, _) => data.x,
                          yValueMapper: (ChartData data, _) => data.y,
                          pointColorMapper: (ChartData data, _) => data.color,
                          onPointTap: (ChartPointDetails details) {
                            // homeCubit.setHomeIndex(1);
                          },
                          name: 'Vehicles Status',
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(5),
                            topRight: Radius.circular(5),
                          )
                          //   color: Color.fromRGBO(8, 142, 255, 1),
                          )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            SizedBox(
                              height: 150,
                              width: 150,
                              child: InkWell(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, RoutesName.deviceListForReports);
                                },
                                child: Card(
                                  // shape: AppColors.cardBorderShape,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Text(
                                        'Reports',
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Image(
                                          image: AssetImage(
                                              'assets/images/ComboChart_48px.png'),
                                          height: 60,
                                          width: 60,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 150,
                              width: 150,
                              child: InkWell(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, RoutesName.deviceListForHistory);
                                },
                                child: Card(
                                  // shape: AppColors.cardBorderShape,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Text(
                                        'History',
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Image(
                                            image: AssetImage(
                                                'assets/images/TimeMachine_50px.png'),
                                            height: 50,
                                            width: 50),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  // const SizedBox(
                  //   height: 7,
                  // ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            SizedBox(
                              height: 150,
                              width: 150,
                              child: InkWell(
                                onTap: () {
                                  homeCubit.setHomeIndex(2);
                                },
                                child: Card(
                                  // shape: AppColors.cardBorderShape,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Text(
                                        'Map',
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Image(
                                            image: AssetImage(
                                                'assets/images/TrackOrder_48px.png'),
                                            height: 45,
                                            width: 58),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 150,
                              width: 150,
                              child: InkWell(
                                onTap: () {
                                  homeCubit.setHomeIndex(3);
                                },
                                child: Card(
                                  // shape: AppColors.cardBorderShape,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Text(
                                        'Alerts',
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Image(
                                            image: AssetImage(
                                                'assets/images/notification-96.png'),
                                            height: 45,
                                            width: 45),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 7,
                  ),
                  Row(
                    children: [
                      Card(
                        // shape: AppColors.cardBorderShape,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 15,
                        ),
                        child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            // ignore: sized_box_for_whitespace
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.90,
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Column(
                                  children: const [
                                    Text(
                                      '!انتباہ',
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Divider(height: 5),
                                    Text(
                                        'ٹریکر ڈیوائس موٹر انشورنس کے متبادل نہیں ہے اور نا ہی چوری کو روکنے کا آلہ ہے، کمپنی گاڑی چوری کی صورت میں زمہ دار نہیں ہوگی۔',
                                        textAlign: TextAlign.center),
                                  ],
                                ),
                              ),
                            )),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 7,
                  ),

                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Powered by Auto Telematics Pvt. Ltd.',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  )
                ],
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
    );
  }
}

class _ChartData {
  _ChartData(this.x, this.y);

  final String x;
  final double y;
}
