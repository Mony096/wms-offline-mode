import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:wms_mobile/component/form/input_col.dart';
import 'package:wms_mobile/feature/bin_location/presentation/cubit/bin_cubit.dart';
import 'package:wms_mobile/feature/bin_location/presentation/cubit/bin_offline_cubit.dart';
import 'package:wms_mobile/feature/inbound/good_receipt_po/presentation/duplicateItem_GPO_Screen.dart';
import 'package:wms_mobile/feature/item/presentation/cubit/items_barcode_offline_cubit.dart';
import 'package:wms_mobile/feature/item/presentation/cubit/items_offline_cubit.dart';
import 'package:wms_mobile/feature/item_by_code/presentation/screen/item_page.dart';
import 'package:wms_mobile/feature/outbounce/delivery/presentation/cubit/delivery_cubit.dart';
import 'package:wms_mobile/feature/outbounce/delivery/presentation/cubit/delivery_failed_offline_cubit.dart';
import 'package:wms_mobile/feature/outbounce/delivery/presentation/cubit/delivery_offline_cubit.dart';
import 'package:wms_mobile/feature/outbounce/delivery/presentation/duplicateItem_DLR_Screen.dart';
import 'package:wms_mobile/feature/outbounce/sale_order/presentation/cubit/sale_order_offline_cubit.dart';
import 'package:wms_mobile/feature/outbounce/sale_order/presentation/sale_order_page.dart';
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

class CreateDeliveryScreen extends StatefulWidget {
  const CreateDeliveryScreen({
    super.key,
    this.isEdit,
    this.isEditFaild,
  });
  final dynamic isEdit;
  final dynamic isEditFaild;
  @override
  State<CreateDeliveryScreen> createState() => _CreateDeliveryScreenState();
}

class _CreateDeliveryScreenState extends State<CreateDeliveryScreen> {
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
  final serialsInput = TextEditingController();
  final batchesInput = TextEditingController();
  final docEntry = TextEditingController();
  final refLineNo = TextEditingController();
  final totalQty = TextEditingController();
  final saveId = TextEditingController();

  List<dynamic> isBin = [{}];
  //
  final isBatch = TextEditingController();
  final isSerial = TextEditingController();
  final DioClient dio = DioClient();
  List<dynamic> itemCodeFilter = [];
  final barCode = TextEditingController();
  final originalQty = TextEditingController();

  int isEdit = -1;
  bool isSerialOrBatch = false;
  List<dynamic> items = [];
  List<dynamic> baseEntry = [];
  bool loading = false;
  bool isReview = false;
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
  }

  void fromEdit() async {
    try {
      if (widget.isEdit == null) return;
      print(widget.isEdit);
      // ✅ Populate text fields safely
      poText.text = getDataFromDynamic(widget.isEdit['DocumentLines'].length > 0
          ? widget.isEdit['DocumentLines'][0]["BaseEntry"]
          : null);

      cardCode.text = getDataFromDynamic(widget.isEdit['CardCode']);
      cardName.text = getDataFromDynamic(widget.isEdit['CardName']);
      warehouse.text = getDataFromDynamic(widget.isEdit['WarehouseCode']);
      saveId.text = getDataFromDynamic(widget.isEdit['SaveId']);
      if (mounted) MaterialDialog.loading(context);

      final barcodeList = context.read<ItemBarcodeOfflineCubit>().state;
      final saleOrder = context.read<SaleOrderOfflineCubit>().state;

      final List<Map<String, dynamic>> rawItems = [];
      final List<dynamic> lines =
          (widget.isEdit['DocumentLines'] as List?) ?? [];

      final refDocEntry =
          getDataFromDynamic(widget.isEdit["DocumentLines"]?[0]?["BaseEntry"]);
      docEntry.text = refDocEntry;
      final matchedSaleOrde = saleOrder.firstWhere(
        (rcr) => rcr['DocEntry'].toString() == refDocEntry,
        orElse: () => {},
      );
      if (matchedSaleOrde.isEmpty) {
        if (mounted) MaterialDialog.close(context);

        MaterialDialog.warning(
          context,
          title: 'Error',
          body: "Sale order Not Found!",
        );
        return;
      }
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

        final matchedPOLine = (matchedSaleOrde.isNotEmpty &&
                matchedSaleOrde["DocumentLines"] != null)
            ? (matchedSaleOrde["DocumentLines"] as List).firstWhere(
                (b) => b['ItemCode'] == itemCode && b['UoMEntry'] == uomEntry,
                orElse: () => {},
              )
            : {};

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
          // "TotalQuantity": matchedPOLine["Quantity"],
          "TotalQuantity": widget.isEditFaild == true
              ? double.tryParse(
                  matchedPOLine["RemainingOpenQuantity"].toString())
              : (double.tryParse(
                          matchedPOLine["RemainingOpenQuantity"].toString()) ??
                      0.0) +
                  (double.tryParse(element["Quantity"].toString()) ?? 0.0),
          "WarehouseCode": warehouse.text,
          "UoMEntry": getDataFromDynamic(element['UoMEntry']),
          "UoMCode": element['UoMCode'],
          "UoMGroupDefinitionCollection":
              itemMapped['UoMGroupDefinitionCollection'],
          "BaseUoM": itemMapped['BaseUoM'],
          "BinId": binID,
          "DocEntry": refDocEntry,
          "BinCode": binCodeFind["BinCode"],
          "BaseLine": element['BaseLine'],
          "ManageSerialNumbers": itemMapped["ManageSerialNumbers"],
          "ManageBatchNumbers": itemMapped["ManageBatchNumbers"],
          "Serials": element["SerialNumbers"] ?? [],
          "Batches": element["BatchNumbers"] ?? [],
          if (matchedBarcode.isNotEmpty) "BarCode": matchedBarcode['BarCode'],
          "OriginalQty": element['Quantity'],
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
    // if (cardCode.text == "") return;
    // setState(() {
    //   isEdit = -1;
    // });
    // goTo(
    //         context,
    //         ItemByCodePage(
    //             type: ItemType.sale,
    //             itemCode: itemCodeFilter
    //                 .map((item) => "ItemCode eq '$item'")
    //                 .join(' or ')))
    //     .then((value) {
    //   if (value == null) return;

    //   onSetItemTemp(value);
    // });
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

      if (quantity.text == '' || quantity.text == '0') {
        throw Exception('Quantity must be greater than zero.');
      }

      final item = {
        "ItemCode": itemCode.text,
        "ItemDescription": itemName.text,
        "Quantity": quantity.text,
        "WarehouseCode": warehouse.text,
        "UoMEntry": uomAbEntry.text,
        "DocEntry": docEntry.text,
        "UoMCode": uom.text,
        "UoMGroupDefinitionCollection":
            jsonDecode(uoMGroupDefinitionCollection.text) ?? [],
        "BaseUoM": baseUoM.text,
        "TotalQuantity": totalQty.text,
        "BinId": binId.text,
        "BinCode": binCode.text,
        "ManageSerialNumbers": isSerial.text,
        "ManageBatchNumbers": isBatch.text,
        "BaseLine": refLineNo.text,
        "Serials":
            serialsInput.text == "" ? [] : jsonDecode(serialsInput.text) ?? [],
        "Batches":
            batchesInput.text == "" ? [] : jsonDecode(batchesInput.text) ?? [],
        "BarCode": barCode.text,
        "OriginalQty": originalQty.text
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

  void onEdit(dynamic item, index) {
    // final index = items.indexWhere((e) => e['ItemCode'] == item['ItemCode']);

    if (index < 0) return;
    print(item);
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
        totalQty.text = getDataFromDynamic(item['TotalQuantity']);
        uoMGroupDefinitionCollection.text = jsonEncode(
          item['UoMGroupDefinitionCollection'],
        );
        isSerial.text = getDataFromDynamic(item['ManageSerialNumbers']);
        isBatch.text = getDataFromDynamic(item['ManageBatchNumbers']);
        batchesInput.text = jsonEncode(item['Batches'] ?? []);
        serialsInput.text = jsonEncode(item['Serials'] ?? []);
        barCode.text = getDataFromDynamic(item['BarCode']);
        originalQty.text = getDataFromDynamic(item['OriginalQty']);
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
    if (itemCode.text.isEmpty) {
      MaterialDialog.warning(context,
          title: 'Warning',
          body: "Pleases chose item before select bin location");
      return;
    }
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
    if (items.isEmpty) {
      MaterialDialog.warning(context,
          title: 'Error', body: "Opps, Items is required");
      return;
    }
    try {
      // print(items);
      // return;
      var uuid = Uuid();
      MaterialDialog.loading(context);
      if (poText.text == '') {
        throw Exception(
            "You can only perform action with Return Receipt Request Document.");
      }
      final filteredItems = items.where((item) {
        final qty = int.tryParse(item["Quantity"].toString()) ?? 0;
        return qty != 0;
      }).toList();
      Map<String, dynamic> data = {
        "SaveId": widget.isEdit != null && widget.isEditFaild == true
            ? saveId.text
            : widget.isEdit != null
                ? saveId.text
                : uuid.v4(),
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
            "OriginalQty": item["OriginalQty"],
            "WarehouseCode": warehouse.text,
            "BaseType": 17, // sale order object
            "BaseEntry": item['DocEntry'],
            "BaseLine": item['BaseLine'],
            "SerialNumbers": item['Serials'] ?? [],
            "BatchNumbers": item['Batches'] ?? [],
            "DocumentLinesBinAllocations":
                item['BinId'] != "" ? binAllocations : []
          };
        }).toList(),
      };
      // print(data);
      // return;
      if (widget.isEdit != null && widget.isEditFaild == true) {
        context.read<DeliveryFailedOfflineCubit>().removeByFailId(saveId.text);
        context.read<DeliveryOfflineCubit>().addData(data);
        final refDocEntry =
            int.tryParse((data["DocumentLines"]?[0]?["BaseEntry"]).toString());
        for (var element in data["DocumentLines"].toList()) {
          context.read<SaleOrderOfflineCubit>().decreaseQuantityByLine(
              docEntry: refDocEntry ?? -1,
              lineId: int.tryParse(element["BaseLine"].toString()) ?? -1,
              quantity: double.tryParse(element["Quantity"].toString()) ?? 0.0,
              context: context);
        }
      } else if (widget.isEdit != null) {
        context.read<DeliveryOfflineCubit>().updateBySaveId(saveId.text, data);
        final refDocEntry =
            int.tryParse((data["DocumentLines"]?[0]?["BaseEntry"]).toString());
        for (var element in data["DocumentLines"].toList()) {
          final updateQty =
              (double.tryParse(element["Quantity"].toString()) ?? 0.0) -
                  (double.tryParse(element["OriginalQty"].toString()) ?? 0.0);
          context.read<SaleOrderOfflineCubit>().decreaseQuantityByLine(
              docEntry: refDocEntry,
              lineId: int.tryParse(element["BaseLine"].toString()) ?? -1,
              quantity: updateQty,
              context: context);
        }
      } else {
        context.read<DeliveryOfflineCubit>().addData(data);
        for (var element in data["DocumentLines"].toList()) {
          context.read<SaleOrderOfflineCubit>().decreaseQuantityByLine(
              docEntry: int.tryParse(docEntry.text.toString()) ?? -1,
              lineId: int.tryParse(element["BaseLine"].toString()) ?? -1,
              quantity: double.tryParse(element["Quantity"].toString()) ?? 0.0,
              context: context);
        }
      }
      if (mounted) {
        Navigator.of(context).pop();
        MaterialDialog.success(
          context,
          title: 'Successfully',
          body: widget.isEdit != null && widget.isEditFaild == true
              ? "Edited Faild Delivery"
              : widget.isEdit != null
                  ? "Edited Delivery"
                  : "Saved Delivery",
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
    refLineNo.text = '';
    isEdit = -1;
  }

  void onSetItemTemp(dynamic value) async {
    try {
      if (value == null) return;
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
      // uom.text = getDataFromDynamic(value['InventoryUOM'] ?? 'Manual');
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
            isEdit: isEdit,
            itemName: itemName.text,
            warehouse: warehouse.text,
            listAllSerial: true,
            binCode: binCode.text),
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
            isEdit: isEdit,
            listAllBatch: true,
            itemName: itemName.text,
            warehouse: warehouse.text,
            binCode: binCode.text),
      ).then((value) {
        if (value == null) return;
        quantity.text = value['quantity'] ?? "0";
        batchesInput.text = jsonEncode(value['items']);
      });
    }
  }

  void onNavigateToSO() async {
    goTo(context, SaleOrderPage()).then((value) async {
      if (value == null) return;

      cardCode.text = getDataFromDynamic(value['CardCode']);
      cardName.text = getDataFromDynamic(value['CardName']);
      poText.text = getDataFromDynamic(value['DocNum']);

      if (mounted) MaterialDialog.loading(context);

      List<Map<String, dynamic>> rawItems = [];
      final openLines = value['DocumentLines']
          .where((line) =>
              line['LineStatus'] == 'bost_Open' &&
              (double.tryParse(line['RemainingOpenQuantity'].toString()) ??
                      0.0) >
                  0.0)
          .toList();
      for (var element in openLines) {
        final itemResponse =
            findFullItemInformation(context, element['ItemCode']);
        if (itemResponse == null) return;
        // print(element);
        rawItems.add({
          "DocEntry": element['DocEntry'],
          "BaseEntry": element['DocEntry'],
          "ItemCode": element['ItemCode'],
          "ItemDescription": element['ItemName'] ?? element['ItemDescription'],
          "Quantity": "0",
          "TotalQuantity": getDataFromDynamic(element['RemainingOpenQuantity']),
          "WarehouseCode": warehouse.text,
          "UoMEntry": getDataFromDynamic(element['UoMEntry']),
          "UoMCode": element['UoMCode'],
          "UoMGroupDefinitionCollection":
              itemResponse['UoMGroupDefinitionCollection'],
          "BaseUoM": itemResponse['BaseUoM'],
          "BinId": binId.text,
          "BaseLine": element['LineNum'],
          "ManageSerialNumbers": itemResponse["ManageSerialNumbers"],
          "ManageBatchNumbers": itemResponse["ManageBatchNumbers"],
          "Serials": element["SerialNumbers"] ?? [],
          "Batches": element["BatchNumbers"] ?? [],
          "BarCode": element['BarCode'],
        });
        baseEntry.add({
          "BaseEntry": element['DocEntry'],
          "ItemCode": element['ItemCode'],
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
    });
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
          "DocEntry": item['DocEntry'],
          "BaseEntry": item['DocEntry'],
          "ItemCode": item["ItemCode"],
          "ItemDescription": item["ItemDescription"],
          "Quantity": "0",
          "TotalQuantity": quantity,
          "WarehouseCode": item["WarehouseCode"],
          "UoMEntry": item["UoMEntry"],
          "UoMCode": item["UoMCode"],
          "BaseLine": item['BaseLine'],
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

  void onCompleteTextEditItem() async {
    try {
      if (barCode.text == '') return;

      final duplicateItem =
          items.where((e) => e["BarCode"] == barCode.text).toList();
      if (duplicateItem.isEmpty) {
        MaterialDialog.success(context, title: 'Opps.', body: "Item not found");
        return;
      }
      if (duplicateItem.length > 1) {
        goTo(
            context,
            DuplicateItemDLRPage(
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
      final item = await items.firstWhere((e) => e["BarCode"] == barCode.text);
      final index = items.indexWhere((e) => e['BarCode'] == item['BarCode']);
      onEdit(item, index);
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
        title: Padding(
          padding: const EdgeInsets.only(right: 60),
          child: Center(
            child: const Text(
              'Create Delivery',
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
          child: isReview
              ? Column(
                  children: [
                    SizedBox(
                      height: 5,
                    ),
                    ReviewHeader(),
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
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(5),
                      child: Column(
                        children: [
                          Input(
                            controller: poText,
                            readOnly: true,
                            label: 'SO. #',
                            placeholder: 'DocNum',
                            onPressed: onNavigateToSO,
                          ),
                          Input(
                            label: 'Warehouse',
                            placeholder: 'Warehouse',
                            controller: warehouse,
                            readOnly: true,
                            onPressed: onChangeWhs,
                          ),
                          Divider(thickness: 1, color: Colors.grey.shade400),
                          Input(
                            controller: cardCode,
                            readOnly: true,
                            label: 'Customer Code',
                            placeholder: 'Customer Code',
                          ),
                          Input(
                            controller: cardName,
                            readOnly: true,
                            label: 'Customer Name',
                            placeholder: 'Customer Name',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),
                    Divider(thickness: 0.5, color: Colors.grey.shade300),
                    const SizedBox(height: 5),

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
                            onPressed: null,
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
                        const SizedBox(width: 12),
                      ],
                    ),
                    const SizedBox(height: 8),
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
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
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
                        border:
                            Border.all(color: Colors.grey.shade300, width: 0.5),
                      ),
                      child: Column(
                        children: [
                          ContentHeader(),
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
                  style: TextStyle(color: Colors.white, fontSize: 12.5),
                ),
              ),
            ),
            const SizedBox(width: 5),
            isReview
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
                        style: TextStyle(color: Colors.white, fontSize: 12.5),
                      ),
                    ),
                  ),
            isReview ? Container() : const SizedBox(width: 5),
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
                  style: TextStyle(color: PRIMARY_COLOR, fontSize: 12.5),
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
  const ContentHeader({
    super.key,
  });
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
          Expanded(
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
        ],
      ),
    );
  }
}

class ItemRow extends StatelessWidget {
  const ItemRow({super.key, required this.item});
  final dynamic item;
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
              Expanded(
                flex: 1,
                child: Text(
                  ((double.tryParse(item['TotalQuantity'].toString()) ?? 0) -
                          (double.tryParse(item['Quantity'].toString()) ?? 0))
                      .toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13),
                ),
              )
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
