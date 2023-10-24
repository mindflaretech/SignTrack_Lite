import 'package:autotelematic_new_app/model/changepassowrdmodel.dart';
import 'package:autotelematic_new_app/repository/changepassword_repository.dart';
import 'package:autotelematic_new_app/res/usersession.dart';
import 'package:bloc/bloc.dart';

part 'change_password_state.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  ChangePasswordCubit() : super(ChangePasswordInitial());
  ChangePasswordRepository changePasswordRepository =
      ChangePasswordRepository();
  void changePasswrod(String password) async {
    String? userApiHashKey = await UserSessions.getUserApiHash();

    try {
      emit(ChangePasswordLoading());
      ChangePasswordModel changePasswordModel = await changePasswordRepository
          .changePasswordFromAPI(userApiHashKey.toString(), password);
      emit(ChangePasswordComplete(changePasswordModel: changePasswordModel));
    } catch (e) {
      emit(ChangePasswordError(message: e.toString()));
    }
  }
}
