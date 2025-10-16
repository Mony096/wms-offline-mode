import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_mobile/component/form/input_col.dart';
import 'package:wms_mobile/feature/bin_location/presentation/cubit/bin_cubit.dart';
import 'package:wms_mobile/feature/item_by_code/presentation/screen/item_page.dart';
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
    // inWhsQty.text = "0";

    if (!widget.isQuickCount) {
      // Populate text fields with PO data
      // poText.text = getDataFromDynamic(widget.po['DocNum']);
      // cardCode.text = getDataFromDynamic(widget.po['CardCode']);
      // cardName.text = getDataFromDynamic(widget.po['CardName']);

      // Show loading indicator
      if (mounted) MaterialDialog.loading(context);

      // Initialize the list of items
      List<Map<String, dynamic>> rawItems = [];
      // final openLines = widget.po['DocumentLines']
      //     .where((line) => line['LineStatus'] == 'bost_Open')
      //     .toList();
      final cycleLineCount = await dio.get(
          "/view.svc/CycleItemCountB1SLQuery?\$filter = WhsCode eq '${warehouse.text}'");

      if (cycleLineCount.statusCode == 200) {
        for (var element in cycleLineCount.data["value"]) {
          final itemResponse =
              await _blocItem.find("('${element['ItemCode']}')");
          print(itemResponse);

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
            "BinId": binId.text,
            "ManageSerialNumbers": itemResponse["ManageSerialNumbers"],
            "ManageBatchNumbers": itemResponse["ManageBatchNumbers"],
            "BarCode": element['BarCode'],
          });

          itemCodeFilter.add(element['ItemCode']);
        }
      }

      items = combineItems(rawItems);

      // Combine items with the same ItemCode and UoMCode

      // Close loading indicator
      if (mounted) MaterialDialog.close(context);

      // Update state with combined items
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
      final stateBin = _blocBin.state;
      if (stateBin is BinData) {
        // print(state.entities);
        binLists = stateBin.entities;
      }

      if (binLists.where((b) => b.warehouse == warehouse.text).isEmpty) {
        final url =
            "/view.svc/ItemB1SLQuery?\$filter=ItemCode eq '${value["ItemCode"]}' and WhsCode eq '${warehouse.text}'";
        print("🌐 Request URL: $url");

        final response = await dio.get(url);

        final data = response.data["value"];
        if (data != null && data.isNotEmpty) {
          final onHandQty = data[0]["OnHandQty"] ?? 0;
          setState(() {
            inWhsQty.text = onHandQty.toString();
          });
        } else {
          setState(() {
            inWhsQty.text = "0";
          });
        }
      }
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

        uom.text = (value as UnitOfMeasurementEntity).code;
        uomAbEntry.text = (value).id.toString();
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
        final stateBin = _blocBin.state;
        if (stateBin is BinData) {
          // print(state.entities);
          binLists = stateBin.entities;
        }

        if (binLists.where((b) => b.warehouse == warehouse.text).isEmpty &&
            !widget.isQuickCount) {
          final url =
              "/view.svc/ItemB1SLQuery?\$filter=ItemCode eq '${item['ItemCode']}' and WhsCode eq '${warehouse.text}'";
          print("🌐 Request URL: $url");

          final response = await dio.get(url);

          final data = response.data["value"];
          print(data);
          if (data != null && data.isNotEmpty) {
            final onHandQty = data[0]["OnHandQty"] ?? 0;
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
        final url =
            "/view.svc/ItemB1SLQuery?\$filter=ItemCode eq '$item' and WhsCode eq '$whs' and BinID eq $bin";
        print("🌐 Request URL: $url");

        final response = await dio.get(url);

        final data = response.data["value"];
        if (data != null && data.isNotEmpty) {
          final onHandQty = data[0]["OnHandQty"] ?? 0;
          setState(() {
            inWhsQty.text = onHandQty.toString();
          });
        } else {
          setState(() {
            inWhsQty.text = "0";
          });
        }
      }

      print("📦 In-warehouse quantity: ${inWhsQty.text}");
    } catch (e, stack) {
      print("❌ Error during Dio request: $e");
      print("📜 Stack trace: $stack");
      setState(() {
        inWhsQty.text = "0";
      });
    }
  }

  void onChangeWhs() async {
    goTo(context, WarehousePage()).then((value) {
      if (value == null) return;
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
      setState(() {
        print(data);
      });
      final response = await _bloc.post(data);
      if (mounted) {
        Navigator.of(context).pop();
        MaterialDialog.success(
          context,
          title: 'Successfully',
          body: "Quick Count - ${response['DocumentNumber']}.",
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
      // final bin = await dio
      //     .get("/BinLocations?\$filter=Warehouse eq '${warehouse.text}'");
      // if (bin.data["value"].length == 0) {
      //   final totalQtyWh = await dio.get(
      //       "/view.svc/ItemB1SLQuery?\$filter=ItemCode eq '${itemCode.text}' and WhsCode eq '${warehouse.text}'");
      //   if (totalQtyWh.statusCode == 200) {
      //     try {
      //       // Sum the OnHandQty values from the response
      //       inWhsQty.text = "0";
      //       dynamic totalQty = totalQtyWh.data["value"]
      //           .map<dynamic>((item) => item["OnHandQty"] as dynamic)
      //           .reduce((a, b) => a + b);

      //       // Update the inWhsQty TextEditingController with the total quantity
      //       inWhsQty.text = totalQty.toString();

      //       // Set the state to reflect the changes
      //       setState(() {
      //         print(totalQtyWh);
      //       });
      //     } catch (e) {
      //       print('Error occurred while processing the data: $e');
      //     }
      //   }
      // }
      final item = itemCode.text.trim();
      final whs = warehouse.text.trim();
      final bin = binId.text.trim();

      print("🧾 Item: $item");
      print("🏭 Warehouse: $whs");
      print("📦 BinID: $bin");

      try {
        if (item.isNotEmpty && whs.isNotEmpty && bin.isNotEmpty) {
          final url =
              "/view.svc/ItemB1SLQuery?\$filter=ItemCode eq '$item' and WhsCode eq '$whs' and BinID eq $bin";
          print("🌐 Request URL: $url");

          final response = await dio.get(url);

          final data = response.data["value"];
          if (data != null && data.isNotEmpty) {
            final onHandQty = data[0]["OnHandQty"] ?? 0;
            setState(() {
              inWhsQty.text = onHandQty.toString();
            });
          } else {
            setState(() {
              inWhsQty.text = "0";
            });
          }
        }

        print("📦 In-warehouse quantity: ${inWhsQty.text}");
      } catch (e, stack) {
        print("❌ Error during Dio request: $e");
        print("📜 Stack trace: $stack");
        setState(() {
          inWhsQty.text = "0";
        });
      }
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
  //     if (itemCode.text == '') return;

  //     //
  //     MaterialDialog.loading(context);
  //     final item = await _blocItem.find("('${itemCode.text}')");
  //     if (getDataFromDynamic(item['PurchaseItem']) == '' ||
  //         getDataFromDynamic(item['PurchaseItem']) == 'tNO') {
  //       throw Exception('${itemCode.text} is not purchase item.');
  //     }
  //     if (mounted) {
  //       MaterialDialog.close(context);
  //     }

  //     onSetItemTemp(item);
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
      quantity.text = '';
      MaterialDialog.loading(context);
      final barcodeRes = await dio.get(
          "/view.svc/WMS_ITEM_BARCODEB1SLQuery?\$filter=BarCode eq '${barCode.text}' ");
      if (barcodeRes.statusCode == 200) {
        if (barcodeRes.data["value"].length == 0) {
          if (barcodeRes.data["value"].length == 0) {
            MaterialDialog.close(
              context,
            );
            clear();
            MaterialDialog.success(context, title: 'Opps.', body: "No Item");
            return;
          }
        }
        if (barcodeRes.data["value"].length > 1) {
          for (var element in barcodeRes.data["value"]) {
            itemCodeFilter.add(element['ItemCode']);
          }
          goTo(
                  context,
                  ItemByCodePage(
                      type: ItemType.purchase,
                      itemCode: itemCodeFilter
                          .map((item) => "ItemCode eq '$item'")
                          .join(' or ')))
              .then((value) {
            if (value == null) return;
            if (mounted) {
              MaterialDialog.close(context);
            }
            uom.text =
                getDataFromDynamic(barcodeRes.data["value"]?[0]?["UomCode"]);
            uomAbEntry.text =
                getDataFromDynamic(barcodeRes.data["value"]?[0]?["UomEntry"]);
            onSetItemTemp(value);
          });
          return;
        }
        final item = await _blocItem
            .find("('${barcodeRes.data["value"]?[0]?["ItemCode"]}')");
        if (mounted) {
          MaterialDialog.close(context);
        }
        uom.text = getDataFromDynamic(barcodeRes.data["value"]?[0]?["UomCode"]);
        uomAbEntry.text =
            getDataFromDynamic(barcodeRes.data["value"]?[0]?["UomEntry"]);
        onSetItemTemp(item);
      }
    } catch (e) {
      if (mounted) {
        MaterialDialog.close(context);
        if (e is ServerFailure) {
          MaterialDialog.success(context, title: 'Failed', body: e.message);
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
              // Input(
              //   label: 'Warehouse',
              //   placeholder: 'Warehouse',
              //   controller: warehouse,
              //   readOnly: true,
              //   onPressed: onChangeWhs,
              // ),
              // Input(
              //   controller: ref,
              //   label: 'Ref.',
              //   placeholder: 'Referance',
              // ),
              // Input(
              //   controller: itemCode,
              //   onEditingComplete: onCompleteTextEditItem,
              //   label: 'Item.',
              //   placeholder: 'Item',
              //   onPressed: onSelectItem,
              // ),
              // Input(
              //   controller: uom,
              //   label: 'UoM.',
              //   placeholder: 'Unit Of Measurement',
              //   onPressed: onChangeUoM,
              // ),
              // Input(
              //   controller: binCode,
              //   label: 'Bin.',
              //   placeholder: 'Bin Location',
              //   onPressed: onChangeBin,
              // ),
              // Input(
              //   controller: inWhsQty,
              //   label: 'In Whs Qty.',
              //   placeholder: 'Total Qty',
              //   readOnly: true,
              // ),
              // Input(
              //   controller: quantity,
              //   label: 'Quantity.',
              //   placeholder: 'Quantity',
              //   keyboardType: TextInputType.numberWithOptions(decimal: true),
              //   onEditingComplete: onCompleteQuantiyInput,
              //   onPressed: isSerialOrBatch
              //       ? () {
              //           onNavigateSerialOrBatch(force: true);
              //         }
              //       : null,
              // ),
              // const SizedBox(height: 40),
              // ContentHeader(),
              // Column(
              //   children: items.asMap().entries.map((entry) {
              //     final index = entry.key;
              //     final item = entry.value;

              //     return GestureDetector(
              //       onTap: () =>
              //           onEdit(item, index), // Pass both item and index
              //       child: ItemRow(item: item),
              //     );
              //   }).toList(),
              // ),
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
              ),
              const SizedBox(height: 8),

              // ====== Bin Location ======

              // ====== Scan & Select Items ======
              Row(
                children: [
                  Expanded(
                    child: InputCol(
                      label: 'Item Code',
                      placeholder: 'Chose Item',
                      controller: itemCode,
                      readOnly: true,
                      onPressed: widget.isQuickCount ? onSelectItem : null,
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 30),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      onPressed: () {
                        // your action here
                      },
                      icon:
                          const Icon(Icons.document_scanner_outlined, size: 22),
                      color: Colors.black87,
                      tooltip: 'Scan items', // optional hover/long-press text
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),

              const SizedBox(height: 7),
              InputCol(
                label: 'Bin Location',
                placeholder: 'Chose Bin Location',
                controller: binCode,
                readOnly: true,
                onPressed: onChangeBin,
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
