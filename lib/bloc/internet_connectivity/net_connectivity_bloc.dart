import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:connectivity/connectivity.dart';
part 'net_connectivity_event.dart';
part 'net_connectivity_state.dart';

class NetConnectivityBloc
    extends Bloc<NetConnectivityEvent, NetConnectivityState> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? connectivitySubscription;
  NetConnectivityBloc() : super(NetConnectivityInitial()) {
    on<NetConnectivityLostEvent>(
        (event, emit) => emit(NetConnectivityLostState()));

    on<NetConnectivityConnectedEvent>(
        (event, emit) => emit(NetConnectivityGainState()));

    connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((result) {
      if (result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi) {
        add(NetConnectivityConnectedEvent());
      } else {
        add(NetConnectivityLostEvent());
      }
    });
  }
  @override
  Future<void> close() {
    connectivitySubscription?.cancel();
    return super.close();
  }
}
