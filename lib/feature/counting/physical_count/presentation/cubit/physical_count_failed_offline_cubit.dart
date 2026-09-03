import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PhysicalCountFailedOfflineCubit extends Cubit<List<dynamic>> {
  PhysicalCountFailedOfflineCubit() : super([]) {
    loadData();
  }

  final Box box = Hive.box('failed_physical_count');

  // 🔹 Load existing data from Hive
  void loadData() {
    final List<dynamic> items =
        box.get('data', defaultValue: []).cast<dynamic>();
    emit(items);
  }

  // 🔹 Add data to Hive
  void addData(dynamic item) {
    final List<dynamic> items =
        box.get('data', defaultValue: []).cast<dynamic>();
    items.addAll(item);
    box.put('data', items);
    emit(items);
  }

  // 🔹 Clear all data
  void clearData() {
    box.put('data', []);
    emit([]);
  }

  // 🔹 Print all saved data
  void printAllData() {
    final List<dynamic> items =
        box.get('data', defaultValue: []).cast<dynamic>();
    print("🟢 Hive Data: $items");
  }

  // 🔹 Count failed records
  int getFailed() {
    final items = box.get('data', defaultValue: []).cast<dynamic>();
    return items.length;
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
}
