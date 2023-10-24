part of 'events_cubit.dart';

abstract class EventsState {
  const EventsState();
}

class EventsInitial extends EventsState {}

class EventsLoading extends EventsState {}

class EventsLoadingComplete extends EventsState {
  //EventsModel eventsModel;
  List<Data> alertsDataList;
  EventsLoadingComplete(this.alertsDataList);
}

class EventsLoadingError extends EventsState {
  String message;
  EventsLoadingError(this.message);
}
