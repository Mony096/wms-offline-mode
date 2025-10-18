import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_mobile/component/form/input_col.dart';
import 'package:wms_mobile/feature/batch/good_receip_batch_screen.dart';
import 'package:wms_mobile/feature/bin_location/presentation/cubit/bin_cubit.dart';
import 'package:wms_mobile/feature/inbound/good_receipt_po/presentation/duplicateItem_GPO_Screen.dart';
import 'package:wms_mobile/feature/item/presentation/cubit/items_barcode_offline_cubit.dart';
import 'package:wms_mobile/feature/item/presentation/cubit/items_offline_cubit.dart';
import 'package:wms_mobile/feature/item_by_code/presentation/screen/item_page.dart';
import 'package:wms_mobile/feature/serial/good_receip_serial_screen.dart';
import 'package:wms_mobile/feature/unit_of_measurement/presentation/cubit/uom_group_offline_cubit.dart';
import 'package:wms_mobile/feature/warehouse/presentation/screen/warehouse_page.dart';
import 'package:wms_mobile/utilies/dio_client.dart';
import '/feature/bin_location/domain/entity/bin_entity.dart';
import '/feature/bin_location/presentation/screen/bin_page.dart';
import '/feature/business_partner/presentation/screen/business_partner_page.dart';
import '/feature/inbound/good_receipt_po/presentation/cubit/purchase_good_receipt_cubit.dart';
import '/feature/inbound/purchase_order/presentation/cubit/purchase_order_cubit.dart';
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

class CreateGoodReceiptPOScreen extends StatefulWidget {
  const CreateGoodReceiptPOScreen(
      {super.key, this.po = null, this.quickReceipt});
  final dynamic quickReceipt;
  final dynamic po;

  @override
  State<CreateGoodReceiptPOScreen> createState() =>
      _CreateGoodReceiptPOScreenState();
}

class _CreateGoodReceiptPOScreenState extends State<CreateGoodReceiptPOScreen> {
  final cardCode = TextEditingController();
  final cardName = TextEditingController();
  final poText = TextEditingController();
  final uomText = TextEditingController();
  final quantity = TextEditingController();
  final totalQuantity = TextEditingController();

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
  final barCode = TextEditingController();
  List<dynamic> isBin = [{}];
  //
  final isBatch = TextEditingController();
  final isSerial = TextEditingController();

  late PurchaseGoodReceiptCubit _bloc;
  late ItemCubit _blocItem;
  late PurchaseOrderCubit _blocCubit;
  late BinCubit _blocBin;

  final DioClient dio = DioClient();

  int isEdit = -1;
  bool isSerialOrBatch = false;
  List<dynamic> items = [];
  bool loading = false;
  List<dynamic> itemCodeFilter = [];
  bool isReview = false;
  //scanner
  bool isClickScanItem = false;
  bool isClickScanBin = false;
  final FocusNode _itemCode = FocusNode();
  final FocusNode _quantity = FocusNode();
  final FocusNode _bin = FocusNode();
//scanner
  @override
  void initState() {
    init();
    _bloc = context.read<PurchaseGoodReceiptCubit>();
    _blocItem = context.read<ItemCubit>();
    _blocCubit = context.read<PurchaseOrderCubit>();
    _blocBin = context.read<BinCubit>();

    //
    // IscanDataPlugin.methodChannel.setMethodCallHandler((MethodCall call) async {
    //   if (call.method == "onScanResults") {
    //     if (loading) return;

    //     setState(() {
    //       if (call.arguments['data'] == "decode error") return;
    //       //
    //       barCode.text = call.arguments['data'];
    //       onCompleteTextEditItem();
    //     });
    //   }
    // });
    super.initState();
  }

  void init() async {
    try {
      // Retrieve warehouse information
      final whs = await LocalStorageManger.getString('warehouse');
      warehouse.text = whs;

      if (widget.po != null) {
        // Populate text fields with PO data
        poText.text = getDataFromDynamic(widget.po['DocNum']);
        cardCode.text = getDataFromDynamic(widget.po['CardCode']);
        cardName.text = getDataFromDynamic(widget.po['CardName']);

        // Show loading indicator
        if (mounted) MaterialDialog.loading(context);
        // final state = _blocBin.state;
        // // If state is not BinData, just return (no data yet)
        // if (state is! BinData) {
        //   debugPrint("BinCubit has no data yet.");
        //   return;
        // }
        // final bins = state.entities;
        // if (bins.where((b) => b.warehouse == warehouse.text).isEmpty) {
        //   isBin.clear();
        // }
        // Initialize the list of items
        List<Map<String, dynamic>> rawItems = [];
        final openLines = widget.po['DocumentLines']
            .where((line) => line['LineStatus'] == 'bost_Open')
            .toList();

        for (var element in openLines) {
          final itemResponse =
              await _blocItem.find("('${element['ItemCode']}')");

          rawItems.add({
            "ItemCode": element['ItemCode'],
            "ItemDescription":
                element['ItemName'] ?? element['ItemDescription'],
            "Quantity": "0",
            "TotalQuantity":
                getDataFromDynamic(element['RemainingOpenQuantity']),
            "WarehouseCode": warehouse.text,
            "UoMEntry": getDataFromDynamic(element['UoMEntry']),
            "UoMCode": element['UoMCode'],
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

        // Combine items with the same ItemCode and UoMCode
        items = combineItems(rawItems);

        // Close loading indicator
        if (mounted) MaterialDialog.close(context);

        // Update state with combined items
        if (mounted) {
          setState(() {
            items;
          });
        }
      }
    } catch (e) {
      // Handle errors
      if (mounted) {
        MaterialDialog.close(context);
        // Optionally show an error message
        // MaterialDialog.showError(context, 'An error occurred: $e');
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
          "Quantity": "0",
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

  void onSelectItem() async {
    setState(() {
      isEdit = -1;
    });
    if (widget.quickReceipt) {
      goTo(context, ItemPage(type: ItemType.purchase)).then((value) {
        if (value == null) return;
        // print(value["UoMGroupDefinitionCollection"]);
        onSetItemTemp(value);
      });
    }
    // else {
    //   // return;
    //   goTo(
    //           context,
    //           ItemByCodePage(
    //               type: ItemType.purchase,
    //               itemCode: itemCodeFilter
    //                   .map((item) => "ItemCode eq '$item'")
    //                   .join(' or ')))
    //       .then((value) {
    //     if (value == null) return;
    //     onSetItemTemp(value);
    //   });
    // }
  }

  void onChangeUoM() async {
    //  if (!widget.quickReceipt) return;
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

      if (quantity.text == '' || quantity.text == '0') {
        throw Exception('Quantity must be greater than zero.');
      }

      final item = {
        "ItemCode": itemCode.text,
        "ItemDescription": itemName.text,
        "Quantity": quantity.text,
        "WarehouseCode": warehouse.text,
        "UoMEntry": uomAbEntry.text,
        "UoMCode": uom.text,
        "UoMGroupDefinitionCollection":
            jsonDecode(uoMGroupDefinitionCollection.text) ?? [],
        "BaseUoM": baseUoM.text,
        "TotalQuantity": totalQuantity.text,
        "BinId": binId.text,
        "BinCode": binCode.text,
        "ManageSerialNumbers": isSerial.text,
        "ManageBatchNumbers": isBatch.text,
        "Serials":
            serialsInput.text == "" ? [] : jsonDecode(serialsInput.text) ?? [],
        "Batches":
            batchesInput.text == "" ? [] : jsonDecode(batchesInput.text) ?? [],
        "BarCode": barCode.text,
      };

      if (isEdit == -1) {
        // if (!force) {
        //   final exist = items.indexWhere((row) =>
        //       row['ItemCode'] == item['ItemCode'] &&
        //       row['UoMCode'] == item['UoMCode']);

        //   if (exist >= 0) {
        //     throw Exception('${item['ItemCode']} already exist.');
        //   }
        // }

        // throw Exception('${item['ItemCode']} already exist.');

        data.add(item);
      } else {
        data[isEdit] = item;
      }

      // print(item);

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

  void onEdit(dynamic item, int index) {
    // final index = items.indexWhere((e) => e['ItemCode'] == item['ItemCode']);
    print(item);

    if (index < 0) return;

    MaterialDialog.warning(
      context,
      title: 'Item (${item['ItemCode']})',
      confirmLabel: "Edit",
      cancelLabel: "Remove",
      onConfirm: () {
        print(item);
        itemCode.text = getDataFromDynamic(item['ItemCode']);
        itemName.text = getDataFromDynamic(item['ItemDescription']);
        quantity.text = getDataFromDynamic(item['Quantity']);
        uom.text = getDataFromDynamic(item['UoMCode']);
        uomAbEntry.text = getDataFromDynamic(item['UoMEntry']);
        binCode.text = getDataFromDynamic(item['BinCode']);
        binId.text = getDataFromDynamic(item['BinId']);
        baseUoM.text = getDataFromDynamic(item['BaseUoM']);
        uoMGroupDefinitionCollection.text = jsonEncode(
          item['UoMGroupDefinitionCollection'],
        );
        totalQuantity.text = getDataFromDynamic(item['TotalQuantity']);
        isSerial.text = getDataFromDynamic(item['ManageSerialNumbers']);
        isBatch.text = getDataFromDynamic(item['ManageBatchNumbers']);
        batchesInput.text = jsonEncode(item['Batches'] ?? []);
        serialsInput.text = jsonEncode(item['Serials'] ?? []);
        barCode.text = getDataFromDynamic(item['BarCode']);
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

  void onChangeCardCode() async {
    if (!widget.quickReceipt) return;
    goTo(context, BusinessPartnerPage(type: BusinessPartnerType.supplier))
        .then((value) {
      if (value == null) return;

      cardCode.text = getDataFromDynamic(value['CardCode']);
      cardName.text = getDataFromDynamic(value['CardName']);
    });
  }

  void onChangeBin() async {
    goTo(context, BinPage(warehouse: warehouse.text, itemCode: itemCode.text))
        .then((value) {
      if (value == null) return;

      binId.text = getDataFromDynamic((value as BinEntity).id);
      binCode.text = getDataFromDynamic(value.code);
    });
  }

  void onChangeWhs() async {
    goTo(context, WarehousePage()).then((value) {
      if (value == null) return;
      warehouse.text = getDataFromDynamic(value);
    });
  }

  void onPostToSAP() async {
    // print(items);
    // return;
    try {
      final filteredItems = items.where((item) {
        final qty = int.tryParse(item["Quantity"].toString()) ?? 0;
        return qty != 0;
      }).toList();

      // print(filteredItems);
      // return;
      Map<String, dynamic> data = {
        // "BPL_IDAssignedToInvoice": 1,
        "CardCode": cardCode.text,
        "CardName": cardName.text,
        "WarehouseCode": warehouse.text,
        "DocumentLines": filteredItems.asMap().entries.map((entry) {
          int parentIndex = entry.key;
          Map<String, dynamic> item = entry.value;
          List<dynamic> uomCollections =
              item["UoMGroupDefinitionCollection"] ?? [];

          final alternativeUoM = uomCollections.firstWhere(
            (row) => row['AlternateUoM'] == int.parse(item['UoMEntry']),
            orElse: () => null, // Provide a default value if not found
          );

          if (alternativeUoM == null) {
            throw Exception(
                "No matching UoM found for item ${item['ItemCode']}");
          }
          int baseType = -1;
          dynamic baseEntry = null;
          dynamic baseLine = null;
          if (widget.po != null) {
            final lines = (widget.po['DocumentLines'] ?? []) as List<dynamic>;
            final ele =
                lines.singleWhere((row) => row['ItemCode'] == item['ItemCode']);

            if (ele != null) {
              baseType = 22;
              baseEntry = ele['DocEntry'];
              baseLine = ele['LineNum'];
            }
          }
          dynamic qty = 0;
          if (item['Quantity'] is double) {
            qty = item['Quantity'].toString();
          } else {
            // Handle other types if necessary, e.g., if it's already a string
            qty = item['Quantity'];
          }
          List<dynamic> binAllocations = [
            {
              "Quantity": convertQuantityUoM(
                alternativeUoM['BaseQuantity'],
                alternativeUoM['AlternateQuantity'],
                double.tryParse(qty) ?? 0.00,
              ),
              "BinAbsEntry": item['BinId'],
              "BaseLineNumber": parentIndex,
              "AllowNegativeQuantity": "tNO",
              "SerialAndBatchNumbersBaseLine": -1
            }
          ];

          bool isBatch = item['ManageBatchNumbers'] == 'tYES';
          bool isSerial = item['ManageSerialNumbers'] == 'tYES';

          if (isBatch || isSerial) {
            binAllocations = [];

            List<dynamic> batchOrSerialLines =
                isSerial ? item['Serials'] ?? [] : item['Batches'] ?? [];

            int index = 0;
            for (var element in batchOrSerialLines) {
              binAllocations.add({
                "BinAbsEntry": item['BinId'],
                "AllowNegativeQuantity": "tNO",
                "BaseLineNumber": parentIndex,
                "SerialAndBatchNumbersBaseLine": index,
                "Quantity": convertQuantityUoM(
                    alternativeUoM['BaseQuantity'],
                    alternativeUoM['AlternateQuantity'],
                    double.tryParse(element['Quantity']) ?? 0.00),
              });

              index++;
            }
          }

          return {
            "ItemCode": item['ItemCode'],
            "ItemDescription": item['ItemDescription'],
            "UoMCode": item['UoMCode'],
            "UoMEntry": item['UoMEntry'],
            "Quantity": item['Quantity'],
            "WarehouseCode": warehouse.text,
            "BaseType": baseType,
            "BaseEntry": baseEntry,
            "BaseLine": baseLine,
            "SerialNumbers": item['Serials'] ?? [],
            "BatchNumbers": item['Batches'] ?? [],
            "DocumentLinesBinAllocations":
                isBin.length > 0 ? binAllocations : []
          };
        }).toList(),
      };

      if (widget.po != null) {
        data['DocumentReferences'] = [
          {
            "RefDocEntr": widget.po['DocEntry'],
            "RefDocNum": widget.po['DocNum'],
            "RefObjType": "rot_PurchaseOrder",
            "IssueDate": DateTime.now().toIso8601String(),
            "Remark": "WMS",
          }
        ];
      }
      MaterialDialog.loading(context);
      // setState(() {
      //   print(data);
      // });
      // return;
      final response = await _bloc.post(data);
      if (mounted) {
        if (widget.po != null) {
          _blocCubit.remove(widget.po['DocEntry']);
        }
        Navigator.of(context).pop();
        MaterialDialog.success(
          context,
          title: 'Successfully',
          body: widget.quickReceipt
              ? "Quick Receipt - ${response['DocNum']}."
              : "Good Receipt PO - ${response['DocNum']}.",
          onOk: () => Navigator.of(context)
              .pop(widget.po == null ? null : widget.po['DocEntry']),
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
    isEdit = -1;
  }

  void onSetItemTemp(dynamic value) async {
    try {
      if (value == null) return;
      // final state = _blocBin.state;
      // // If state is not BinData, just return (no data yet)
      // if (state is! BinData) {
      //   debugPrint("BinCubit has no data yet.");
      //   return;
      // }
      // final bins = state.entities;
      // if (bins.where((b) => b.warehouse == warehouse.text).isEmpty) {
      //   isBin.clear();
      // }
      isSerialOrBatch = false;
      MaterialDialog.loading(context);
      FocusScope.of(context).requestFocus(FocusNode());
      // final bin = await dio
      //     .get("/BinLocations?\$filter=Warehouse eq '${warehouse.text}'");
      // if (bin.data["value"].length == 0) {
      //   isBin.clear();
      // }
      itemCode.text = getDataFromDynamic(value['ItemCode']);
      itemName.text = getDataFromDynamic(value['ItemName']);
      // quantity.text = '0';
      uom.text = getDataFromDynamic(value['InventoryUOM'] ?? 'Manual');
      uomAbEntry.text = getDataFromDynamic(value['InventoryUoMEntry'] ?? '-1');
      baseUoM.text = jsonEncode(getDataFromDynamic(value['BaseUoM'] ?? '-1'));
      // log(value.toString());
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

  void onCompleteTextEditItem() async {
    try {
      if (barCode.text == '') return;
      if (widget.po != null) {
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

        // Find matching barcodes
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

        uom.text = getDataFromDynamic(first['UomCode']);
        uomAbEntry.text = getDataFromDynamic(first['UomEntry']);
        onSetItemTemp(itemMapped);
      }
    } catch (e) {
      if (mounted) {
        MaterialDialog.close(context);
        if (e is ServerFailure) {
          MaterialDialog.success(context, title: 'Failed', body: e.message);
        } else {
          MaterialDialog.success(context, title: 'Failed', body: e.toString());
        }
      }
    }
  }

  void onCompleteQuantiyInput() {
    FocusScope.of(context).requestFocus(FocusNode());
    onNavigateSerialOrBatch();
  }

  void onNavigateSerialOrBatch({bool force = false}) {
    if (isSerial.text == 'tYES') {
      final serialList = serialsInput.text == "" || serialsInput.text == "null"
          ? []
          : jsonDecode(serialsInput.text) as List<dynamic>;

      if (force == false && (quantity.text == serialList.length.toString())) {
        return;
      }
      print(serialList);
      goTo(
        context,
        GoodReceiptSerialScreen(
            itemCode: itemCode.text,
            quantity: quantity.text,
            serials: serialList,
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
            serials: batches,
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
        onCompleteTextEditItem();
        isClickScanItem = false;
      } else if (_bin.hasFocus) {
        // ✅ If secondary input is focused → clear it
        binCode.text = barcode;
        isClickScanBin = false;
      } else if (_quantity.hasFocus) {
        // ✅ If secondary input is focused → clear it
        quantity.clear();
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
          leading: IconButton(
            icon: Icon(Icons.arrow_back), // Back arrow icon
            onPressed: () {
              if (isReview && !widget.quickReceipt) {
                setState(() {
                  isReview = false;
                });
              } else {
                Navigator.pop(context); // Go back to previous screen
              }
            },
          ),
          backgroundColor: PRIMARY_COLOR,
          iconTheme: IconThemeData(color: Colors.white),
          title: widget.quickReceipt
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 65),
                    child: const Text(
                      'Create Quick Goods Receipt',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white),
                    ),
                  ),
                )
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 65),
                    child: const Text(
                      'Create Goods Receipt PO',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white),
                    ),
                  ),
                )),
      body: Padding(
          padding: const EdgeInsets.all(15),
          child: SingleChildScrollView(
            child: isReview
                ? Column(
                    children: [
                      SizedBox(
                        height: 5,
                      ),
                      ReviewHeader(hideOpenQty: widget.quickReceipt),
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
                        return ReviewRow(
                          item: item,
                          // Optional: pass index if you need inside ItemRow
                        );
                      }).toList(),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ====== Supplier Info Card ======
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(5),
                        child: Column(
                          children: [
                            Input(
                              label: 'Supplier Code',
                              placeholder: 'Supplier Code',
                              controller: cardCode,
                              readOnly: true,
                              onPressed:
                                  widget.quickReceipt ? onChangeCardCode : null,
                            ),
                            Input(
                              label: 'Supplier Name',
                              placeholder: 'Supplier Name',
                              controller: cardName,
                              readOnly: true,
                            ),
                            Divider(thickness: 1, color: Colors.grey.shade400),
                            if (widget.po != null)
                              Input(
                                label: 'PO #',
                                placeholder: 'PO DocNum',
                                controller: poText,
                                readOnly: true,
                              ),
                            Input(
                              label: 'Warehouse',
                              placeholder: 'Warehouse',
                              controller: warehouse,
                              readOnly: true,
                              onPressed: onChangeWhs,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),
                      Divider(thickness: 0.5, color: Colors.grey.shade300),
                      const SizedBox(height: 5),

                      // ====== Bin Location ======
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
                              Future.delayed(const Duration(milliseconds: 100),
                                  () {
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
                              onPressed:
                                  widget.quickReceipt ? onSelectItem : null,
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
                              Future.delayed(const Duration(milliseconds: 100),
                                  () {
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

                          // Container(
                          //   margin: EdgeInsets.only(top: 30),
                          //   decoration: BoxDecoration(
                          //     color: Colors.grey.shade100,
                          //     borderRadius: BorderRadius.circular(8),
                          //     border: Border.all(
                          //       color: isClickScan
                          //           ? Colors.green
                          //           : Colors
                          //               .transparent, // ✅ green border when active
                          //       width: 2,
                          //     ),
                          //   ),
                          //   child: IconButton(
                          //     onPressed: () {
                          //       setState(() {
                          //         isClickScan = true; // turn on scan mode
                          //         itemCode.clear();
                          //       });

                          //       // 2. Clear current focus before switching
                          //       FocusScope.of(context).unfocus();

                          //       // 3. Focus scanner input
                          //       Future.delayed(
                          //           const Duration(milliseconds: 100), () {
                          //         _requestFocus(_itemCode);
                          //       });
                          //     },
                          //     icon: const Icon(Icons.document_scanner_outlined,
                          //         size: 22),
                          //     color: Colors.black87,
                          //     tooltip:
                          //         'Scan items', // optional hover/long-press text
                          //   ),
                          // ),
                          const SizedBox(width: 12),
                        ],
                      ),

                      const SizedBox(height: 7),

                      // ====== Input Qty & UoM ======
                      Row(
                        children: [
                          Expanded(
                            child: InputCol(
                              label: 'Input Qty',
                              placeholder: 'Quantity',
                              controller: quantity,
                              focusNode: _quantity,
                              onFieldSubmitted: (value) {
                                _handleScanSubmitted(value, _quantity);
                              },
                              readOnly:
                                  isSerialOrBatch ? true : false, // simpler
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              onTap: () {
                                isClickScanItem = false; // turn on scan mode
                                isClickScanBin = false; // turn on scan mode
                                if (isSerialOrBatch) {
                                  onNavigateSerialOrBatch(force: true);
                                }
                              },
                              // ? () {
                              //     onNavigateSerialOrBatch(force: true);
                              //   }
                              // : null,
                              onEditingComplete: onCompleteQuantiyInput,
                              onPressed: isSerialOrBatch
                                  ? () {
                                      onNavigateSerialOrBatch(force: true);
                                    }
                                  : null, // remove if icon not needed
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InputCol(
                              label: 'Input UoM',
                              placeholder: 'UoM',
                              controller: uom,
                              readOnly: true,
                              onPressed: onChangeUoM,
                            ),
                          ),
                        ],
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
                          border: Border.all(
                              color: Colors.grey.shade300, width: 0.5),
                        ),
                        child: Column(
                          children: [
                            ContentHeader(hideOpenQty: widget.quickReceipt),
                            items.isEmpty
                                ? Container(
                                    padding: EdgeInsets.all(20),
                                    child: Text(
                                      "No Item available",
                                      style: TextStyle(
                                          fontSize: 15, color: Colors.grey),
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
                                    po: widget.po,
                                    hideOpenQty: widget.quickReceipt
                                    // Optional: pass index if you need inside ItemRow
                                    ),
                              );
                            }).toList(),
                          ],
                        ),
                      )
                    ],
                  ),
          )),
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
                  'Post ',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            isReview || widget.quickReceipt
                ? Container()
                : const SizedBox(width: 12),
            isReview || widget.quickReceipt
                ? Container()
                : Expanded(
                    child: Button(
                      onPressed: () {
                        setState(() {
                          isReview = !isReview;
                        });
                      },
                      bgColor: Colors.green.shade700,
                      child: Text(
                        "Review",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
            const SizedBox(width: 12),
            Expanded(
              child: Button(
                variant: ButtonVariant.outline,
                onPressed: () {
                  // if (items.length > 0) {
                  //   MaterialDialog.warning(
                  //     context,
                  //     title: 'Warning',
                  //     body:
                  //         'Are you sure leave? once you pressed ok the data will be ereas.',
                  //     confirmLabel: 'Ok',
                  //     cancelLabel: 'Cancel',
                  //     onConfirm: () {
                  //       Navigator.of(context).pop();
                  //     },
                  //     onCancel: () {},
                  //   );
                  // } else {
                  //   Navigator.of(context).pop();
                  // }
                  setState(() {
                    isReview = false;
                  });
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
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'Item No',
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w600,
                fontSize: 12,
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
                fontSize: 12,
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
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          !hideOpenQty
              ? Expanded(
                  flex: 1,
                  child: Text(
                    'Op/Qty',
                    style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : SizedBox(),
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
                  getDataFromDynamic(item['Quantity']),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              !hideOpenQty
                  ? Expanded(
                      flex: 1,
                      child: Text(
                        ((double.tryParse(item['TotalQuantity'].toString()) ??
                                    0) -
                                (double.tryParse(item['Quantity'].toString()) ??
                                    0))
                            .toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13),
                      ),
                    )
                  : SizedBox(),
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

class ReviewHeader extends StatelessWidget {
  const ReviewHeader({super.key, this.hideOpenQty = false});
  final bool hideOpenQty;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PRIMARY_COLOR, // Navy header
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      child: Row(
        children: const [
          Expanded(
            flex: 3,
            child: Text(
              'Item Code',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Description',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class ReviewRow extends StatelessWidget {
  const ReviewRow({
    super.key,
    required this.item,
  });

  final Map<String, dynamic> item;

  String getDataFromDynamic(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 245, 246, 247),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 0.8),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 First row: ItemCode + Description
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                getDataFromDynamic(item['ItemCode']),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              Flexible(
                child: Text(
                  getDataFromDynamic(item['ItemDescription']),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 🔹 Second row: Qty | Qty Receive | UoM | Open Qty
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Expanded(
                child: Text(
                  "Qty",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  "Qty Receive",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  "UoM",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  "Open Qty",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // 🔹 Third row: values
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  getDataFromDynamic(item['TotalQuantity']),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                child: Text(
                  getDataFromDynamic(item['Quantity']),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                child: Text(
                  getDataFromDynamic(item['UoMCode']),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                child: Text(
                  ((double.tryParse(item['TotalQuantity'].toString()) ?? 0) -
                          (double.tryParse(item['Quantity'].toString()) ?? 0))
                      .toString(),
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
