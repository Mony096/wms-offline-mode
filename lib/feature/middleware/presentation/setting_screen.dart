
import 'package:flutter/material.dart';
import 'package:wms_mobile/constant/style.dart';
import 'package:wms_mobile/utilies/storage/locale_storage.dart';
import '../../../utilies/dialog/dialog.dart';

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
    final db = await LocalStorageManger.getString('db');

    setState(() {
      _hostConfig.text = host.isEmpty ? 'https://svr10.biz-dimension.com' : host;
      _portConfig.text = port.isEmpty ? '5000' : port;
      _dbConfig.text = db.isEmpty ? "SBOLK" : db;
    });
  }

  Future<void> saveSetting() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    await Future.delayed(const Duration(milliseconds: 700));

    await LocalStorageManger.setString('host', _hostConfig.text);
    await LocalStorageManger.setString('port', _portConfig.text);
    await LocalStorageManger.setString('db', _dbConfig.text);

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
