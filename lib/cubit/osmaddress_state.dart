part of 'osmaddress_cubit.dart';

abstract class OsmaddressState {
  const OsmaddressState();
}

class OsmaddressInitial extends OsmaddressState {}

class OsmaddressLoading extends OsmaddressState {}

class OsmaddressError extends OsmaddressState {
  String message;
  OsmaddressError(this.message);
}

class OsmaddressLoadingComplete extends OsmaddressState {
  OsmAddressModel osmAddressModel = OsmAddressModel();
  OsmaddressLoadingComplete(this.osmAddressModel);
}
