// import 'package:flutter/material.dart';
// import 'package:wms_mobile/component/button/button.dart';
// import 'package:wms_mobile/constant/style.dart';
// import 'package:wms_mobile/utilies/storage/locale_storage.dart';

// import '../../../utilies/dialog/dialog.dart';

// class SettingScreen extends StatefulWidget {
//   const SettingScreen({super.key});

//   @override
//   State<SettingScreen> createState() => _SettingScreenState();
// }

// class _SettingScreenState extends State<SettingScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _hostConfig = TextEditingController(text: 'https://192.168.1.11');
//   final _portConfig = TextEditingController(text: '50000');
//   bool loading = false;

//   Future<void> saveSetting() async {
//     setState(() => loading = true);

//     if (!_formKey.currentState!.validate()) return;

//     await Future.delayed(const Duration(seconds: 2));

//     LocalStorageManger.setString('host', _hostConfig.text);
//     LocalStorageManger.setString('port', _portConfig.text);

//     if (mounted) {
//       setState(() => loading = false);
//       // MaterialDialog.close(context);
//       MaterialDialog.snackBar(context, "Saved.");
//       Navigator.of(context).pop();
//     }
//   }

//   Future<void> init() async {
//     // final host = await LocalStorageManger.getString('host');
//     // final port = await LocalStorageManger.getString('port');

//     // _hostConfig.text = host;
//     // _portConfig.text = port;
//   }

//   @override
//   void initState() {
//     super.initState();
//     init();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           elevation: 0.6,
//           iconTheme: const IconThemeData(
//             color: Colors.black, //change your color here
//           ),
//           backgroundColor: const Color.fromARGB(255, 255, 255, 255),
//           title: const Text(
//             "Setting",
//             style: TextStyle(color: Colors.black, fontSize: 18),
//           ),
//         ),
//         body: Container(
//           color: Colors.white,
//           width: MediaQuery.of(context).size.width,
//           height: MediaQuery.of(context).size.height,
//           child: Form(
//             key: _formKey,
//             child: Column(
//               children: [
//                 SizedBox(
//                   width: double.infinity,
//                   child: Container(
//                     padding: EdgeInsets.all(size(context).width * 0.055),
//                     width: double.infinity,
//                     // color: Colors.red,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "Adress Configuration",
//                           style: TextStyle(
//                               fontSize: size(context).width * 0.055,
//                               height: 1.7),
//                         ),
//                         const SizedBox(height: 30),
//                         TextFormField(
//                           controller: _hostConfig,
//                           keyboardType: TextInputType.url,
//                           validator: (value) {
//                             if (value == null || value == '') {
//                               return 'Please enter ip or server url';
//                             }

//                             return null;
//                           },
//                           decoration: const InputDecoration(
//                               labelText: 'Web Server Adress',
//                               border: OutlineInputBorder(),
//                               hintText: 'Enter Web Server Adress',
//                               isDense: true),
//                         ),
//                         const SizedBox(height: 25),
//                         TextFormField(
//                           controller: _portConfig,
//                           keyboardType: TextInputType.number,
//                           validator: (value) {
//                             if (value == null || value == '') {
//                               return 'Please enter port number';
//                             }

//                             return null;
//                           },
//                           decoration: const InputDecoration(
//                             labelText: 'Port',
//                             border: OutlineInputBorder(),
//                             hintText: 'Enter Port',
//                             isDense: true,
//                           ),
//                         ),
//                         const SizedBox(height: 40),
//                         Button(
//                           loading: loading,
//                           onPressed: saveSetting,
//                           child: const Text(
//                             'Save',
//                             style: TextStyle(color: Colors.white),
//                           ),
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//                 const Spacer(),
//                 const SizedBox(
//                   width: double.infinity,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         "Copyright@ 2023 BizDimension Cambodia",
//                         style: TextStyle(fontSize: 14.5, color: Colors.grey),
//                       ),
//                       SizedBox(
//                         height: 10,
//                       ),
//                       Text(
//                         "All right reserved",
//                         style: TextStyle(fontSize: 14.5, color: Colors.grey),
//                       )
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 30)
//               ],
//             ),
//           ),
//         ));
//   }
// }
import 'package:flutter/material.dart';
import 'package:wms_mobile/component/button/button.dart';
import 'package:wms_mobile/constant/style.dart';
import 'package:wms_mobile/utilies/storage/locale_storage.dart';
import '../../../utilies/dialog/dialog.dart';
import '../../../helper/helper.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hostConfig = TextEditingController();
  final _portConfig = TextEditingController();
  final _dbConfig = TextEditingController();

  bool loading = false;

  Future<void> init() async {
    final host = await LocalStorageManger.getString('host');
    final port = await LocalStorageManger.getString('port');
    final db = await LocalStorageManger.getString('CONNECT_COMPANY');

    setState(() {
      _hostConfig.text = host.isEmpty ? 'https://192.168.1.11' : host;
      _portConfig.text = port.isEmpty ? '50000' : port;
      _dbConfig.text = db.isEmpty ? "SBODEMOUS" : db;
    });
  }

  Future<void> saveSetting() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    await Future.delayed(const Duration(milliseconds: 700));

    await LocalStorageManger.setString('host', _hostConfig.text);
    await LocalStorageManger.setString('port', _portConfig.text);
    await LocalStorageManger.setString('CONNECT_COMPANY', _dbConfig.text);

    if (mounted) {
      setState(() => loading = false);
      MaterialDialog.snackBar(context, "Settings saved successfully!");
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Card Container
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Connection Settings",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: PRIMARY_COLOR,
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Web Server
                      TextFormField(
                        controller: _hostConfig,
                        keyboardType: TextInputType.url,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter IP or server URL';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.language),
                          labelText: 'Web Server Address',
                          hintText: 'Enter web server address',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Port
                      TextFormField(
                        controller: _portConfig,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter port number';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.router),
                          labelText: 'Port',
                          hintText: 'Enter port number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Company Database Dropdown
                      // InputDecorator(
                      //   decoration: InputDecoration(
                      //     labelText: "Company Database",
                      //     border: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(12),
                      //     ),
                      //     contentPadding: const EdgeInsets.symmetric(
                      //         horizontal: 12, vertical: 4),
                      //   ),
                      //   child: DropdownButtonHideUnderline(
                      //     child: DropdownButton<String>(
                      //       isExpanded: true,
                      //       value: _selectedDB,
                      //       icon: const Icon(Icons.arrow_drop_down),
                      //       items: companyDBs.map((db) {
                      //         return DropdownMenuItem<String>(
                      //           value: db['value'],
                      //           child: Text(db['name']!),
                      //         );
                      //       }).toList(),
                      //       onChanged: (value) {
                      //         setState(() => _selectedDB = value);
                      //       },
                      //     ),
                      //   ),
                      // ),
                      TextFormField(
                        controller: _dbConfig,
                        // keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Dababase';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.data_saver_on),
                          labelText: 'Database',
                          hintText: 'Enter database',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 35),

                      // Save button
                      ElevatedButton(
                        onPressed: loading ? null : saveSetting,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PRIMARY_COLOR,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        child: loading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                'Save Settings',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),

                // Footer
                const Column(
                  children: [
                    Text(
                      "© 2025 BizDimension Cambodia",
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "All rights reserved",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
