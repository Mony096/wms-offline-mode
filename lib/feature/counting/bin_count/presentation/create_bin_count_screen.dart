import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_mobile/component/form/input_col.dart';
import 'package:wms_mobile/feature/counting/cos/presentation/screen/cos_page.dart';
import 'package:wms_mobile/feature/item_by_code/presentation/screen/item_page.dart';
import 'package:wms_mobile/feature/warehouse/presentation/screen/warehouse_page.dart';
import 'package:wms_mobile/utilies/dio_client.dart';
import 'package:wms_mobile/utilies/storage/locale_storage.dart';
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
import '../../../../constant/style.dart';
import 'cubit/binlocation_count_cubit.dart';

class CreateBinCountScreen extends StatefulWidget {
  const CreateBinCountScreen({super.key});

  @override
  State<CreateBinCountScreen> createState() => _CreateBinCountScreenState();
}

class _CreateBinCountScreenState extends State<CreateBinCountScreen> {
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
  final cosDocEntry = TextEditingController();
  final cos = TextEditingController();
  final isBatch = TextEditingController();
  final isSerial = TextEditingController();
  late BinlocationCountCubit _bloc;
  late ItemCubit _blocItem;
  final barCode = TextEditingController();
  final DioClient dio = DioClient();
  List<dynamic> itemCodeFilter = [];
  int isEdit = -1;
  bool isSerialOrBatch = false;
  List<dynamic> isSerialOrBatchs = [{}];

  List<dynamic> items = [];
  bool loading = false;
  String queryBin = "?\$top=100&\$select=AbsEntry,BinCode,Warehouse,Sublevel1";
  List<BinEntity> dataBin = [];

  @override
  void initState() {
    _bloc = context.read<BinlocationCountCubit>();
    _blocItem = context.read<ItemCubit>();
    init();
    //
    try {
      // IscanDataPlugin.methodChannel
      //     .setMethodCallHandler((MethodCall call) async {
      //   if (call.method == "onScanResults") {
      //     if (loading) return;

      //     setState(() {
      //       if (call.arguments['data'] == "decode error") return;
      //       barCode.text = call.arguments['data'];
      //       onCompleteTextEditItem();
      //     });
      //   }
      // });
    } catch (e) {
      print("Error setting method call handler: $e");
    }
    super.initState();
  }

  void init() async {
    final whs = await LocalStorageManger.getString('warehouse');
    warehouse.text = whs;
  }

  void onSelectItem() async {
    // return;
    setState(() {
      isEdit = -1;
    });
    goTo(context, ItemPage(type: ItemType.inventory)).then((value) {
      if (value == null) return;

      onSetItemTemp(value);
    });
  }

  void onSelectCos() async {
    setState(() {
      isEdit = -1;
    });
    goTo(context, CosPage()).then((value) {
      if (value == null) return;

      onSetCosTemp(value);
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

      // if (binId.text == '') {
      //   throw Exception('Bin Location is missing.');
      // }

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
        "InventoryCountingLineUoMs": isSerialOrBatchs,
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
        binCode.text = getDataFromDynamic(item['BinCode']);
        binId.text = getDataFromDynamic(item['BinId']);
        baseUoM.text = getDataFromDynamic(item['BaseUoM']);
        docEntry.text = getDataFromDynamic(item['DocEntry']);
        refLineNo.text = getDataFromDynamic(item['BaseLine']);
        uoMGroupDefinitionCollection.text = jsonEncode(
          item['UoMGroupDefinitionCollection'],
        );
        setState(() {
          isEdit = index;
          isSerialOrBatchs = item['InventoryCountingLineUoMs'];
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
    // return;
    goTo(
        context,
        BinPage(
          warehouse: warehouse.text,
          itemCode: itemCode.text,
        )).then((value) {
      if (value == null) return;

      binId.text = getDataFromDynamic((value as BinEntity).id);
      binCode.text = getDataFromDynamic(value.code);
    });
  }

  void onPostToSAP() async {
    try {
      MaterialDialog.loading(context);
      Map<String, dynamic> data = {
        // "BranchID": 1,
        "DocumentNumber": cos.text,
        "InventoryCountingLines": items.map((item) {
          List<dynamic> inventoryCountingLineUoMs = [
            // {
            //   "UoMCountedQuantity": item["Quantity"],
            //   "CountedQuantity": item["Quantity"],
            //   "UoMCode": item['UoMCode']
            // }
          ];

          if (isSerialOrBatchs.isEmpty) {
            inventoryCountingLineUoMs = [];
          }
          return {
            "ItemCode": item['ItemCode'],
            "ItemDescription": item['ItemDescription'],
            "UoMCode": item['UoMCode'],
            "BinEntry": item["BinId"],
            "CountedQuantity": item["Quantity"],
            "WarehouseCode": warehouse.text,
            "InventoryCountingSerialNumbers": item['Serials'] ?? [],
            "InventoryCountingBatchNumbers": item['Batches'] ?? [],
            "InventoryCountingLineUoMs": inventoryCountingLineUoMs
          };
        }).toList(),
      };

      final response = await _bloc.post(data);
      if (mounted) {
        Navigator.of(context).pop();
        MaterialDialog.success(
          context,
          title: 'Successfully',
          body: "Physical Count - ${response["DocumentNumber"]}.",
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

  void onSetItemTemp(dynamic value) {
    try {
      if (value == null) return;
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
    } catch (e) {
      print(e);
    }
  }

  void onSetCosTemp(dynamic value) async {
    try {
      if (value == null) return;
      if (mounted) MaterialDialog.loading(context);
      FocusScope.of(context).requestFocus(FocusNode());
      cosDocEntry.text = getDataFromDynamic(value['DocumentEntry']);
      cos.text = getDataFromDynamic(value['DocumentNumber']);
      clear();
      if (value['DocumentEntry'] != null) {
        try {
          final response =
              await dio.get('/InventoryCountings(${value['DocumentEntry']})');

          if (response.statusCode == 200) {
            final binResponse = await dio.get(
                "/BinLocations?\$filter=Warehouse eq '${response.data["InventoryCountingLines"]?[0]?["WarehouseCode"]}' & \$select=AbsEntry,Warehouse,BinCode");
            warehouse.text =
                response.data["InventoryCountingLines"]?[0]?["WarehouseCode"];
            if (binResponse.statusCode == 200) {
              final binData = binResponse.data['value'];
              warehouse.text =
                  response.data["InventoryCountingLines"]?[0]?["WarehouseCode"];
              items = [];

              for (var element in response.data["InventoryCountingLines"]) {
                var binCode = binData.firstWhere(
                  (e) => e["AbsEntry"] == element['BinEntry'],
                  orElse: () => null,
                )?['BinCode'];

                items.add({
                  "ItemCode": element['ItemCode'],
                  "ItemDescription":
                      element['ItemName'] ?? element['ItemDescription'],
                  "Quantity": getDataFromDynamic(element['CountedQuantity']),
                  "WarehouseCode": warehouse.text,
                  "UoMCode": element['UoMCode'],
                  "BinId": element['BinEntry'],
                  "BinCode": binCode,
                  "InventoryCountingLineUoMs":
                      element['InventoryCountingLineUoMs'],
                });
              }
            }
          }

          setState(() {
            items = items;
          });

          if (mounted) MaterialDialog.close(context);
        } catch (e) {
          print('Error: $e');
        }
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
    return;
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
        ),
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
        ),
      ).then((value) {
        if (value == null) return;
        quantity.text = value['quantity'] ?? "0";
        batchesInput.text = jsonEncode(value['items']);
      });
    }
  }

  void onChangeWhs() async {
    goTo(context, WarehousePage()).then((value) {
      if (value == null) return;
      warehouse.text = getDataFromDynamic(value);
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
              'Bin Location Count',
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
              //   controller: cos,
              //   label: 'CoS.',
              //   placeholder: 'Counting Sheet',
              //   onPressed: onSelectCos,
              // ),
              // Input(
              //   label: 'Warehouse',
              //   placeholder: 'Warehouse',
              //   controller: warehouse,
              //   readOnly: true,
              //   onPressed: onChangeWhs,
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
              // ====== Bin Location ======
              InputCol(
                label: 'Bin Location',
                placeholder: 'Chose Bin Location',
                controller: binCode,
                readOnly: true,
                onPressed: onChangeBin,
              ),
              const SizedBox(height: 8),

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
                      // onTap: isSerialOrBatch
                      //     ? () {
                      //         onNavigateSerialOrBatch(force: true);
                      //       }
                      //     : null,
                      onEditingComplete: onCompleteQuantiyInput,
                      // onPressed: isSerialOrBatch
                      //     ? () {
                      //         onNavigateSerialOrBatch(force: true);
                      //       }
                      //     : null, // remove if icon not needed
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
