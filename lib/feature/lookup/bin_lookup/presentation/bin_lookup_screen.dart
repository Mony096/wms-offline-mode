import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_mobile/component/form/input_col.dart';
import 'package:wms_mobile/feature/bin_location/presentation/cubit/bin_offline_cubit.dart';
import 'package:wms_mobile/feature/bin_location/presentation/screen/bin_page.dart';
import 'package:wms_mobile/feature/item/presentation/cubit/items_find_stock_offline_cubit.dart';
import 'package:wms_mobile/feature/lookup/bin_lookup/presentation/cubit/binlocation_lookup_cubit.dart';
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
import 'package:wms_mobile/feature/list_batch/presentation/cubit/batch_list_offline_cubit.dart';
import '../../../../constant/style.dart';

class CreateBinLookUpScreen extends StatefulWidget {
  const CreateBinLookUpScreen({super.key});

  @override
  State<CreateBinLookUpScreen> createState() => _CreateBinLookUpScreenState();
}

class _CreateBinLookUpScreenState extends State<CreateBinLookUpScreen> {
  final warehouse = TextEditingController();
  final warehouseNameUI = TextEditingController();
  final binCode = TextEditingController();
  final barCode = TextEditingController();

  late BinLookUpCubit _bloc;
  List<dynamic> items = [];
  List<dynamic> serialOrBatchList = [];
  bool loading = false;
  bool isClickScanBin = false;
  final FocusNode _bin = FocusNode();
  Map<String, dynamic> detailItem = {
    "MinQty": 0.0,
    "MaxQty": 0.0,
    "NoItem": 0,
    "ItemQty": 0.0,
    "NoBatch": 0,
    "NoSerial": 0
  };
  final DioClient dio = DioClient();

  @override
  void initState() {
    init();
    _bloc = context.read<BinLookUpCubit>();

    //
    // IscanDataPlugin.methodChannel.setMethodCallHandler((MethodCall call) async {
    //   if (call.method == "onScanResults") {
    //     if (loading) return;

    //     setState(() {
    //       if (call.arguments['data'] == "decode error") return;
    //       //
    //       binCode.text = call.arguments['data'];
    //     });
    //   }
    // });
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

  void onChangeBin() async {
    goTo(context, BinPage(warehouse: warehouse.text, fromBinlookUp: true))
        .then((value) {
      if (value == null) return;

      binCode.text = getDataFromDynamic(value.code);
    });
  }

  void onGetItem() async {
    try {
      MaterialDialog.loading(context);

      // Add a smooth 2 second loading delay for better UX
      await Future.delayed(const Duration(seconds: 1));

      final itemCubit = context.read<ItemFindStockOfflineCubit>();
      final binCubit = context.read<BinOfflineCubit>();

      // Get offline item stock data
      final itemStockList = itemCubit.getJsonData();

      // Filter by itemCode and warehouse
      final matchedItems = itemStockList
          .where(
            (item) =>
                item['BinCode'] == binCode.text &&
                item['WhsCode'] == warehouse.text,
          )
          .toList();
      // print(itemStockList);
      if (matchedItems.isEmpty) {
        setState(() {
          items = [];
          detailItem = {};
        });
        MaterialDialog.close(context);
        MaterialDialog.success(context, title: 'Oops.', body: "No Items");
        return;
      }

      // Get offline bin data
      final binList = binCubit.state;
      final matchedBin = binList.firstWhere(
        (b) => b['Warehouse'] == warehouse.text && b['BinCode'] == binCode.text,
        orElse: () => {},
      );

      final batchListCubit = context.read<BatchListOfflineCubit>();
      List<dynamic> allSerialsOrBatches = [];
      for (var itemData in matchedItems) {
        final isSerialOrBatch =
            itemData["IsSerial"] == "Y" || itemData["IsBatch"] == "Y";
        if (isSerialOrBatch) {
          final batchList = batchListCubit.getJsonData();
          final matchedSerialOrBatch = batchList
              .where(
                (b) =>
                    b['ItemCode'] == itemData['ItemCode'] &&
                    b['WhsCode'] == warehouse.text,
              )
              .toList();
          allSerialsOrBatches.addAll(matchedSerialOrBatch);
        }
      }

      // Update state
      if (mounted) {
        setState(() {
          items = matchedItems;
          serialOrBatchList = allSerialsOrBatches;

          detailItem["MinQty"] = matchedBin["MinimumQty"] ?? 0.0;
          detailItem["MaxQty"] = matchedBin["MaximumQty"] ?? 0.0;
          detailItem["NoItem"] = matchedItems.length;
          detailItem["ItemQty"] = matchedItems.fold<double>(
            0.0,
            (sum, item) => sum + (item['OnHandQty'] as double? ?? 0.0),
          );

          detailItem["NoBatch"] = matchedItems
              .where((e) =>
                  e["IsBatch"] == "Y" && (e["OnHandQty"] as double? ?? 0) > 0)
              .length;
          detailItem["NoSerial"] = matchedItems
              .where((e) =>
                  e["IsSerial"] == "Y" && (e["OnHandQty"] as double? ?? 0) > 0)
              .length;
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
    binCode.text = '';
  }

  void onChangeWhs() async {
    goTo(context, WarehousePage()).then((value) {
      if (value == null) return;
      if (value is Map) {
        warehouse.text = getDataFromDynamic(value['code']);
        warehouseNameUI.text = getDataFromDynamic(value['name']).isNotEmpty
            ? getDataFromDynamic(value['name'])
            : warehouse.text;
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
      binCode.text = getDataFromDynamic(value['BinCode']);
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
      if (_bin.hasFocus) {
        // ✅ If filter input is focused → set scanned value
        barCode.text = barcode;
        binCode.clear();
        isClickScanBin = false;
        MaterialDialog.warning(context,
            title: 'Oops.', body: "Scan Bin not impliment yet");
        return;
        onGetItem();
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
              'Bin  Lookup',
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

              // ====== Scan & Select Items ======

              const SizedBox(height: 7),

              // ====== Input Qty & UoM ======
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
                        binCode.clear();
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
              items.isEmpty
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(10, 35, 0, 0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Row(
                              children: [
                                SizedBox(width: 90, child: Text("Min. Qty")),
                                Text(
                                  formatQuantity(detailItem["MinQty"]),
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Row(
                              children: [
                                SizedBox(width: 90, child: Text("Max. Qty")),
                                Text(formatQuantity(detailItem["MaxQty"]),
                                    style:
                                        TextStyle(fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
              items.isEmpty
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(10, 15, 0, 0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Row(
                              children: [
                                SizedBox(width: 90, child: Text("No. Items")),
                                Text("${detailItem["NoItem"]}",
                                    style:
                                        TextStyle(fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Row(
                              children: [
                                SizedBox(width: 90, child: Text("Items. Qty")),
                                Text(formatQuantity(detailItem["ItemQty"]),
                                    style:
                                        TextStyle(fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
              items.isEmpty
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(10, 15, 0, 0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Row(
                              children: [
                                SizedBox(width: 90, child: Text("No. Batch")),
                                Text("${detailItem["NoBatch"]}",
                                    style:
                                        TextStyle(fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Row(
                              children: [
                                SizedBox(width: 90, child: Text("No. Serial")),
                                Text("${detailItem["NoSerial"]}",
                                    style:
                                        TextStyle(fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
              const SizedBox(height: 30),
              // List Header
              Container(
                margin: EdgeInsets.zero,
                decoration: const BoxDecoration(
                  color: PRIMARY_COLOR,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.inventory_2_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Bin Detail',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    const Padding(
                      padding: EdgeInsets.only(right: 17.0),
                      child: Text(
                        'Qty',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (items.isEmpty)
                Container(
                  margin: EdgeInsets.zero,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  padding: EdgeInsets.all(30),
                  child: Center(
                    child: Text(
                      "No Item available",
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                  ),
                ),
              if (items.isNotEmpty)
                Container(
                  margin: EdgeInsets.zero,
                  padding: EdgeInsets.fromLTRB(6, 7, 6, 4),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 246, 246, 246),
                    border: Border(
                      left: BorderSide(color: Colors.grey.shade200),
                      right: BorderSide(color: Colors.grey.shade200),
                      bottom: BorderSide(color: Colors.grey.shade200),
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: Column(
                    children: items
                        .where((e) => e["OnHandQty"] > 0)
                        .map((item) => GestureDetector(
                              // onTap: () => onEdit(item),
                              child: Container(
                                margin: EdgeInsets.only(bottom: 8),
                                padding: EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                  border:
                                      Border.all(color: Colors.grey.shade100),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            getDataFromDynamic(
                                                item['ItemCode']),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: Colors.black87),
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color:
                                                PRIMARY_COLOR.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            formatQuantity(item['OnHandQty']),
                                            style: TextStyle(
                                                color: PRIMARY_COLOR,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      getDataFromDynamic(item['ItemName']),
                                      style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 13,
                                          height: 1.3),
                                    ),
                                    SizedBox(height: 12),
                                    Divider(
                                        height: 1, color: Colors.grey.shade100),
                                    SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Spacer(),
                                        if (getDataFromDynamic(
                                                item['InvntryUom'])
                                            .isNotEmpty)
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              getDataFromDynamic(
                                                  item['InvntryUom']),
                                              style: TextStyle(
                                                  color: Colors.grey.shade700,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                      ],
                                    ),
                                    // Serial/Batch List
                                    if ((item["IsSerial"] == "Y" ||
                                            item["IsBatch"] == "Y") &&
                                        (item["OnHandQty"] as double? ?? 0) > 0)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: const Color.fromARGB(
                                                255, 249, 249, 249),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          padding: const EdgeInsets.all(10),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .subdirectory_arrow_right,
                                                    size: 16,
                                                    color: Colors.grey.shade500,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Expanded(
                                                    flex: 4,
                                                    child: Text(
                                                      item["IsBatch"] == "Y"
                                                          ? "Batch Info."
                                                          : "Serial Info.",
                                                      style: TextStyle(
                                                          color: Colors
                                                              .grey.shade700,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 13),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 3,
                                                    child: Text(
                                                      "Expiry",
                                                      style: TextStyle(
                                                          color: Colors
                                                              .grey.shade700,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 13),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      "Qty",
                                                      textAlign:
                                                          TextAlign.right,
                                                      style: TextStyle(
                                                          color: Colors
                                                              .grey.shade700,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 13),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              ...serialOrBatchList
                                                  .where((e) =>
                                                      e['ItemCode'] ==
                                                          item['ItemCode'] &&
                                                      (e["Quantity"]
                                                                  as double? ??
                                                              0) >
                                                          0)
                                                  .map(
                                                    (e) => Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 8,
                                                              bottom: 4),
                                                      child: Row(
                                                        children: [
                                                          const SizedBox(
                                                              width:
                                                                  22), // indent past arrow
                                                          Expanded(
                                                              flex: 4,
                                                              child: Text(
                                                                getDataFromDynamic(
                                                                    e["Batch_Serial"]),
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        13,
                                                                    color: Colors
                                                                        .black87),
                                                              )),
                                                          Expanded(
                                                              flex: 3,
                                                              child: Text(
                                                                  getDataFromDynamic(e[
                                                                      'ExpDate']),
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .red
                                                                          .shade400,
                                                                      fontSize:
                                                                          13))),
                                                          Expanded(
                                                              flex: 2,
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            9.0),
                                                                child: Text(
                                                                  formatQuantity(
                                                                      e['Quantity']),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .right,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          13,
                                                                      color: Colors
                                                                          .black87),
                                                                ),
                                                              ))
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                  .toList(),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ))
                        .toList(),
                  ),
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
