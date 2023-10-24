import 'package:autotelematic_new_app/cubit/osmaddress_cubit.dart';
import 'package:autotelematic_new_app/model/events_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EventsOnMapScreen extends StatefulWidget {
  final Data eventData; // Declare eventData as a final property
  const EventsOnMapScreen({Key? key, required this.eventData})
      : super(key: key);

  @override
  State<EventsOnMapScreen> createState() => _EventsOnMapScreenState();
}

class _EventsOnMapScreenState extends State<EventsOnMapScreen> {
  final List<Marker> _markers = [];
  late GoogleMapController _controller;
  OsmaddressCubit osmaddressCubit = OsmaddressCubit();
  @override
  void initState() {
    _markers.add(Marker(
      markerId: const MarkerId('1'),
      position: LatLng(double.parse(widget.eventData.latitude.toString()),
          double.parse(widget.eventData.longitude.toString())),
      infoWindow: InfoWindow(title: widget.eventData.deviceName),
      icon: BitmapDescriptor.defaultMarker,
      //rotation: direction,
    ));
    osmaddressCubit.fetchOSMAddress(
        widget.eventData.latitude, widget.eventData.longitude);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
      ),
      floatingActionButton: FloatingActionButton.small(
        child: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      body: Stack(
        children: [
          GoogleMap(
            minMaxZoomPreference: const MinMaxZoomPreference(1, 21),
            initialCameraPosition: CameraPosition(
              target: LatLng(double.parse(widget.eventData.latitude.toString()),
                  double.parse(widget.eventData.longitude.toString())),
              zoom: 15,
            ),
            onCameraMove: (position) {},
            markers: Set<Marker>.of(_markers),
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
              _controller.showMarkerInfoWindow(const MarkerId('1'));
            },
            padding: const EdgeInsets.only(bottom: 70, right: 7),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 1,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Row(
                              children: [
                                const Icon(Icons.notifications_none_outlined),
                                const VerticalDivider(),
                                Text(
                                  widget.eventData.message.toString(),
                                  style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Row(
                              children: [
                                const Icon(Icons.alarm),
                                const VerticalDivider(),
                                Text(widget.eventData.time.toString(),
                                    style:
                                        Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Row(
                              children: [
                                const Icon(Icons.speed),
                                const VerticalDivider(),
                                Text('${widget.eventData.speed} km/h',
                                    style:
                                        Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Row(
                              children: [
                                const Icon(Icons.pin_drop_outlined),
                                const VerticalDivider(),
                                BlocProvider<OsmaddressCubit>(
                                  create: (context) => osmaddressCubit,
                                  child: BlocBuilder<OsmaddressCubit,
                                      OsmaddressState>(
                                    builder: (context, state) {
                                      if (state is OsmaddressLoading) {
                                        return const Text('fetching address');
                                      }
                                      if (state is OsmaddressError) {
                                        return Text(state.message);
                                      }
                                      if (state is OsmaddressLoadingComplete) {
                                        return Expanded(
                                          child: Text(state
                                                  .osmAddressModel
                                                  .features
                                                  ?.first
                                                  .properties
                                                  ?.displayName
                                                  .toString() ??
                                              'Unknowm Address'),
                                        );
                                      }
                                      return Text(
                                          widget.eventData.message.toString(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
