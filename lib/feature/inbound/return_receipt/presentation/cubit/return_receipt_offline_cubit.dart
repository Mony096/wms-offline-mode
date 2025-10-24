import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:wms_mobile/feature/inbound/return_receipt/presentation/cubit/return_receipt_failed_offline_cubit.dart';
import 'package:wms_mobile/helper/helper.dart';
import 'package:wms_mobile/utilies/storage/locale_storage.dart';

class ReturnReceiptOfflineCubit extends Cubit<List<dynamic>> {
  ReturnReceiptOfflineCubit() : super([]) {
    loadData();
  }

  final Box box = Hive.box('return_receipt');
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
  void clearCachLog() {
    failedRecords = [];
    successRecords = [];
  }
  List<dynamic> getJsonData() {
    final items = box.get('data', defaultValue: []).cast<dynamic>();
    return items;
  }

  int getLog() {
    final items = [...successRecords, ...failedRecords];
    return items.length;
  }

  void printAllData() {
    final items = getJsonData();
    print("🟢 Hive Data: $items");
  }

// 🔹 Remove record by failId
  void removeByFailId(dynamic failId) {
    final List<dynamic> items =
        box.get('data', defaultValue: []).cast<dynamic>();

    final updatedItems = items.where((item) {
      if (item is Map && item.containsKey('SaveId')) {
        return item['SaveId'] != failId;
      }
      return true; // keep items without failId field
    }).toList();

    box.put('data', updatedItems);
    emit(updatedItems);
  }

  // 🔹 Update record by failId
  void updateBySaveId(dynamic failId, Map<String, dynamic> newData) {
    final List<dynamic> items =
        box.get('data', defaultValue: []).cast<dynamic>();

    final updatedItems = items.map((item) {
      if (item is Map &&
          item.containsKey('SaveId') &&
          item['SaveId'] == failId) {
        return {...item, ...newData}; // merge old data with new data
      }
      return item;
    }).toList();

    box.put('data', updatedItems);
    emit(updatedItems);
  }

  Future<void> post(ReturnReceiptFailedOfflineCubit failCubit) async {
    final items = getJsonData();
    if (items.isEmpty) {
      print("⚠️ No offline records to sync.");
      return;
    }

    // 1️⃣ Clear data before sync attempt
    box.put('data', []);
    emit([]);

    failedRecords.clear();
    successRecords.clear();

    final host = await LocalStorageManger.getString('host');
    final port = await LocalStorageManger.getString('port');

    // ✅ Use saved token if available
    String loginToken = await LocalStorageManger.getString('token');

    if (loginToken.isEmpty) {
      // 2️⃣ Load stored credentials
      final username = await LocalStorageManger.getString('username');
      final password = await LocalStorageManger.getString('password');
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
      loginToken = loginData['SessionId'] ?? "";

      if (loginToken.isEmpty) {
        debugPrint("❌ Token not found in login response");
        await LocalStorageManger.setString('isDownloaded', 'false');
        return;
      }
    }

    loginFailTime = "";
    loginFail = "";
    var uuid = Uuid();

    // 3️⃣ Post each record to SAP
    for (var item in items) {
      final startTime = DateTime.now();
      try {
        await postToSAP(
          host: host,
          port: port,
          token: loginToken,
          endpoint: 'Returns',
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
        print(item);
        failedRecords.add({
          ...item,
          'error': e.toString(),
          'timestamp': startTime.toIso8601String(),
          'failId': uuid.v4(),
        });
      }
    }
    // Clean up failed records
    final cleanedFailedRecords = failedRecords.map((item) {
      final newItem = Map<String, dynamic>.from(item);
      newItem.remove('error');
      // newItem.remove('timestamp');
      return newItem;
    }).toList();

    // ✅ Add to failed box using the other cubit
    failCubit.addData(cleanedFailedRecords);

    print(
        "🎯 Sync completed. Success: ${items.length - failedRecords.length}, Failed: ${failedRecords.length}");
  }
}

