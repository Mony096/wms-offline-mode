import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_mobile/constant/api.dart';
import 'package:wms_mobile/feature/middleware/domain/entity/login_entity.dart';
import 'package:wms_mobile/feature/middleware/presentation/bloc/authorization_bloc.dart';
import 'package:wms_mobile/mobile_function/dashboard_screen.dart';

import '../../../utilies/dialog/dialog.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _userName = TextEditingController();
  final _password = TextEditingController();

  late bool checkTypeInput = false;

  Future<void> _postData() async {
    try {
      MaterialDialog.loading(context);
      if (mounted) {
        // MaterialDialog.close(context);
        final loginEntity = LoginEntity(
          username: _userName.text,
          password: _password.text,
          db: CONNECT_COMPANY,
        );

        BlocProvider.of<AuthorizationBloc>(context).add(
          RequestLoginOnlineEvent(entity: loginEntity),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  final bool _obscureText = true;

  void _isSuccess() {
    if (mounted) {
      MaterialDialog.close(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const DashboardScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Container(
        color: Colors.white,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Text("12")
              Container(
                padding: EdgeInsets.only(right: 25),
                height: 70,
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: [
                    Expanded(
                        flex: 2,
                        child: Container(
                          margin: EdgeInsets.only(right: 10),
                          child: Text(
                            "User Id :",
                            style: TextStyle(fontSize: 16.5),
                            textAlign: TextAlign.end,
                          ),
                        )),
                    Expanded(
                      flex: 5,
                      child: TextField(
                        controller: _userName,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          hintText: 'User Id',
                          isDense: true,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(right: 25),
                height: 70,
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: [
                    Expanded(
                        flex: 2,
                        child: Container(
                          margin: EdgeInsets.only(right: 10),
                          child: Text(
                            "Whs :",
                            style: TextStyle(fontSize: 16.5),
                            textAlign: TextAlign.end,
                          ),
                        )),
                    Expanded(
                      flex: 5,
                      child: TextField(
                        controller: _password,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          hintText: 'Warehouse Code',
                          isDense: true,
                        ),
                      ),
                    )
                  ],
                ),
              ),

              Container(
                padding: EdgeInsets.only(right: 25),
                height: 70,
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: [
                    Expanded(
                        flex: 2,
                        child: Container(
                          margin: EdgeInsets.only(right: 10),
                          child: Text(
                            style: TextStyle(fontSize: 16.5),
                            "Password :",
                            textAlign: TextAlign.end,
                          ),
                        )),
                    Expanded(
                      flex: 5,
                      child: TextField(
                        obscureText: _obscureText,
                        // controller: _password,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          hintText: 'Password',
                          isDense: true,
                        ),
                      ),
                    )
                  ],
                ),
              ),

              Container(
                padding: EdgeInsets.only(right: 25),
                height: 70,
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: [
                    Expanded(
                        flex: 2,
                        child: Container(
                          margin: EdgeInsets.only(right: 10),
                          child: Text(
                            "",
                            textAlign: TextAlign.end,
                          ),
                        )),
                    Expanded(
                        flex: 5,
                        child: Container(
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: SizedBox(
                                  width: 130,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            5), // No border radius
                                        side: BorderSide(
                                          color: Color.fromARGB(
                                              255, 68, 71, 74), // Border color
                                          width: 1.0, // Border width
                                        ),
                                      ),
                                    ),
                                    onPressed: () async {
                                      // await _postData();
                                    },
                                    child: const Text(
                                      "Log In",
                                      style: TextStyle(
                                          color: Color.fromARGB(255, 3, 3, 3)),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 20),
                              Expanded(
                                flex: 3,
                                child: SizedBox(
                                  width: 130,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            5), // No border radius
                                        side: BorderSide(
                                          color: Color.fromARGB(
                                              255, 68, 71, 74), // Border color
                                          width: 1.0, // Border width
                                        ),
                                      ),
                                    ),
                                    onPressed: () async {
                                      // await _postData();
                                    },
                                    child: const Text(
                                      "Cancel",
                                      style: TextStyle(
                                          color: Color.fromARGB(255, 3, 3, 3)),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    ));
  }
}
