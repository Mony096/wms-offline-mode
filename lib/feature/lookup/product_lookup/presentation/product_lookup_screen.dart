import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wms_mobile/component/form/input_col.dart';
import 'package:wms_mobile/core/error/failure.dart';
import 'package:wms_mobile/feature/item/presentation/cubit/items_barcode_offline_cubit.dart';
import 'package:wms_mobile/feature/item/presentation/cubit/items_find_stock_offline_cubit.dart';
import 'package:wms_mobile/feature/item/presentation/cubit/items_offline_cubit.dart';
import 'package:wms_mobile/feature/item_by_code/presentation/screen/item_page.dart';
import 'package:wms_mobile/feature/list_batch/presentation/cubit/batch_list_offline_cubit.dart';
import 'package:wms_mobile/feature/unit_of_measurement/presentation/cubit/uom_group_offline_cubit.dart';
import 'package:wms_mobile/feature/warehouse/presentation/screen/warehouse_page.dart';
import 'package:wms_mobile/utilies/dio_client.dart';
import '../../../item/presentation/cubit/item_cubit.dart';
import '/component/button/button.dart';
import '/component/form/input.dart';
import '/core/enum/global.dart';
import '/feature/item/presentation/screen/item_page.dart';
import '/helper/helper.dart';
import '/utilies/dialog/dialog.dart';
import '/utilies/storage/locale_storage.dart';
// import 'package:iscan_data_plugin/iscan_data_plugin.dart';
import '../../../../constant/style.dart';
import 'cubit/product_lookup_cubit.dart';

class CreateProductLookUpScreen extends StatefulWidget {
  const CreateProductLookUpScreen({super.key});

  @override
  State<CreateProductLookUpScreen> createState() =>
      _CreateProductLookUpScreenState();
}

class _CreateProductLookUpScreenState extends State<CreateProductLookUpScreen> {
  final warehouse = TextEditingController();
  final warehouseNameUI = TextEditingController();
  final itemCode = TextEditingController();
  final itemName = TextEditingController();

  late ProductLookUpCubit _bloc;
  late ItemCubit _blocItem;
  final barCode = TextEditingController();
  final DioClient dio = DioClient();
  List<dynamic> itemCodeFilter = [];
  List<dynamic> items = [];
  List<dynamic> serialOrBatchList = [];
  bool loading = false;
  bool isClickScanItem = false;
  final FocusNode _itemCode = FocusNode();
  final FocusNode _quantity = FocusNode();
  final FocusNode _bin = FocusNode();
  @override
  void initState() {
    init();
    _bloc = context.read<ProductLookUpCubit>();
    _blocItem = context.read<ItemCubit>();

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
    final whsName = await LocalStorageManger.getString('warehouseName');
    warehouseNameUI.text = whsName.isNotEmpty ? whsName : warehouse.text;
  }

  void onSelectItem() async {
    goTo(context, ItemPage(type: ItemType.inventory)).then((value) {
      if (value == null) return;

      onSetItemTemp(value);
    });
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
        MaterialDialog.success(context, title: 'Oops.', body: "Item not found");
        return;
      }

      onSetItemTemp(matchedItem);
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
  // void onChangeBin() async {
  //   goTo(context, BinPage(warehouse: warehouse.text)).then((value) {
  //     if (value == null) return;

  //     binId.text = getDataFromDynamic((value as BinEntity).id);
  //     binCode.text = getDataFromDynamic(value.code);
  //   });
  // }

  void onGetItem() async {
    try {
      MaterialDialog.loading(context);

      final itemStockCubit = context.read<ItemFindStockOfflineCubit>();
      final batchListCubit = context.read<BatchListOfflineCubit>();

      // Get offline stock data
      final itemStockList = itemStockCubit.getJsonData();

      // Step 1: Find item in offline stock list
      final matchedItemStock = itemStockList
          .where(
            (item) =>
                item['ItemCode'] == itemCode.text &&
                item['WhsCode'] == warehouse.text,
          )
          .toList();

      if (matchedItemStock.isEmpty) {
        setState(() {
          items = [];
          serialOrBatchList = [];
        });
        MaterialDialog.close(context);
        MaterialDialog.success(context, title: 'Oops.', body: "No Items");
        return;
      }

      // Step 2: Check if item requires serial or batch
      final itemData = matchedItemStock[0];
      final isSerialOrBatch =
          itemData["IsSerial"] == "Y" || itemData["IsBatch"] == "Y";

      if (isSerialOrBatch) {
        // Get offline batch/serial data
        final batchList = batchListCubit.getJsonData();
        final matchedSerialOrBatch = batchList
            .where(
              (b) =>
                  b['ItemCode'] == itemCode.text &&
                  b['WhsCode'] == warehouse.text,
            )
            .toList();

        setState(() {
          items = [itemData];
          serialOrBatchList = matchedSerialOrBatch;
        });

        print("Serial/Batch List: $serialOrBatchList");
      } else {
        // Regular non-serial/batch item
        setState(() {
          items = [itemData];
          serialOrBatchList = [];
        });
      }

      MaterialDialog.close(context);
    } catch (e) {
      if (mounted) {
        MaterialDialog.close(context);
        MaterialDialog.success(context, title: 'Error.', body: e.toString());
      }
    }
  }

  void clear() {
    itemCode.text = '';
    itemName.text = '';
  }

  void onChangeWhs() async {
    goTo(context, WarehousePage()).then((value) {
      if (value == null) return;
      if (value is Map) {
        warehouse.text = getDataFromDynamic(value['code']);
        warehouseNameUI.text = getDataFromDynamic(value['name']).isNotEmpty ? getDataFromDynamic(value['name']) : warehouse.text;
      } else {
        warehouse.text = getDataFromDynamic(value);
        warehouseNameUI.text = warehouse.text;
      }
    });
  }

  void onSetItemTemp(dynamic value) {
    try {
      if (value == null) return;
      FocusScope.of(context).requestFocus(FocusNode());
      itemCode.text = getDataFromDynamic(value['ItemCode']);
      itemName.text = getDataFromDynamic(value['ItemName']);
    } catch (e) {
      print(e);
    }
  }

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
              onGetItem();

        isClickScanItem = false;
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
              'Product  Lookup',
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
                      label: 'Warehouse',
                      placeholder: 'Warehouse',
                      controller: warehouseNameUI,
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
                        itemCode.clear();
                        itemName.clear();
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
              InputCol(
                label: 'Description',
                placeholder: 'Description',
                controller: itemName,
                readOnly: true,
              ),

              const SizedBox(height: 8),

              // ====== Bin Location ======

              const SizedBox(height: 30),
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
                  ],
                ),
              ),
              // Column(children: []),
              Column(
                children: items
                    .where((f) => f["OnHandQty"] > 0)
                    .map(
                      (item) => GestureDetector(
                        // onTap: () => onEdit(item),
                        child: Container(
                          padding:
                              item["IsBatch"] == "Y" && item["IsSerial"] == "Y"
                                  ? EdgeInsets.only(top: 15)
                                  : EdgeInsets.fromLTRB(5, 15, 0, 15),
                          decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(width: 0.1)),
                              color: Colors.grey.shade50),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      getDataFromDynamicBin(item['BinCode']),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                      child: Text((getDataFromDynamic(
                                          item['InvntryUom'])))),
                                  Expanded(
                                      child: Text((getDataFromDynamic(
                                          item['OnHandQty'])))),
                                ],
                              ),
                              // SizedBox(
                              //   height: 15,
                              // ),
                              //Serial///////////////////////////
                              item["IsSerial"] == "Y"
                                  ? Row(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 7),
                                            child: SvgPicture.asset(
                                              color: Color.fromARGB(
                                                  235, 183, 184, 186),
                                              "images/svg/down_right.svg",
                                              width: size(context).width * 0.06,
                                              height:
                                                  size(context).width * 0.06,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 11,
                                          child: Container(
                                            margin: EdgeInsets.only(top: 13),
                                            padding:
                                                EdgeInsets.fromLTRB(5, 5, 5, 5),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                              color: Color.fromARGB(
                                                  255, 243, 243, 244),
                                              // border: Border(
                                              //   bottom: BorderSide(
                                              //     color: Color.fromARGB(255, 226, 229,
                                              //         233), // Change the color as needed
                                              //     width: 1.0, // Change the width as needed
                                              //   ),
                                              // ),
                                            ),
                                            child: Row(
                                              children: const [
                                                Expanded(
                                                  flex: 4,
                                                  child: Text(
                                                    "Serial Info.",
                                                    style:
                                                        TextStyle(fontSize: 14),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: Text(
                                                    "Qty.",
                                                    style:
                                                        TextStyle(fontSize: 14),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Container(),
                              item["IsSerial"] == "Y"
                                  ? Column(
                                      children: serialOrBatchList
                                          .where((e) =>
                                              e["AbsEntry"] == item["BinID"])
                                          .map((e) => Row(
                                                children: [
                                                  Expanded(
                                                      flex: 1, child: Text("")),
                                                  Expanded(
                                                      flex: 11,
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                5, 7, 5, 10),
                                                        color:
                                                            Colors.grey.shade50,
                                                        child: Column(
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                    flex: 4,
                                                                    child: Text(
                                                                      getDataFromDynamic(
                                                                          e["Batch_Serial"]),
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              14),
                                                                    )),
                                                                Expanded(
                                                                    flex: 3,
                                                                    child: Text(
                                                                        "1",
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                14)))
                                                              ],
                                                            ),
                                                            SizedBox(
                                                              height: 5,
                                                            ),
                                                          ],
                                                        ),
                                                      )),
                                                ],
                                              ))
                                          .toList(),
                                    )
                                  : Container(),
                              //Batch1111111111
                              item["IsBatch"] == "Y"
                                  ? Row(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 7),
                                            child: SvgPicture.asset(
                                              color: Color.fromARGB(
                                                  235, 183, 184, 186),
                                              "images/svg/down_right.svg",
                                              width: size(context).width * 0.06,
                                              height:
                                                  size(context).width * 0.06,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 11,
                                          child: Container(
                                            margin: EdgeInsets.only(top: 13),
                                            padding:
                                                EdgeInsets.fromLTRB(5, 5, 5, 5),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                              color: Color.fromARGB(
                                                  255, 243, 243, 244),
                                              // border: Border(
                                              //   bottom: BorderSide(
                                              //     color: Color.fromARGB(255, 226, 229,
                                              //         233), // Change the color as needed
                                              //     width: 1.0, // Change the width as needed
                                              //   ),
                                              // ),
                                            ),
                                            child: Row(
                                              children: const [
                                                Expanded(
                                                  flex: 4,
                                                  child: Text(
                                                    "Batch Info.",
                                                    style:
                                                        TextStyle(fontSize: 14),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: Text(
                                                    "Expiry",
                                                    style:
                                                        TextStyle(fontSize: 14),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 5),
                                                    child: Text(
                                                      "Qty",
                                                      style: TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Container(),
                              item["IsBatch"] == "Y"
                                  ? Column(
                                      children: serialOrBatchList
                                          .where((e) =>
                                              e["AbsEntry"] == item["BinID"])
                                          .map((e) => Row(
                                                children: [
                                                  Expanded(
                                                      flex: 1, child: Text("")),
                                                  Expanded(
                                                      flex: 11,
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                5, 10, 5, 10),
                                                        color:
                                                            Colors.grey.shade50,
                                                        child: Column(
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                    flex: 4,
                                                                    child: Text(
                                                                      getDataFromDynamic(
                                                                          e["Batch_Serial"]), // Use null-aware operator to handle null
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              14),
                                                                    )),
                                                                Expanded(
                                                                    flex: 3,
                                                                    child: Text(
                                                                        getDataFromDynamic(e[
                                                                            'ExpDate']),
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.red,
                                                                            fontSize: 14))),
                                                                Expanded(
                                                                    flex: 2,
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              5),
                                                                      child:
                                                                          Text(
                                                                        (getDataFromDynamic(
                                                                            e['Quantity'])),
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                14),
                                                                      ),
                                                                    ))
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      )),
                                                ],
                                              ))
                                          .toList(),
                                    )
                                  : Container(),
                              // //End11111111111111
                            ],
                          ),
                        ),
                      ),
                      // GestureDetector(
                      //       // onTap: () => onEdit(item),
                      //       child: Container(
                      //         padding: const EdgeInsets.symmetric(vertical: 20),
                      //         decoration: BoxDecoration(
                      //             border: Border(bottom: BorderSide(width: 0.1))),
                      //         child: Column(
                      //           crossAxisAlignment: CrossAxisAlignment.start,
                      //           children: [
                      //             Row(
                      //               children: [
                      //                 Expanded(
                      //                   flex: 3,
                      //                   child: Text(
                      //                     getDataFromDynamic(item['BinCode']),
                      //                     style: TextStyle(
                      //                       fontWeight: FontWeight.w600,
                      //                     ),
                      //                   ),
                      //                 ),
                      //                 Expanded(
                      //                     child: Text(getDataFromDynamic(
                      //                         item['UoMCode']))),
                      //                 Expanded(
                      //                     child: Text('${item['OnHandQty']}')),
                      //               ],
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //     )
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.fromLTRB(15, 0, 15, 15),
        child: Button(
          bgColor: PRIMARY_COLOR,
          onPressed: onGetItem,
          child: Text(
            "Search",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
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
        color: PRIMARY_COLOR, // Dark navy header
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
              'Bin Info',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.only(right: 30),
              child: Text(
                'UoM',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Qty',
              style: TextStyle(
                color: Colors.white,
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
  const ItemRow({super.key, required this.item});

  final dynamic item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  getDataFromDynamic(item['ItemCode']),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(child: Text(getDataFromDynamic(item['UoMCode']))),
              Expanded(child: Text('${item['Quantity']}/0')),
            ],
          ),
          SizedBox(height: 6),
          Text(getDataFromDynamic(item['ItemDescription']))
        ],
      ),
    );
  }
}
