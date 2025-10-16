import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_mobile/component/form/input_col.dart';
import 'package:wms_mobile/feature/bin_location/presentation/cubit/bin_cubit.dart';
import 'package:wms_mobile/feature/item_by_code/presentation/screen/item_page.dart';
import 'package:wms_mobile/feature/warehouse/presentation/cubit/warehouse_cubit.dart';
import 'package:wms_mobile/feature/warehouse/presentation/screen/warehouse_page.dart';
import 'package:wms_mobile/utilies/dio_client.dart';
import '/feature/batch/good_receip_batch_screen.dart';
import '/feature/serial/good_receip_serial_screen.dart';
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
import 'cubit/put_away_cubit.dart';

class CreatePutAwayScreen extends StatefulWidget {
  const CreatePutAwayScreen({super.key});

  @override
  State<CreatePutAwayScreen> createState() => _CreatePutAwayScreenState();
}

class _CreatePutAwayScreenState extends State<CreatePutAwayScreen> {
  // final cardCode = TextEditingController();
  // final cardName = TextEditingController();
  // final poText = TextEditingController();
  final uomText = TextEditingController();
  final quantity = TextEditingController();
  final warehouse = TextEditingController();
  final uom = TextEditingController();
  final uomAbEntry = TextEditingController();
  final itemCode = TextEditingController();
  final itemName = TextEditingController();
  final baseUoM = TextEditingController();
  final uoMGroupDefinitionCollection = TextEditingController();
  final sbinId = TextEditingController();
  final sbinCode = TextEditingController();
  final tbinId = TextEditingController();
  final tbinCode = TextEditingController();
  final serialsInput = TextEditingController();
  final batchesInput = TextEditingController();
  final docEntry = TextEditingController();
  final refLineNo = TextEditingController();

  //
  final isBatch = TextEditingController();
  final isSerial = TextEditingController();

  late PutAwayCubit _bloc;
  late ItemCubit _blocItem;
  late WarehouseCubit _blocWarehouse;

  final DioClient dio = DioClient();
  List<dynamic> itemCodeFilter = [];
  final barCode = TextEditingController();

  int isEdit = -1;
  bool isSerialOrBatch = false;
  List<dynamic> items = [];
  bool loading = false;
  late BinCubit _blocBin;

  @override
  void initState() {
    init();
    _bloc = context.read<PutAwayCubit>();
    _blocItem = context.read<ItemCubit>();
    _blocWarehouse = context.read<WarehouseCubit>();
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
    // Load warehouse code first
    final whs = await LocalStorageManger.getString('warehouse');
    warehouse.text = whs;
    // Get current BinCubit state
    final state = _blocBin.state;
    final stateWarehouse = _blocWarehouse.state;
    // If state is not BinData, just return (no data yet)
    if (state is! BinData) {
      debugPrint("BinCubit has no data yet.");
      return;
    }
    if (stateWarehouse is! WarehouseData) {
      debugPrint("WarehouseCubit has no data yet.");
      return;
    }
    final warehouses = stateWarehouse.entities;
    final bins = state.entities; // List<BinEntity>
    // Try to find bin with matching warehouse
    try {
      final defBinFromWhs =
          warehouses.firstWhere((w) => w.code == warehouse.text).defBin;
      final binInit = bins.firstWhere(
          (b) => b.id == int.tryParse(defBinFromWhs?.toString() ?? ''));
      // Assign values to your text controllers
      sbinId.text = binInit.id.toString();
      sbinCode.text = binInit.code;
    } catch (e) {
      debugPrint("No bin found for warehouse ${warehouse.text}: $e");
    }
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

      if (sbinId.text == '') {
        throw Exception('Bin Location is missing.');
      }

      if (tbinId.text == '') {
        throw Exception('Bin Location is missing.');
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
        "BaseEntry": docEntry.text,
        "BaseLine": refLineNo.text,
        "UoMGroupDefinitionCollection":
            jsonDecode(uoMGroupDefinitionCollection.text) ?? [],
        "BaseUoM": baseUoM.text,
        "SBinId": sbinId.text,
        "SBinCode": sbinCode.text,
        "TBinId": tbinId.text,
        "TBinCode": tbinCode.text,
        "ManageSerialNumbers": isSerial.text,
        "ManageBatchNumbers": isBatch.text,
        "Serials":
            serialsInput.text == "" ? [] : jsonDecode(serialsInput.text) ?? [],
        "Batches":
            batchesInput.text == "" ? [] : jsonDecode(batchesInput.text) ?? [],
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
        sbinCode.text = getDataFromDynamic(item['SBinCode']);
        sbinId.text = getDataFromDynamic(item['SBinId']);
        tbinCode.text = getDataFromDynamic(item['TBinCode']);
        tbinId.text = getDataFromDynamic(item['TBinId']);
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

  // void onChangeCardCode() async {
  //   goTo(context, BusinessPartnerPage(type: BusinessPartnerType.supplier))
  //       .then((value) {
  //     if (value == null) return;

  //     cardCode.text = getDataFromDynamic(value['CardCode']);
  //     cardName.text = getDataFromDynamic(value['CardName']);
  //   });
  // }

  void onChangeSBin() async {
    goTo(context, BinPage(warehouse: warehouse.text, itemCode: itemCode.text))
        .then((value) {
      if (value == null) return;

      sbinId.text = getDataFromDynamic((value as BinEntity).id);
      sbinCode.text = getDataFromDynamic(value.code);
    });
  }

  void onChangeTBin() async {
    goTo(context, BinPage(warehouse: warehouse.text, itemCode: itemCode.text))
        .then((value) {
      if (value == null) return;
      tbinId.text = getDataFromDynamic((value as BinEntity).id);
      tbinCode.text = getDataFromDynamic((value).code);
    });
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
      Map<String, dynamic> data = {
        // "BPLID": 1,
        // "CardCode": cardCode.text,
        // "CardName": cardName.text,
        "FromWarehouse": warehouse.text,
        "ToWarehouse": warehouse.text,
        "DocumentStatus": "bost_Open",
        // "U_tl_sobincode": tbinCode.text,
        "StockTransferLines": items.asMap().entries.map((entry) {
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
              "BinAbsEntry": item['SBinId'],
              "BaseLineNumber": parentIndex,
              "AllowNegativeQuantity": "tNO",
              "SerialAndBatchNumbersBaseLine": -1,
              "BinActionType": "batFromWarehouse",
            },
            {
              "Quantity": convertQuantityUoM(
                alternativeUoM['BaseQuantity'],
                alternativeUoM['AlternateQuantity'],
                double.tryParse(item['Quantity']) ?? 0.00,
              ),
              "BinAbsEntry": item['TBinId'],
              "BaseLineNumber": parentIndex,
              "AllowNegativeQuantity": "tNO",
              "SerialAndBatchNumbersBaseLine": -1,
              "BinActionType": "batToWarehouse",
            }
          ];

          bool isBatch = item['ManageBatchNumbers'] == 'tYES';
          bool isSerial = item['ManageSerialNumbers'] == 'tYES';

          if (isBatch || isSerial) {
            binAllocations = [
              {
                "BinAbsEntry": item['SBinId'],
                "Quantity": item['Quantity'],
                "AllowNegativeQuantity": "tNO",
                "SerialAndBatchNumbersBaseLine": parentIndex,
                "BinActionType": "batFromWarehouse",
                "BaseLineNumber": parentIndex
              },
              {
                "BinAbsEntry": item['TBinId'],
                "Quantity": item['Quantity'],
                "AllowNegativeQuantity": "tNO",
                "SerialAndBatchNumbersBaseLine": parentIndex,
                "BinActionType": "batToWarehouse",
                "BaseLineNumber": parentIndex
              }
            ];

            // List<dynamic> batchOrSerialLines =
            //     isSerial ? item['Serials'] : item['Batches'];
            // print(batchOrSerialLines);
            // int index = 0;
            // for (var element in batchOrSerialLines) {
            //   binAllocations.add({
            //     "BinAbsEntry": item['SBinId'],
            //     "AllowNegativeQuantity": "tNO",
            //     "BaseLineNumber": parentIndex,
            //     "SerialAndBatchNumbersBaseLine": index,
            //     "Quantity": convertQuantityUoM(
            //         alternativeUoM['BaseQuantity'],
            //         alternativeUoM['AlternateQuantity'],
            //         double.tryParse(element['Quantity']) ?? 0.00),
            //   });

            //   index++;
            // }
          }

          return {
            "ItemCode": item['ItemCode'],
            "ItemDescription": item['ItemDescription'],
            "UoMCode": item['UoMCode'],
            // "UoMEntry": item['UoMEntry'],
            "Quantity": item['Quantity'],
            "WarehouseCode": warehouse.text,
            "FromWarehouseCode": warehouse.text,
            // "BaseType": 234000031,
            // "BaseEntry": item['BaseEntry'],
            // "BaseLine": item['BaseLine'],
            "SerialNumbers": item['Serials'] ?? [],
            "BatchNumbers": item['Batches'] ?? [],
            "StockTransferLinesBinAllocations": binAllocations
          };
        }).toList(),
      };
      setState(() {
        print(data);
      });
      // return;
      final response = await _bloc.post(data);
      if (mounted) {
        Navigator.of(context).pop();
        MaterialDialog.success(
          context,
          title: 'Successfully',
          body: "Put Away - ${response['DocNum']}.",
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
    sbinId.text = '';
    sbinCode.text = '';
    tbinId.text = '';
    tbinCode.text = '';
    uom.text = '';
    uomAbEntry.text = '';
    isBatch.text = '';
    isSerial.text = '';
    docEntry.text = '';
    refLineNo.text = '';
    isEdit = -1;
  }

  void onSetItemTemp(dynamic value) {
    try {
      if (value == null) return;
      setState(() {
        isSerialOrBatch = false;
      });
      FocusScope.of(context).requestFocus(FocusNode());
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
            binCode: sbinId.text,
            listAllSerial: true,
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
            listAllBatch: true,
            itemName: itemName.text,
            warehouse: warehouse.text,
            binCode: sbinId.text,
            isEdit: isEdit),
      ).then((value) {
        if (value == null) return;
        quantity.text = value['quantity'] ?? "0";
        batchesInput.text = jsonEncode(value['items']);
      });
    }
  }

  // void onNavigateToReturnReceiptRequest() async {
  //   goTo(context, ReturnReceiptRequestPage()).then((value) async {
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
              'Create Put Away',
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
              //   controller: sbinCode,
              //   label: 'S.Bin.',
              //   placeholder: 'Bin Location',
              //   onPressed: onChangeSBin,
              // ),
              // Input(
              //   controller: tbinCode,
              //   label: 'T.Bin.',
              //   placeholder: 'Bin Location',
              //   onPressed: onChangeTBin,
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
              // )
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
                    Input(
                      controller: sbinCode,
                      label: 'S.Bin.',
                      placeholder: 'Bin Location',
                      onPressed: onChangeSBin,
                    ),
                    Input(
                      controller: tbinCode,
                      label: 'T.Bin.',
                      placeholder: 'Bin Location',
                      onPressed: onChangeTBin,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Divider(thickness: 0.5, color: Colors.grey.shade500),
              const SizedBox(height: 5),

              // ====== Scan & Select Items ======
              Row(
                children: [
                  Expanded(
                    child: InputCol(
                      label: 'Item Code',
                      placeholder: 'Chose Item',
                      controller: itemCode,
                      readOnly: true,
                      onPressed: onSelectItem,
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
