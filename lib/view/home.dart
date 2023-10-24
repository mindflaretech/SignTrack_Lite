import 'package:autotelematic_new_app/cubit/home_cubit.dart';
import 'package:autotelematic_new_app/utils/commonutils.dart';
import 'package:autotelematic_new_app/utils/localnotification.dart';
import 'package:autotelematic_new_app/view/dashboard.dart';
import 'package:autotelematic_new_app/view/events.dart';
import 'package:autotelematic_new_app/view/map_for_all_vehicles.dart';
import 'package:autotelematic_new_app/view/settings.dart';
import 'package:autotelematic_new_app/view/vehicle_list_dashboard.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Widget> _screens = [
    const DashBoardScreen(),
    const VehicleListDashBoardScreen(),
    const MapForAllVehiclesScreen(),
    const VehicleEventssScreen(),
    const AppSettingsScreen(),
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

  @override
  void initState() {
    FirebaseMessaging.instance.getInitialMessage().then((event) async {
      if (event != null) {
        if (event.notification != null) {
          LocalNotificationServices.showNotifiationForground(event);
          CommonUtils.showSnackbar(context, 'data updated');
          LocalNotificationServices.showNotifiationForgroundString(
              event.notification.toString(), event.notification.toString());
        }
      }
    });

    FirebaseMessaging.onMessage.listen((event) async {
      if (event.notification != null) {
        LocalNotificationServices.showNotifiationForground(event);
      }
      CommonUtils.showSnackbar(context, event.notification!.title.toString());
    });
    FirebaseMessaging.onMessageOpenedApp.listen((event) async {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final homeCubit = context.read<HomeCubit>();
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: BlocConsumer<HomeCubit, HomeState>(
        listener: (context, state) {
          if (state is HomeLoadingComplete) {
            // CommonUtils.showSnackbar(context, 'data updated');
            // LocalNotificationServices.showNotifiationForgroundString(
            //     'API updated', 'API updated');
          }
          homeCubit.stopPeriodicUpdates();
          homeCubit.startPeriodicUpdates();
        },
        builder: (context, state) {
          if (state is HomeScreenIndex) {
            return Container();
          }
          return SafeArea(
            top: false,
            child: Scaffold(
              body: _screens[homeCubit.homeCurrentIndex],
              bottomNavigationBar: Container(
                color: const Color.fromARGB(255, 255, 166, 2),
                child: BottomNavigationBar(
                  currentIndex: homeCubit.homeCurrentIndex,
                  onTap: (index) {
                    homeCubit.setHomeIndex(index);
                  },
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.dashboard_outlined),
                      label: 'Dashboard',
                      activeIcon: Icon(Icons.dashboard),
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.map_outlined),
                      label: 'Status',
                      activeIcon: Icon(Icons.map),
                    ),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.location_on_outlined),
                        label: 'Map',
                        activeIcon: Icon(Icons.location_on)),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.notifications_outlined),
                        label: 'Alerts',
                        activeIcon: Icon(Icons.notifications)),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.settings_outlined),
                        label: 'Settings',
                        activeIcon: Icon(Icons.settings)),
                  ],
                  showSelectedLabels: true,
                  selectedItemColor: Colors.blue,
                  unselectedItemColor: Colors.black,
                  selectedLabelStyle: const TextStyle(color: Colors.black87),
                  useLegacyColorScheme: false,
                  iconSize: 28.0,
                  elevation: 1,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
