import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'setting_state.dart';

class SettingCubit extends Cubit<SettingState> {
  SettingCubit() : super(SettingInitial());
  bool notificationsEnabled = true;
  String? userID = 'user id';

  void getSharedPreferenceSettings() async {
    SharedPreferences? sp;
    emit(SettingLoading());
    sp = await SharedPreferences.getInstance();

    notificationsEnabled = sp.getBool('notifications')!;

    userID = sp.getString('userid');

    emit(SettingComplete());
  }

  void setNotifications() async {
    emit(SettingLoading());
    SharedPreferences? sp;
    sp = await SharedPreferences.getInstance();
    notificationsEnabled = !notificationsEnabled;
    sp.setBool('notifications', notificationsEnabled);
    print('Notification is set to ' + notificationsEnabled.toString());
    emit(SettingComplete());
  }
}
