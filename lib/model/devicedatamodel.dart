import 'package:google_maps_flutter/google_maps_flutter.dart';

class DeviceData {
  dynamic deviceData;
  int? groupID;
  int? deviceIndexInGroup;
  String? groupTitle;
  Marker? deviceMarker;
  DeviceData(
      {this.deviceData,
      this.groupID,
      this.deviceIndexInGroup,
      this.groupTitle});
}
