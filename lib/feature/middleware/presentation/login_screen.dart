import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_mobile/constant/api.dart';
import 'package:wms_mobile/constant/style.dart';
import 'package:wms_mobile/feature/middleware/domain/entity/login_entity.dart';
import 'package:wms_mobile/feature/middleware/presentation/bloc/authorization_bloc.dart';
import 'package:wms_mobile/feature/middleware/presentation/setting_screen.dart';
import 'package:wms_mobile/download.dart';
import 'package:wms_mobile/utilies/dialog/dialog.dart';
import 'package:wms_mobile/utilies/storage/locale_storage.dart';
import '../../../helper/helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.fromLogout});
  final dynamic fromLogout;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userName = TextEditingController();
  final _password = TextEditingController();

  bool _rememberMe = false;
  bool _obscureText = true;

  late AuthorizationBloc _bloc;

  @override
  void initState() {
    _bloc = context.read<AuthorizationBloc>();
    _loadSavedLogin();
    super.initState();
  }

  /// Load saved username & password if "Remember Me" was used
  Future<void> _loadSavedLogin() async {
    final remember = await LocalStorageManger.getString('remember_me');
    final user = await LocalStorageManger.getString('saved_username');
    final pass = await LocalStorageManger.getString('saved_password');

    setState(() {
      _rememberMe = remember == 'true';
      if (_rememberMe) {
        _userName.text = user;
        _password.text = pass;
      }
    });
  }

  Future<void> _postData() async {
    try {
      if (mounted) {
        final loginEntity = LoginEntity(
          username: _userName.text,
          password: _password.text,
          db: CONNECT_COMPANY,
        );

        // Handle Remember Me storage
        if (_rememberMe) {
          await LocalStorageManger.setString('remember_me', 'true');
          await LocalStorageManger.setString('saved_username', _userName.text);
          await LocalStorageManger.setString('saved_password', _password.text);
        } else {
          await LocalStorageManger.setString('remember_me', 'false');
          await LocalStorageManger.removeString('saved_username');
          await LocalStorageManger.removeString('saved_password');
        }

        BlocProvider.of<AuthorizationBloc>(context).add(
          RequestLoginOnlineEvent(entity: loginEntity),
        );
      }
    } catch (e) {
      debugPrint('Login Error: $e');
    }
  }

  Future<bool> _onWillPop() async {
    if (widget.fromLogout == true) {
      SystemNavigator.pop();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 26.0),
            child: BlocConsumer<AuthorizationBloc, AuthorizationState>(
              listener: (context, state) {
                if (state is AuthorizationSuccess) {
                  MaterialDialog.snackBar(context, "Login successful.");
                } else if (state is RequestLoginFailedState) {
                  MaterialDialog.warning(
                    context,
                    title: 'Failed',
                    body: state.message,
                  );
                }
              },
              builder: (context, state) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),
                    Text(
                      "WMS Mobile",
                      style: TextStyle(
                        color: PRIMARY_COLOR,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),
                    const Text(
                      "Warehouse Management System",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 40),

                    /// Login Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _userName,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.person_outline),
                              labelText: 'Username',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _password,
                            obscureText: _obscureText,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock_outline),
                              labelText: 'Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureText
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          /// Remember Me
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                activeColor: PRIMARY_COLOR,
                                onChanged: (value) {
                                  setState(() {
                                    _rememberMe = value ?? false;
                                  });
                                },
                              ),
                              const Text(
                                "Remember Me",
                                style: TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          /// Login Button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: state is RequestingAuthorization
                                  ? null
                                  : _postData,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: PRIMARY_COLOR,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                              ),
                              child: state is RequestingAuthorization
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      "LOGIN",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 15),

                          /// Settings Button
                          OutlinedButton.icon(
                            icon: const Icon(Icons.settings),
                            label: Text(
                              "Settings",
                              style: TextStyle(
                                color: PRIMARY_COLOR,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: PRIMARY_COLOR),
                              minimumSize: const Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () =>
                                goTo(context, const SettingScreen()),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    /// Footer
                    const Text(
                      "© 2025 BizDimension Cambodia",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const Text(
                      "All rights reserved",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:wms_mobile/constant/style.dart';
// import 'package:wms_mobile/download_screen.dart';
// import 'package:wms_mobile/feature/middleware/presentation/setting_screen.dart';
// import 'package:wms_mobile/feature/warehouse/presentation/screen/warehouse_page.dart';
// import 'package:wms_mobile/mobile_function/dashboard.dart';
// import 'package:wms_mobile/provider/login_provider.dart';
// import 'package:wms_mobile/utilies/dialog/dialog.dart';
// import 'package:wms_mobile/utilies/storage/locale_storage.dart';
// import '../../../helper/helper.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key, this.fromLogout});
//   final dynamic fromLogout;

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final TextEditingController _userName = TextEditingController(text: "T005");
//   final TextEditingController _password = TextEditingController(text: "1234");
//   bool _obscureText = true;
//   bool _rememberMe = false;
//   // String _selectedCompany = "SBODEMOUS";

//   // final List<String> companyList = [
//   //   "SBODEMOUS",
//   //   "SBODEMO_CBD",
//   // ];

//   @override
//   void initState() {
//     super.initState();
//     _loadSavedData();
//   }

//   Future<void> _loadSavedData() async {
//     final provider = Provider.of<LoginProvider>(context, listen: false);
//     await Future.delayed(const Duration(milliseconds: 200));
//     setState(() {
//       _userName.text = provider.username ?? 'T005';
//       _password.text = provider.password ?? '1234';
//       // _selectedCompany = provider.company ?? "SBODEMOUS";
//       _rememberMe = provider.rememberMe || provider.username != null;
//     });
//   }

//   Future<void> _onLogin() async {
//     final provider = Provider.of<LoginProvider>(context, listen: false);

//     if (_userName.text.isEmpty || _password.text.isEmpty) {
//       MaterialDialog.success(context,
//           title: 'Missing Fields', body: 'Please enter username and password.');
//       return;
//     }

//     await provider.login(
//       _userName.text.trim(),
//       _password.text.trim(),
//       // _selectedCompany,
//       _rememberMe,
//     );

//     if (provider.isLoggedIn && mounted) {
//       MaterialDialog.snackBar(context, "Login successful.");
//       Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(builder: (_) => WarehousePage(isPicker: true)),
//         (Route<dynamic> route) => false,
//       );
//     }
//   }

//   Future<bool> _onWillPop() async {
//     if (widget.fromLogout == true) {
//       SystemNavigator.pop();
//       return false;
//     }
//     return true;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<LoginProvider>(context);

//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//         backgroundColor: const Color(0xFFF5F6FA),
//         body: Center(
//           child: SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 26.0),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const SizedBox(height: 50),
//                   // App title
//                   Text(
//                     "WMS Mobile",
//                     style: TextStyle(
//                       color: PRIMARY_COLOR,
//                       fontSize: 30,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   const Text(
//                     "Warehouse Management System",
//                     style: TextStyle(
//                       color: Colors.grey,
//                       fontSize: 15,
//                     ),
//                   ),
//                   const SizedBox(height: 40),

//                   // Login card
//                   Container(
//                     padding: const EdgeInsets.all(24),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(18),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.grey.withOpacity(0.15),
//                           blurRadius: 10,
//                           offset: const Offset(0, 5),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       children: [
//                         TextField(
//                           controller: _userName,
//                           decoration: InputDecoration(
//                             prefixIcon: const Icon(Icons.person_outline),
//                             labelText: 'Username',
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                         TextField(
//                           obscureText: _obscureText,
//                           controller: _password,
//                           decoration: InputDecoration(
//                             prefixIcon: const Icon(Icons.lock_outline),
//                             labelText: 'Password',
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             suffixIcon: IconButton(
//                               icon: Icon(
//                                 _obscureText
//                                     ? Icons.visibility
//                                     : Icons.visibility_off,
//                               ),
//                               onPressed: () {
//                                 setState(() {
//                                   _obscureText = !_obscureText;
//                                 });
//                               },
//                             ),
//                           ),
//                         ),
//                         // const SizedBox(height: 20),
//                         // DropdownButtonFormField<String>(
//                         //   value: _selectedCompany,
//                         //   items: companyList
//                         //       .map((e) => DropdownMenuItem(
//                         //             value: e,
//                         //             child: Text(e),
//                         //           ))
//                         //       .toList(),
//                         //   onChanged: (value) {
//                         //     setState(() {
//                         //       _selectedCompany = value ?? "SBODEMOUS";
//                         //     });
//                         //   },
//                         //   decoration: InputDecoration(
//                         //     prefixIcon: const Icon(Icons.storage_outlined),
//                         //     labelText: "Company Database",
//                         //     border: OutlineInputBorder(
//                         //       borderRadius: BorderRadius.circular(12),
//                         //     ),
//                         //   ),
//                         // ),
//                         const SizedBox(height: 15),
//                         Row(
//                           children: [
//                             Checkbox(
//                               value: _rememberMe,
//                               onChanged: (v) {
//                                 setState(() => _rememberMe = v ?? false);
//                               },
//                             ),
//                             const Text("Remember me"),
//                           ],
//                         ),
//                         const SizedBox(height: 25),
//                         SizedBox(
//                           width: double.infinity,
//                           height: 48,
//                           child: ElevatedButton(
//                             onPressed:
//                                 provider.isLoading ? null : () => _onLogin(),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: PRIMARY_COLOR,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               elevation: 4,
//                             ),
//                             child: provider.isLoading
//                                 ? const CircularProgressIndicator(
//                                     color: Colors.white,
//                                   )
//                                 : const Text(
//                                     "LOGIN IN",
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.bold,
//                                       letterSpacing: 1.1,
//                                     ),
//                                   ),
//                           ),
//                         ),
//                         const SizedBox(height: 15),
//                         OutlinedButton.icon(
//                           icon: const Icon(Icons.settings),
//                           label: Text(
//                             "Settings",
//                             style: TextStyle(
//                               color: PRIMARY_COLOR,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           style: OutlinedButton.styleFrom(
//                             side: BorderSide(color: PRIMARY_COLOR),
//                             minimumSize: const Size(double.infinity, 48),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           onPressed: () => goTo(context, const SettingScreen()),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 40),
//                   const Text(
//                     "© 2025 BizDimension Cambodia",
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                   const Text(
//                     "All rights reserved",
//                     style: TextStyle(color: Colors.grey, fontSize: 13),
//                   ),
//                   const SizedBox(height: 20),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
