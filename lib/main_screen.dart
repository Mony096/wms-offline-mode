import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_mobile/download.dart';
import 'package:wms_mobile/feature/warehouse/presentation/screen/warehouse_page.dart';
import 'package:wms_mobile/feature/middleware/presentation/login_screen.dart';
import 'package:wms_mobile/feature/middleware/presentation/bloc/authorization_bloc.dart';
import 'package:wms_mobile/utilies/storage/locale_storage.dart';
import 'constant/style.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool isPickedWarehouse = false;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {
    final value = await LocalStorageManger.getString('warehouse');
    if (value != '') {
      setState(() {
        isPickedWarehouse = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthorizationBloc, AuthorizationState>(
      listener: (context, state) {
        if (state is UnAuthorization) {
          _navigatorKey.currentState?.pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen(fromLogout:true)),
          );
        } else if (state is AuthorizationSuccess) {
          _navigatorKey.currentState?.pushReplacement(
            MaterialPageRoute(builder: (context) => DownloadScreen()),
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
        home: BlocBuilder<AuthorizationBloc, AuthorizationState>(
          builder: (context, state) {
            if (state is AuthorizationSuccess) {
              return DownloadScreen() ;
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
