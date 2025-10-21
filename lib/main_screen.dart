import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_mobile/download.dart';
import 'package:wms_mobile/feature/warehouse/presentation/screen/warehouse_page.dart';
import 'package:wms_mobile/feature/middleware/presentation/login_screen.dart';
import 'package:wms_mobile/feature/middleware/presentation/bloc/authorization_bloc.dart';
import 'package:wms_mobile/mobile_function/dashboard.dart';
import 'package:wms_mobile/utilies/storage/locale_storage.dart';
import 'constant/style.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool isPickedWarehouse = false;
  bool hasCredentials = false;
  bool isLoading = true; // 👈 Loading flag
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    setState(() {
      isLoading = true;
    });

    // Simulate async loading
    final username = await LocalStorageManger.getString('username');
    final password = await LocalStorageManger.getString('password');
    final warehouse = await LocalStorageManger.getString('warehouse');

    hasCredentials = username.isNotEmpty && password.isNotEmpty;
    isPickedWarehouse = warehouse.isNotEmpty;

    // Small delay for smooth loader (optional)
    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      isLoading = false;
    });

    // Navigate if credentials exist
    if (hasCredentials) {
      _navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(builder: (context) => const Dashboard()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthorizationBloc, AuthorizationState>(
      listener: (context, state) {
        if (state is UnAuthorization) {
          _navigatorKey.currentState?.pushReplacement(
            MaterialPageRoute(
                builder: (context) => const LoginScreen(fromLogout: true)),
          );
        } else if (state is AuthorizationSuccess) {
          _navigatorKey.currentState?.pushReplacement(
            MaterialPageRoute(
                builder: (context) => DownloadScreen(fromDashboard: false)),
          );
        }
      },
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: const ColorScheme.light(
            primary: PRIMARY_COLOR,
            onPrimary: Colors.white,
          ),
        ),
        title: 'Flutter layout demo',
        home: isLoading
            ? const Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 20,),
                      Text("Waiting Initializing App",style: TextStyle(fontSize: 15),)
                    ],
                  ), // 👈 Loader while init
                ),
              )
            : BlocBuilder<AuthorizationBloc, AuthorizationState>(
                builder: (context, state) {
                  if (hasCredentials) {
                    return const Dashboard();
                  } else if (state is AuthorizationSuccess) {
                    return DownloadScreen(fromDashboard: false);
                  } else {
                    return const LoginScreen();
                  }
                },
              ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:wms_mobile/feature/middleware/presentation/login_screen.dart';
// import 'package:wms_mobile/constant/style.dart';
// import 'package:wms_mobile/feature/warehouse/presentation/screen/warehouse_page.dart';
// import 'package:wms_mobile/provider/login_provider.dart';

// class MainScreen extends StatefulWidget {
//   const MainScreen({super.key});

//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }

// class _MainScreenState extends State<MainScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (_) => LoginProvider(),
//       child: Consumer<LoginProvider>(
//         builder: (context, provider, _) {
//           return MaterialApp(
//             debugShowCheckedModeBanner: false,
//             theme: ThemeData(
//               colorScheme: const ColorScheme.light(
//                 primary: PRIMARY_COLOR,
//                 onPrimary: Colors.white,
//               ),
//             ),
//             home: provider.isLoading
//                 ? const Scaffold(
//                     body: Center(child: CircularProgressIndicator()),
//                   )
//                 : provider.isLoggedIn
//                     ? WarehousePage(isPicker: true)
//                     : const LoginScreen(),
//           );
//         },
//       ),
//     );
//   }
// }
