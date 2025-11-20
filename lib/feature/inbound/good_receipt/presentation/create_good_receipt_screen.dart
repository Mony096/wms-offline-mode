import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:wms_mobile/component/form/input_col.dart';
import 'package:wms_mobile/feature/bin_location/presentation/cubit/bin_cubit.dart';
import 'package:wms_mobile/feature/bin_location/presentation/cubit/bin_offline_cubit.dart';
import 'package:wms_mobile/feature/good_receipt_type/domain/entity/grt_entity.dart';
import 'package:wms_mobile/feature/good_receipt_type/presentation/screen/grt_page.dart';
import 'package:wms_mobile/feature/inbound/good_receipt/presentation/cubit/good_receipt_failed_offline_cubit.dart';
import 'package:wms_mobile/feature/inbound/good_receipt/presentation/cubit/goods_receipt_offline_cubit.dart';
import 'package:wms_mobile/feature/item/presentation/cubit/items_barcode_offline_cubit.dart';
import 'package:wms_mobile/feature/item/presentation/cubit/items_offline_cubit.dart';
import 'package:wms_mobile/feature/item_by_code/presentation/screen/item_page.dart';
import 'package:wms_mobile/feature/unit_of_measurement/presentation/cubit/uom_group_offline_cubit.dart';
import 'package:wms_mobile/feature/warehouse/presentation/screen/warehouse_page.dart';
import 'package:wms_mobile/utilies/dio_client.dart';
import '/feature/inbound/return_receipt_request/presentation/return_receipt_request_page.dart';
import '/feature/batch/good_receip_batch_screen.dart';
import '/feature/serial/good_receip_serial_screen.dart';
import '/feature/bin_location/domain/entity/bin_entity.dart';
import '/feature/bin_location/presentation/screen/bin_page.dart';
import '/feature/business_partner/presentation/screen/business_partner_page.dart';
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
import 'cubit/good_receipt_cubit.dart';

class CreateGoodReceiptScreen extends StatefulWidget {
  const CreateGoodReceiptScreen({
    super.key,
    this.isEdit,
    this.isEditFaild,
  });
  final dynamic isEdit;
  final dynamic isEditFaild;
  @override
  State<CreateGoodReceiptScreen> createState() =>
      _CreateGoodReceiptScreenState();
}

class _CreateGoodReceiptScreenState extends State<CreateGoodReceiptScreen> {
  final cardCode = TextEditingController();
  final cardName = TextEditingController();
  final poText = TextEditingController();
  final uomText = TextEditingController();
  final quantity = TextEditingController();
  final warehouse = TextEditingController();
  final uom = TextEditingController();
  final uomAbEntry = TextEditingController();
  final itemCode = TextEditingController();
  final itemName = TextEditingController();
  final baseUoM = TextEditingController();
  final uoMGroupDefinitionCollection = TextEditingController();
  final binId = TextEditingController();
  final binCode = TextEditingController();
  final grType = TextEditingController();
  final grTypeName = TextEditingController();

  final serialsInput = TextEditingController();
  final batchesInput = TextEditingController();
  final docEntry = TextEditingController();
  final refLineNo = TextEditingController();

  //
  final isBatch = TextEditingController();
  final isSerial = TextEditingController();
  final saveId = TextEditingController();
  List<dynamic> isBin = [{}];
  int isEdit = -1;
  bool isSerialOrBatch = false;
  List<dynamic> items = [];
  bool loading = false;
  final barCode = TextEditingController();
  final DioClient dio = DioClient();
  List<dynamic> itemCodeFilter = [];
  bool isClickScanItem = false;
  bool isClickScanBin = false;
  final FocusNode _itemCode = FocusNode();
  final FocusNode _quantity = FocusNode();
  final FocusNode _bin = FocusNode();
  @override
  void initState() {
    super.initState();

    init();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      fromEdit();
    });
    //
  }

  void fromEdit() async {
    try {
      if (widget.isEdit == null) return;
      print(widget.isEdit);
      // ✅ Populate text fields safely
      grType.text = getDataFromDynamic(widget.isEdit['U_lk_grtype']);
      warehouse.text = getDataFromDynamic(widget.isEdit['U_lk_whsdesc']);
      saveId.text = getDataFromDynamic(widget.isEdit['SaveId']);
      if (mounted) MaterialDialog.loading(context);

      final barcodeList = context.read<ItemBarcodeOfflineCubit>().state;

      final List<Map<String, dynamic>> rawItems = [];
      final List<dynamic> lines =
          (widget.isEdit['DocumentLines'] as List?) ?? [];

      for (var element in lines) {
        final itemList = context.read<ItemOfflineCubit>().state;
        final binList = context.read<BinOfflineCubit>().state;

        final itemCode = getDataFromDynamic(element["ItemCode"]);
        final uomEntry =
            int.tryParse(getDataFromDynamic(element["UoMEntry"]).toString()) ??
                0;

        // ✅ Find matching barcode record
        final matchedBarcode = barcodeList.firstWhere(
          (b) => b['ItemCode'] == itemCode && b['UoMEntry'] == uomEntry,
          orElse: () => {},
        );

        final matchedItem = itemList.firstWhere(
            (e) => e['ItemCode'] == element['ItemCode'],
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
        final binID = element["DocumentLinesBinAllocations"].length > 0
            ? element["DocumentLinesBinAllocations"][0]["BinAbsEntry"]
            : -1;
        final binCodeFind = binList.firstWhere(
          (u) => u['AbsEntry'] == int.tryParse(getDataFromDynamic(binID)),
          orElse: () => {},
        );

        rawItems.add({
          "ItemCode": element['ItemCode'],
          "ItemDescription": element['ItemName'] ?? element['ItemDescription'],
          "Quantity": element['Quantity'],
          "WarehouseCode": warehouse.text,
          "UoMEntry": getDataFromDynamic(element['UoMEntry']),
          "UoMCode": element['UoMCode'],
          "UoMGroupDefinitionCollection":
              itemMapped['UoMGroupDefinitionCollection'],
          "BaseUoM": itemMapped['BaseUoM'],
          "BinId": binId.text,
          "BinCode": binCodeFind["BinCode"],
          "BaseLine": element['BaseLine'],
          "ManageSerialNumbers": itemMapped["ManageSerialNumbers"],
          "ManageBatchNumbers": itemMapped["ManageBatchNumbers"],
          "Serials": element["SerialNumbers"] ?? [],
          "Batches": element["BatchNumbers"] ?? [],
          if (matchedBarcode.isNotEmpty) "BarCode": matchedBarcode['BarCode'],
        });

        itemCodeFilter.add(element['ItemCode']);
      }
      // ✅ Update items
      items = rawItems;

      // Debug
      // debugPrint("✅ Processed ${items.length} item(s)");
      // debugPrint("🧾 rawItems: $items");

      // ✅ Close loading indicator
      if (mounted) MaterialDialog.close(context);

      // ✅ Refresh UI
      if (mounted) setState(() {});
    } catch (e, stackTrace) {
      if (mounted) MaterialDialog.close(context);
      debugPrint("❌ fromFailed error: $e\n$stackTrace");
    }
  }

  void init() async {
    final whs = await LocalStorageManger.getString('warehouse');
    warehouse.text = whs;
  }

  void onSelectItem() async {
    setState(() {
      isEdit = -1;
    });
    goTo(context, ItemPage(type: ItemType.inventory)).then((value) {
      if (value == null) return;

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

      // if (binId.text == '') {
      //   throw Exception('Bin Location is missing.');
      // }

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
        "BaseEntry": docEntry.text,
        "BaseLine": refLineNo.text,
        "UoMGroupDefinitionCollection":
            jsonDecode(uoMGroupDefinitionCollection.text) ?? [],
        "BaseUoM": baseUoM.text,
        "BinId": binId.text,
        "BinCode": binCode.text,
        "ManageSerialNumbers": isSerial.text,
        "ManageBatchNumbers": isBatch.text,
        "Serials":
            serialsInput.text == "" ? [] : jsonDecode(serialsInput.text) ?? [],
        "Batches":
            batchesInput.text == "" ? [] : jsonDecode(batchesInput.text) ?? [],
      };
      batchesInput.clear();
      serialsInput.clear();
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
    final index = items.indexWhere((e) => e['ItemCode'] == item['ItemCode']);

    if (index < 0) return;

    MaterialDialog.warning(
      context,
      title: 'Item (${item['ItemCode']})',
      confirmLabel: "Edit",
      cancelLabel: "Remove",
      onConfirm: () {
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

  void onChangeGrt() async {
    goTo(context, GrtPage()).then((value) {
      if (value == null) return;

      grType.text = getDataFromDynamic(value["Code"]);
      grTypeName.text = getDataFromDynamic(value["Name"]);
    });
  }

  void onChangeWhs() async {
    goTo(context, WarehousePage()).then((value) {
      if (value == null) return;
      warehouse.text = getDataFromDynamic(value);
    });
  }

  void onPostToSAP() async {
    if (items.isEmpty) {
      MaterialDialog.warning(context,
          title: 'Error', body: "Opps, Items is required");
      return;
    }
    try {
      var uuid = Uuid();
      Map<String, dynamic> data = {
        // "BPL_IDAssignedToInvoice": 1,
        // "CardCode": cardCode.text,
        // "CardName": cardName.text,
        "SaveId": widget.isEdit != null && widget.isEditFaild == true
            ? saveId.text
            : widget.isEdit != null
                ? saveId.text
                : uuid.v4(),
        "U_lk_grtype": grType.text,
        "U_lk_whsdesc": warehouse.text,
        "DocumentLines": items.asMap().entries.map((entry) {
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

          List<dynamic> binAllocations = [
            {
              "Quantity": convertQuantityUoM(
                alternativeUoM['BaseQuantity'],
                alternativeUoM['AlternateQuantity'],
                double.tryParse(item['Quantity']) ?? 0.00,
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
                isSerial ? item['Serials'] : item['Batches'];
            int index = 0;
            for (var element in batchOrSerialLines) {
              setState(() {
                print(element);
              });
              binAllocations.add({
                "BinAbsEntry": item['BinId'],
                "AllowNegativeQuantity": "tNO",
                "BaseLineNumber": parentIndex,
                "SerialAndBatchNumbersBaseLine": index,
                "Quantity": convertQuantityUoM(
                    alternativeUoM['BaseQuantity'],
                    alternativeUoM['AlternateQuantity'],
                    double.tryParse(element["Quantity"]) ?? 0.00),
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
            // "BaseType": 234000031,
            // "BaseEntry": item['BaseEntry'],
            // "BaseLine": item['BaseLine'],
            "UseBaseUnits": "tNO",
            "SerialNumbers": item['Serials'] ?? [],
            "BatchNumbers": item['Batches'] ?? [],
            "DocumentLinesBinAllocations": item['BinId'] != "" ? binAllocations : []
          };
        }).toList(),
      };
      MaterialDialog.loading(context);
      if (widget.isEdit != null && widget.isEditFaild == true) {
        context
            .read<GoodReceiptFailedOfflineCubit>()
            .removeByFailId(saveId.text);
        context.read<GoodsReceiptOfflineCubit>().addData(data);
      } else if (widget.isEdit != null) {
        context
            .read<GoodsReceiptOfflineCubit>()
            .updateBySaveId(saveId.text, data);
      } else {
        context.read<GoodsReceiptOfflineCubit>().addData(data);
      }
      if (mounted) {
        Navigator.of(context).pop();
        MaterialDialog.success(
          context,
          title: 'Successfully',
          body: widget.isEdit != null && widget.isEditFaild == true
              ? "Edited Faild Goods Receipt"
              : widget.isEdit != null
                  ? "Edited Goods Receipt"
                  : "Saved Goods Receipt",
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
  }

  void onSetItemTemp(dynamic value) async {
    try {
      if (value == null) return;
      setState(() {
        isSerialOrBatch = false;
      });
      MaterialDialog.loading(context);
      FocusScope.of(context).requestFocus(FocusNode());
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

  // void onNavigateToReturnReceiptRequest() async {
  //   goTo(
  //       context,
  //       ReturnReceiptRequestPage(
  //         type: BusinessPartnerType.customer,
  //       )).then((value) async {
  //     if (value == null) return;

  //     cardCode.text = getDataFromDynamic(value['CardCode']);
  //     cardName.text = getDataFromDynamic(value['CardName']);
  //     poText.text = getDataFromDynamic(value['DocNum']);

  //     if (mounted) MaterialDialog.loading(context);

  //     items = [];
  //     for (var element in value['DocumentLines']) {
  //       final itemResponse = await _blocItem.find("('${element['ItemCode']}')");

  //       items.add({
  //         "DocEntry": element['DocEntry'],
  //         "BaseEntry": element['DocEntry'],
  //         "BaseLine": element['LineNum'],
  //         "ItemCode": element['ItemCode'],
  //         "ItemDescription": element['ItemName'] ?? element['ItemDescription'],
  //         "Quantity": getDataFromDynamic(element['RemainingOpenQuantity']),
  //         "WarehouseCode": warehouse.text,
  //         "UoMEntry": getDataFromDynamic(element['UoMEntry']),
  //         "UoMCode": element['UoMCode'],
  //         "UoMGroupDefinitionCollection":
  //             itemResponse['UoMGroupDefinitionCollection'],
  //         "BaseUoM": itemResponse['BaseUoM'],
  //         "BinId": binId.text,
  //       });
  //     }

  //     if (mounted) MaterialDialog.close(context);

  //     setState(() {
  //       items;
  //     });
  //   });
  // }

  void onCompleteTextEditItem() async {
    try {
      if (barCode.text == '') return;

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
        MaterialDialog.warning(context, title: 'Oops.', body: "Item not found");
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
        "UoMGroupDefinitionCollection": uomGroup['UoMGroupDefinitionCollection']
      };

      uom.text = getDataFromDynamic(first['UomCode']);
      uomAbEntry.text = getDataFromDynamic(first['UomEntry']);
      onSetItemTemp(itemMapped);
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
        title: Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 65),
            child: const Text(
              'Create Goods Receipt',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white),
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
                      label: 'Goods Receipt Type',
                      placeholder: 'Type',
                      controller: grTypeName,
                      readOnly: true,
                      onPressed: onChangeGrt,
                    ),
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
                      readOnly: isSerialOrBatch ? true : false, // simpler
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onTap: isSerialOrBatch
                          ? () {
                              onNavigateSerialOrBatch(force: true);
                            }
                          : null,
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
        height: 70,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Button(
                variant: ButtonVariant.primary,
                disabled: isEdit != -1,
                onPressed: onPostToSAP,
                child: Text(
                  'Save',
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
                  getDataFromDynamic(item['Quantity']),
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
