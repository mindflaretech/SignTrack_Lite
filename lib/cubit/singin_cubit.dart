import 'package:autotelematic_new_app/model/user_signin_model.dart';
import 'package:autotelematic_new_app/repository/auth_repository.dart';
import 'package:autotelematic_new_app/res/usersession.dart';
import 'package:bloc/bloc.dart';

part 'singin_state.dart';

class SinginCubit extends Cubit<SinginState> {
  SinginCubit() : super(SinginInitial());
  AuthRepository authRepository = AuthRepository();
  UserLoginData userLoginData = UserLoginData();
  UserSessions userSessions = UserSessions();

  void signIn(dynamic data) async {
    emit(SigninLoadingState());
    try {
      userLoginData = await authRepository.signinAPI(data);
      userSessions.saveUserSession(userLoginData, data['email']);
      emit(SignInSuccessState(userLoginData));
    } catch (e) {
      emit(SigninErrorState('Some Error Accord....'));
    }
  }
}
