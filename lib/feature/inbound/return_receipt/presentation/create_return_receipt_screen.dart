import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:wms_mobile/feature/bin_location/presentation/cubit/bin_offline_cubit.dart';
import 'package:wms_mobile/feature/inbound/return_receipt/presentation/cubit/return_receipt_failed_offline_cubit.dart';
import 'package:wms_mobile/feature/inbound/return_receipt/presentation/cubit/return_receipt_offline_cubit.dart';
import 'package:wms_mobile/feature/inbound/return_receipt/presentation/duplicateItem_RTR_Screen.dart';
import 'package:wms_mobile/feature/inbound/return_receipt_request/presentation/cubit/return_receipt_request_offline_cubit.dart';
import 'package:wms_mobile/feature/inbound/return_receipt_request/presentation/return_receipt_request_page.dart';
import 'package:wms_mobile/feature/item/presentation/cubit/items_barcode_offline_cubit.dart';
import 'package:wms_mobile/feature/item/presentation/cubit/items_offline_cubit.dart';
import 'package:wms_mobile/feature/unit_of_measurement/presentation/cubit/uom_group_offline_cubit.dart';
import 'package:wms_mobile/feature/unit_of_measurement/presentation/cubit/uom_offline_cubit.dart';
import 'package:wms_mobile/feature/warehouse/presentation/cubit/warhouse_offline_cubit.dart';
import 'package:wms_mobile/utilies/dio_client.dart';
import '/component/button/button.dart';
import '/core/enum/global.dart';
import '/helper/helper.dart';
import '/utilies/dialog/dialog.dart';
import '/utilies/storage/locale_storage.dart';
import '../../../../core/error/failure.dart';
import '../../../../constant/style.dart';

class CreateReturnReceiptScreen extends StatefulWidget {
  const CreateReturnReceiptScreen({
    super.key,
    this.isEdit,
    this.isEditFaild,
  });
  final dynamic isEdit;
  final dynamic isEditFaild;
  @override
  State<CreateReturnReceiptScreen> createState() =>
      _CreateReturnReceiptScreenState();
}

class _CreateReturnReceiptScreenState extends State<CreateReturnReceiptScreen> {
  final cardCode = TextEditingController();
  final cardName = TextEditingController();
  final remark = TextEditingController();
  final rtrText = TextEditingController();
  final uomText = TextEditingController();
  final quantity = TextEditingController();
  final warehouse = TextEditingController();
  final warehouseNameUI = TextEditingController();
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
  final barCode = TextEditingController();
  final totalQuantity = TextEditingController();
  final saveId = TextEditingController();
  final originalQty = TextEditingController();

  //
  final isBatch = TextEditingController();
  final isSerial = TextEditingController();
  final DioClient dio = DioClient();
  List<dynamic> itemCodeFilter = [];
  bool _isHeaderCollapsed = false;
  bool _isLineItemCollapsed = false;
  final ScrollController _scrollController = ScrollController();
  final uomName = TextEditingController();
  int isEdit = -1;
  bool isSerialOrBatch = false;
  List<dynamic> items = [];
  bool loading = false;
  bool isReview = false;
  bool isClickScanItem = false;
  bool isClickScanBin = false;
  final FocusNode _itemCode = FocusNode();
  final FocusNode _quantity = FocusNode();
  final FocusNode _bin = FocusNode();
  List<Map<String, dynamic>> activeDimensions = [];
  final Map<int, TextEditingController> _headerCostingCodes = {
    1: TextEditingController(),
    2: TextEditingController(),
    3: TextEditingController(),
    4: TextEditingController(),
    5: TextEditingController(),
  };
  final Map<int, TextEditingController> _headerCostingCodeNames = {
    1: TextEditingController(),
    2: TextEditingController(),
    3: TextEditingController(),
    4: TextEditingController(),
    5: TextEditingController(),
  };
  final Map<int, TextEditingController> _lineCostingCodes = {
    1: TextEditingController(),
    2: TextEditingController(),
    3: TextEditingController(),
    4: TextEditingController(),
    5: TextEditingController(),
  };
  final Map<int, TextEditingController> _lineCostingCodeNames = {
    1: TextEditingController(),
    2: TextEditingController(),
    3: TextEditingController(),
    4: TextEditingController(),
    5: TextEditingController(),
  };

  @override
  void initState() {
    super.initState();

    init();
    _loadDimensions();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fromEdit();
    });
  }

  @override
  void dispose() {
    cardCode.dispose();
    cardName.dispose();
    remark.dispose();
    rtrText.dispose();
    uomText.dispose();
    quantity.dispose();
    totalQuantity.dispose();
    warehouse.dispose();
    warehouseNameUI.dispose();
    uom.dispose();
    uomAbEntry.dispose();
    uomName.dispose();
    itemCode.dispose();
    itemName.dispose();
    baseUoM.dispose();
    uoMGroupDefinitionCollection.dispose();
    binId.dispose();
    binCode.dispose();
    serialsInput.dispose();
    batchesInput.dispose();
    barCode.dispose();
    refLineNo.dispose();
    docEntry.dispose();
    saveId.dispose();
    originalQty.dispose();
    isBatch.dispose();
    isSerial.dispose();
    _scrollController.dispose();
    _itemCode.dispose();
    _quantity.dispose();
    _bin.dispose();
    for (final controllers in [
      _headerCostingCodes,
      _headerCostingCodeNames,
      _lineCostingCodes,
      _lineCostingCodeNames
    ]) {
      for (final controller in controllers.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  Future<void> _loadDimensions() async {
    try {
      // 1. Try local cache from master data storage
      final cachedMetaStr =
          await LocalStorageManger.getString('dimensions_meta');
      List<dynamic> cachedMeta = [];
      if (cachedMetaStr.isNotEmpty) {
        try {
          cachedMeta = jsonDecode(cachedMetaStr) as List<dynamic>;
        } catch (_) {}
      }

      final cachedStr = await LocalStorageManger.getString('dimension_v2');
      if (cachedStr.isNotEmpty) {
        try {
          final decoded = jsonDecode(cachedStr) as List<dynamic>;
          if (decoded.isNotEmpty) {
            final list = List<Map<String, dynamic>>.from(
              decoded.map((e) => Map<String, dynamic>.from(e)),
            );

            // Repair cached descriptions if metadata is present
            for (var d in list) {
              final code =
                  int.tryParse(d['DimensionCode']?.toString() ?? '') ?? 0;
              final metaMatch = cachedMeta.firstWhere(
                (m) =>
                    (int.tryParse(m['DimensionCode']?.toString() ?? '') ?? 0) ==
                    code,
                orElse: () => null,
              );
              if (metaMatch != null) {
                final mDesc = metaMatch['DimensionDescription']?.toString();
                if (mDesc != null && mDesc.trim().isNotEmpty) {
                  d['DimensionDescription'] = mDesc.trim();
                  d['DimensionName'] =
                      metaMatch['DimensionName'] ?? d['DimensionDescription'];
                  d['IsActive'] = metaMatch['IsActive'] ?? 'tYES';
                }
              } else {
                if (d['DimensionDescription'] == 'Cost Center' ||
                    d['DimensionDescription'] == 'Dimension $code') {
                  if (code == 1) d['DimensionDescription'] = 'Line of Business';
                  if (code == 2) d['DimensionDescription'] = 'Department';
                  if (code == 3) d['DimensionDescription'] = 'Region';
                }
              }
            }

            // Filter to only active dimensions
            final activeOnly = list.where((d) {
              final active = d['IsActive']?.toString();
              return active == null ||
                  active == 'tYES' ||
                  active == 'Y' ||
                  active == 'true';
            }).toList();

            if (activeOnly.isNotEmpty && mounted) {
              setState(() {
                activeDimensions = activeOnly;
              });
              return;
            }
          }
        } catch (_) {}
      }

      // 2. If dimension_v2 is empty, construct from distribution_rules
      final rulesCachedStr =
          await LocalStorageManger.getString('distribution_rules');
      if (rulesCachedStr.isNotEmpty) {
        try {
          final decodedRules = jsonDecode(rulesCachedStr) as List<dynamic>;
          final List<Map<String, dynamic>> fallbackDims = [];
          final Set<int> dimCodes = {};
          for (var r in decodedRules) {
            final code =
                int.tryParse(r['InWhichDimension']?.toString() ?? '') ?? 0;
            if (code >= 1 && code <= 5) dimCodes.add(code);
          }
          final sortedCodes = dimCodes.toList()..sort();
          for (var dimCode in sortedCodes) {
            final dimRules = decodedRules.where((r) {
              final ruleDim =
                  int.tryParse(r['InWhichDimension']?.toString() ?? '') ?? 0;
              return ruleDim == dimCode;
            }).toList();

            final matchedMeta = cachedMeta.firstWhere(
              (m) =>
                  (int.tryParse(m['DimensionCode']?.toString() ?? '') ?? 0) ==
                  dimCode,
              orElse: () => null,
            );

            String desc = 'Dimension $dimCode';
            if (matchedMeta != null &&
                matchedMeta['DimensionDescription']
                        ?.toString()
                        .trim()
                        .isNotEmpty ==
                    true) {
              desc = matchedMeta['DimensionDescription'].toString().trim();
            } else {
              if (dimCode == 1) desc = 'Line of Business';
              if (dimCode == 2) desc = 'Department';
              if (dimCode == 3) desc = 'Region';
            }

            fallbackDims.add({
              'DimensionCode': dimCode,
              'DimensionName': matchedMeta?['DimensionName'] ?? desc,
              'DimensionDescription': desc,
              'IsActive': 'tYES',
              'rules': dimRules,
            });
          }
          if (fallbackDims.isNotEmpty && mounted) {
            setState(() {
              activeDimensions = fallbackDims;
            });
          }
        } catch (_) {}
      }
    } catch (e) {
      debugPrint("Error loading dimensions from local storage: $e");
    }
  }

  void fromEdit() async {
    try {
      if (widget.isEdit == null) return;

      // ✅ Populate text fields safely
      cardCode.text = getDataFromDynamic(widget.isEdit['CardCode']);
      cardName.text = getDataFromDynamic(widget.isEdit['CardName']);
      remark.text = getDataFromDynamic(widget.isEdit['Comments']);
      warehouse.text = getDataFromDynamic(widget.isEdit['WarehouseCode']);
      warehouseNameUI.text = warehouse.text;
      saveId.text = getDataFromDynamic(widget.isEdit['SaveId']);
      if (mounted) MaterialDialog.loading(context);

      final barcodeList = context.read<ItemBarcodeOfflineCubit>().state;
      final receiptRequest =
          context.read<ReturnReceiptRequestOfflineCubit>().state;

      final List<Map<String, dynamic>> rawItems = [];
      final List<dynamic> lines =
          (widget.isEdit['DocumentLines'] as List?) ?? [];

      final refDocEntry =
          lines.isEmpty ? '' : getDataFromDynamic(lines.first['BaseEntry']);
      docEntry.text = refDocEntry;
      final matchedRReq = receiptRequest.firstWhere(
        (rcr) => rcr['DocEntry'].toString() == refDocEntry,
        orElse: () => {},
      );
      if (matchedRReq.isEmpty) {
        if (mounted) MaterialDialog.close(context);

        MaterialDialog.warning(
          context,
          title: 'Error',
          body: "Return Receipt Request Not Found!",
        );
        return;
      }
      rtrText.text = getDataFromDynamic(matchedRReq['DocNum']);

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

        final matchedPOLine =
            (matchedRReq.isNotEmpty && matchedRReq["DocumentLines"] != null)
                ? (matchedRReq["DocumentLines"] as List).firstWhere(
                    (b) =>
                        getDataFromDynamic(b['LineNum']) ==
                            getDataFromDynamic(element['BaseLine']) &&
                        b['ItemCode'] == itemCode &&
                        b['UoMEntry'] == uomEntry,
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
        final allocations =
            (element['DocumentLinesBinAllocations'] as List?) ?? [];
        final binID =
            allocations.isEmpty ? '' : allocations.first['BinAbsEntry'];
        final binCodeFind = binList.firstWhere(
          (u) => u['AbsEntry'] == int.tryParse(getDataFromDynamic(binID)),
          orElse: () => {},
        );

        rawItems.add({
          for (int d = 1; d <= 5; d++) ...{
            (d == 1 ? 'CostingCode' : 'CostingCode$d'): getDataFromDynamic(
                element[d == 1 ? 'CostingCode' : 'CostingCode$d']),
            (d == 1 ? 'CostingCodeName' : 'CostingCode${d}Name'):
                getDataFromDynamic(element[
                    d == 1 ? 'CostingCodeName' : 'CostingCode${d}Name']),
          },
          "BaseEntry": element["BaseEntry"],
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
      _restoreHeaderDimensions();

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
    if (widget.isEdit != null) return;
    final whs = await LocalStorageManger.getString('warehouse');
    final name = await LocalStorageManger.getString('warehouseName');
    if (!mounted) return;
    setState(() {
      warehouse.text = whs;
      warehouseNameUI.text = name.isEmpty ? whs : name;
    });
  }

  void _restoreHeaderDimensions() {
    for (int d = 1; d <= 5; d++) {
      final key = d == 1 ? 'CostingCode' : 'CostingCode$d';
      final nameKey = d == 1 ? 'CostingCodeName' : 'CostingCode${d}Name';
      final code = items.isEmpty ? '' : getDataFromDynamic(items.first[key]);
      final uniform =
          items.every((row) => getDataFromDynamic(row[key]) == code);
      _headerCostingCodes[d]?.text = uniform ? code : '';
      _headerCostingCodeNames[d]?.text = uniform && items.isNotEmpty
          ? getDataFromDynamic(items.first[nameKey])
          : '';
    }
  }

  void onSelectItem() {
    _unfocusAll();
    _openGenericPickerModal<int>(
      title: 'Select Return Request Line',
      subtitle: 'RTR: ${rtrText.text}',
      icon: Icons.inventory_2_outlined,
      items: List<int>.generate(items.length, (index) => index),
      currentCode: isEdit < 0 ? '' : '${isEdit + 1}',
      getCode: (index) => '${index + 1}',
      getName: (index) =>
          '${items[index]['ItemCode']} - ${items[index]['ItemDescription']}',
      onSelected: (index) {
        if (index != null) _startEditItem(index);
      },
    );
  }

  void onChangeUoM() async {
    _unfocusAll();
    if (itemCode.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Please select an item first to choose its Unit of Measure.'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      List<int> validUomIds = [];
      if (uoMGroupDefinitionCollection.text.isNotEmpty) {
        try {
          final data =
              jsonDecode(uoMGroupDefinitionCollection.text) as List<dynamic>;
          validUomIds = data
              .map((e) =>
                  int.tryParse(e['AlternateUoM']?.toString() ?? '') ?? -1)
              .where((id) => id > 0)
              .toList();
        } catch (_) {}
      }

      final offlineUoms = context.read<UOMOfflineCubit>().state;
      List<dynamic> itemsToSelect = [];
      if (validUomIds.isNotEmpty) {
        itemsToSelect = offlineUoms
            .where((u) => validUomIds.contains(u['AbsEntry']))
            .toList();
      }
      if (itemsToSelect.isEmpty) {
        itemsToSelect = offlineUoms;
      }

      _openGenericPickerModal<dynamic>(
        title: 'Select Unit of Measure',
        subtitle: 'Item: ${itemCode.text}',
        icon: Icons.straighten_rounded,
        items: itemsToSelect,
        currentCode: uom.text,
        getCode: (item) => getDataFromDynamic(item['Code']),
        getName: (item) => getDataFromDynamic(item['Name']),
        showCode: true,
        allowClear: false,
        onSelected: (selected) {
          if (selected == null) return;
          setState(() {
            uom.text = getDataFromDynamic(selected['Code']);
            uomAbEntry.text = getDataFromDynamic(selected['AbsEntry']);
            final name = getDataFromDynamic(selected['Name']);
            uomName.text = name.isNotEmpty ? name : uom.text;
          });
        },
      );
    } catch (e) {
      debugPrint("Error selecting UoM: $e");
    }
  }

  void onChangeWhs() {
    List<dynamic> whs = [];
    try {
      final cubit = context.read<WarehouseOfflineCubit>();
      cubit.loadData();
      whs = cubit.state;
    } catch (_) {}
    if (whs.isEmpty) {
      try {
        final box = Hive.box('warehouse');
        whs = box.get('data', defaultValue: []).cast<dynamic>();
      } catch (_) {}
    }

    _openGenericPickerModal<dynamic>(
      title: 'Select Warehouse',
      subtitle: 'Destination warehouse',
      icon: Icons.warehouse_outlined,
      items: whs,
      currentCode: warehouse.text,
      getCode: (item) {
        final c = getDataFromDynamic(item['WarehouseCode']);
        return c.isNotEmpty ? c : getDataFromDynamic(item['code']);
      },
      getName: (item) {
        final n = getDataFromDynamic(item['WarehouseName']);
        return n.isNotEmpty ? n : getDataFromDynamic(item['name']);
      },
      allowClear: false,
      onSelected: (item) {
        if (item == null) return;
        final code = getDataFromDynamic(item['WarehouseCode']).isNotEmpty
            ? getDataFromDynamic(item['WarehouseCode'])
            : getDataFromDynamic(item['code']);
        final name = getDataFromDynamic(item['WarehouseName']).isNotEmpty
            ? getDataFromDynamic(item['WarehouseName'])
            : getDataFromDynamic(item['name']);
        warehouse.text = code;
        warehouseNameUI.text = name.isNotEmpty ? name : code;
        setState(() {});
      },
    );
  }

  void onAddItem({bool force = false}) {
    FocusScope.of(context).unfocus();
    try {
      List<dynamic> data = [...items];

      if (itemCode.text == '') {
        throw Exception('Item is missing.');
      }

      // if (binId.text == '') {
      //   throw Exception('Bin Location is missing.');
      // }

      if ((double.tryParse(quantity.text.replaceAll(',', '')) ?? 0) <= 0) {
        throw Exception('Quantity must be greater than zero.');
      }

      final item = {
        "ItemCode": itemCode.text,
        "ItemDescription": itemName.text,
        "Quantity": quantity.text.replaceAll(',', ''),
        "TotalQuantity": totalQuantity.text.replaceAll(',', ''),
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
        "BarCode": barCode.text,
        "ManageSerialNumbers": isSerial.text,
        "ManageBatchNumbers": isBatch.text,
        "Serials":
            serialsInput.text == "" ? [] : jsonDecode(serialsInput.text) ?? [],
        "Batches":
            batchesInput.text == "" ? [] : jsonDecode(batchesInput.text) ?? [],
        "OriginalQty": originalQty.text.replaceAll(',', ''),
        "UoMName": uomName.text,
        for (int d = 1; d <= 5; d++) ...{
          (d == 1 ? 'CostingCode' : 'CostingCode$d'):
              (isEdit == -1 ? _headerCostingCodes : _lineCostingCodes)[d]
                      ?.text ??
                  '',
          (d == 1 ? 'CostingCodeName' : 'CostingCode${d}Name'): (isEdit == -1
                      ? _headerCostingCodeNames
                      : _lineCostingCodeNames)[d]
                  ?.text ??
              '',
        },
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
        // print(docEntry.text);
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

  void _unfocusAll() {
    _quantity.unfocus();
    _itemCode.unfocus();
    _bin.unfocus();
    FocusScope.of(context).unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _quantity.unfocus();
        _itemCode.unfocus();
        _bin.unfocus();
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      }
    });
  }

  void _startEditItem(int targetIndex) {
    if (targetIndex < 0 || targetIndex >= items.length) return;
    final item = items[targetIndex];

    itemCode.text = getDataFromDynamic(item['ItemCode']);
    itemName.text = getDataFromDynamic(item['ItemDescription']);
    quantity.text = formatQuantity(getDataFromDynamic(item['Quantity']));
    uom.text = getDataFromDynamic(item['UoMCode']);
    uomAbEntry.text = getDataFromDynamic(item['UoMEntry']);
    uomName.text = getDataFromDynamic(item['UoMName']);
    if (uomName.text.isEmpty && uom.text.isNotEmpty) {
      try {
        final offlineUoms = context.read<UOMOfflineCubit>().state;
        final matchedUom = offlineUoms.firstWhere(
          (u) =>
              getDataFromDynamic(u['Code']) == uom.text ||
              getDataFromDynamic(u['AbsEntry']) == uomAbEntry.text,
          orElse: () => null,
        );
        if (matchedUom != null) {
          final name = getDataFromDynamic(matchedUom['Name']);
          uomName.text = name.isNotEmpty ? name : uom.text;
        } else {
          uomName.text = uom.text;
        }
      } catch (_) {
        uomName.text = uom.text;
      }
    }
    binCode.text = getDataFromDynamic(item['BinCode']);
    binId.text = getDataFromDynamic(item['BinId']);
    baseUoM.text = getDataFromDynamic(item['BaseUoM']);
    if (getDataFromDynamic(item['BaseEntry']).isNotEmpty) {
      docEntry.text = getDataFromDynamic(item['BaseEntry']);
    }
    refLineNo.text = getDataFromDynamic(item['BaseLine']);
    originalQty.text = getDataFromDynamic(item['OriginalQty']);
    totalQuantity.text =
        formatQuantity(getDataFromDynamic(item['TotalQuantity']));
    barCode.text = getDataFromDynamic(item['BarCode']);
    uoMGroupDefinitionCollection.text = jsonEncode(
      item['UoMGroupDefinitionCollection'] ?? [],
    );
    isSerial.text = getDataFromDynamic(item['ManageSerialNumbers']);
    isBatch.text = getDataFromDynamic(item['ManageBatchNumbers']);
    batchesInput.text = jsonEncode(item['Batches'] ?? []);
    serialsInput.text = jsonEncode(item['Serials'] ?? []);

    // Pre-populate line item dimensions from item (or fallback to header)
    for (int d = 1; d <= 5; d++) {
      final codeKey = d == 1 ? 'CostingCode' : 'CostingCode$d';
      final nameKey = d == 1 ? 'CostingCodeName' : 'CostingCode${d}Name';
      String code = getDataFromDynamic(item[codeKey]);
      String name = getDataFromDynamic(item[nameKey]);
      if (name.isEmpty && code.isNotEmpty) {
        final dim = activeDimensions.firstWhere(
          (ad) =>
              (int.tryParse(ad['DimensionCode']?.toString() ?? '') ?? 0) == d,
          orElse: () => {},
        );
        final rules = (dim['rules'] as List<dynamic>?) ?? [];
        final matchedRule = rules.firstWhere(
          (r) => r['FactorCode']?.toString() == code,
          orElse: () => null,
        );
        if (matchedRule != null) {
          name = matchedRule['FactorDescription']?.toString() ?? '';
        }
      }
      _lineCostingCodes[d]?.text = code;
      _lineCostingCodeNames[d]?.text = name;
    }

    setState(() {
      isEdit = targetIndex;
      _isLineItemCollapsed = false;

      isSerialOrBatch = false;
    });

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        130,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _deleteItem(int targetIndex) async {
    if (targetIndex < 0 || targetIndex >= items.length) return;
    final item = items[targetIndex];
    final itemCodeStr = getDataFromDynamic(item['ItemCode']);

    _unfocusAll();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(Icons.delete_outline_rounded,
                color: Colors.red.shade600, size: 24),
            const SizedBox(width: 8),
            Text('Remove Item',
                style: TextStyle(
                    fontSize: AppFontSize.dialogTitle,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Are you sure you want to remove "$itemCodeStr" from receipt list?',
          style: TextStyle(fontSize: AppFontSize.base),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _unfocusAll();
            },
            child: Text('Cancel',
                style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: AppFontSize.buttonSmall)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                final list = [...items];
                list.removeAt(targetIndex);
                items = list;
                if (isEdit == targetIndex) {
                  clear();
                  isSerialOrBatch = false;
                } else if (isEdit > targetIndex) {
                  isEdit -= 1;
                }
              });
            },
            child:
                Text('Remove', style: TextStyle(fontSize: AppFontSize.button)),
          ),
        ],
      ),
    );

    if (mounted) {
      _unfocusAll();
    }
  }

  Widget _buildModalDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              fontSize: AppFontSize.detailItemLabel,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Text(
          ' :  ',
          style: TextStyle(
            fontSize: AppFontSize.detailItemLabel,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: AppFontSize.detailItemValue,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }

  void _showItemActionDialog(dynamic item, int index) async {
    _unfocusAll();

    final itemCodeStr = getDataFromDynamic(item['ItemCode']);
    final itemDescStr = getDataFromDynamic(item['ItemDescription']);
    final qtyStr = formatQuantity(getDataFromDynamic(item['Quantity']));
    final uomStr = getDataFromDynamic(item['UoMCode']);
    final binCodeStr = getDataFromDynamic(item['BinCode']);

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: PRIMARY_COLOR.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.inventory_2_outlined,
                  size: 20, color: PRIMARY_COLOR),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    itemCodeStr.isEmpty ? 'Item Details' : itemCodeStr,
                    style: TextStyle(
                      fontSize: AppFontSize.dialogTitle,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (itemDescStr.isNotEmpty)
                    Text(
                      itemDescStr,
                      style: TextStyle(
                          fontSize: AppFontSize.md,
                          color: Colors.grey.shade600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.format_list_bulleted_rounded,
                              size: 15, color: PRIMARY_COLOR),
                          const SizedBox(width: 6),
                          Text(
                            'Item Details',
                            style: TextStyle(
                              fontSize: AppFontSize.sectionTitle,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: PRIMARY_COLOR.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Row #${index + 1}',
                          style: TextStyle(
                            fontSize: AppFontSize.badge,
                            fontWeight: FontWeight.w700,
                            color: PRIMARY_COLOR,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(
                      height: 1,
                      thickness: 0.6,
                      color: Color(0xFFCBD5E1),
                    ),
                  ),
                  _buildModalDetailRow(
                      'Quantity', '$qtyStr ${uomStr.isNotEmpty ? uomStr : ''}'),
                  ...[
                    const SizedBox(height: 6),
                    _buildModalDetailRow(
                        'Available Quantity',
                        formatQuantity(
                            getDataFromDynamic(item['TotalQuantity']))),
                  ],
                  if (binCodeStr.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    _buildModalDetailRow('Bin Location', binCodeStr),
                  ],
                  ...List.generate(5, (i) {
                    final d = i + 1;
                    final codeKey = d == 1 ? 'CostingCode' : 'CostingCode$d';
                    final nameKey =
                        d == 1 ? 'CostingCodeName' : 'CostingCode${d}Name';
                    final code = getDataFromDynamic(item[codeKey]);
                    if (code.isEmpty) return const SizedBox.shrink();

                    final dim = activeDimensions.firstWhere(
                      (e) =>
                          (int.tryParse(e['DimensionCode']?.toString() ?? '') ??
                              0) ==
                          d,
                      orElse: () => {},
                    );
                    final dimLabel = (dim['DimensionDescription']
                                ?.toString()
                                .trim()
                                .isNotEmpty ??
                            false)
                        ? dim['DimensionDescription'].toString()
                        : ((dim['DimensionName']
                                    ?.toString()
                                    .trim()
                                    .isNotEmpty ??
                                false)
                            ? dim['DimensionName'].toString()
                            : 'Dimension $d');
                    String name = getDataFromDynamic(item[nameKey]);
                    if (name.isEmpty && code.isNotEmpty) {
                      final rules = (dim['rules'] as List<dynamic>?) ?? [];
                      final matchedRule = rules.firstWhere(
                        (r) => r['FactorCode']?.toString() == code,
                        orElse: () => null,
                      );
                      if (matchedRule != null) {
                        name =
                            matchedRule['FactorDescription']?.toString() ?? '';
                      }
                    }
                    final display = name.isNotEmpty ? name : code;

                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: _buildModalDetailRow(dimLabel, display),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: PRIMARY_COLOR,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                _unfocusAll();
                _startEditItem(index);
              },
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: Text(
                'Edit Item',
                style: TextStyle(
                    fontSize: AppFontSize.button, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade700,
                side: BorderSide(color: Colors.red.shade300),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                _unfocusAll();
                _deleteItem(index);
              },
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              label: Text(
                'Delete Item',
                style: TextStyle(
                    fontSize: AppFontSize.button, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _unfocusAll();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: AppFontSize.buttonSmall),
              ),
            ),
          ],
        )),
      ),
    );

    if (mounted) {
      _unfocusAll();
    }
  }

  void onEdit(dynamic item, int index) {
    if (index >= 0 && index < items.length) {
      _showItemActionDialog(item, index);
    }
  }

  void onChangeBin() {
    List<dynamic> allBins = [];
    try {
      allBins = context.read<BinOfflineCubit>().state;
    } catch (_) {}
    if (allBins.isEmpty) {
      try {
        final box = Hive.box('bin');
        allBins = box.get('data', defaultValue: []).cast<dynamic>();
      } catch (_) {}
    }

    final filteredBins = warehouse.text.isNotEmpty
        ? allBins
            .where((b) => getDataFromDynamic(b['Warehouse']) == warehouse.text)
            .toList()
        : allBins;

    _openGenericPickerModal<dynamic>(
      title: 'Select Bin Location',
      subtitle: warehouse.text.isNotEmpty
          ? 'Warehouse: ${warehouseNameUI.text.isNotEmpty ? warehouseNameUI.text : warehouse.text}'
          : 'All Bins',
      icon: Icons.grid_view_rounded,
      items: filteredBins,
      currentCode: binCode.text,
      getCode: (item) => getDataFromDynamic(item['BinCode']),
      getName: (item) {
        final sub = getDataFromDynamic(item['Sublevel1']);
        return sub.isNotEmpty
            ? 'Sublevel: $sub'
            : getDataFromDynamic(item['BinCode']);
      },
      getExtraInfo: (item) {
        final wh = getDataFromDynamic(item['Warehouse']);
        return wh.isNotEmpty ? 'Whs: $wh' : '';
      },
      allowClear: true,
      clearLabel: 'None (Clear Bin Location)',
      onSelected: (item) {
        if (item == null) {
          binCode.clear();
          binId.clear();
        } else {
          binCode.text = getDataFromDynamic(item['BinCode']);
          binId.text = getDataFromDynamic(item['AbsEntry']);
        }
        setState(() {});
      },
    );
  }

  void onPostToSAP() async {
    if (items.isEmpty) {
      MaterialDialog.warning(context,
          title: 'Error', body: "Opps, Items is required");
      return;
    }
    try {
      var uuid = Uuid();
      MaterialDialog.loading(context);
      if (cardCode.text == '') {
        throw Exception(
            "You can only perform action with Return Receipt Request Document.");
      }
      final filteredItems = items.where((item) {
        final qty = double.tryParse(item["Quantity"].toString()) ?? 0.0;
        return qty != 0;
      }).toList();
      if (filteredItems.isEmpty) {
        throw Exception('Enter a received quantity for at least one item.');
      }
      Map<String, dynamic> data = {
        // "BPL_IDAssignedToInvoice": 1,
        "SaveId": widget.isEdit != null && widget.isEditFaild == true
            ? saveId.text
            : widget.isEdit != null
                ? saveId.text
                : uuid.v4(),
        "CardCode": cardCode.text,
        "CardName": cardName.text,
        "Comments": remark.text,
        "WarehouseCode": warehouse.text,
        "DocumentLines": filteredItems.asMap().entries.map((entry) {
          int parentIndex = entry.key;
          Map<String, dynamic> item = entry.value;

          List<dynamic> uomCollections =
              item["UoMGroupDefinitionCollection"] ?? [];

          final alternativeUoM = uomCollections.firstWhere(
            (row) =>
                row['AlternateUoM'].toString() == item['UoMEntry'].toString(),
            orElse: () => null, // Provide a default value if not found
          );

          if (alternativeUoM == null) {
            throw Exception(
                "No matching UoM found for item ${item['ItemCode']}");
          }

          List<dynamic> binAllocations = [
            {
              "Quantity": convertQuantityUoM(
                double.tryParse(alternativeUoM['BaseQuantity'].toString()) ??
                    1.0,
                double.tryParse(
                        alternativeUoM['AlternateQuantity'].toString()) ??
                    1.0,
                double.tryParse(item['Quantity'].toString()) ?? 0.00,
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
                    double.tryParse(
                            alternativeUoM['BaseQuantity'].toString()) ??
                        1.0,
                    double.tryParse(
                            alternativeUoM['AlternateQuantity'].toString()) ??
                        1.0,
                    double.tryParse(element['Quantity'].toString()) ?? 0.00),
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
            for (int d = 1; d <= 5; d++)
              if (getDataFromDynamic(
                      item[d == 1 ? 'CostingCode' : 'CostingCode$d'])
                  .isNotEmpty)
                (d == 1 ? 'CostingCode' : 'CostingCode$d'):
                    item[d == 1 ? 'CostingCode' : 'CostingCode$d'],
            "WarehouseCode": warehouse.text,
            "BaseEntry": docEntry.text,
            "BaseType": 234000031,
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
        context
            .read<ReturnReceiptFailedOfflineCubit>()
            .removeByFailId(saveId.text);
        context.read<ReturnReceiptOfflineCubit>().addData(data);
        final refDocEntry =
            int.tryParse((data["DocumentLines"]?[0]?["BaseEntry"]).toString());
        for (var element in data["DocumentLines"].toList()) {
          context
              .read<ReturnReceiptRequestOfflineCubit>()
              .decreaseQuantityByLine(
                  docEntry: refDocEntry ?? -1,
                  lineId: int.tryParse(element["BaseLine"].toString()) ?? -1,
                  quantity:
                      double.tryParse(element["Quantity"].toString()) ?? 0.0,
                  context: context);
        }
      } else if (widget.isEdit != null) {
        context
            .read<ReturnReceiptOfflineCubit>()
            .updateBySaveId(saveId.text, data);
        final refDocEntry =
            int.tryParse((data["DocumentLines"]?[0]?["BaseEntry"]).toString());
        for (var element in data["DocumentLines"].toList()) {
          final updateQty =
              (double.tryParse(element["Quantity"].toString()) ?? 0.0) -
                  (double.tryParse(element["OriginalQty"].toString()) ?? 0.0);
          context
              .read<ReturnReceiptRequestOfflineCubit>()
              .decreaseQuantityByLine(
                  docEntry: refDocEntry,
                  lineId: int.tryParse(element["BaseLine"].toString()) ?? -1,
                  quantity: updateQty,
                  context: context);
        }
      } else {
        context.read<ReturnReceiptOfflineCubit>().addData(data);
        for (var element in data["DocumentLines"].toList()) {
          context
              .read<ReturnReceiptRequestOfflineCubit>()
              .decreaseQuantityByLine(
                  docEntry: int.tryParse(docEntry.text.toString()) ?? -1,
                  lineId: int.tryParse(element["BaseLine"].toString()) ?? -1,
                  quantity:
                      double.tryParse(element["Quantity"].toString()) ?? 0.0,
                  context: context);
        }
      }
      // final response = await _bloc.post(data);
      if (mounted) {
        Navigator.of(context).pop();
        MaterialDialog.success(
          context,
          title: 'Success',
          body: widget.isEdit != null && widget.isEditFaild == true
              ? "Edited Faild Return Receipt"
              : widget.isEdit != null
                  ? "Edited Return Receipt"
                  : "Saved Return Receipt",
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
    for (final controller in [
      itemCode,
      itemName,
      quantity,
      binId,
      binCode,
      uom,
      uomAbEntry,
      uomName,
      isBatch,
      isSerial,
      serialsInput,
      batchesInput,
      totalQuantity,
      refLineNo,
      originalQty,
      barCode,
      baseUoM,
      uoMGroupDefinitionCollection,
      ..._lineCostingCodes.values,
      ..._lineCostingCodeNames.values
    ]) {
      controller.clear();
    }
    isEdit = -1;
    isSerialOrBatch = false;
  }

  void onCompleteQuantiyInput() {
    FocusScope.of(context).requestFocus(FocusNode());
    onNavigateSerialOrBatch();
  }

  void onNavigateSerialOrBatch({bool force = false}) {
    // Customer returns accept received quantity without serial/batch entry.
  }

  void onNavigateToReturnReceiptRequest() async {
    _unfocusAll();
    final value = await goTo(
        context, ReturnReceiptRequestPage(type: BusinessPartnerType.customer));
    if (!mounted || value == null) return;
    loadReturnReceiptRequest(value);
  }

  void loadReturnReceiptRequest(dynamic value) {
    final List<dynamic> openLines =
        List<dynamic>.from(value['DocumentLines'] ?? [])
            .where((line) =>
                line['LineStatus'] == 'bost_Open' &&
                (double.tryParse(line['RemainingOpenQuantity'].toString()) ??
                        0) >
                    0)
            .toList();
    final List<dynamic> loaded = [];
    for (final element in openLines) {
      final info = findFullItemInformation(context, element['ItemCode']);
      if (info == null) return;
      loaded.add({
        'BaseEntry': value['DocEntry'],
        'BaseLine': element['LineNum'],
        'ItemCode': element['ItemCode'],
        'ItemDescription': element['ItemName'] ?? element['ItemDescription'],
        'Quantity': '0',
        'TotalQuantity': getDataFromDynamic(element['RemainingOpenQuantity']),
        'WarehouseCode': warehouse.text,
        'UoMEntry': getDataFromDynamic(element['UoMEntry']),
        'UoMCode': element['UoMCode'],
        'UoMGroupDefinitionCollection': info['UoMGroupDefinitionCollection'],
        'BaseUoM': info['BaseUoM'],
        'BinId': '',
        'BinCode': '',
        'BarCode': element['BarCode'],
        'ManageSerialNumbers': info['ManageSerialNumbers'],
        'ManageBatchNumbers': info['ManageBatchNumbers'],
        'Serials': [],
        'Batches': [],
        for (int d = 1; d <= 5; d++) ...{
          (d == 1 ? 'CostingCode' : 'CostingCode$d'): getDataFromDynamic(
              element[d == 1 ? 'CostingCode' : 'CostingCode$d']),
          (d == 1 ? 'CostingCodeName' : 'CostingCode${d}Name'):
              getDataFromDynamic(
                  element[d == 1 ? 'CostingCodeName' : 'CostingCode${d}Name']),
        },
      });
    }
    setState(() {
      clear();
      cardCode.text = getDataFromDynamic(value['CardCode']);
      cardName.text = getDataFromDynamic(value['CardName']);
      docEntry.text = getDataFromDynamic(value['DocEntry']);
      rtrText.text = getDataFromDynamic(value['DocNum']);
      items = loaded;
      _restoreHeaderDimensions();
      isReview = false;
    });
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
            DuplicateItemRTRPage(
              barCode: barCode.text,
              items: duplicateItem,
            )).then((item) {
          if (item == null) return;
          final index = items.contains(item)
              ? items.indexOf(item)
              : items.indexWhere((e) =>
                  e['BarCode'] == item['BarCode'] &&
                  e['ItemCode'] == item['ItemCode']);
          onEdit(item, index);
        });
        return;
      }
      // Continue processing if there is only one matching item
      final item = duplicateItem.first;
      final index = items.indexOf(item);
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

  String _calculateTotalQuantity() {
    double total = 0.0;
    for (var item in items) {
      final qStr = item['Quantity']?.toString().replaceAll(',', '') ?? '0';
      final val = double.tryParse(qStr) ?? 0.0;
      total += val;
    }
    return formatQuantity(total.toString());
  }

  Widget _buildSelectorTile({
    required String label,
    required String value,
    required bool isEmpty,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: AppFontSize.label,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 6),
        Material(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onTap,
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: AppFontSize.value,
                        fontWeight:
                            isEmpty ? FontWeight.normal : FontWeight.w600,
                        color: isEmpty
                            ? Colors.grey.shade400
                            : const Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScannerField({
    required String label,
    required String placeholder,
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isScanning,
    required VoidCallback onStartScan,
    VoidCallback? onCancelScan,
    required VoidCallback onManualPick,
    required Function(String) onSubmitted,
    VoidCallback? onTapField,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: AppFontSize.label,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            if (isScanning)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onCancelScan,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.only(
                        left: 8, right: 4, top: 2, bottom: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: Colors.green.shade400, width: 0.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.green.shade700,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Ready to Scan',
                          style: TextStyle(
                            fontSize: AppFontSize.badge,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade800,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color:
                                Colors.green.shade800.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.close_rounded,
                            size: 11,
                            color: Colors.green.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isScanning
                        ? Colors.green.shade600
                        : Colors.grey.shade300,
                    width: isScanning ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        keyboardType: TextInputType.none,
                        style: TextStyle(
                          fontSize: AppFontSize.input,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0F172A),
                        ),
                        onTap: onTapField,
                        onFieldSubmitted: onSubmitted,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                          hintText: placeholder,
                          hintStyle: TextStyle(
                            fontSize: AppFontSize.hint,
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.normal,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: onManualPick,
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: PRIMARY_COLOR,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: isScanning
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: isScanning ? (onCancelScan ?? onStartScan) : onStartScan,
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isScanning
                          ? Colors.green.shade600
                          : Colors.grey.shade300,
                      width: isScanning ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.qr_code_scanner_rounded,
                        color:
                            isScanning ? Colors.green.shade700 : PRIMARY_COLOR,
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuantityAndUomRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quantity
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quantity',
                style: TextStyle(
                  fontSize: AppFontSize.label,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: quantity,
                        focusNode: _quantity,
                        readOnly: isSerialOrBatch,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [ThousandsSeparatorInputFormatter()],
                        style: TextStyle(
                          fontSize: AppFontSize.input,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0F172A),
                        ),
                        onTap: isSerialOrBatch
                            ? () => onNavigateSerialOrBatch(force: true)
                            : null,
                        onEditingComplete: onCompleteQuantiyInput,
                        onFieldSubmitted: (value) =>
                            _handleScanSubmitted(value, _quantity),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                          hintText: '0.00',
                          hintStyle: TextStyle(
                              fontSize: AppFontSize.hint,
                              color: Colors.grey.shade400),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                    if (isSerialOrBatch)
                      InkWell(
                        onTap: () => onNavigateSerialOrBatch(force: true),
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: PRIMARY_COLOR.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.format_list_bulleted_rounded,
                                  size: 14, color: PRIMARY_COLOR),
                              const SizedBox(width: 4),
                              Text(
                                'Manage',
                                style: TextStyle(
                                  fontSize: AppFontSize.badgeSmall,
                                  fontWeight: FontWeight.w600,
                                  color: PRIMARY_COLOR,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),

        // UoM
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Unit of Measure',
                style: TextStyle(
                  fontSize: AppFontSize.label,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 6),
              Material(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: onChangeUoM,
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            uom.text.isEmpty
                                ? 'Select UoM'
                                : (uomName.text.isNotEmpty
                                    ? uomName.text
                                    : uom.text),
                            style: TextStyle(
                              fontSize: AppFontSize.value,
                              fontWeight: uom.text.isEmpty
                                  ? FontWeight.normal
                                  : FontWeight.w600,
                              color: uom.text.isEmpty
                                  ? Colors.grey.shade400
                                  : const Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: Colors.grey.shade400,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void onHeaderDimensionChange(int dimCode, String code, String name) {
    setState(() {
      _headerCostingCodes[dimCode]?.text = code;
      _headerCostingCodeNames[dimCode]?.text = name;

      // Update all existing items in items list based on header
      final key = dimCode == 1 ? 'CostingCode' : 'CostingCode$dimCode';
      final nameKey =
          dimCode == 1 ? 'CostingCodeName' : 'CostingCode${dimCode}Name';
      for (var item in items) {
        item[key] = code;
        item[nameKey] = name;
      }
    });
  }

  Widget _buildHeaderDimensionTile(Map<String, dynamic> dim) {
    final dimCode = int.tryParse(dim['DimensionCode']?.toString() ?? '') ?? 0;
    if (dimCode < 1 || dimCode > 5) return const SizedBox.shrink();

    final dimName =
        (dim['DimensionDescription']?.toString().trim().isNotEmpty ?? false)
            ? dim['DimensionDescription'].toString()
            : ((dim['DimensionName']?.toString().trim().isNotEmpty ?? false)
                ? dim['DimensionName'].toString()
                : 'Dimension $dimCode');
    final selectedCode = _headerCostingCodes[dimCode]?.text ?? '';
    String selectedName = _headerCostingCodeNames[dimCode]?.text ?? '';
    if (selectedName.isEmpty && selectedCode.isNotEmpty) {
      final rules = (dim['rules'] as List<dynamic>?) ?? [];
      final matchedRule = rules.firstWhere(
        (r) => r['FactorCode']?.toString() == selectedCode,
        orElse: () => null,
      );
      if (matchedRule != null) {
        selectedName = matchedRule['FactorDescription']?.toString() ?? '';
        _headerCostingCodeNames[dimCode]?.text = selectedName;
      }
    }

    String displayText = 'Select $dimName';
    final bool isEmpty = selectedCode.isEmpty;
    if (!isEmpty) {
      displayText = selectedName.isNotEmpty ? selectedName : selectedCode;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dimName,
            style: TextStyle(
              fontSize: AppFontSize.label,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 6),
          Material(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => _openHeaderDimensionPicker(dim),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        displayText,
                        style: TextStyle(
                          fontSize: AppFontSize.value,
                          fontWeight:
                              isEmpty ? FontWeight.normal : FontWeight.w600,
                          color: isEmpty
                              ? Colors.grey.shade400
                              : const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineDimensionTile(Map<String, dynamic> dim) {
    final dimCode = int.tryParse(dim['DimensionCode']?.toString() ?? '') ?? 0;
    if (dimCode < 1 || dimCode > 5) return const SizedBox.shrink();

    final dimName =
        (dim['DimensionDescription']?.toString().trim().isNotEmpty ?? false)
            ? dim['DimensionDescription'].toString()
            : ((dim['DimensionName']?.toString().trim().isNotEmpty ?? false)
                ? dim['DimensionName'].toString()
                : 'Dimension $dimCode');
    final selectedCode = _lineCostingCodes[dimCode]?.text ?? '';
    String selectedName = _lineCostingCodeNames[dimCode]?.text ?? '';
    if (selectedName.isEmpty && selectedCode.isNotEmpty) {
      final rules = (dim['rules'] as List<dynamic>?) ?? [];
      final matchedRule = rules.firstWhere(
        (r) => r['FactorCode']?.toString() == selectedCode,
        orElse: () => null,
      );
      if (matchedRule != null) {
        selectedName = matchedRule['FactorDescription']?.toString() ?? '';
        _lineCostingCodeNames[dimCode]?.text = selectedName;
      }
    }

    String displayText = 'Select $dimName';
    final bool isEmpty = selectedCode.isEmpty;
    if (!isEmpty) {
      displayText = selectedName.isNotEmpty ? selectedName : selectedCode;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dimName,
            style: TextStyle(
              fontSize: AppFontSize.label,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 6),
          Material(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => _openLineDimensionPicker(dim),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        displayText,
                        style: TextStyle(
                          fontSize: AppFontSize.value,
                          fontWeight:
                              isEmpty ? FontWeight.normal : FontWeight.w600,
                          color: isEmpty
                              ? Colors.grey.shade400
                              : const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openHeaderDimensionPicker(Map<String, dynamic> dim) {
    final dimCode = int.tryParse(dim['DimensionCode']?.toString() ?? '') ?? 0;
    _openDimensionPicker(
      dim: dim,
      currentCode: _headerCostingCodes[dimCode]?.text ?? '',
      subtitle: 'Document Header (applies to all line items)',
      onSelect: (code, desc) {
        onHeaderDimensionChange(dimCode, code, desc);
      },
    );
  }

  void _openLineDimensionPicker(Map<String, dynamic> dim) {
    final dimCode = int.tryParse(dim['DimensionCode']?.toString() ?? '') ?? 0;
    _openDimensionPicker(
      dim: dim,
      currentCode: _lineCostingCodes[dimCode]?.text ?? '',
      subtitle:
          'Line Item (${itemCode.text.isNotEmpty ? itemCode.text : "Editing Row #${isEdit + 1}"})',
      onSelect: (code, desc) {
        setState(() {
          _lineCostingCodes[dimCode]?.text = code;
          _lineCostingCodeNames[dimCode]?.text = desc;
        });
      },
    );
  }

  void _openGenericPickerModal<T>({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<T> items,
    required String currentCode,
    required String Function(T item) getCode,
    required String Function(T item) getName,
    String Function(T item)? getExtraInfo,
    bool showCode = true,
    bool allowClear = false,
    String clearLabel = 'None (Blank / Unselect)',
    required void Function(T? selectedItem) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomCtx) {
        String query = '';
        final searchCtrl = TextEditingController();

        return StatefulBuilder(
          builder: (context, setModalState) {
            final q = query.trim().toLowerCase();
            final filteredList = items.where((item) {
              if (q.isEmpty) return true;
              final code = getCode(item).toLowerCase();
              final name = getName(item).toLowerCase();
              final extra =
                  getExtraInfo != null ? getExtraInfo(item).toLowerCase() : '';
              return code.contains(q) || name.contains(q) || extra.contains(q);
            }).toList();

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(bottomCtx).viewInsets.bottom,
              ),
              child: Material(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  height: MediaQuery.of(bottomCtx).size.height * 0.75,
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 10, bottom: 8),
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: PRIMARY_COLOR.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                icon,
                                size: 20,
                                color: PRIMARY_COLOR,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: TextStyle(
                                      fontSize: AppFontSize.dialogTitle,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                  if (subtitle.isNotEmpty)
                                    Text(
                                      subtitle,
                                      style: TextStyle(
                                        fontSize: AppFontSize.md,
                                        color: Colors.grey.shade600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, size: 20),
                              color: Colors.grey.shade600,
                              onPressed: () => Navigator.of(bottomCtx).pop(),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextField(
                            controller: searchCtrl,
                            onChanged: (val) {
                              setModalState(() {
                                query = val;
                              });
                            },
                            style: TextStyle(fontSize: AppFontSize.input),
                            decoration: InputDecoration(
                              hintText: 'Search by code or description...',
                              hintStyle: TextStyle(
                                  fontSize: AppFontSize.hint,
                                  color: Colors.grey.shade500),
                              prefixIcon: Icon(Icons.search_rounded,
                                  size: 20, color: Colors.grey.shade500),
                              suffixIcon: query.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear_rounded,
                                          size: 18),
                                      onPressed: () {
                                        searchCtrl.clear();
                                        setModalState(() {
                                          query = '';
                                        });
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Divider(height: 1, thickness: 0.5),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          children: [
                            if (allowClear &&
                                (q.isEmpty ||
                                    'none'.contains(q) ||
                                    'blank'.contains(q) ||
                                    'clear'.contains(q))) ...[
                              ListTile(
                                dense: true,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                tileColor: currentCode.isEmpty
                                    ? PRIMARY_COLOR.withValues(alpha: 0.06)
                                    : null,
                                leading: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: currentCode.isEmpty
                                        ? PRIMARY_COLOR
                                        : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    Icons.block_rounded,
                                    size: 16,
                                    color: currentCode.isEmpty
                                        ? Colors.white
                                        : Colors.grey.shade500,
                                  ),
                                ),
                                title: Text(
                                  clearLabel,
                                  style: TextStyle(
                                    fontSize: AppFontSize.value,
                                    fontWeight: currentCode.isEmpty
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: currentCode.isEmpty
                                        ? PRIMARY_COLOR
                                        : const Color(0xFF334155),
                                  ),
                                ),
                                trailing: currentCode.isEmpty
                                    ? const Icon(Icons.check_circle_rounded,
                                        color: PRIMARY_COLOR, size: 20)
                                    : null,
                                onTap: () {
                                  onSelected(null);
                                  Navigator.of(bottomCtx).pop();
                                  _unfocusAll();
                                },
                              ),
                              const Divider(height: 8, thickness: 0.5),
                            ],
                            if (filteredList.isEmpty)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 40),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(Icons.search_off_rounded,
                                          size: 40,
                                          color: Colors.grey.shade300),
                                      const SizedBox(height: 8),
                                      Text(
                                        q.isEmpty
                                            ? 'No items found'
                                            : 'No items matching "$query"',
                                        style: TextStyle(
                                            fontSize: AppFontSize.label,
                                            color: Colors.grey.shade500),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              ...filteredList.map((item) {
                                final code = getCode(item);
                                final name = getName(item);
                                final extra = getExtraInfo != null
                                    ? getExtraInfo(item)
                                    : '';
                                final isSelected = currentCode.isNotEmpty &&
                                    currentCode == code;

                                return ListTile(
                                  dense: true,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  tileColor: isSelected
                                      ? PRIMARY_COLOR.withValues(alpha: 0.06)
                                      : null,
                                  leading: showCode && code.isNotEmpty
                                      ? Container(
                                          constraints: const BoxConstraints(
                                              maxWidth: 90),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? PRIMARY_COLOR
                                                : const Color(0xFFF1F5F9),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            code,
                                            style: TextStyle(
                                              fontSize: AppFontSize.badge,
                                              fontWeight: FontWeight.bold,
                                              color: isSelected
                                                  ? Colors.white
                                                  : const Color(0xFF1E293B),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        )
                                      : null,
                                  title: Text(
                                    name.isNotEmpty ? name : code,
                                    style: TextStyle(
                                      fontSize: AppFontSize.value,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? PRIMARY_COLOR
                                          : const Color(0xFF0F172A),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: extra.isNotEmpty
                                      ? Text(
                                          extra,
                                          style: TextStyle(
                                            fontSize: AppFontSize.md,
                                            color: const Color(0xFF64748B),
                                          ),
                                        )
                                      : null,
                                  trailing: isSelected
                                      ? const Icon(Icons.check_circle_rounded,
                                          color: PRIMARY_COLOR, size: 20)
                                      : null,
                                  onTap: () {
                                    onSelected(item);
                                    Navigator.of(bottomCtx).pop();
                                    _unfocusAll();
                                  },
                                );
                              }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openDimensionPicker({
    required Map<String, dynamic> dim,
    required String currentCode,
    required String subtitle,
    required void Function(String code, String desc) onSelect,
  }) {
    final dimCode = int.tryParse(dim['DimensionCode']?.toString() ?? '') ?? 0;
    final dimName =
        (dim['DimensionDescription']?.toString().trim().isNotEmpty ?? false)
            ? dim['DimensionDescription'].toString()
            : ((dim['DimensionName']?.toString().trim().isNotEmpty ?? false)
                ? dim['DimensionName'].toString()
                : 'Dimension $dimCode');
    final rules = (dim['rules'] as List<dynamic>?) ?? [];

    _openGenericPickerModal<dynamic>(
      title: 'Select $dimName',
      subtitle: subtitle,
      icon: Icons.account_tree_outlined,
      items: rules,
      currentCode: currentCode,
      getCode: (rule) => getDataFromDynamic(rule['FactorCode']),
      getName: (rule) => getDataFromDynamic(rule['FactorDescription']),
      showCode: true,
      allowClear: true,
      clearLabel: 'None (Blank / Unselect)',
      onSelected: (item) {
        if (item == null) {
          onSelect('', '');
        } else {
          onSelect(
            getDataFromDynamic(item['FactorCode']),
            getDataFromDynamic(item['FactorDescription']),
          );
        }
      },
    );
  }

  Widget _buildRemarkField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Remark',
          style: TextStyle(
            fontSize: AppFontSize.label,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextFormField(
            controller: remark,
            maxLines: 3,
            minLines: 3,
            keyboardType: TextInputType.multiline,
            style: TextStyle(
              fontSize: AppFontSize.input,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              hintText: 'Enter remark...',
              hintStyle: TextStyle(
                fontSize: AppFontSize.hint,
                color: Colors.grey.shade400,
                fontWeight: FontWeight.normal,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemActionButtons() {
    if (isEdit == -1) {
      return SizedBox(
        width: double.infinity,
        height: 46,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: PRIMARY_COLOR,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: onAddItem,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_rounded, size: 20),
              const SizedBox(width: 6),
              Text(
                'Add Item',
                style: TextStyle(
                  fontSize: AppFontSize.button,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: SizedBox(
            height: 46,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: PRIMARY_COLOR,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: onAddItem,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_rounded, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Update Item',
                    style: TextStyle(
                      fontSize: AppFontSize.button,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 46,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF64748B),
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                _unfocusAll();
                setState(() {
                  clear();
                  isSerialOrBatch = false;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.close_rounded, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: AppFontSize.buttonSmall,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRenderTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: PRIMARY_COLOR.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: PRIMARY_COLOR.withValues(alpha: 0.15),
                          width: 0.8,
                        ),
                      ),
                      child: const Icon(
                        Icons.table_chart_outlined,
                        size: 18,
                        color: PRIMARY_COLOR,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Receipt Items',
                      style: TextStyle(
                        fontSize: AppFontSize.sectionTitle,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: PRIMARY_COLOR.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${items.length}',
                        style: TextStyle(
                          fontSize: AppFontSize.badge,
                          fontWeight: FontWeight.w700,
                          color: PRIMARY_COLOR,
                        ),
                      ),
                    ),
                  ],
                ),
                if (items.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      'Total Qty: ${_calculateTotalQuantity()}',
                      style: TextStyle(
                        fontSize: AppFontSize.badge,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(
            height: 1,
            thickness: 0.8,
            color: Color(0xFFE2E8F0),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isPhone = constraints.maxWidth < 600;
                final content = Column(
                  children: [
                    ContentHeader(isPhone: isPhone, hideOpenQty: false),
                    if (items.isEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 36, horizontal: 20),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Icon(
                            //   Icons.inventory_2_outlined,
                            //   size: 44,
                            //   color: Colors.grey.shade400,
                            // ),
                            // const SizedBox(height: 10),
                            Text(
                              "No Items Added Yet",
                              style: TextStyle(
                                fontSize: AppFontSize.sectionTitle,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Scan or select an item above to add to this goods receipt",
                              style: TextStyle(
                                fontSize: AppFontSize.md,
                                color: Colors.grey.shade500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else
                      ...items.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return Column(
                          children: [
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _showItemActionDialog(item, index),
                                child: ItemRow(
                                  item: item,
                                  index: index,
                                  hideOpenQty: false,
                                  isPhone: isPhone,
                                  isBeingEdited: isEdit == index,
                                ),
                              ),
                            ),
                            if (index < items.length - 1)
                              Divider(
                                height: 1,
                                thickness: 0.5,
                                color: Colors.grey.shade200,
                              ),
                          ],
                        );
                      }).toList(),
                  ],
                );

                if (isPhone) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: content,
                  );
                }
                return content;
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (isReview) {
                setState(() {
                  isReview = false;
                });
              } else {
                Navigator.of(context).pop();
              }
            }),
        backgroundColor: PRIMARY_COLOR,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          '${widget.isEdit != null ? 'Edit' : 'Create'} Return Receipt',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: AppFontSize.appBarTitle,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.white.withValues(alpha: 0.15),
            height: 1,
          ),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _unfocusAll,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!isReview) ...[
                // Card 1: Document Header Card
                AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeInOutCubic,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isHeaderCollapsed
                          ? const Color(0xFFCBD5E1)
                          : const Color(0xFFE2E8F0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                            alpha: _isHeaderCollapsed ? 0.02 : 0.03),
                        blurRadius: _isHeaderCollapsed ? 4 : 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: _isHeaderCollapsed ? 10 : 14,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isHeaderCollapsed = !_isHeaderCollapsed;
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: PRIMARY_COLOR.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color:
                                        PRIMARY_COLOR.withValues(alpha: 0.15),
                                    width: 0.8,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.receipt_long_rounded,
                                  size: 18,
                                  color: PRIMARY_COLOR,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                  child: Text(
                                'General Information',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: AppFontSize.cardTitle,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0F172A),
                                  letterSpacing: 0.2,
                                ),
                              )),
                              AnimatedRotation(
                                turns: _isHeaderCollapsed ? 0.0 : 0.5,
                                duration: const Duration(milliseconds: 280),
                                curve: Curves.easeInOutCubic,
                                child: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Color(0xFF64748B),
                                  size: 22,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      AnimatedCrossFade(
                        firstChild:
                            const SizedBox(width: double.infinity, height: 0),
                        secondChild: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            const Divider(
                              height: 1,
                              thickness: 0.8,
                              color: Color(0xFFE2E8F0),
                            ),
                            const SizedBox(height: 12),
                            _buildSelectorTile(
                                label: 'RTR No.',
                                value: rtrText.text.isEmpty
                                    ? 'Select Return Receipt Request'
                                    : rtrText.text,
                                isEmpty: rtrText.text.isEmpty,
                                icon: Icons.receipt_long_outlined,
                                onTap: onNavigateToReturnReceiptRequest),
                            const SizedBox(height: 10),
                            _buildSelectorTile(
                                label: 'Customer',
                                value: cardName.text.isEmpty
                                    ? 'Select a return request first'
                                    : '${cardCode.text} - ${cardName.text}',
                                isEmpty: cardCode.text.isEmpty,
                                icon: Icons.business_outlined,
                                onTap: () {}),
                            const SizedBox(height: 10),
                            _buildSelectorTile(
                              label: 'Warehouse',
                              value: warehouseNameUI.text.isEmpty
                                  ? 'Select Warehouse'
                                  : warehouseNameUI.text,
                              isEmpty: warehouseNameUI.text.isEmpty,
                              icon: Icons.warehouse_outlined,
                              onTap: onChangeWhs,
                            ),
                            if (isEdit == -1 &&
                                activeDimensions.isNotEmpty) ...[
                              ...activeDimensions
                                  .map((dim) => _buildHeaderDimensionTile(dim)),
                            ],
                          ],
                        ),
                        crossFadeState: _isHeaderCollapsed
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                        duration: const Duration(milliseconds: 280),
                        sizeCurve: Curves.easeInOutCubic,
                        firstCurve: Curves.easeInOutCubic,
                        secondCurve: Curves.easeInOutCubic,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Card 2: Item Entry & Scanner Card
                AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeInOutCubic,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isEdit != -1
                          ? Colors.amber.shade400
                          : (_isLineItemCollapsed
                              ? const Color(0xFFCBD5E1)
                              : const Color(0xFFE2E8F0)),
                      width: isEdit != -1 ? 1.5 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                            alpha: isEdit != -1
                                ? 0.05
                                : (_isLineItemCollapsed ? 0.02 : 0.03)),
                        blurRadius: isEdit != -1 ? 8 : 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: _isLineItemCollapsed ? 10 : 14,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isLineItemCollapsed = !_isLineItemCollapsed;
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: isEdit != -1
                                          ? Colors.amber.shade100
                                          : PRIMARY_COLOR.withValues(
                                              alpha: 0.08),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isEdit != -1
                                            ? Colors.amber.shade400
                                            : PRIMARY_COLOR.withValues(
                                                alpha: 0.15),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Icon(
                                      isEdit != -1
                                          ? Icons.edit_note_rounded
                                          : Icons.playlist_add_rounded,
                                      size: 18,
                                      color: isEdit != -1
                                          ? Colors.amber.shade900
                                          : PRIMARY_COLOR,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    isEdit != -1
                                        ? 'Edit Line Item'
                                        : 'Line Item',
                                    style: TextStyle(
                                      fontSize: AppFontSize.cardTitle,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF0F172A),
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    child: isEdit != -1
                                        ? Container(
                                            key: const ValueKey('edit_badge'),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: Colors.amber.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  color: Colors.amber.shade400),
                                            ),
                                            child: Text(
                                              'Editing Row #${isEdit + 1}',
                                              style: TextStyle(
                                                fontSize: AppFontSize.badge,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.amber.shade900,
                                              ),
                                            ),
                                          )
                                        : (_isLineItemCollapsed &&
                                                itemCode.text.isNotEmpty)
                                            ? Container(
                                                key:
                                                    const ValueKey('item_chip'),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 2.5),
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFFF1F5F9),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  border: Border.all(
                                                      color: const Color(
                                                          0xFFE2E8F0)),
                                                ),
                                                child: Text(
                                                  itemCode.text,
                                                  style: TextStyle(
                                                    fontSize: AppFontSize.badge,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        const Color(0xFF475569),
                                                  ),
                                                ),
                                              )
                                            : const SizedBox.shrink(
                                                key: ValueKey('none')),
                                  ),
                                  const SizedBox(width: 6),
                                  AnimatedRotation(
                                    turns: _isLineItemCollapsed ? 0.0 : 0.5,
                                    duration: const Duration(milliseconds: 280),
                                    curve: Curves.easeInOutCubic,
                                    child: const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: Color(0xFF64748B),
                                      size: 22,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      AnimatedCrossFade(
                        firstChild:
                            const SizedBox(width: double.infinity, height: 0),
                        secondChild: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            const Divider(
                              height: 1,
                              thickness: 0.8,
                              color: Color(0xFFE2E8F0),
                            ),
                            const SizedBox(height: 12),

                            // Bin Location
                            _buildScannerField(
                              label: 'Bin Location',
                              placeholder: 'Choose or scan bin location',
                              controller: binCode,
                              focusNode: _bin,
                              isScanning: isClickScanBin,
                              onStartScan: () {
                                setState(() {
                                  isClickScanBin = true;
                                  isClickScanItem = false;
                                  binCode.clear();
                                  binId.clear();
                                });
                                FocusScope.of(context).unfocus();
                                Future.delayed(
                                    const Duration(milliseconds: 100), () {
                                  _requestFocus(_bin);
                                });
                              },
                              onCancelScan: () {
                                setState(() {
                                  isClickScanBin = false;
                                });
                                FocusScope.of(context).unfocus();
                              },
                              onManualPick: onChangeBin,
                              onSubmitted: (value) {
                                _handleScanSubmitted(value, _bin);
                              },
                              onTapField: () {
                                setState(() {
                                  isClickScanBin = false;
                                });
                                FocusScope.of(context).unfocus();
                              },
                            ),
                            const SizedBox(height: 12),

                            // Item Code
                            _buildScannerField(
                              label: 'Item Code',
                              placeholder: 'Select or scan item code',
                              controller: itemCode,
                              focusNode: _itemCode,
                              isScanning: isClickScanItem,
                              onStartScan: () {
                                setState(() {
                                  isClickScanItem = true;
                                  isClickScanBin = false;
                                  itemCode.clear();
                                });
                                FocusScope.of(context).unfocus();
                                Future.delayed(
                                    const Duration(milliseconds: 100), () {
                                  _requestFocus(_itemCode);
                                });
                              },
                              onCancelScan: () {
                                setState(() {
                                  isClickScanItem = false;
                                });
                                FocusScope.of(context).unfocus();
                              },
                              onManualPick: onSelectItem,
                              onSubmitted: (value) {
                                _handleScanSubmitted(value, _itemCode);
                              },
                              onTapField: () {
                                setState(() {
                                  isClickScanItem = false;
                                });
                                FocusScope.of(context).unfocus();
                              },
                            ),

                            const SizedBox(height: 12),

                            // Quantity & UoM
                            _buildQuantityAndUomRow(),
                            const SizedBox(height: 12),

                            // Account
                            if (isEdit != -1) ...[
                              _buildSelectorTile(
                                  label: 'Available Quantity',
                                  value: totalQuantity.text,
                                  isEmpty: totalQuantity.text.isEmpty,
                                  icon: Icons.inventory_outlined,
                                  onTap: () {}),
                              const SizedBox(height: 12),
                            ],
                            if (isEdit != -1 &&
                                activeDimensions.isNotEmpty) ...[
                              ...activeDimensions
                                  .map((dim) => _buildLineDimensionTile(dim)),
                            ],
                            const SizedBox(height: 12),

                            // Remark
                            _buildRemarkField(),
                            const SizedBox(height: 16),

                            // Add / Update item action buttons
                            _buildItemActionButtons(),
                          ],
                        ),
                        crossFadeState: _isLineItemCollapsed
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                        duration: const Duration(milliseconds: 280),
                        sizeCurve: Curves.easeInOutCubic,
                        firstCurve: Curves.easeInOutCubic,
                        secondCurve: Curves.easeInOutCubic,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],
              // Card 3: Render Table Card
              _buildRenderTable(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Button(
                variant: ButtonVariant.primary,
                bgColor: PRIMARY_COLOR,
                disabled: isEdit != -1 || items.isEmpty,
                onPressed: onPostToSAP,
                child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cloud_upload_outlined,
                            size: 20, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          items.isNotEmpty ? 'Save (${items.length})' : 'Save',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: AppFontSize.button,
                          ),
                        ),
                      ],
                    )),
              ),
            ),
            ...[
              const SizedBox(width: 12),
              Expanded(
                  child: Button(
                disabled: isEdit != -1 || items.isEmpty,
                onPressed: () {
                  _unfocusAll();
                  setState(() {
                    isReview = !isReview;
                  });
                },
                child: Text(isReview ? 'Back to Form' : 'Review',
                    style: TextStyle(
                        color: Colors.white, fontSize: AppFontSize.button)),
              )),
            ],
            const SizedBox(width: 12),
            Expanded(
              child: Button(
                variant: ButtonVariant.outline,
                onPressed: () {
                  if (items.isNotEmpty) {
                    MaterialDialog.warning(
                      context,
                      title: 'Warning',
                      body:
                          'Are you sure you want to leave? Once you leave, unsaved data will be erased.',
                      confirmLabel: 'Leave',
                      cancelLabel: 'Stay',
                      onConfirm: () {
                        Navigator.of(context).pop();
                      },
                      onCancel: () {},
                    );
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.close_rounded,
                            size: 18, color: PRIMARY_COLOR),
                        const SizedBox(width: 6),
                        Text(
                          'Cancel',
                          style: TextStyle(
                            color: PRIMARY_COLOR,
                            fontWeight: FontWeight.w600,
                            fontSize: AppFontSize.button,
                          ),
                        ),
                      ],
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ContentHeader extends StatelessWidget {
  const ContentHeader(
      {super.key, this.hideOpenQty = true, this.isPhone = false});
  final dynamic hideOpenQty;
  final bool isPhone;

  Widget _buildColumn(Widget child, int flex, double fixedWidth,
      {Alignment alignment = Alignment.center}) {
    if (isPhone) {
      return Container(
        width: fixedWidth,
        alignment: alignment,
        child: child,
      );
    }
    return Expanded(
      flex: flex,
      child: Container(
        alignment: alignment,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w700,
      fontSize: AppFontSize.tableHeader,
      letterSpacing: 0.3,
    );

    return Container(
      decoration: const BoxDecoration(
        color: PRIMARY_COLOR,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
      child: Row(
        children: [
          _buildColumn(
            Text('#', style: textStyle),
            1,
            34,
            alignment: Alignment.center,
          ),
          const SizedBox(width: 8),
          _buildColumn(
            Text('Item No / Description', style: textStyle),
            6,
            200,
            alignment: Alignment.centerLeft,
          ),
          _buildColumn(
            Text('UoM', style: textStyle),
            2,
            70,
            alignment: Alignment.center,
          ),
          _buildColumn(
            Text('QTY Received', style: textStyle),
            3,
            110,
            alignment: Alignment.centerRight,
          ),
          if (!hideOpenQty)
            _buildColumn(Text('Open QTY', style: textStyle), 3, 100,
                alignment: Alignment.centerRight),
        ],
      ),
    );
  }
}

class ItemRow extends StatelessWidget {
  const ItemRow({
    super.key,
    required this.item,
    required this.index,
    this.po,
    this.hideOpenQty = true,
    this.isPhone = false,
    this.isBeingEdited = false,
  });

  final dynamic po;
  final dynamic item;
  final dynamic hideOpenQty;
  final int index;
  final bool isPhone;
  final bool isBeingEdited;

  String getDataFromDynamic(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  Widget _buildColumn(Widget child, int flex, double fixedWidth,
      {Alignment alignment = Alignment.center}) {
    if (isPhone) {
      return Container(
        width: fixedWidth,
        alignment: alignment,
        child: child,
      );
    }
    return Expanded(
      flex: flex,
      child: Container(
        alignment: alignment,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemCodeStr = getDataFromDynamic(item['ItemCode']);
    final itemDescStr = getDataFromDynamic(item['ItemDescription']);
    final uomStr = getDataFromDynamic(item['UoMCode']);
    final qtyStr = formatQuantity(getDataFromDynamic(item['Quantity']));
    final isBatch = getDataFromDynamic(item['ManageBatchNumbers']) == 'tYES';
    final isSerial = getDataFromDynamic(item['ManageSerialNumbers']) == 'tYES';

    final isEven = index % 2 == 0;
    final rowBgColor = isBeingEdited
        ? const Color(0xFFFFFBEB)
        : (isEven ? Colors.white : const Color(0xFFF8FAFC));

    return Container(
      color: rowBgColor,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Index Badge
          _buildColumn(
            Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isBeingEdited
                    ? Colors.amber.shade200
                    : const Color(0xFFE2E8F0),
                shape: BoxShape.circle,
              ),
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontSize: AppFontSize.badge,
                  fontWeight: FontWeight.w700,
                  color: isBeingEdited
                      ? Colors.amber.shade900
                      : const Color(0xFF475569),
                ),
              ),
            ),
            1,
            34,
            alignment: Alignment.center,
          ),
          const SizedBox(width: 8),

          // Item Code & Description
          _buildColumn(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  itemCodeStr.isEmpty ? '-' : itemCodeStr,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: AppFontSize.tableItemTitle,
                    color: const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (itemDescStr.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    itemDescStr,
                    style: TextStyle(
                      color: const Color(0xFF64748B),
                      fontSize: AppFontSize.tableItemDesc,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (isBatch || isSerial) ...[
                  const SizedBox(height: 3),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isBatch)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                                color: Colors.blue.shade200, width: 0.5),
                          ),
                          child: Text(
                            'BATCH',
                            style: TextStyle(
                              fontSize: AppFontSize.badgeSmall,
                              fontWeight: FontWeight.w700,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ),
                      if (isSerial) ...[
                        if (isBatch) const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                                color: Colors.purple.shade200, width: 0.5),
                          ),
                          child: Text(
                            'SERIAL',
                            style: TextStyle(
                              fontSize: AppFontSize.badgeSmall,
                              fontWeight: FontWeight.w700,
                              color: Colors.purple.shade800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
            6,
            200,
            alignment: Alignment.centerLeft,
          ),

          // UoM
          _buildColumn(
            Text(
              uomStr.isEmpty ? '-' : uomStr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppFontSize.tableCell,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF334155),
              ),
            ),
            2,
            70,
            alignment: Alignment.center,
          ),

          // Quantity Received
          _buildColumn(
            Text(
              qtyStr.isEmpty ? '0' : qtyStr,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: AppFontSize.tableCell,
                fontWeight: FontWeight.w700,
                color: PRIMARY_COLOR,
              ),
            ),
            3,
            110,
            alignment: Alignment.centerRight,
          ),
          if (!hideOpenQty)
            _buildColumn(
                Text(formatQuantity(_openQuantity(item).toString()),
                    style: TextStyle(fontSize: AppFontSize.tableCell),
                    textAlign: TextAlign.right),
                3,
                100,
                alignment: Alignment.centerRight),
        ],
      ),
    );
  }

  double _openQuantity(dynamic row) {
    final total = double.tryParse(row['TotalQuantity'].toString()) ?? 0;
    final received = double.tryParse(row['Quantity'].toString()) ?? 0;
    return (total - received).clamp(0, double.infinity).toDouble();
  }
}
