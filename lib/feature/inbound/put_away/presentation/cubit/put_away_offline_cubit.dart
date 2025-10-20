import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:wms_mobile/helper/helper.dart';
import 'package:wms_mobile/utilies/storage/locale_storage.dart';

class PutAwayOfflineCubit extends Cubit<List<dynamic>> {
  PutAwayOfflineCubit() : super([]) {
    loadData();
  }

  final Box box = Hive.box('put_away');
  List<dynamic> failedRecords = []; // 🔴 store failed syncs separately
  List<dynamic> successRecords = []; //  success syncs separately
  String loginFail = "";
  String loginFailTime = "";

  // Load data from Hive
  void loadData() {
    final items = box.get('data', defaultValue: []).cast<dynamic>();
    emit(items);
  }

  // Add data to Hive
  void addData(dynamic item) {
    final items = box.get('data', defaultValue: []).cast<dynamic>();
    items.add(item);
    box.put('data', items);
    emit(items);
  }

  // Clear all data
  void clearData() {
    box.put('data', []);
    emit([]);
  }

  List<dynamic> getJsonData() {
    final items = box.get('data', defaultValue: []).cast<dynamic>();
    return items;
  }

  void printAllData() {
    final items = getJsonData();
    print("🟢 Hive Data: $items");
  }

  // ✅ Post all offline data to SAP
  Future<void> post() async {
    final items = getJsonData();
    if (items.isEmpty) {
      print("⚠️ No offline records to sync.");
      return;
    }

    // 1️⃣ Clear data before sync attempt
    box.put('data', []);
    emit([]);

    // 2️⃣ Load stored credentials
    final username = await LocalStorageManger.getString('username');
    final password = await LocalStorageManger.getString('password');
    final host = await LocalStorageManger.getString('host');
    final port = await LocalStorageManger.getString('port');
    final company = await LocalStorageManger.getString('db');

    if (username.isEmpty || password.isEmpty || company.isEmpty) {
      debugPrint("❌ Missing username, password, or companyDB");
      return;
    }

    print("🌐 Logging in to SAP...");
    final loginResponse = await http.post(
      Uri.parse('$host:$port/b1s/v1/Login'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "CompanyDB": company,
        "UserName": username,
        "Password": password,
      }),
    );

    if (loginResponse.statusCode != 200) {
      debugPrint("❌ Login failed: ${loginResponse.body}");
      final startTime = DateTime.now();
      loginFailTime = startTime.toIso8601String();
      loginFail = loginResponse.body.toString();
      return;
    }

    final loginData = jsonDecode(loginResponse.body);
    final token = loginData['SessionId'];
    loginFailTime = "";
    loginFail = "";
    if (token == null) {
      debugPrint("❌ Token not found in login response");
      await LocalStorageManger.setString('isDownloaded', 'false');
      return;
    }

    failedRecords.clear();
    successRecords.clear();
    // 3️⃣ Post each record to SAP
    for (var item in items) {
      final startTime = DateTime.now();
      try {
        await postToSAP(
          host: host,
          port: port,
          token: token,
          endpoint: 'StockTransfers',
          body: item,
        );
        successRecords.add({
          ...item,
          'success': "Synced Successfully to SAP",
          'timestamp': startTime.toIso8601String(),
        });
        print("✅ Synced: ${item['DocEntry'] ?? 'N/A'}");
      } catch (e) {
        print("🔥 Failed to sync record: $e");
        print(e);
        failedRecords.add({
          ...item,
          'error': e.toString(),
          'timestamp': startTime.toIso8601String(),
        });
      }
    }
    print(
        "🎯 Sync completed. Success: ${items.length - failedRecords.length}, Failed: ${failedRecords.length}");
  }
}
