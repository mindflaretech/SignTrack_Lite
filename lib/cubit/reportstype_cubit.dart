import 'package:autotelematic_new_app/model/reporttypemodel.dart';
import 'package:autotelematic_new_app/repository/reporttyperepository.dart';
import 'package:autotelematic_new_app/res/usersession.dart';
import 'package:bloc/bloc.dart';

part 'reportstype_state.dart';

class ReportstypeCubit extends Cubit<ReportstypeState> {
  ReportstypeCubit() : super(ReportstypeInitial());

  ReportTypeRepository reportTypeRepository = ReportTypeRepository();
  ReportTypeModel reportTypeModel = const ReportTypeModel();

  void fetchReportsTypeFromApi() async {
    emit(ReportstypeLoading());

    try {
      String? userApiHashKey = await UserSessions.getUserApiHash();
      reportTypeModel = await reportTypeRepository
          .getReportsTypeFromAPI(userApiHashKey.toString());

      emit(ReportstypeLoadingComplete(reportTypeModel));
    } catch (e) {
      emit(ReportstypeError('There is an error'));
      rethrow;
    }
  }
}
