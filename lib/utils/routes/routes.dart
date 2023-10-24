import 'package:autotelematic_new_app/bloc/internet_connectivity/net_connectivity_bloc.dart';
import 'package:autotelematic_new_app/cubit/events_cubit.dart';
import 'package:autotelematic_new_app/cubit/get_reports_cubit.dart';
import 'package:autotelematic_new_app/cubit/home_cubit.dart';
import 'package:autotelematic_new_app/cubit/reportstype_cubit.dart';
import 'package:autotelematic_new_app/cubit/setting_cubit.dart';
import 'package:autotelematic_new_app/cubit/singin_cubit.dart';
import 'package:autotelematic_new_app/model/devicedatamodalforhistoryandreport.dart';
import 'package:autotelematic_new_app/model/events_model.dart';
import 'package:autotelematic_new_app/model/viewreportinitialdata.dart';
import 'package:autotelematic_new_app/utils/routes/routes_names.dart';
import 'package:autotelematic_new_app/view/alertstypelist.dart';
import 'package:autotelematic_new_app/view/dashboard.dart';
import 'package:autotelematic_new_app/view/events.dart';
import 'package:autotelematic_new_app/view/eventsonmaps.dart';
import 'package:autotelematic_new_app/view/home.dart';
import 'package:autotelematic_new_app/view/notconnected.dart';
import 'package:autotelematic_new_app/view/repoertstype.dart';
import 'package:autotelematic_new_app/view/settings.dart';
import 'package:autotelematic_new_app/view/sign_in.dart';
import 'package:autotelematic_new_app/view/splash_screen.dart';
import 'package:autotelematic_new_app/view/vehicle_list_dashboard.dart';
import 'package:autotelematic_new_app/view/vehicle_tracking.dart';
import 'package:autotelematic_new_app/view/vehiclehistoryonmap.dart';
import 'package:autotelematic_new_app/view/vehiclelistforhistory.dart';
import 'package:autotelematic_new_app/view/vehiclelistforreports.dart';
import 'package:autotelematic_new_app/view/vehiclesensors.dart';
import 'package:autotelematic_new_app/view/viewreport.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    SinginCubit singinCubit = SinginCubit();

    switch (settings.name) {
      case RoutesName.splashSceen:
        return MaterialPageRoute(
          builder: (BuildContext context) => BlocProvider(
            create: (context) => NetConnectivityBloc(),
            child: const SplachScreen(),
          ),
        );
      case RoutesName.notConnectedSceen:
        return MaterialPageRoute(
          builder: (BuildContext context) => const NotConnectedScreen(),
        );
      case RoutesName.login:
        return MaterialPageRoute(
          builder: (BuildContext context) => BlocProvider(
            create: (context) => singinCubit,
            child: const LoginScreen(),
          ),
        );
      case RoutesName.home:
        return MaterialPageRoute(
          builder: (BuildContext context) => MultiBlocProvider(
            providers: [
              // Example Bloc providers, replace with your actual Blocs
              BlocProvider(
                create: (context) => HomeCubit()..fetchDevicesFromApi(),
              ),

              BlocProvider(
                create: (context) => EventsCubit(),
              ),
              BlocProvider(
                create: (context) =>
                    SettingCubit()..getSharedPreferenceSettings(),
              ),
            ],
            child: const HomeScreen(),
          ),
        );
      case RoutesName.dashboard:
        return MaterialPageRoute(
          builder: (BuildContext context) => BlocProvider(
            create: (context) => HomeCubit(),
            child: const DashBoardScreen(),
          ),
        );

      case RoutesName.settings:
        return MaterialPageRoute(
          builder: (BuildContext context) => BlocProvider(
            create: (context) => SettingCubit(),
            child: const AppSettingsScreen(),
          ),
        );
      case RoutesName.reportTypes:
        final dataForReportsAndHistory =
            settings.arguments as DeviceDataForReportsAndHistory;
        return MaterialPageRoute(
          builder: (BuildContext context) => BlocProvider(
            create: (context) => ReportstypeCubit()..fetchReportsTypeFromApi(),
            child: ReportTypesScreen(
                deviceDataForReportsAndHistory: dataForReportsAndHistory),
          ),
        );
      case RoutesName.viewHistory:
        final dataForReportsAndHistory =
            settings.arguments as DeviceDataForReportsAndHistory;
        return MaterialPageRoute(
          builder: (BuildContext context) => VehicleHistoryOnMapScreen(
              deviceDataForReportsAndHistory: dataForReportsAndHistory),
        );
      case RoutesName.viewReport:
        final viewReportIntialData = settings.arguments as ViewReportIntialData;
        return MaterialPageRoute(
          builder: (BuildContext context) => BlocProvider(
            create: (context) => GetReportsCubit(),
            child:
                ViewReportsScreen(viewReportIntialData: viewReportIntialData),
          ),
        );
      case RoutesName.vehicleLiveTracking:
        Map<String, dynamic>? args =
            settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (BuildContext context) => VehicleTrackingOnMapScreen(
            deviceID: args?['deviceID'] ?? 0,
            groupID: args?['groupID'] ?? 0,
          ),
        );
      case RoutesName.vehiclelistdashboad:
        return MaterialPageRoute(
          builder: (BuildContext context) => const VehicleListDashBoardScreen(),
        );
      case RoutesName.deviceListForHistory:
        return MaterialPageRoute(
          builder: (BuildContext context) => BlocProvider(
            create: (context) => HomeCubit()..fetchDevicesFromApi(),
            child: const VehicleListForHistory(),
          ),
        );
      case RoutesName.deviceListForReports:
        return MaterialPageRoute(
          builder: (BuildContext context) => BlocProvider(
            create: (context) => HomeCubit()..fetchDevicesFromApi(),
            child: const VehicleListForReprots(),
          ),
        );

      case RoutesName.eventOnMap:
        Data eventData = settings.arguments as Data;
        return MaterialPageRoute(
          builder: (BuildContext context) => EventsOnMapScreen(
            eventData: eventData,
          ),
        );
      case RoutesName.vehicleSensorData:
        Map<String, dynamic>? args =
            settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (BuildContext context) => VehicleSensorsData(
            vehicleSensorsData: args?['vehicleSensorsData'] ?? [],
            vehicleName: args?['vehicleName'] ?? '',
          ),
        );

      case RoutesName.events:
        return MaterialPageRoute(
          builder: (BuildContext context) => const VehicleEventssScreen(),
        );
      case RoutesName.alertsTypeList:
        return MaterialPageRoute(
          builder: (BuildContext context) => const AlertsTypeListScreen(),
        );
      default:
        return MaterialPageRoute(
          builder: (BuildContext context) => const SplachScreen(),
        );
    }
  }
}
