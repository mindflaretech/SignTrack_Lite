part of 'vehicletracking_cubit.dart';

class VehicletrackingState {
  const VehicletrackingState();
}

class VehicletrackingInitial extends VehicletrackingState {}

class VehicletrackingLoading extends VehicletrackingState {}

class RefreshVehicleTracking extends VehicletrackingState {}

class VehicletrackingError extends VehicletrackingState {
  String message;
  VehicletrackingError(this.message);
}

class VehicletrackingLoadingComplete extends VehicletrackingState {}
