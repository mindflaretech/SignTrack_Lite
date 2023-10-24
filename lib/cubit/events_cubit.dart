import 'package:autotelematic_new_app/model/events_model.dart';
import 'package:autotelematic_new_app/repository/events_repository.dart';
import 'package:autotelematic_new_app/res/usersession.dart';
import 'package:bloc/bloc.dart';

part 'events_state.dart';

class EventsCubit extends Cubit<EventsState> {
  EventsCubit() : super(EventsInitial()) {
    fetchEventsFromApi('', '', '', true);
  }

  EventsRepository eventsRepository = EventsRepository();
  EventsModel eventsModel = EventsModel();
  List<Data> alertsDataList = [];
  int totalPages = 1;

  void fetchEventsFromApi(
      String fromDate, String toDate, String pageNumber, bool isRefresh) async {
    String? userApiHashKey = await UserSessions.getUserApiHash();
    if (isRefresh) {
      alertsDataList.clear();
      // emit(EventsLoading());
    }
    try {
      eventsModel = await eventsRepository.getEventsFromAPI(
          userApiHashKey.toString(), fromDate, toDate, pageNumber);
      totalPages = eventsModel.items!.lastPage!;
      for (var alertData in eventsModel.items!.data!) {
        alertsDataList.add(alertData);
      }
      emit(EventsLoadingComplete(alertsDataList));
    } catch (e) {
      emit(EventsLoadingError('Error...'));
    }
  }

  void deleteEventsfromAPI() async {
    try {
      emit(EventsLoading());
      String? userApiHashKey = await UserSessions.getUserApiHash();
      eventsModel = await eventsRepository
          .destroyEventsAlertsApi(userApiHashKey.toString());
      alertsDataList.clear();

      emit(EventsLoadingComplete(alertsDataList));
    } catch (e) {
      emit(EventsLoadingError('Error...'));
    }
  }
}
