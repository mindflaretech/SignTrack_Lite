part of 'reportstype_cubit.dart';

class ReportstypeState {
  const ReportstypeState();
}

class ReportstypeInitial extends ReportstypeState {}

class ReportstypeLoading extends ReportstypeState {}

class ReportstypeError extends ReportstypeState {
  String message;
  ReportstypeError(this.message);
}

class ReportstypeLoadingComplete extends ReportstypeState {
  ReportTypeModel reportTypeModel = ReportTypeModel();
  ReportstypeLoadingComplete(this.reportTypeModel);
}
