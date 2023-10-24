import 'package:autotelematic_new_app/cubit/change_password_cubit.dart';
import 'package:autotelematic_new_app/cubit/home_cubit.dart';
import 'package:autotelematic_new_app/cubit/setting_cubit.dart';
import 'package:autotelematic_new_app/res/usersession.dart';
import 'package:autotelematic_new_app/utils/commonutils.dart';
import 'package:autotelematic_new_app/utils/routes/routes_names.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  Future<void> showChangePasswordDialog(BuildContext context) async {
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    FocusNode passwordFocusNode = FocusNode();
    ChangePasswordCubit changePasswordCubit = ChangePasswordCubit();

    return showDialog(
      useSafeArea: true,
      barrierDismissible: false,
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Change Password'),
                        InkWell(
                          child: const Icon(Icons.close),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                  TextField(
                    controller: passwordController,
                    focusNode: passwordFocusNode,
                    decoration: const InputDecoration(
                      helperText: 'Password',
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    decoration: const InputDecoration(
                      helperText: 'Confirm Password',
                    ),
                    controller: confirmPasswordController,
                    autofocus: true,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  BlocProvider(
                    create: (context) => changePasswordCubit,
                    child:
                        BlocBuilder<ChangePasswordCubit, ChangePasswordState>(
                      builder: (context, state) {
                        if (state is ChangePasswordLoading) {
                          return const CircularProgressIndicator();
                        }
                        if (state is ChangePasswordError) {
                          return const Text('Error while changing password...');
                        }
                        if (state is ChangePasswordComplete) {
                          UserSessions.removeSession();
                          Future.delayed(const Duration(seconds: 2), () {
                            Navigator.pushReplacementNamed(
                                context, RoutesName.splashSceen);
                          });
                          return const Text('Password changed.Sign in again.');
                        }
                        return ElevatedButton(
                          child: const Text('Change'),
                          onPressed: () {
                            if (passwordController.text.isEmpty ||
                                confirmPasswordController.text.isEmpty) {
                              CommonUtils.showSnackbar(
                                  context, 'Please enter password');
                              return;
                            }
                            if (passwordController.text !=
                                confirmPasswordController.text) {
                              passwordController.clear();
                              confirmPasswordController.clear();
                              passwordFocusNode.requestFocus();

                              CommonUtils.showSnackbar(context,
                                  'Confirmation Password does not match');
                              return;
                            }
                            changePasswordCubit.changePasswrod(
                                passwordController.text.toString());
                          },
                        );
                      },
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var settingsCubit = context.read<SettingCubit>();
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BlocBuilder<SettingCubit, SettingState>(
          builder: (context, state) {
            if (state is SettingComplete) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Card(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  UserSessions.removeSession();
                                  Navigator.pushReplacementNamed(
                                      context, RoutesName.splashSceen);

                                  context.read<HomeCubit>().close();
                                },
                                child: const Text(
                                  'Log out',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.grey[50],
                                    radius: 50,
                                    child: const Image(
                                      image: AssetImage(
                                          'assets/images/5241364.png'),
                                      // height: 120,
                                      // width: 120,
                                    ),
                                  ),
                                  const Text('Hello! Patner'),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      settingsCubit.userID.toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Card(
                      child: InkWell(
                        onTap: () =>
                            CommonUtils.launchURLBrowser('tel:+923096735079'),
                        child: ListTile(
                          leading: const Image(
                            image: AssetImage(
                                'assets/images/2022_ani_cartoon_25.png'),
                            height: 40,
                            width: 40,
                          ),
                          title: Text('Contact Support',
                              style: Theme.of(context).textTheme.titleSmall),
                          subtitle: Text('Contact us if you need any help!',
                              style: Theme.of(context).textTheme.bodySmall),
                          trailing: const Icon(Icons.arrow_forward_ios),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Account Settings',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        )
                      ],
                    ),
                    Card(
                      child: InkWell(
                        onTap: () {
                          showChangePasswordDialog(context);
                        },
                        child: ListTile(
                          leading: const Image(
                            image:
                                AssetImage('assets/images/password_front.png'),
                            height: 40,
                            width: 40,
                          ),
                          title: Text(
                            'Password change',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                        ),
                      ),
                    ),
                    Card(
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                              context, RoutesName.alertsTypeList);
                        },
                        child: ListTile(
                          leading: const Image(
                            image: AssetImage('assets/images/alertset.png'),
                            height: 40,
                            width: 40,
                          ),
                          title: Text('Notifications Settings',
                              style: Theme.of(context).textTheme.titleSmall),
                          trailing: const Padding(
                            padding: EdgeInsets.only(right: 5.0),
                            child: Icon(Icons.arrow_forward_ios),
                          ),
                        ),
                      ),
                    ),
                    // Card(
                    //   child: ListTile(
                    //       leading: const Image(
                    //         image:
                    //             AssetImage('assets/images/notification-96.png'),
                    //         height: 40,
                    //         width: 40,
                    //       ),
                    //       title: Text('Notifications',
                    //           style: Theme.of(context).textTheme.titleSmall),
                    //       trailing: Checkbox(
                    //         value: settingsCubit.notificationsEnabled,
                    //         onChanged: (value) {
                    //           settingsCubit.setNotifications();
                    //         },
                    //       )),
                    // ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Compnay Info',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        )
                      ],
                    ),
                    Card(
                      child: InkWell(
                        onTap: () => CommonUtils.launchURLBrowser(
                            'whatsapp://send?phone=923096735079'),
                        child: ListTile(
                          leading: const Image(
                            image: AssetImage('assets/images/8380066.png'),
                            height: 40,
                            width: 40,
                          ),
                          title: Text(
                            'Whatsapp',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                        ),
                      ),
                    ),
                    Card(
                      child: InkWell(
                        onTap: () => CommonUtils.launchURLBrowser(
                            'https://www.nostrumtrack.com'),
                        child: ListTile(
                          leading: const Image(
                            image: AssetImage('assets/images/8380020.png'),
                            height: 40,
                            width: 40,
                          ),
                          title: Text(
                            'Website',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                        ),
                      ),
                    ),
                    Card(
                      child: InkWell(
                        onTap: () => CommonUtils.launchURLBrowser(
                            'https://www.nostrumtrack.com'),
                        child: ListTile(
                          leading: const Image(
                            image: AssetImage('assets/images/7228764.png'),
                            height: 40,
                            width: 40,
                          ),
                          title: Text(
                            'Terms and conditions',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Powered by Auto Telematics Pvt. Ltd.',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    )
                  ],
                ),
              );
            }
            return const Text('No status');
          },
        ),
      ),
    );
  }
}
