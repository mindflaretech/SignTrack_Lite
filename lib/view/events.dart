import 'package:autotelematic_new_app/cubit/events_cubit.dart';
import 'package:autotelematic_new_app/res/apptheme.dart';
import 'package:autotelematic_new_app/utils/commonutils.dart';
import 'package:autotelematic_new_app/utils/routes/routes_names.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VehicleEventssScreen extends StatefulWidget {
  const VehicleEventssScreen({super.key});

  @override
  State<VehicleEventssScreen> createState() => _VehicleEventssScreenState();
}

class _VehicleEventssScreenState extends State<VehicleEventssScreen> {
  ScrollController scrollController = ScrollController();
  int pageNumber = 1;
  int totalPages = 0;
  bool isPageLoading = false;

  void loadMore() async {
    if (scrollController.position.extentAfter < 100) {
      if (!isPageLoading && (pageNumber < totalPages)) {
        pageNumber = pageNumber + 1;
        CommonUtils.toastMessage('Loading more alerts...');

        // Dispatch an event to the EventsCubit to load more events
        context
            .read<EventsCubit>()
            .fetchEventsFromApi('', '', pageNumber.toString(), false);
      }
      isPageLoading = true;
    }
  }

  Future<bool> deleteEvents(context, EventsCubit eventCubit) async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Are you sure?'),
            content: const Text('Do you want to delete events'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () {
                  eventCubit.deleteEventsfromAPI();
                  Navigator.of(context).pop(false);
                },
                child: const Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  void initState() {
    super.initState();
    scrollController.addListener(loadMore);
  }

  @override
  Widget build(BuildContext context) {
    dynamic eventCubit = context.read<EventsCubit>();
    return RefreshIndicator(
      onRefresh: () => eventCubit.fetchEventsFromApi('', '', '1', true),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Events'),
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () {
                  pageNumber = 1;
                  eventCubit.fetchEventsFromApi(
                      '', '', pageNumber.toString(), true);
                  eventCubit.emit(EventsLoading());
                },
                icon: const Icon(Icons.refresh)),
            IconButton(
                onPressed: () => deleteEvents(context, eventCubit),
                icon: const Icon(Icons.delete))
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlocBuilder<EventsCubit, EventsState>(
              builder: (context, state) {
                if (state is EventsLoading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppTheme.loadingImage,
                        const SizedBox(
                          height: 5,
                        ),
                        const Text('Loading...')
                      ],
                    ),
                  );
                }

                if (state is EventsLoadingError) {
                  return Center(
                    child: Text(state.message),
                  );
                }
                if (state is EventsLoadingComplete) {
                  totalPages = context.read<EventsCubit>().totalPages;
                  isPageLoading = false;
                  return Expanded(
                    child: state.alertsDataList.isNotEmpty
                        ? ListView.builder(
                            controller: scrollController,
                            itemCount: state.alertsDataList.length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () => Navigator.pushNamed(
                                    context, RoutesName.eventOnMap,
                                    arguments: state.alertsDataList[index]),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(12, 5, 12, 0),
                                  child: Card(
                                    child: ListTile(
                                      title: Text(state
                                          .alertsDataList[index].deviceName
                                          .toString()),
                                      subtitle: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  state.alertsDataList[index]
                                                      .message
                                                      .toString(),
                                                  style: const TextStyle(
                                                      color: Colors.red),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                  state.alertsDataList[index]
                                                      .time
                                                      .toString(),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall),
                                            ],
                                          ),
                                        ],
                                      ),
                                      leading: const Icon(
                                          Icons.notifications_none_outlined),
                                      trailing: const Icon(Icons.arrow_forward),
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        : const Center(
                            child: Text('No new alerts at the moment.')),
                  );
                }

                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppTheme.loadingImage,
                      const SizedBox(
                        height: 5,
                      ),
                      const Text('Loading...')
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
