import 'package:autotelematic_new_app/cubit/singin_cubit.dart';
import 'package:autotelematic_new_app/res/apptheme.dart';
import 'package:autotelematic_new_app/utils/commonutils.dart';
import 'package:autotelematic_new_app/utils/routes/routes_names.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  FocusNode emailFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  SinginCubit singinCubit = SinginCubit();
  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        // crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.15),
          const Image(
            width: 250,
            image: AssetImage(
              AppTheme.logoPath,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                child: Text(
                  'Please Sign in here',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ],
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: AppTheme.loginTextFieldWidth(context),
                child: TextFormField(
                  controller: emailController,
                  focusNode: emailFocusNode,
                  keyboardType: TextInputType.emailAddress,
                  onFieldSubmitted: (value) {
                    CommonUtils.fieldFocusChange(
                        context, emailFocusNode, passwordFocusNode);
                  },
                  decoration: AppTheme.textFieldInputDecoration(
                      'Username',
                      const Icon(
                        Icons.person,
                        size: 20,
                      )),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: SizedBox(
                width: AppTheme.loginTextFieldWidth(context),
                child: TextFormField(
                  controller: passwordController,
                  focusNode: passwordFocusNode,
                  obscureText: true,
                  decoration: AppTheme.textFieldInputDecoration(
                      'Password',
                      const Icon(
                        Icons.key,
                        size: 20,
                      )),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 200,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: BlocProvider<SinginCubit>(
                create: (context) => singinCubit,
                child: FilledButton.tonal(
                  onPressed: () {
                    if (emailController.text.isEmpty) {
                      CommonUtils.toastMessage('Please enter username');
                    } else if (passwordController.text.isEmpty) {
                      CommonUtils.toastMessage('please enter password');
                    } else {
                      Map<String, dynamic> userData = {
                        'email': emailController.value.text,
                        'password': passwordController.value.text
                      };
                      singinCubit.signIn(userData);
                    }
                  },
                  child: BlocConsumer<SinginCubit, SinginState>(
                    listener: (context, state) {
                      if (state is SigninErrorState) {
                        CommonUtils.toastMessage(
                            'Invalid username or password');
                      }
                      if (state is SignInSuccessState) {
                        Navigator.pushReplacementNamed(
                            context, RoutesName.home);
                      }
                    },
                    builder: (context, state) {
                      switch (state.runtimeType) {
                        case (SigninLoadingState):
                          return const Center(
                            child: CircularProgressIndicator(),
                          );

                        default:
                          return const Text('Sign In');
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Dont have an account? '),
              GestureDetector(
                onTap: () => CommonUtils.launchURLBrowser(
                    'mailto:trackdrive37@gmail.com'),
                child: const Text(
                  'Contact Us',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
