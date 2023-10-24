import 'dart:async';

import 'package:autotelematic_new_app/bloc/internet_connectivity/net_connectivity_bloc.dart';
import 'package:autotelematic_new_app/res/apptheme.dart';
import 'package:autotelematic_new_app/res/usersession.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class SplachScreen extends StatefulWidget {
  const SplachScreen({super.key});

  @override
  State<SplachScreen> createState() => _SplachScreenState();
}

class _SplachScreenState extends State<SplachScreen> {
  UserSessions userSessions = UserSessions();
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), (() async {
      userSessions.checkUserSession(context);
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<NetConnectivityBloc, NetConnectivityState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state is NetConnectivityGainState) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(50.0),
                child: Image(
                  image: AssetImage(AppTheme.logoPath),
                ),
              ),
            );
          } else if (state is NetConnectivityLostState) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(50.0),
                child: Image(
                  image: AssetImage(AppTheme.notConnectedPath),
                ),
              ),
            );
          } else {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(50.0),
                child: Image(
                  image: AssetImage(AppTheme.notConnectedPath),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
