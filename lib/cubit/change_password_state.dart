// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'change_password_cubit.dart';

class ChangePasswordState {
  const ChangePasswordState();
}

class ChangePasswordInitial extends ChangePasswordState {}

class ChangePasswordLoading extends ChangePasswordState {}

class ChangePasswordError extends ChangePasswordState {
  String message;
  ChangePasswordError({
    required this.message,
  });
}

class ChangePasswordComplete extends ChangePasswordState {
  ChangePasswordModel changePasswordModel;
  ChangePasswordComplete({
    required this.changePasswordModel,
  });
}
