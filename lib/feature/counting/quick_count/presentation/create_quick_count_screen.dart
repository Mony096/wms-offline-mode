import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_mobile/component/form/input_col.dart';
import 'package:wms_mobile/feature/bin_location/presentation/cubit/bin_cubit.dart';
import 'package:wms_mobile/feature/bin_location/presentation/cubit/bin_offline_cubit.dart';
import 'package:wms_mobile/feature/counting/quick_count/presentation/cubit/cycle_count_offline_cubit.dart';
import 'package:wms_mobile/feature/counting/quick_count/presentation/cubit/quick_count_offline_cubit.dart';
import 'package:wms_mobile/feature/inbound/good_receipt_po/presentation/duplicateItem_GPO_Screen.dart';
import 'package:wms_mobile/feature/item/presentation/cubit/items_barcode_offline_cubit.dart';
import 'package:wms_mobile/feature/item/presentation/cubit/items_cycle_count_offline_cubit.dart';
import 'package:wms_mobile/feature/item/presentation/cubit/items_find_stock_offline_cubit.dart';
import 'package:wms_mobile/feature/item/presentation/cubit/items_offline_cubit.dart';
import 'package:wms_mobile/feature/item_by_code/presentation/screen/item_page.dart';
import 'package:wms_mobile/feature/unit_of_measurement/presentation/cubit/uom_group_offline_cubit.dart';
import 'package:wms_mobile/feature/warehouse/presentation/screen/warehouse_page.dart';
import 'package:wms_mobile/utilies/dio_client.dart';
import '../../good_receip_batch_screen.dart' show GoodReceiptBatchScreen;
import '../../good_receip_serial_screen.dart';
import '/feature/bin_location/domain/entity/bin_entity.dart';
import '/feature/bin_location/presentation/screen/bin_page.dart';
import '../../../../core/error/failure.dart';
import '../../../item/presentation/cubit/item_cubit.dart';
import '/component/button/button.dart';
import '/component/form/input.dart';
import '/core/enum/global.dart';
import '/feature/item/presentation/screen/item_page.dart';
import '/feature/unit_of_measurement/domain/entity/unit_of_measurement_entity.dart';
import '/feature/unit_of_measurement/presentation/screen/unit_of_measurement_page.dart';
import '/helper/helper.dart';
import '/utilies/dialog/dialog.dart';
import '/utilies/storage/locale_storage.dart';
// import 'package:iscan_data_plugin/iscan_data_plugin.dart';
import '../../../../constant/style.dart';
import 'cubit/quick_count_cubit.dart';

class CreateQuickCountScreen extends StatefulWidget {
  CreateQuickCountScreen({super.key, required this.isQuickCount});
  bool isQuickCount;
  @override
  State<CreateQuickCountScreen> createState() => _CreateQuickCountScreenState();
}

class _CreateQuickCountScreenState extends State<CreateQuickCountScreen> {
  final uomText = TextEditingController();
  final quantity = TextEditingController();
  final ref = TextEditingController();
  final warehouse = TextEditingController();
  final uom = TextEditingController();
  final uomAbEntry = TextEditingController();
  final itemCode = TextEditingController();
  final itemName = TextEditingController();
  final baseUoM = TextEditingController();
  final uoMGroupDefinitionCollection = TextEditingController();
  final binId = TextEditingController();
  final binCode = TextEditingController();

  final serialsInput = TextEditingController();
  final batchesInput = TextEditingController();
  final docEntry = TextEditingController();
  final refLineNo = TextEditingController();
  final inWhsQty = TextEditingController();

  //
  final isBatch = TextEditingController();
  final isSerial = TextEditingController();

  late QuickCountCubit _bloc;
  late ItemCubit _blocItem;
  final barCode = TextEditingController();
  final DioClient dio = DioClient();
  List<dynamic> itemCodeFilter = [];
  int isEdit = -1;
  bool isSerialOrBatch = false;
  List<dynamic> items = [];
  List<dynamic> binLists = [];
  bool loading = false;
  late BinCubit _blocBin;
  bool isClickScanItem = false;
  bool isClickScanBin = false;
  final FocusNode _itemCode = FocusNode();
  final FocusNode _quantity = FocusNode();
  final FocusNode _bin = FocusNode();
  final FocusNode _ref = FocusNode();

  @override
  void initState() {
    init();
    _bloc = context.read<QuickCountCubit>();
    _blocItem = context.read<ItemCubit>();
    _blocBin = context.read<BinCubit>();

    //
    // IscanDataPlugin.methodChannel.setMethodCallHandler((MethodCall call) async {
    //   try {
    //     IscanDataPlugin.methodChannel
    //         .setMethodCallHandler((MethodCall call) async {
    //       if (call.method == "onScanResults") {
    //         if (loading) return;

    //         setState(() {
    //           if (call.arguments['data'] == "decode error") return;
    //           barCode.text = call.arguments['data'];
    //           onCompleteTextEditItem();
    //         });
    //       }
    //     });
    //   } catch (e) {
    //     print("Error setting method call handler: $e");
    //   }
    // });
    super.initState();
  }

  void init() async {
    final whs = await LocalStorageManger.getString('warehouse');
    warehouse.text = whs;
    if (!widget.isQuickCount) {
      if (mounted) MaterialDialog.loading(context);

      List<Map<String, dynamic>> rawItems = [];
      final itemCycleCount = context.read<ItemCycleCountOfflineCubit>();

      // 🧩 Step 1: Filter bin by warehouse
      final filteredCycleCount = itemCycleCount.state
          .where((b) => b['WhsCode'] == warehouse.text)
          .toList();
      if (filteredCycleCount.isNotEmpty) {
        for (var element in filteredCycleCount) {
          final itemResponse =
              findFullItemInformation(context, element['ItemCode']);

          // if (barCodeObj.isEmpty) {
          //   debugPrint("⚠️ No barcode found for ${element['ItemCode']}");
          //   continue; // skip this item
          // }

          if (itemResponse == null) return;
          final barcodeList = context.read<ItemBarcodeOfflineCubit>().state;
          // Find matching barcodes
          final barCodeObj = barcodeList.firstWhere(
            (e) =>
                e['ItemCode'] == element['ItemCode'] &&
                e['UoMEntry'] == itemResponse["InventoryUoMEntry"],
            orElse: () => {},
          );
          print(element['UoMEntry']);
          print(barCodeObj);
          rawItems.add({
            "ItemCode": element['ItemCode'],
            "ItemDescription": itemResponse['ItemName'],
            "Quantity": null,
            // "TotalQuantity":
            //     getDataFromDynamic(element['RemainingOpenQuantity']),
            "WarehouseCode": warehouse.text,
            "UoMEntry":
                getDataFromDynamic(itemResponse['InventoryUoMEntry'] ?? "-1"),
            "UoMCode": itemResponse['InventoryUOM'] ?? "Manual",
            "UoMGroupDefinitionCollection":
                itemResponse['UoMGroupDefinitionCollection'],
            "BaseUoM": itemResponse['BaseUoM'],

            "ManageSerialNumbers": itemResponse["ManageSerialNumbers"],
            "ManageBatchNumbers": itemResponse["ManageBatchNumbers"],
            "BinId": binId.text,
            "BarCode": barCodeObj['BarCode'],
          });

          itemCodeFilter.add(element['ItemCode']);
        }
      }

      items = combineItems(rawItems);

      if (mounted) MaterialDialog.close(context);

      if (mounted) {
        setState(() {
          items;
        });
      }
    }
  }

  List<Map<String, dynamic>> combineItems(List<Map<String, dynamic>> rawItems) {
    Map<String, Map<String, dynamic>> combinedItemsMap = {};

    for (var item in rawItems) {
      // Convert quantity to double
      double quantity =
          double.tryParse(item["TotalQuantity"].toString()) ?? 0.0;

      String key = '${item["ItemCode"]}_${item["UoMCode"]}';

      if (combinedItemsMap.containsKey(key)) {
        // Add to the existing quantity
        combinedItemsMap[key]!["TotalQuantity"] =
            (combinedItemsMap[key]!["TotalQuantity"] as double) + quantity;
      } else {
        // Add a new item
        combinedItemsMap[key] = {
          "ItemCode": item["ItemCode"],
          "ItemDescription": item["ItemDescription"],
          "Quantity": null,
          "TotalQuantity": quantity,
          "WarehouseCode": item["WarehouseCode"],
          "UoMEntry": item["UoMEntry"],
          "UoMCode": item["UoMCode"],
          "UoMGroupDefinitionCollection": item["UoMGroupDefinitionCollection"],
          "BaseUoM": item["BaseUoM"],
          "BinId": item["BinId"],
          "ManageSerialNumbers": item["ManageSerialNumbers"],
          "ManageBatchNumbers": item["ManageBatchNumbers"],
          "BarCode": item['BarCode'],
        };
      }
    }

    return combinedItemsMap.values.toList();
  }

  onSelectItem() async {
    setState(() {
      isEdit = -1;
    });
    goTo(context, ItemPage(type: ItemType.inventory)).then((value) async {
      if (value == null) return;

      // 🧠 Load Bin and ItemFindStock data from Hive via Cubit
      final binCubit = context.read<BinOfflineCubit>();
      final itemStockCubit = context.read<ItemFindStockOfflineCubit>();

      final binList = binCubit.state;
      final itemStockList = itemStockCubit.getJsonData();

      // 🧩 Step 1: Filter bin by warehouse
      final filteredBin =
          binList.where((b) => b['Warehouse'] == warehouse.text).toList();
      if (filteredBin.isEmpty) {
        // 🧩 Step 2: Find item in offline stock list
        final matchedItemStock = itemStockList.firstWhere(
          (item) =>
              item['ItemCode'] == value['ItemCode'] &&
              item['WhsCode'] == warehouse.text,
          orElse: () => {},
        );

        // 🧩 Step 3: Update stock quantity (offline)
        if (matchedItemStock.isNotEmpty) {
          final onHandQty = matchedItemStock['OnHandQty'] ?? 0;
          setState(() {
            inWhsQty.text = onHandQty.toString();
          });
        } else {
          setState(() {
            inWhsQty.text = "0";
          });
        }
      }

      // 🧩 Step 4: Continue normal item setup
      onSetItemTemp(value);
    });
  }

  void onChangeUoM() async {
    try {
      final data =
          jsonDecode(uoMGroupDefinitionCollection.text) as List<dynamic>;

      goTo(
              context,
              UnitOfMeasurementPage(
                  ids: data.map((e) => e['AlternateUoM'] as int).toList()))
          .then((value) {
        if (value == null) return;

        uom.text = value["Code"];
        uomAbEntry.text = value["AbsEntry"].toString();
      });
    } catch (e) {
      print(e);
    }
  }

  void onAddItem({bool force = false}) {
    try {
      List<dynamic> data = [...items];

      if (itemCode.text == '') {
        throw Exception('Item is missing.');
      }

      final item = {
        "ItemCode": itemCode.text,
        "ItemDescription": itemName.text,
        "Quantity": quantity.text,
        "WarehouseCode": warehouse.text,
        "UoMEntry": uomAbEntry.text,
        "UoMCode": uom.text,
        "BaseEntry": docEntry.text,
        "BaseLine": refLineNo.text,
        "UoMGroupDefinitionCollection":
            jsonDecode(uoMGroupDefinitionCollection.text) ?? [],
        "BaseUoM": baseUoM.text,
        "BinId": binId.text,
        "BinCode": binCode.text,
        "InWhsQty": inWhsQty.text,
        "ManageSerialNumbers": isSerial.text,
        "ManageBatchNumbers": isBatch.text,
        "Serials":
            serialsInput.text == "" ? [] : jsonDecode(serialsInput.text) ?? [],
        "Batches":
            batchesInput.text == "" ? [] : jsonDecode(batchesInput.text) ?? [],
      };

      if (isEdit == -1) {
        data.add(item);
      } else {
        data[isEdit] = item;
      }
      clear();
      setState(() {
        items = data;
        isSerialOrBatch = false;
      });
    } catch (err) {
      if (err is Exception) {
        MaterialDialog.success(context, title: 'Warning', body: err.toString());
      }
    }
  }

  void onEdit(dynamic item, int index) async {
    // final index = items.indexWhere((e) => e['ItemCode'] == item['ItemCode']);

    if (index < 0) return;

    MaterialDialog.warning(
      context,
      title: 'Item (${item['ItemCode']})',
      confirmLabel: "Edit",
      cancelLabel: "Remove",
      onConfirm: () async {
        itemCode.text = getDataFromDynamic(item['ItemCode']);
        itemName.text = getDataFromDynamic(item['ItemDescription']);
        quantity.text = getDataFromDynamic(item['Quantity']);
        uom.text = getDataFromDynamic(item['UoMCode']);
        uomAbEntry.text = getDataFromDynamic(item['UoMEntry']);
        binCode.text = getDataFromDynamic(item['BinCode']);
        binId.text = getDataFromDynamic(item['BinId']);
        baseUoM.text = getDataFromDynamic(item['BaseUoM']);
        docEntry.text = getDataFromDynamic(item['DocEntry']);
        refLineNo.text = getDataFromDynamic(item['BaseLine']);
        uoMGroupDefinitionCollection.text = jsonEncode(
          item['UoMGroupDefinitionCollection'],
        );
        isSerial.text = getDataFromDynamic(item['ManageSerialNumbers']);
        isBatch.text = getDataFromDynamic(item['ManageBatchNumbers']);
        batchesInput.text = jsonEncode(item['Batches'] ?? []);
        serialsInput.text = jsonEncode(item['Serials'] ?? []);
        inWhsQty.text = getDataFromDynamic(item["InWhsQty"]);
        final binCubit = context.read<BinOfflineCubit>();
        final itemStockCubit = context.read<ItemFindStockOfflineCubit>();

        final binList = binCubit.state;
        final itemStockList = itemStockCubit.getJsonData();

        // 🧩 Step 1: Filter bin by warehouse
        final filteredBin =
            binList.where((b) => b['Warehouse'] == warehouse.text).toList();
        if (filteredBin.isEmpty && !widget.isQuickCount) {
          final matchedItemStock = itemStockList.firstWhere(
            (i) =>
                i['ItemCode'] == item['ItemCode'] &&
                i['WhsCode'] == warehouse.text,
            orElse: () => {},
          );
          print(matchedItemStock);
          // 🧩 Step 3: Update stock quantity (offline)
          if (matchedItemStock.isNotEmpty) {
            final onHandQty = matchedItemStock['OnHandQty'] ?? 0;
            setState(() {
              inWhsQty.text = onHandQty.toString();
            });
          } else {
            setState(() {
              inWhsQty.text = "0";
            });
          }
        }
        setState(() {
          isEdit = index;

          if (getDataFromDynamic(item['ManageSerialNumbers']) == 'tYES' ||
              getDataFromDynamic(item['ManageBatchNumbers']) == 'tYES') {
            isSerialOrBatch = true;
          }
        });
      },
      onCancel: () {
        List<dynamic> data = [...items];
        data.removeAt(index);
        setState(() {
          items = data;
        });
      },
    );
  }

  void onChangeBin() async {
    if (itemCode.text.isEmpty) {
      MaterialDialog.warning(context,
          title: 'Warning', body: "Item Code is Required.");
      return;
    }

    final value = await goTo(
      context,
      BinPage(warehouse: warehouse.text, itemCode: itemCode.text),
    );

    if (value == null) return;
    print("✅ onChangeBin started");

    binId.text = getDataFromDynamic((value as BinEntity).id).toString().trim();
    binCode.text = getDataFromDynamic(value.code).toString().trim();

    final item = itemCode.text.trim();
    final whs = warehouse.text.trim();
    final bin = binId.text.trim();

    print("🧾 Item: $item");
    print("🏭 Warehouse: $whs");
    print("📦 BinID: $bin");

    try {
      if (item.isNotEmpty && whs.isNotEmpty && bin.isNotEmpty) {
        // 🧠 Get offline data
        final itemStockCubit = context.read<ItemFindStockOfflineCubit>();
        final stockData = itemStockCubit.getJsonData();

        // 🔍 Find matching item in offline stock
        final matched = stockData.firstWhere(
          (e) =>
              e['ItemCode'].toString().trim() == item &&
              e['WhsCode'].toString().trim() == whs &&
              e['BinID'].toString().trim() == bin,
          orElse: () => {},
        );

        if (matched.isNotEmpty) {
          final onHandQty = matched['OnHandQty'] ?? 0;
          setState(() {
            inWhsQty.text = onHandQty.toString();
          });
        } else {
          // ❌ Not found in offline data
          setState(() {
            inWhsQty.text = "0";
          });
          MaterialDialog.warning(
            context,
            title: "Not Found",
            body: "No offline stock found for this item in the selected bin.",
          );
        }
      }

      print("📦 In-warehouse quantity: ${inWhsQty.text}");
    } catch (e, stack) {
      print("❌ Error during offline lookup: $e");
      print("📜 Stack trace: $stack");
      setState(() {
        inWhsQty.text = "0";
      });
    }
  }

  void onChangeWhs() async {
    goTo(context, WarehousePage()).then((value) {
      if (value == null) return;
      inWhsQty.text = "";
      binCode.text = "";
      binId.text = "";
      itemCode.text = "";
      itemName.text = "";
      uom.text = "";
      uomAbEntry.text = "";
      warehouse.text = getDataFromDynamic(value);
    });
  }

  void onPostToSAP() async {
    try {
      MaterialDialog.loading(context);
      final filteredItems = items.where((item) {
        final qty = int.tryParse(item["Quantity"].toString()) ?? 0;
        return qty != 0;
      }).toList();
      Map<String, dynamic> data = {
        // "BranchID": 1,
        "Reference2": ref.text,
        "InventoryPostingLines": filteredItems.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> item = entry.value;
          List<dynamic> inventoryPostingLineUoMs = [
            // {
            //   "LineNumber": index + 1,
            //   "ChildNumber": 1,
            //   "UoMCountedQuantity": item["Quantity"],
            //   "CountedQuantity": item["Quantity"],
            //   "UoMCode": item['UoMCode']
            // }
          ];

          bool isBatch = item['ManageBatchNumbers'] == 'tYES';
          bool isSerial = item['ManageSerialNumbers'] == 'tYES';

          if (isBatch || isSerial) {
            inventoryPostingLineUoMs = [];
          }

          return {
            "ItemCode": item['ItemCode'],
            "ItemDescription": item['ItemDescription'],
            "UoMCode": item['UoMCode'],
            "BinEntry": item["BinId"],
            "Price": 1,
            "Variance": double.parse(item["Quantity"]).toInt() -
                double.parse(item["InWhsQty"]).toInt(),
            "CountedQuantity": item["Quantity"],
            "WarehouseCode": warehouse.text,
            "InventoryPostingSerialNumbers":
                (item['Serials'] as List<dynamic>).map((b) {
              return {
                "InternalSerialNumber": b["InternalSerialNumber"],
                "Quantity": double.parse(item["Quantity"]).toInt() -
                            double.parse(item["InWhsQty"]).toInt() <
                        0
                    ? -1
                    : 1,
              };
            }).toList(),
            "InventoryPostingBatchNumbers":
                (item['Batches'] as List<dynamic>).map((b) {
              return {
                "BatchNumber": b["BatchNumber"],
                "Quantity": double.parse(item["Quantity"]).toInt() -
                    double.parse(item["InWhsQty"]).toInt(),
                "ExpiryDate": b["ExpiryDate"]
              };
            }).toList(),
            "InventoryPostingLineUoMs": inventoryPostingLineUoMs
          };
        }).toList(),
      };
      if (widget.isQuickCount) {
        context.read<QuickCountOfflineCubit>().addData(data);
      }
      {
        context.read<CycleCountOfflineCubit>().addData(data);
      }
      if (mounted) {
        Navigator.of(context).pop();
        MaterialDialog.success(
          context,
          title: 'Successfully',
          body: widget.isQuickCount ? "Saved Quick Count" : "Saved Cycle Count",
          onOk: () => Navigator.of(context).pop(),
        );
      }
      clear();
      setState(() {
        items = [];
      });
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        MaterialDialog.warning(context, title: 'Error', body: e.toString());
      }
    }
  }

  void clear() {
    itemCode.text = '';
    itemName.text = '';
    quantity.text = '';
    binId.text = '';
    binCode.text = '';
    uom.text = '';
    uomAbEntry.text = '';
    isBatch.text = '';
    isSerial.text = '';
    docEntry.text = '';
    refLineNo.text = '';
    isEdit = -1;
    inWhsQty.text = "0";
  }

  void onSetItemTemp(dynamic value) async {
    try {
      setState(() {
        isSerialOrBatch = false;
      });
      if (value == null) return;
      binId.text = '';
      binCode.text = '';
      MaterialDialog.loading(context);
      itemCode.text = getDataFromDynamic(value['ItemCode']);
      FocusScope.of(context).requestFocus(FocusNode());

      itemCode.text = getDataFromDynamic(value['ItemCode']);
      itemName.text = getDataFromDynamic(value['ItemName']);
      // quantity.text = '0';
      uom.text = getDataFromDynamic(value['InventoryUOM'] ?? 'Manual');

      uomAbEntry.text = getDataFromDynamic(value['InventoryUoMEntry'] ?? '-1');
      baseUoM.text = jsonEncode(getDataFromDynamic(value['BaseUoM'] ?? '-1'));
      uoMGroupDefinitionCollection.text = jsonEncode(
        value['UoMGroupDefinitionCollection'] ?? [],
      );

      isSerial.text = getDataFromDynamic(value['ManageSerialNumbers']);
      isBatch.text = getDataFromDynamic(value['ManageBatchNumbers']);

      if (value['ManageSerialNumbers'] == 'tYES' ||
          value['ManageBatchNumbers'] == 'tYES') {
        setState(() {
          isSerialOrBatch = true;
        });
      }
      if (mounted) {
        MaterialDialog.close(context);
      }
    } catch (e) {
      print(e);
    }
  }

  // void onCompleteTextEditItem() async {
  //   try {
  //     if (barCode.text == '') return;
  //     quantity.text = '';
  //     MaterialDialog.loading(context);
  //     final barcodeRes = await dio.get(
  //         "/view.svc/WMS_ITEM_BARCODEB1SLQuery?\$filter=BarCode eq '${barCode.text}' ");
  //     if (barcodeRes.statusCode == 200) {
  //       if (barcodeRes.data["value"].length == 0) {
  //         if (barcodeRes.data["value"].length == 0) {
  //           MaterialDialog.close(
  //             context,
  //           );
  //           clear();
  //           MaterialDialog.success(context, title: 'Opps.', body: "No Item");
  //           return;
  //         }
  //       }
  //       if (barcodeRes.data["value"].length > 1) {
  //         for (var element in barcodeRes.data["value"]) {
  //           itemCodeFilter.add(element['ItemCode']);
  //         }
  //         goTo(
  //                 context,
  //                 ItemByCodePage(
  //                     type: ItemType.purchase,
  //                     itemCode: itemCodeFilter
  //                         .map((item) => "ItemCode eq '$item'")
  //                         .join(' or ')))
  //             .then((value) {
  //           if (value == null) return;
  //           if (mounted) {
  //             MaterialDialog.close(context);
  //           }
  //           uom.text =
  //               getDataFromDynamic(barcodeRes.data["value"]?[0]?["UomCode"]);
  //           uomAbEntry.text =
  //               getDataFromDynamic(barcodeRes.data["value"]?[0]?["UomEntry"]);
  //           onSetItemTemp(value);
  //         });
  //         return;
  //       }
  //       final item = await _blocItem
  //           .find("('${barcodeRes.data["value"]?[0]?["ItemCode"]}')");
  //       if (mounted) {
  //         MaterialDialog.close(context);
  //       }
  //       uom.text = getDataFromDynamic(barcodeRes.data["value"]?[0]?["UomCode"]);
  //       uomAbEntry.text =
  //           getDataFromDynamic(barcodeRes.data["value"]?[0]?["UomEntry"]);
  //       onSetItemTemp(item);
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       MaterialDialog.close(context);
  //       if (e is ServerFailure) {
  //         MaterialDialog.success(context, title: 'Failed', body: e.message);
  //       }
  //     }
  //   }
  // }
  void onCompleteTextEditItem() async {
    try {
      if (barCode.text == '') return;
      if (!widget.isQuickCount) {
        final duplicateItem =
            items.where((e) => e["BarCode"] == barCode.text).toList();
        if (duplicateItem.isEmpty) {
          MaterialDialog.success(context,
              title: 'Opps.', body: "Item not found");
          return;
        }
        if (duplicateItem.length > 1) {
          goTo(
              context,
              DuplicateItemGPOPage(
                barCode: barCode.text,
                items: duplicateItem,
              )).then((item) {
            if (item == null) return;
            final index = items.indexWhere((e) =>
                e['BarCode'] == item['BarCode'] &&
                e['ItemCode'] == item['ItemCode']);
            onEdit(item, index);
          });
          return;
        }
        // Continue processing if there is only one matching item
        final item =
            await items.firstWhere((e) => e["BarCode"] == barCode.text);
        final index = items.indexWhere((e) => e['BarCode'] == item['BarCode']);
        onEdit(item, index);
      } else {
        quantity.text = '';
        // Get all offline barcode data

        final barcodeList = context.read<ItemBarcodeOfflineCubit>().state;
        final matchedBarcodes =
            barcodeList.where((e) => e['BarCode'] == barCode.text).toList();

        if (matchedBarcodes.isEmpty) {
          clear();
          MaterialDialog.success(context, title: 'Oops.', body: "No Item");
          return;
        }

        if (matchedBarcodes.length > 1) {
          for (var element in matchedBarcodes) {
            itemCodeFilter.add(element['ItemCode']);
          }

          goTo(
            context,
            ItemByCodePage(
              type: ItemType.purchase,
              itemCode: itemCodeFilter
                  .map((item) => "ItemCode eq '$item'")
                  .join(' or '),
            ),
          ).then((value) {
            if (value == null) return;
            if (mounted) MaterialDialog.close(context);

            final first = matchedBarcodes.first;
            uom.text = getDataFromDynamic(first['UomCode']);
            uomAbEntry.text = getDataFromDynamic(first['UomEntry']);
            onSetItemTemp(value);
          });

          return;
        }

        // Only one barcode match
        final first = matchedBarcodes.first;
        final itemList = context.read<ItemOfflineCubit>().state;
        final matchedItem = itemList.firstWhere(
            (e) => e['ItemCode'] == first['ItemCode'],
            orElse: () => null);

        if (matchedItem == null) {
          MaterialDialog.success(context,
              title: 'Oops.', body: "Item not found");
          return;
        }
        final uomGroupCubit = context.read<UOMGroupOfflineCubit>();
        final uomGroup = uomGroupCubit.state.firstWhere(
          (u) => u['AbsEntry'] == matchedItem['UoMGroupEntry'],
          orElse: () => {},
        );
        final itemMapped = {
          ...matchedItem,
          "BaseUoM": uomGroup['BaseUoM'],
          "UoMGroupDefinitionCollection":
              uomGroup['UoMGroupDefinitionCollection']
        };
        final binCubit = context.read<BinOfflineCubit>();
        final itemStockCubit = context.read<ItemFindStockOfflineCubit>();

        final binList = binCubit.state;
        final itemStockList = itemStockCubit.getJsonData();

        // 🧩 Step 1: Filter bin by warehouse
        final filteredBin =
            binList.where((b) => b['Warehouse'] == warehouse.text).toList();
        if (filteredBin.isEmpty) {
          // 🧩 Step 2: Find item in offline stock list
          final matchedItemStock = itemStockList.firstWhere(
            (item) =>
                item['ItemCode'] == itemMapped["ItemCode"] &&
                item['WhsCode'] == warehouse.text,
            orElse: () => {},
          );

          // 🧩 Step 3: Update stock quantity (offline)
          if (matchedItemStock.isNotEmpty) {
            final onHandQty = matchedItemStock['OnHandQty'] ?? 0;
            setState(() {
              inWhsQty.text = onHandQty.toString();
            });
          } else {
            setState(() {
              inWhsQty.text = "0";
            });
          }
        }
        uom.text = getDataFromDynamic(first['UomCode']);
        uomAbEntry.text = getDataFromDynamic(first['UomEntry']);
        onSetItemTemp(itemMapped);
      }
    } catch (e) {
      if (mounted) {
        MaterialDialog.close(context);
        if (e is ServerFailure) {
          MaterialDialog.warning(context, title: 'Failed', body: e.message);
        } else {
          MaterialDialog.warning(context, title: 'Failed', body: e.toString());
        }
      }
    }
  }

  void onCompleteQuantiyInput() {
    FocusScope.of(context).requestFocus(FocusNode());
    onNavigateSerialOrBatch();
  }

  void onNavigateSerialOrBatch({bool force = false}) {
    // return;
    // if (quantity.text == "") return;
    // if (double.parse(inWhsQty.text).toInt() ==
    //     double.parse(quantity.text).toInt()) return;

    if (isSerial.text == 'tYES') {
      final serialList = serialsInput.text == "" || serialsInput.text == "null"
          ? []
          : jsonDecode(serialsInput.text) as List<dynamic>;

      if (force == false && (quantity.text == serialList.length.toString())) {
        return;
      }
      goTo(
        context,
        GoodReceiptSerialScreen(
            itemCode: itemCode.text,
            quantity: quantity.text,
            listAllSerial: double.parse(
                            inWhsQty.text.isEmpty ? "0" : inWhsQty.text)
                        .toInt() <
                    double.parse(quantity.text.isEmpty ? "0" : quantity.text)
                        .toInt()
                ? null
                : true,
            // listAllSerial: true,
            inWhsQty: inWhsQty.text,
            binCode: binId.text,
            serials: serialList,
            isQuickCount: true,
            itemName: itemName.text,
            warehouse: warehouse.text,
            isEdit: isEdit),
      ).then((value) {
        if (value == null) return;

        quantity.text = value['quantity'] ?? "0";
        serialsInput.text = jsonEncode(value['items']);
      });
    } else if (isBatch.text == 'tYES') {
      final batches = batchesInput.text == "" || batchesInput.text == "null"
          ? []
          : jsonDecode(batchesInput.text) as List<dynamic>;
      goTo(
        context,
        GoodReceiptBatchScreen(
            itemCode: itemCode.text,
            quantity: quantity.text,
            isQuickCount: true,
            inWhsQty: inWhsQty.text,
            alcQty: double.parse(quantity.text).toInt() -
                double.parse(inWhsQty.text).toInt(),
            listAllBatch: true,
            // double.parse(inWhsQty.text).toInt() <
            //         double.parse(quantity.text).toInt()
            //     ? null
            //     : true,
            serials: batches,
            binCode: binId.text,
            itemName: itemName.text,
            warehouse: warehouse.text,
            isEdit: isEdit),
      ).then((value) {
        if (value == null) return;
        quantity.text = value['quantity'] ?? "0";
        batchesInput.text = jsonEncode(value['items']);
      });
    }
  }

  // Generic function to request focus on a specific node
  void _requestFocus(FocusNode node) {
    if (!node.hasFocus) {
      // Use microtask for stability with fast, external keyboard input
      Future.microtask(() => node.requestFocus());
    }
  }

  void _handleScanSubmitted(String barcode, FocusNode submittedNode) {
    debugPrint("📦 Scanned Supplier Code: $barcode");

    setState(() {
      // Check which input currently has focus
      if (_itemCode.hasFocus) {
        // ✅ If filter input is focused → set scanned value
        barCode.text = barcode;
        itemCode.clear();
        onCompleteTextEditItem();
        isClickScanItem = false;
      } else if (_bin.hasFocus) {
        // ✅ If secondary input is focused → clear it
        binCode.clear();
        binId.clear();
        MaterialDialog.warning(context,
            title: 'Opps', body: "Scan Bin not impliment yet!");
        isClickScanBin = false;
      } else if (_quantity.hasFocus) {
        quantity.clear();
      } else if (_ref.hasFocus) {
        ref.clear();
      }
      // else {
      //   // ✅ Optional: fallback behavior if no input focused
      //   debugPrint("⚠️ No input focused, ignoring scan");
      // }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: PRIMARY_COLOR,
        iconTheme: IconThemeData(color: Colors.white),
        title: Padding(
          padding: const EdgeInsets.only(right: 60),
          child: Center(
            child: Text(
              widget.isQuickCount
                  ? 'Create Quick Counting'
                  : 'Create Cycle Counting',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(5),
                child: Column(
                  children: [
                    Input(
                      label: 'Warehouse',
                      placeholder: 'Warehouse',
                      controller: warehouse,
                      readOnly: true,
                      onPressed: onChangeWhs,
                    ),
                    // Divider(thickness: 1, color: Colors.grey.shade400),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Divider(thickness: 0.5, color: Colors.grey.shade500),
              const SizedBox(height: 5),
              InputCol(
                label: 'Reference',
                placeholder: 'Please input reference',
                controller: ref,
                focusNode: _ref,
                onFieldSubmitted: (value) {
                  _handleScanSubmitted(value, _ref);
                },
              ),
              const SizedBox(height: 8),

              // ====== Bin Location ======

              // ====== Scan & Select Items ======
              Row(
                children: [
                  Expanded(
                    child: InputCol(
                      focusNode: _itemCode,
                      label: 'Item Code',
                      placeholder: 'Chose Item',
                      controller: itemCode,
                      onTap: () => {
                        setState(() {
                          isClickScanItem = false; // turn on scan mode
                          // itemCode.clear();
                        }),
                        // 2. Clear current focus before switching
                        FocusScope.of(context).unfocus()
                      },
                      keyboardType: TextInputType.none,
                      onFieldSubmitted: (value) {
                        _handleScanSubmitted(value, _itemCode);
                      },
                      onPressed: onSelectItem,
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  GestureDetector(
                    onTap: () {
                      // 1. Switch to scan mode
                      setState(() {
                        isClickScanItem = true; // turn on scan mode
                        isClickScanBin = false; // turn on scan mode
                        itemCode.clear();
                      });

                      // 2. Clear current focus before switching
                      FocusScope.of(context).unfocus();

                      // 3. Focus scanner input
                      Future.delayed(const Duration(milliseconds: 100), () {
                        _requestFocus(_itemCode);
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(top: 30),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F3F4),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isClickScanItem
                              ? Colors.green
                              : Colors
                                  .transparent, // ✅ green border when active
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.document_scanner_outlined,
                        color: Color(0xFF12169D),
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
              const SizedBox(height: 7),
              Row(
                children: [
                  Expanded(
                    child: InputCol(
                      label: 'Bin Location',
                      placeholder: 'Chose Bin Location',
                      controller: binCode,
                      focusNode: _bin,
                      onTap: () => {
                        setState(() {
                          isClickScanBin = false; // turn on scan mode
                          // itemCode.clear();
                        }),
                        // 2. Clear current focus before switching
                        FocusScope.of(context).unfocus()
                      },
                      keyboardType: TextInputType.none,
                      onPressed: onChangeBin,
                      onFieldSubmitted: (value) {
                        _handleScanSubmitted(value, _bin);
                      },
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  GestureDetector(
                    onTap: () {
                      // 1. Switch to scan mode
                      setState(() {
                        isClickScanBin = true; // turn on scan mode
                        isClickScanItem = false;
                        binCode.clear();
                        binId.clear();
                      });

                      // 2. Clear current focus before switching
                      FocusScope.of(context).unfocus();

                      // 3. Focus scanner input
                      Future.delayed(const Duration(milliseconds: 100), () {
                        _requestFocus(_bin);
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(top: 30),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F3F4),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isClickScanBin
                              ? Colors.green
                              : Colors
                                  .transparent, // ✅ green border when active
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.document_scanner_outlined,
                        color: Color(0xFF12169D),
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
              const SizedBox(height: 8),
              // ====== Input Qty & UoM ======
              Row(
                children: [
                  Expanded(
                    child: InputCol(
                      label: 'Input Qty',
                      placeholder: 'Quantity',
                      controller: quantity,
                      // readOnly: isSerialOrBatch ? true : false, // simpler
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      // onTap: isSerialOrBatch
                      //     ? () {
                      //         onNavigateSerialOrBatch(force: true);
                      //       }
                      //     : null,
                      onEditingComplete: onCompleteQuantiyInput,
                      onPressed: quantity.text.isNotEmpty &&
                              (isBatch.text == "tYES" ||
                                  isSerial.text == "tYES")
                          ? double.parse(inWhsQty.text.isEmpty
                                          ? "0"
                                          : inWhsQty.text)
                                      .toInt() !=
                                  double.parse(quantity.text.isEmpty
                                          ? "0"
                                          : quantity.text)
                                      .toInt()
                              ? () {
                                  onNavigateSerialOrBatch(force: true);
                                }
                              : null
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InputCol(
                      label: 'In Whs Qty',
                      placeholder: 'In Whs Qty',
                      controller: inWhsQty,
                      readOnly: true,
                      // onPressed: onChangeUoM,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              InputCol(
                label: 'Input UoM',
                placeholder: 'UoM',
                controller: uom,
                readOnly: true,
                onPressed: onChangeUoM,
              ),
              const SizedBox(height: 20),
              Container(
                margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
                child: Button(
                  bgColor: PRIMARY_COLOR,
                  onPressed: onAddItem,
                  child: Text(
                    isEdit == -1 ? "Add Item" : "Update Item",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300, width: 0.5),
                ),
                child: Column(
                  children: [
                    ContentHeader(),
                    items.isEmpty
                        ? Container(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              "No Item available",
                              style:
                                  TextStyle(fontSize: 15, color: Colors.grey),
                            ),
                          )
                        : Container(),
                    ...items.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return GestureDetector(
                        onTap: () => onEdit(item, index),
                        child: ItemRow(
                          item: item,

                          // Optional: pass index if you need inside ItemRow
                        ),
                      );
                    }).toList(),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: size(context).height * 0.09,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Button(
                variant: ButtonVariant.primary,
                disabled: isEdit != -1,
                onPressed: onPostToSAP,
                child: Text(
                  'Post',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Button(
                variant: ButtonVariant.outline,
                onPressed: () {
                  if (items.length > 0) {
                    MaterialDialog.warning(
                      context,
                      title: 'Warning',
                      body:
                          'Are you sure leave? once you pressed ok the data will be ereas.',
                      confirmLabel: 'Ok',
                      cancelLabel: 'Cancel',
                      onConfirm: () {
                        Navigator.of(context).pop();
                      },
                      onCancel: () {},
                    );
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: PRIMARY_COLOR,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ContentHeader extends StatelessWidget {
  const ContentHeader({super.key, this.hideOpenQty});
  final dynamic hideOpenQty;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 214, 214, 215), // Dark navy header
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Row(
        children: const [
          Expanded(
            flex: 3,
            child: Text(
              'Item No',
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'UoM',
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Qty',
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class ItemRow extends StatelessWidget {
  const ItemRow({super.key, required this.item, this.po, this.hideOpenQty});
  final dynamic po;
  final dynamic item;
  final dynamic hideOpenQty;
  String getDataFromDynamic(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade50,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // First Row (Item, UoM, Qty, Open Qty)
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  getDataFromDynamic(item['ItemCode']),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  getDataFromDynamic(item['UoMCode']),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  getDataFromDynamic(item['Quantity'] ?? "0"),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Second Row (Description)
          Text(
            getDataFromDynamic(item['ItemDescription']),
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 13,
            ),
          ),

          // Divider
          const SizedBox(height: 8),
          Divider(
            height: 1,
            thickness: 0.6,
            color: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }
}
