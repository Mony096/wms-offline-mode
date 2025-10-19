import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:wms_mobile/helper/helper.dart';
import 'package:wms_mobile/utilies/storage/locale_storage.dart';

class QuickGoodReceiptOfflineCubit extends Cubit<List<dynamic>> {
  QuickGoodReceiptOfflineCubit() : super([]) {
    loadData();
  }
  final Box box = Hive.box('quick_goods_receipt');

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
    final items = box.get('data', defaultValue: []).cast<dynamic>();
    print("🟢 Hive Data: $items");
  }

  // ✅ Post all offline data to SAP
  Future<void> post() async {
    final items = getJsonData();
    if (items.isEmpty) {
      print("⚠️ No offline records to sync.");
      return;
    }
    // 1️⃣ Load offline credentials
    final username = await LocalStorageManger.getString('username');
    final password = await LocalStorageManger.getString('password');
    final host = await LocalStorageManger.getString('host');
    final port = await LocalStorageManger.getString('port');
    final company = await LocalStorageManger.getString('db');

    if (username.isEmpty || password.isEmpty || company.isEmpty) {
      debugPrint("❌ No username or passowrd or companyDB");
      return;
    }
    print(company);
    print(username);
    print(password);
    print("Login....");
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
      return;
    }

    final loginData = jsonDecode(loginResponse.body);
    final token = loginData['SessionId'];
    if (token == null) {
      debugPrint("❌ Token not found in login response");
      return;
    }

    List<dynamic> failed = [];

    for (var item in items) {
      try {
        await postToSAP(
          host: host,
          port: port,
          token: token,
          endpoint: 'PurchaseDeliveryNotes',
          body: item,
        );
        print("✅ Synced: ${item['DocEntry'] ?? 'N/A'}");
      } catch (e) {
        print("❌ Failed record: $e");
        failed.add({...item, 'error': e.toString()});
      }
    }

    box.put('data', failed);
    emit(failed);
    print(
        "🎯 Done. Success: ${items.length - failed.length}, Failed: ${failed.length}");
  }
}
