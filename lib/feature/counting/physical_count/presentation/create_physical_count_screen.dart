import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_mobile/component/form/input_col.dart';
import 'package:wms_mobile/feature/bin_location/presentation/cubit/bin_offline_cubit.dart';
import 'package:wms_mobile/feature/counting/cos/presentation/screen/cos_page.dart';
import 'package:wms_mobile/feature/counting/physical_count/presentation/cubit/physical_count_cubit.dart';
import 'package:wms_mobile/feature/counting/physical_count/presentation/cubit/physical_count_offline_cubit.dart';
import 'package:wms_mobile/feature/outbounce/delivery/presentation/duplicateItem_DLR_Screen.dart';
import 'package:wms_mobile/utilies/dio_client.dart';
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
// import 'package:iscan_data_plugin/iscan_data_plugin.dart';
import '../../../../constant/style.dart';

class CreatePhysicalCountScreen extends StatefulWidget {
  const CreatePhysicalCountScreen({super.key});

  @override
  State<CreatePhysicalCountScreen> createState() =>
      _CreatePhysicalCountScreenState();
}

class _CreatePhysicalCountScreenState extends State<CreatePhysicalCountScreen> {
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
  late PhysicalCountCubit _bloc;
  late ItemCubit _blocItem;
  int isEdit = -1;
  bool isSerialOrBatch = false;
  List<dynamic> isSerialOrBatchs = [{}];
  List<dynamic> items = [];
  final DioClient dio = DioClient();
  bool loading = false;
  final barCode = TextEditingController();

  bool isClickScanItem = false;
  bool isClickScanBin = false;
  final FocusNode _itemCode = FocusNode();
  final FocusNode _quantity = FocusNode();
  final FocusNode _bin = FocusNode();
  @override
  void initState() {
    _bloc = context.read<PhysicalCountCubit>();
    _blocItem = context.read<ItemCubit>();

    //
    // IscanDataPlugin.methodChannel.setMethodCallHandler((MethodCall call) async {
    //   if (call.method == "onScanResults") {
    //     if (loading) return;

    //     setState(() {
    //       if (call.arguments['data'] == "decode error") return;
    //       //
    //       itemCode.text = call.arguments['data'];
    //       onCompleteTextEditItem();
    //     });
    //   }
    // });
    super.initState();
  }

  void onSelectItem() async {
    return;
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
    goTo(context, BinPage(warehouse: warehouse.text)).then((value) {
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
            {
              "UoMCountedQuantity": item["Quantity"],
              "CountedQuantity": item["Quantity"],
              "UoMCode": item['UoMCode']
            }
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
      context.read<PhysicalCountOfflineCubit>().addData(data);
      if (mounted) {
        Navigator.of(context).pop();
        MaterialDialog.success(
          context,
          title: 'Successfully',
          body: "Saved Physical Count",
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
      setState(() {
        isSerialOrBatch = true;
      });
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
      try {
        // final binResponse = await dio.get(
        //     "/BinLocations?\$filter=Warehouse eq '${response.data["InventoryCountingLines"]?[0]?["WarehouseCode"]}' & \$select=AbsEntry,Warehouse,BinCode");
        final binCubit = context.read<BinOfflineCubit>();

        final binList = binCubit.state;

        // 🧩 Step 1: Filter bin by warehouse
        final filteredBin = binList
            .where((b) =>
                b['Warehouse'] ==
                value["InventoryCountingLines"]?[0]?["WarehouseCode"])
            .toList();

        warehouse.text = value["InventoryCountingLines"]?[0]?["WarehouseCode"];
        warehouse.text = value["InventoryCountingLines"]?[0]?["WarehouseCode"];
        items = [];
        for (var element in value["InventoryCountingLines"]) {
          var binCode = filteredBin.firstWhere(
            (e) => e["AbsEntry"] == element['BinEntry'],
            orElse: () => null,
          )?['BinCode'];
          // final itemResponse =
          //     findFullItemInformation(context, element['ItemCode']);
          // if (itemResponse == null) return;

          items.add({
            "ItemCode": element['ItemCode'],
            "ItemDescription":
                element['ItemName'] ?? element['ItemDescription'],
            "Quantity": getDataFromDynamic(element['CountedQuantity']),
            "WarehouseCode": warehouse.text,
            "UoMCode": element['UoMCode'],
            "BinId": element['BinEntry'],
            "BinCode": binCode,
            "InventoryCountingLineUoMs": element['InventoryCountingLineUoMs'],
            "BarCode": element["BarCode"]
            // "UoMEntry":
            //     getDataFromDynamic(itemResponse['InventoryUoMEntry'] ?? "-1"),
            // "UoMGroupDefinitionCollection":
            //     itemResponse['UoMGroupDefinitionCollection'],
          });
        }

        setState(() {
          items = items;
        });

        if (mounted) MaterialDialog.close(context);
      } catch (e) {
        print('Error: $e');
      }
    } catch (e) {
      print(e);
    }
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
      } else if (_quantity.hasFocus) {
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
        backgroundColor: PRIMARY_COLOR,
        iconTheme: IconThemeData(color: Colors.white),
        title: Padding(
          padding: const EdgeInsets.only(right: 60),
          child: Center(
            child: const Text(
              'Physical Count',
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
                      controller: cos,
                      label: 'Counting Sheet',
                      placeholder: 'Cos.',
                      onPressed: onSelectCos,
                    ),
                    Input(
                      label: 'Warehouse',
                      placeholder: 'Warehouse',
                      controller: warehouse,
                      readOnly: true,
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
                      // onTap: isSerialOrBatch
                      //     ? () {
                      //         onNavigateSerialOrBatch(force: true);
                      //       }
                      //     : null,
                      // onEditingComplete: onCompleteQuantiyInput,
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
