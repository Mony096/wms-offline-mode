import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

class WarehouseOfflineCubit extends Cubit<List<dynamic>> {
  WarehouseOfflineCubit() : super([]) {
    loadData();
  }

  final Box box = Hive.box('warehouse');

  // Load existing data from Hive
  void loadData() {
    final List<dynamic> items = box.get('data', defaultValue: []).cast<dynamic>();
    emit(items);
  }

  // Add data to Hive
  void addData(dynamic item) {
    final List<dynamic> items = box.get('data', defaultValue: []).cast<dynamic>();
    items.addAll(item);
    box.put('data', items);
    emit(items);
  }

  // Clear data
  void clearData() {
    box.put('data', []);
    emit([]);
  }
   // 👇 New function to print all saved data
  void printAllData() {
    final List<dynamic> items = box.get('data', defaultValue: []).cast<dynamic>();
    print("🟢 Hive Data: $items");
  }
}
