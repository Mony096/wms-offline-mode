import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:wms_mobile/utilies/dialog/dialog.dart';

class PurchaseReturnRequestOfflineCubit extends Cubit<List<dynamic>> {
  PurchaseReturnRequestOfflineCubit() : super([]) {
    loadData();
  }

  final Box box = Hive.box('purchase_return_request');

  // Load existing data from Hive
  void loadData() {
    final List<dynamic> items =
        box.get('data', defaultValue: []).cast<dynamic>();
    emit(items);
  }

  // Add data to Hive
  void addData(dynamic item) {
    final List<dynamic> items =
        box.get('data', defaultValue: []).cast<dynamic>();
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
    final List<dynamic> items =
        box.get('data', defaultValue: []).cast<dynamic>();
    print("🟢 Hive Data: $items");
  }

  // ✅ Decrease quantity by DocEntry and LineId
  void decreaseQuantityByLine(
      {required dynamic docEntry,
      required int lineId,
      required double quantity,
      required BuildContext context}) {
    final List<dynamic> items =
        box.get('data', defaultValue: []).cast<dynamic>();

    final int docIndex =
        items.indexWhere((element) => element['DocEntry'] == docEntry);
    if (docIndex != -1) {
      final po = Map<String, dynamic>.from(items[docIndex]);

      if (po['DocumentLines'] != null) {
        final List<dynamic> documentLines =
            List<dynamic>.from(po['DocumentLines']);
        // Find the matching LineId
        final int lineIndex =
            documentLines.indexWhere((line) => line['LineNum'] == lineId);

        if (lineIndex != -1) {
          final currentQty =
              (documentLines[lineIndex]['RemainingOpenQuantity'] ?? 0)
                  .toDouble();

          // Decrease quantity but not below 0
          final newQty = (currentQty - quantity).clamp(0, double.infinity);
          documentLines[lineIndex]['RemainingOpenQuantity'] = newQty;
          po['DocumentLines'] = documentLines;
          // Update list & Hive
          items[docIndex] = po;
          box.put('data', items);
          emit(items);

          print(
              "✅ Decreased Quantity for DocEntry $docEntry, LineId $lineId → $currentQty → $newQty");
          return;
        }
      }
    } else {
      MaterialDialog.warning(context,
          title: 'Error',
          body:
              "PO No matching DocEntry ($docEntry) or LineId ($lineId) found.");

      print("⚠️ No matching DocEntry ($docEntry) or LineId ($lineId) found.");
    }
  }

  // ✅ Increase quantity by DocEntry and LineId
  void increaseQuantityByLine(
      {required int docEntry,
      required int lineId,
      required double quantity,
      required BuildContext context}) {
    final List<dynamic> items =
        box.get('data', defaultValue: []).cast<dynamic>();

    // Find the purchase order with matching DocEntry
    final int docIndex =
        items.indexWhere((element) => element['DocEntry'] == docEntry);

    if (docIndex != -1) {
      final po = Map<String, dynamic>.from(items[docIndex]);

      if (po['DocumentLines'] != null) {
        final List<dynamic> documentLines =
            List<dynamic>.from(po['DocumentLines']);

        // Find the matching LineId
        final int lineIndex =
            documentLines.indexWhere((line) => line['LineNum'] == lineId);

        if (lineIndex != -1) {
          final currentQty =
              (documentLines[lineIndex]['RemainingOpenQuantity'] ?? 0)
                  .toDouble();

          // Increase quantity
          final newQty = currentQty + quantity;

          documentLines[lineIndex]['RemainingOpenQuantity'] = newQty;
          po['DocumentLines'] = documentLines;

          // Update list & Hive
          items[docIndex] = po;
          box.put('data', items);
          emit(items);

          print(
              "✅ Increased Quantity for DocEntry $docEntry, LineId $lineId → $currentQty → $newQty");
          return;
        }
      }
    } else {
      MaterialDialog.warning(context,
          title: 'Error',
          body:
              "PO No matching DocEntry ($docEntry) or LineId ($lineId) found.");
      print("⚠️ No matching DocEntry ($docEntry) or LineId ($lineId) found.");
    }
  }
}
