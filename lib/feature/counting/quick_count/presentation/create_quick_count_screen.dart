import '../../component/counting_table.dart';
import 'package:wms_mobile/feature/warehouse/presentation/cubit/warhouse_offline_cubit.dart';
import 'package:wms_mobile/feature/unit_of_measurement/presentation/cubit/uom_offline_cubit.dart';
import 'package:hive/hive.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:wms_mobile/feature/bin_location/presentation/cubit/bin_offline_cubit.dart';
import 'package:wms_mobile/feature/counting/quick_count/presentation/cubit/cycle_count_failed_offline_cubit.dart';
import 'package:wms_mobile/feature/counting/quick_count/presentation/cubit/cycle_count_offline_cubit.dart';
import 'package:wms_mobile/feature/counting/quick_count/presentation/cubit/quick_count_failed_offline_cubit.dart';
import 'package:wms_mobile/feature/counting/quick_count/presentation/cubit/quick_count_offline_cubit.dart';
import 'package:wms_mobile/feature/inbound/good_receipt_po/presentation/duplicateItem_GPO_Screen.dart';
import 'package:wms_mobile/feature/item/presentation/cubit/items_barcode_offline_cubit.dart';
import 'package:wms_mobile/feature/item/presentation/cubit/items_cycle_count_offline_cubit.dart';
import 'package:wms_mobile/feature/item/presentation/cubit/items_find_stock_offline_cubit.dart';
import 'package:wms_mobile/feature/item/presentation/cubit/items_offline_cubit.dart';
import 'package:wms_mobile/feature/item_by_code/presentation/screen/item_page.dart';
import 'package:wms_mobile/feature/unit_of_measurement/presentation/cubit/uom_group_offline_cubit.dart';
import 'package:wms_mobile/utilies/dio_client.dart';
import '../../good_receip_batch_screen.dart' show GoodReceiptBatchScreen;
import '../../good_receip_serial_screen.dart';
import '../../../../core/error/failure.dart';
import '/component/button/button.dart';
import '/core/enum/global.dart';
import '/feature/item/presentation/screen/item_page.dart';
import '/helper/helper.dart';
import '/utilies/dialog/dialog.dart';
import '/utilies/storage/locale_storage.dart';
import '../../../../constant/style.dart';
import 'cubit/quick_count_cubit.dart';

class CreateQuickCountScreen extends StatefulWidget {
  const CreateQuickCountScreen(
      {super.key,
      required this.isQuickCount,
      this.isEdit,
      this.isEditFaildCC,
      this.isEditFaildQC});
  final bool isQuickCount;
  final dynamic isEdit;
  final dynamic isEditFaildQC;
  final dynamic isEditFaildCC;
  @override
  State<CreateQuickCountScreen> createState() => _CreateQuickCountScreenState();
}

class _CreateQuickCountScreenState extends State<CreateQuickCountScreen> {
  final uomText = TextEditingController();
  final remark = TextEditingController();
  final quantity = TextEditingController();
  final ref = TextEditingController();
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
  final saveIdQC = TextEditingController();
  final saveIdCC = TextEditingController();
  final isBatch = TextEditingController();
  final isSerial = TextEditingController();
  final barCode = TextEditingController();
  final variance = TextEditingController();
  final inWhsQty = TextEditingController();

  final DioClient dio = DioClient();
  List<dynamic> itemCodeFilter = [];
  bool _isHeaderCollapsed = false;
  bool _isLineItemCollapsed = false;
  final ScrollController _scrollController = ScrollController();
  final uomName = TextEditingController();
  int isEdit = -1;
  bool isSerialOrBatch = false;
  List<dynamic> items = [];
  List<dynamic> binLists = [];
  bool loading = false;
  bool isClickScanItem = false;
  bool isClickScanBin = false;
  final FocusNode _itemCode = FocusNode();
  final FocusNode _quantity = FocusNode();
  final FocusNode _bin = FocusNode();
  final FocusNode _ref = FocusNode();
  late final QuickCountCubit _bloc = context.read<QuickCountCubit>();

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
    _loadDimensions();
    init();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fromEdit();
    });
  }

  @override
  void dispose() {
    uomText.dispose();
    remark.dispose();
    quantity.dispose();
    ref.dispose();
    warehouse.dispose();
    warehouseNameUI.dispose();
    uom.dispose();
    uomAbEntry.dispose();
    itemCode.dispose();
    itemName.dispose();
    baseUoM.dispose();
    uoMGroupDefinitionCollection.dispose();
    binId.dispose();
    binCode.dispose();
    serialsInput.dispose();
    batchesInput.dispose();
    docEntry.dispose();
    refLineNo.dispose();
    saveIdQC.dispose();
    saveIdCC.dispose();
    isBatch.dispose();
    isSerial.dispose();
    barCode.dispose();
    variance.dispose();
    inWhsQty.dispose();
    uomName.dispose();
    _scrollController.dispose();
    _itemCode.dispose();
    _quantity.dispose();
    _bin.dispose();
    _ref.dispose();
    for (final group in [
      _headerCostingCodes,
      _headerCostingCodeNames,
      _lineCostingCodes,
      _lineCostingCodeNames
    ]) {
      for (final controller in group.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  Future<void> _loadDimensions() async {
    try {
      final cachedMetaStr =
          await LocalStorageManger.getString('dimensions_meta');
      List<dynamic> cachedMeta = [];
      if (cachedMetaStr.isNotEmpty) {
        try {
          cachedMeta = jsonDecode(cachedMetaStr) as List<dynamic>;
        } catch (_) {}
      }

      final cachedStr = await LocalStorageManger.getString('dimension_v2');
      if (!mounted) return;
      if (cachedStr.isNotEmpty) {
        try {
          final decoded = jsonDecode(cachedStr) as List<dynamic>;
          if (decoded.isNotEmpty) {
            final list = List<Map<String, dynamic>>.from(
              decoded.map((e) => Map<String, dynamic>.from(e)),
            );

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
      debugPrint(widget.isEdit.toString());
      debugPrint('Restoring count');
      warehouse.text = getDataFromDynamic(
          widget.isEdit['InventoryPostingLines'].length > 0
              ? widget.isEdit['InventoryPostingLines'][0]["WarehouseCode"]
              : null);
      ref.text = getDataFromDynamic(widget.isEdit['Reference2']);
      remark.text = getDataFromDynamic(widget.isEdit['Remarks']);
      saveIdQC.text = getDataFromDynamic(widget.isEdit['SaveId']);
      saveIdCC.text = getDataFromDynamic(widget.isEdit['SaveId']);
      if (mounted) MaterialDialog.loading(context);

      final barcodeList = context.read<ItemBarcodeOfflineCubit>().state;
      final List<Map<String, dynamic>> rawItems = [];
      final List<dynamic> lines =
          (widget.isEdit['InventoryPostingLines'] as List?) ?? [];

      for (var element in lines) {
        final itemList = context.read<ItemOfflineCubit>().state;
        final binList = context.read<BinOfflineCubit>().state;
        final itemCode = getDataFromDynamic(element["ItemCode"]);
        final uomCode = getDataFromDynamic(element["UoMCode"]).toString();
        final itemStockCubit = context.read<ItemFindStockOfflineCubit>();

        final itemStockList = itemStockCubit.getJsonData();

        final filteredBin =
            binList.where((b) => b['Warehouse'] == warehouse.text).toList();
        dynamic whsQty;
        if (filteredBin.isEmpty) {
          final matchedItemStock = itemStockList.firstWhere(
            (item) =>
                item['ItemCode'] == element['ItemCode'] &&
                item['WhsCode'] == warehouse.text,
            orElse: () => {},
          );

          if (matchedItemStock.isNotEmpty) {
            final onHandQty = matchedItemStock['OnHandQty'] ?? 0;
            setState(() {
              whsQty = onHandQty.toString();
            });
          } else {
            setState(() {
              whsQty = "0";
            });
          }
        } else {
          final itemStockCubit = context.read<ItemFindStockOfflineCubit>();
          final stockData = itemStockCubit.getJsonData();

          final matched = stockData.firstWhere(
            (e) =>
                e['ItemCode'].toString().trim() == element["ItemCode"] &&
                e['WhsCode'].toString().trim() == warehouse.text &&
                e['BinID'].toString().trim() == element["BinEntry"],
            orElse: () => {},
          );

          if (matched.isNotEmpty) {
            final onHandQty = matched['OnHandQty'] ?? 0;
            setState(() {
              whsQty = onHandQty.toString();
            });
          } else {
            setState(() {
              whsQty = "0";
            });
            MaterialDialog.warning(
              context,
              title: "Not Found",
              body: "No offline stock found for this item in the selected bin.",
            );
          }
        }
        final matchedBarcode = barcodeList.firstWhere(
          (b) => b['ItemCode'] == itemCode && b['UomCode'] == uomCode,
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
        final binID = element["BinEntry"] ?? -1;

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
          "ItemCode": element['ItemCode'],
          "ItemDescription": element['ItemName'] ?? element['ItemDescription'],
          "Quantity": element['CountedQuantity'],
          "Variance": element["Variance"],
          "WarehouseCode": warehouse.text,
          "UoMEntry": getDataFromDynamic(
              element['UoMEntry'] ?? itemMapped['InventoryUoMEntry']),
          "UoMCode": element['UoMCode'],
          "UoMGroupDefinitionCollection":
              itemMapped['UoMGroupDefinitionCollection'],
          "BaseUoM": itemMapped['BaseUoM'],
          "BinEntry": element["BinEntry"],
          "BinCode": binCodeFind["BinCode"],
          "BaseLine": element['BaseLine'],
          "ManageSerialNumbers": itemMapped["ManageSerialNumbers"],
          "ManageBatchNumbers": itemMapped["ManageBatchNumbers"],
          "Serials": element["InventoryCountingSerialNumbers"] ??
              element["InventoryPostingSerialNumbers"] ??
              element["SerialNumbers"] ??
              [],
          "Batches": element["InventoryCountingBatchNumbers"] ??
              element["InventoryPostingBatchNumbers"] ??
              element["BatchNumbers"] ??
              [],
          "InWhsQty": element["InWarehouseQuantity"] ?? whsQty,
          if (matchedBarcode.isNotEmpty) "BarCode": matchedBarcode['BarCode'],
        });

        itemCodeFilter.add(element['ItemCode']);
      }
      items = rawItems;
      _restoreCountHeaderDimensions();

      if (mounted) MaterialDialog.close(context);

      if (mounted) setState(() {});
    } catch (e, stackTrace) {
      if (mounted) MaterialDialog.close(context);
      debugPrint("❌ fromFailed error: $e\n$stackTrace");
    }
  }

  void init() async {
    if (widget.isEdit != null) return;
    final whs = await LocalStorageManger.getString('warehouse');
    if (!mounted) return;

    final whsName = await LocalStorageManger.getString('warehouseName');
    if (!mounted) return;
    if (!mounted) return;
    warehouse.text = whs;
    warehouseNameUI.text = whsName.isNotEmpty ? whsName : warehouse.text;
    setState(() {});
    if (!widget.isQuickCount && widget.isEdit == null) {
      if (mounted) MaterialDialog.loading(context);

      List<Map<String, dynamic>> rawItems = [];
      final itemCycleCount = context.read<ItemCycleCountOfflineCubit>();

      final filteredCycleCount = itemCycleCount.state
          .where((b) => b['WhsCode'] == warehouse.text)
          .toList();
      if (filteredCycleCount.isNotEmpty) {
        for (var element in filteredCycleCount) {
          final itemResponse =
              findFullItemInformation(context, element['ItemCode']);

          if (itemResponse == null) return;
          final barcodeList = context.read<ItemBarcodeOfflineCubit>().state;
          final barCodeObj = barcodeList.firstWhere(
            (e) =>
                e['ItemCode'] == element['ItemCode'] &&
                e['UoMEntry'] == itemResponse["InventoryUoMEntry"],
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
            "ItemCode": element['ItemCode'],
            "ItemDescription": itemResponse['ItemName'],
            "Quantity": null,
            "WarehouseCode": warehouse.text,
            "UoMEntry":
                getDataFromDynamic(itemResponse['InventoryUoMEntry'] ?? "-1"),
            "UoMCode": itemResponse['InventoryUOM'] ?? "Manual",
            "UoMGroupDefinitionCollection":
                itemResponse['UoMGroupDefinitionCollection'],
            "BaseUoM": itemResponse['BaseUoM'],
            "ManageSerialNumbers": itemResponse["ManageSerialNumbers"],
            "ManageBatchNumbers": itemResponse["ManageBatchNumbers"],
            "BinId": binId.text,
            "BinEntry": binId.text,
            "BarCode": barCodeObj['BarCode'],
          });

          itemCodeFilter.add(element['ItemCode']);
        }
      }

      items = rawItems;
      _restoreCountHeaderDimensions();

      if (mounted) MaterialDialog.close(context);

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
      double quantity =
          double.tryParse(item["TotalQuantity"].toString()) ?? 0.0;

      String key = '${item["ItemCode"]}_${item["UoMCode"]}';

      if (combinedItemsMap.containsKey(key)) {
        combinedItemsMap[key]!["TotalQuantity"] =
            (combinedItemsMap[key]!["TotalQuantity"] as double) + quantity;
      } else {
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
          "BinId": (item["BinEntry"] ?? item["BinId"]),
          "ManageSerialNumbers": item["ManageSerialNumbers"],
          "ManageBatchNumbers": item["ManageBatchNumbers"],
          "BarCode": item['BarCode'],
        };
      }
    }

    return combinedItemsMap.values.toList();
  }

  void onSelectItem() async {
    _unfocusAll();
    if (!widget.isQuickCount) {
      _openGenericPickerModal<int>(
          title: 'Select Count Line',
          subtitle: 'Count items',
          icon: Icons.inventory_2_outlined,
          items: List<int>.generate(items.length, (index) => index),
          currentCode: isEdit < 0 ? '' : '$isEdit',
          getCode: (index) => '$index',
          getName: (index) =>
              '${items[index]['ItemCode']} - ${items[index]['ItemDescription']}',
          onSelected: (index) {
            if (index != null) _startEditItem(index);
          });
      return;
    }
    final value = await goTo(context, ItemPage(type: ItemType.inventory));
    if (!mounted) return;
    if (!mounted || value == null) return;
    final selectedBin = binId.text;
    final selectedBinCode = binCode.text;
    clear();
    onSetItemTemp(value);
    binId.text = selectedBin;
    binCode.text = selectedBinCode;
    _refreshCountStock();
    setState(() {});
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

  void onAddItem({bool force = false}) {
    FocusScope.of(context).unfocus();
    final binList = context.read<BinOfflineCubit>().state;
    final filteredBin =
        binList.where((b) => b['Warehouse'] == warehouse.text).toList();
    if (filteredBin.isNotEmpty && binId.text.isEmpty) {
      MaterialDialog.warning(context,
          title: 'Error', body: "Opps, Bin Location is required");
      return;
    }
    try {
      List<dynamic> data = [...items];

      if (itemCode.text == '') {
        throw Exception('Item is missing.');
      }
      final counted = double.tryParse(quantity.text.replaceAll(',', ''));
      if (counted == null || !counted.isFinite || counted < 0) {
        throw Exception('Enter a counted quantity of zero or greater.');
      }
      variance.text = formatQuantity(counted - parseQuantity(inWhsQty.text));
      final item = {
        "ItemCode": itemCode.text,
        "ItemDescription": itemName.text,
        "Quantity": quantity.text.replaceAll(',', ''),
        "WarehouseCode": warehouse.text,
        "UoMEntry": uomAbEntry.text,
        "UoMCode": uom.text,
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
        "BaseEntry": docEntry.text,
        "BaseLine": refLineNo.text,
        "UoMGroupDefinitionCollection":
            jsonDecode(uoMGroupDefinitionCollection.text) ?? [],
        "BaseUoM": baseUoM.text,
        "BinEntry": binId.text,
        "BinId": binId.text,
        "BinCode": binCode.text,
        "InWhsQty": inWhsQty.text.replaceAll(',', ''),
        "Variance": variance.text.replaceAll(',', ''),
        "BarCode": barCode.text,
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
        MaterialDialog.warning(context, title: 'Warning', body: err.toString());
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
    binId.text = getDataFromDynamic(item['BinEntry'] ?? item['BinId']);
    baseUoM.text = getDataFromDynamic(item['BaseUoM']);
    docEntry.text = getDataFromDynamic(item['DocEntry']);
    refLineNo.text = getDataFromDynamic(item['BaseLine']);
    barCode.text = getDataFromDynamic(item['BarCode']);
    uoMGroupDefinitionCollection.text = jsonEncode(
      item['UoMGroupDefinitionCollection'] ?? [],
    );
    inWhsQty.text =
        getDataFromDynamic(item['InWhsQty'] ?? item['InWarehouseQuantity']);
    variance.text = getDataFromDynamic(item['Variance']);
    _refreshCountStock();
    isSerial.text = getDataFromDynamic(item['ManageSerialNumbers']);
    isBatch.text = getDataFromDynamic(item['ManageBatchNumbers']);
    batchesInput.text = jsonEncode(item['Batches'] ?? []);
    serialsInput.text = jsonEncode(item['Serials'] ?? []);

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

      if (getDataFromDynamic(item['ManageSerialNumbers']) == 'tYES' ||
          getDataFromDynamic(item['ManageBatchNumbers']) == 'tYES') {
        isSerialOrBatch = true;
      } else {
        isSerialOrBatch = false;
      }
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
                  _buildModalDetailRow(
                      'In Warehouse',
                      formatQuantity(getDataFromDynamic(
                          item['InWhsQty'] ?? item['InWarehouseQuantity']))),
                  _buildModalDetailRow('Variance',
                      formatQuantity(getDataFromDynamic(item['Variance']))),
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

  void _restoreCountHeaderDimensions() {
    for (int d = 1; d <= 5; d++) {
      final key = d == 1 ? 'CostingCode' : 'CostingCode$d';
      final name = d == 1 ? 'CostingCodeName' : 'CostingCode${d}Name';
      final code = items.isEmpty ? '' : getDataFromDynamic(items.first[key]);
      final uniform =
          items.every((row) => getDataFromDynamic(row[key]) == code);
      _headerCostingCodes[d]?.text = uniform ? code : '';
      _headerCostingCodeNames[d]?.text = uniform && items.isNotEmpty
          ? getDataFromDynamic(items.first[name])
          : '';
    }
  }

  void _refreshCountStock() {
    try {
      final bins = context.read<BinOfflineCubit>().state;
      final usesBins = bins
          .any((bin) => getDataFromDynamic(bin['Warehouse']) == warehouse.text);
      final stock = context.read<ItemFindStockOfflineCubit>().getJsonData();
      final row = stock.firstWhere(
          (row) =>
              getDataFromDynamic(row['ItemCode']) == itemCode.text &&
              getDataFromDynamic(row['WhsCode']) == warehouse.text &&
              (!usesBins || getDataFromDynamic(row['BinID']) == binId.text),
          orElse: () => {});
      if (row.isNotEmpty) {
        inWhsQty.text = formatQuantity(getDataFromDynamic(row['OnHandQty']));
      }
    } catch (_) {}
    if (inWhsQty.text.isEmpty) inWhsQty.text = '0';
    variance.text = quantity.text.isEmpty
        ? ''
        : formatQuantity(
            parseQuantity(quantity.text) - parseQuantity(inWhsQty.text));
  }

  void onChangeBin() {
    _unfocusAll();
    List<dynamic> bins = [];
    try {
      bins = context.read<BinOfflineCubit>().state;
    } catch (_) {}
    _openGenericPickerModal<dynamic>(
      title: 'Select Bin Location',
      subtitle: 'Warehouse: ${warehouseNameUI.text}',
      icon: Icons.grid_view_rounded,
      items: bins
          .where(
              (bin) => getDataFromDynamic(bin['Warehouse']) == warehouse.text)
          .toList(),
      currentCode: binCode.text,
      getCode: (bin) => getDataFromDynamic(bin['BinCode']),
      getName: (bin) => getDataFromDynamic(bin['BinCode']),
      onSelected: (bin) {
        if (bin == null) return;
        setState(() {
          binId.text = getDataFromDynamic(bin['AbsEntry']);
          binCode.text = getDataFromDynamic(bin['BinCode']);
          inWhsQty.text = '';
          _refreshCountStock();
        });
      },
    );
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
        clear();
        warehouse.text = code;
        warehouseNameUI.text = name.isNotEmpty ? name : code;
        setState(() {});
      },
    );
  }

  bool _isCountedRow(dynamic row) {
    final quantity =
        double.tryParse(row['Quantity']?.toString().replaceAll(',', '') ?? '');
    return quantity != null && quantity.isFinite && quantity >= 0;
  }

  void onPostToSAP() async {
    if (!items.any(_isCountedRow)) {
      MaterialDialog.warning(context,
          title: 'Error',
          body: 'Enter a counted quantity for at least one item.');
      return;
    }

    try {
      var uuid = Uuid();
      MaterialDialog.loading(context);
      final filteredItems = items.where(_isCountedRow).toList();
      Map<String, dynamic> data = {
        "SaveId": widget.isEdit != null
            ? widget.isQuickCount
                ? saveIdQC.text
                : saveIdCC.text
            : uuid.v4(),
        "Reference2": ref.text,
        "Remarks": remark.text,
        "InventoryPostingLines": filteredItems.asMap().entries.map((entry) {
          Map<String, dynamic> item = entry.value;
          List<dynamic> inventoryPostingLineUoMs = [];

          bool isBatch = item['ManageBatchNumbers'] == 'tYES';
          bool isSerial = item['ManageSerialNumbers'] == 'tYES';

          if (isBatch || isSerial) {
            inventoryPostingLineUoMs = [];
          }

          return {
            "ItemCode": item['ItemCode'],
            "ItemDescription": item['ItemDescription'],
            "UoMCode": item['UoMCode'],
            "BinEntry": item["BinEntry"],
            "Price": 1,
            "Variance": parseQuantity(item["Quantity"]) -
                parseQuantity(item["InWhsQty"]),
            "CountedQuantity": item["Quantity"],
            "InWarehouseQuantity": parseQuantity(item['InWhsQty'] ?? 0),
            for (int d = 1; d <= 5; d++)
              if (getDataFromDynamic(
                      item[d == 1 ? 'CostingCode' : 'CostingCode$d'])
                  .isNotEmpty)
                (d == 1 ? 'CostingCode' : 'CostingCode$d'):
                    item[d == 1 ? 'CostingCode' : 'CostingCode$d'],
            "WarehouseCode": warehouse.text,
            "InventoryPostingSerialNumbers":
                (item['Serials'] as List<dynamic>).map((b) {
              return {
                "InternalSerialNumber": b["InternalSerialNumber"],
                "Quantity": parseQuantity(item["Quantity"]) -
                            parseQuantity(item["InWhsQty"]) <
                        0
                    ? -1
                    : 1,
              };
            }).toList(),
            "InventoryPostingBatchNumbers":
                (item['Batches'] as List<dynamic>).map((b) {
              return {
                "BatchNumber": b["BatchNumber"],
                "Quantity": parseQuantity(item["Quantity"]) -
                    parseQuantity(item["InWhsQty"]),
                "ExpiryDate": b["ExpiryDate"]
              };
            }).toList(),
            "InventoryPostingLineUoMs": inventoryPostingLineUoMs
          };
        }).toList(),
      };
      if (widget.isQuickCount) {
        if (widget.isEdit != null && widget.isEditFaildQC == true) {
          context
              .read<QuickCountFailedOfflineCubit>()
              .removeByFailId(saveIdQC.text);
          context.read<QuickCountOfflineCubit>().addData(data);
        } else if (widget.isEdit != null) {
          context
              .read<QuickCountOfflineCubit>()
              .updateBySaveId(saveIdQC.text, data);
        } else {
          context.read<QuickCountOfflineCubit>().addData(data);
        }
      } else {
        if (widget.isEdit != null && widget.isEditFaildCC == true) {
          context
              .read<CycleCountFailedOfflineCubit>()
              .removeByFailId(saveIdCC.text);
          context.read<CycleCountOfflineCubit>().addData(data);
        } else if (widget.isEdit != null) {
          context
              .read<CycleCountOfflineCubit>()
              .updateBySaveId(saveIdCC.text, data);
        } else {
          context.read<CycleCountOfflineCubit>().addData(data);
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
        MaterialDialog.success(
          context,
          title: 'Success',
          body: widget.isQuickCount
              ? widget.isEdit != null && widget.isEditFaildQC == true
                  ? "Edited Faild Quick Count"
                  : widget.isEdit != null
                      ? "Edited Quick Count"
                      : "Saved Quick Count"
              : widget.isEdit != null && widget.isEditFaildCC == true
                  ? "Edited Faild Cycle Count"
                  : widget.isEdit != null
                      ? "Edited Cycle Count"
                      : "Saved Cycle Count",
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

  void onPostOnlineToSAP() async {
    if (!items.any(_isCountedRow)) {
      MaterialDialog.warning(context,
          title: 'Error', body: "Opps, Items is required");
      return;
    }
    final connected = await hasInternet();
    if (!mounted) return;
    if (!connected) {
      MaterialDialog.warning(context,
          title: "Error Connection",
          body:
              "No internet connection. Please connect to Wi-Fi or mobile data.");
      return;
    }

    final username = await LocalStorageManger.getString('username');
    if (!mounted) return;
    final password = await LocalStorageManger.getString('password');
    if (!mounted) return;
    final host = await LocalStorageManger.getString('host');
    if (!mounted) return;
    final port = await LocalStorageManger.getString('port');
    if (!mounted) return;
    final company = await LocalStorageManger.getString('db');
    if (!mounted) return;

    if (username.isEmpty || password.isEmpty || company.isEmpty) {
      MaterialDialog.close(context);
      MaterialDialog.warning(context,
          title: "Missing Credentials",
          body: "Please check your SAP login configuration.");
      return;
    }

    try {
      MaterialDialog.loading(context);
      debugPrint("🌐 Logging in to SAP...");
      final loginResponse = await http.post(
        Uri.parse('$host:$port/b1s/v1/Login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "CompanyDB": company,
          "UserName": username,
          "Password": password,
        }),
      );
      if (!mounted) return;

      if (loginResponse.statusCode != 200) {
        MaterialDialog.close(context);
        debugPrint("❌ Login failed: ${loginResponse.body}");
        MaterialDialog.warning(context,
            title: "Login Failed",
            body: "Cannot connect to SAP. Please check your credentials.");
        return;
      }

      final loginData = jsonDecode(loginResponse.body);
      final token = loginData['SessionId'];

      await LocalStorageManger.setString('SessionId', token);
      if (!mounted) return;
      final filteredItems = items.where(_isCountedRow).toList();

      Map<String, dynamic> data = {
        "Reference2": ref.text,
        "Remarks": remark.text,
        "InventoryPostingLines": filteredItems.asMap().entries.map((entry) {
          Map<String, dynamic> item = entry.value;
          List<dynamic> inventoryPostingLineUoMs = [];

          bool isBatch = item['ManageBatchNumbers'] == 'tYES';
          bool isSerial = item['ManageSerialNumbers'] == 'tYES';

          if (isBatch || isSerial) {
            inventoryPostingLineUoMs = [];
          }

          return {
            "ItemCode": item['ItemCode'],
            "ItemDescription": item['ItemDescription'],
            "UoMCode": item['UoMCode'],
            "BinEntry": item["BinEntry"],
            "Price": 1,
            "Variance": parseQuantity(item["Quantity"]) -
                parseQuantity(item["InWhsQty"]),
            "CountedQuantity": item["Quantity"],
            "InWarehouseQuantity": parseQuantity(item['InWhsQty'] ?? 0),
            for (int d = 1; d <= 5; d++)
              if (getDataFromDynamic(
                      item[d == 1 ? 'CostingCode' : 'CostingCode$d'])
                  .isNotEmpty)
                (d == 1 ? 'CostingCode' : 'CostingCode$d'):
                    item[d == 1 ? 'CostingCode' : 'CostingCode$d'],
            "WarehouseCode": warehouse.text,
            "InventoryPostingSerialNumbers":
                (item['Serials'] as List<dynamic>).map((b) {
              return {
                "InternalSerialNumber": b["InternalSerialNumber"],
                "Quantity": parseQuantity(item["Quantity"]) -
                            parseQuantity(item["InWhsQty"]) <
                        0
                    ? -1
                    : 1,
              };
            }).toList(),
            "InventoryPostingBatchNumbers":
                (item['Batches'] as List<dynamic>).map((b) {
              return {
                "BatchNumber": b["BatchNumber"],
                "Quantity": parseQuantity(item["Quantity"]) -
                    parseQuantity(item["InWhsQty"]),
                "ExpiryDate": b["ExpiryDate"]
              };
            }).toList(),
            "InventoryPostingLineUoMs": inventoryPostingLineUoMs
          };
        }).toList(),
      };
      final response = await _bloc.post(data);
      if (!mounted) return;
      if (mounted) {
        Navigator.of(context).pop();
        MaterialDialog.success(
          context,
          title: 'Success',
          body: widget.isQuickCount
              ? "Quick Count - ${response['DocumentNumber']}."
              : "Cycle Count - ${response['DocumentNumber']}.",
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
      inWhsQty,
      variance,
      binId,
      binCode,
      uom,
      uomAbEntry,
      uomName,
      isBatch,
      isSerial,
      serialsInput,
      batchesInput,
      refLineNo,
      docEntry,
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

      itemCode.text = getDataFromDynamic(value['ItemCode']);
      itemName.text = getDataFromDynamic(value['ItemName']);
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
      debugPrint(e.toString());
    }
  }

  void onCompleteTextEditItem() async {
    try {
      if (barCode.text == '') return;
      if (!widget.isQuickCount) {
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
            final index = items.contains(item)
                ? items.indexOf(item)
                : items.indexWhere((e) =>
                    e['BarCode'] == item['BarCode'] &&
                    e['ItemCode'] == item['ItemCode']);
            onEdit(item, index);
          });
          return;
        }
        final item = duplicateItem.first;
        final index = items.indexOf(item);
        onEdit(item, index);
      } else {
        quantity.text = '';

        final barcodeList = context.read<ItemBarcodeOfflineCubit>().state;
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
        final binCubit = context.read<BinOfflineCubit>();
        final itemStockCubit = context.read<ItemFindStockOfflineCubit>();

        final binList = binCubit.state;
        final itemStockList = itemStockCubit.getJsonData();

        final filteredBin =
            binList.where((b) => b['Warehouse'] == warehouse.text).toList();
        if (filteredBin.isEmpty) {
          final matchedItemStock = itemStockList.firstWhere(
            (item) =>
                item['ItemCode'] == itemMapped["ItemCode"] &&
                item['WhsCode'] == warehouse.text,
            orElse: () => {},
          );

          if (matchedItemStock.isNotEmpty) {
            final onHandQty = matchedItemStock['OnHandQty'] ?? 0;
            setState(() {
              inWhsQty.text = formatQuantity(onHandQty);
            });
          } else {
            setState(() {
              inWhsQty.text = "0";
            });
          }
        }
        uom.text = getDataFromDynamic(first['UomCode']);
        uomAbEntry.text = getDataFromDynamic(first['UomEntry']);
        onSetItemTemp(itemMapped);
      }
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

  void onCompleteQuantiyInput() {
    FocusScope.of(context).requestFocus(FocusNode());
    variance.text =
        (parseQuantity(quantity.text) - parseQuantity(inWhsQty.text))
            .toString();
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
            listAllSerial:
                parseQuantity(inWhsQty.text) < parseQuantity(quantity.text)
                    ? null
                    : true,
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
        variance.text = formatQuantity(
            parseQuantity(quantity.text) - parseQuantity(inWhsQty.text));
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
            alcQty: parseQuantity(quantity.text) - parseQuantity(inWhsQty.text),
            listAllBatch: true,
            serials: batches,
            binCode: binId.text,
            itemName: itemName.text,
            warehouse: warehouse.text,
            isEdit: isEdit),
      ).then((value) {
        if (value == null) return;
        quantity.text = value['quantity'] ?? "0";
        variance.text = formatQuantity(
            parseQuantity(quantity.text) - parseQuantity(inWhsQty.text));
        batchesInput.text = jsonEncode(value['items']);
      });
    }
  }

  void _requestFocus(FocusNode node) {
    if (!node.hasFocus) {
      Future.microtask(() => node.requestFocus());
    }
  }

  void _handleScanSubmitted(String barcode, FocusNode submittedNode) {
    debugPrint("📦 Scanned Supplier Code: $barcode");

    setState(() {
      if (_itemCode.hasFocus) {
        barCode.text = barcode;
        itemCode.clear();
        onCompleteTextEditItem();
        isClickScanItem = false;
      } else if (_bin.hasFocus) {
        binCode.clear();
        binId.clear();
        MaterialDialog.warning(context,
            title: 'Opps', body: "Scan Bin not impliment yet!");
        isClickScanBin = false;
      }
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

  Widget _buildCountTextField(String label, TextEditingController controller,
      {bool readOnly = false, bool numeric = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: TextStyle(
              fontSize: AppFontSize.label,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700)),
      const SizedBox(height: 6),
      TextFormField(
          controller: controller,
          readOnly: readOnly,
          focusNode: numeric ? _quantity : null,
          keyboardType: numeric
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          inputFormatters:
              numeric ? [ThousandsSeparatorInputFormatter()] : null,
          onChanged: numeric
              ? (value) {
                  variance.text = formatQuantity(
                      parseQuantity(value) - parseQuantity(inWhsQty.text));
                  setState(() {});
                }
              : null,
          onEditingComplete: numeric ? onCompleteQuantiyInput : null,
          style: TextStyle(
            fontSize: AppFontSize.input,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    BorderSide(color: Colors.grey.shade300, width: 1.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    BorderSide(color: Colors.grey.shade300, width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: PRIMARY_COLOR, width: 1.2),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    BorderSide(color: Colors.grey.shade300, width: 1.0),
              ),
              hintText: numeric ? '0.00' : label,
              hintStyle: TextStyle(
                fontSize: AppFontSize.hint,
                color: Colors.grey.shade400,
                fontWeight: FontWeight.normal,
              ))),
    ]);
  }

  Widget _buildQuantityAndUomRow() {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
            child: _buildCountTextField('Counted Quantity', quantity,
                numeric: true)),
        const SizedBox(width: 12),
        Expanded(
            child: _buildSelectorTile(
                label: 'Unit of Measure',
                value: uomName.text.isNotEmpty
                    ? uomName.text
                    : (uom.text.isEmpty ? 'Select UoM' : uom.text),
                isEmpty: uom.text.isEmpty,
                onTap: onChangeUoM)),
      ]),
      const SizedBox(height: 12),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
            child:
                _buildCountTextField('In Warehouse', inWhsQty, readOnly: true)),
        const SizedBox(width: 12),
        Expanded(
            child: _buildCountTextField('Variance', variance, readOnly: true)),
      ]),
      if (isSerialOrBatch &&
          quantity.text.isNotEmpty &&
          parseQuantity(quantity.text) != parseQuantity(inWhsQty.text))
        TextButton.icon(
            onPressed: () => onNavigateSerialOrBatch(force: true),
            icon: const Icon(Icons.format_list_bulleted),
            label: const Text('Batch / Serial Details')),
    ]);
  }

  void onHeaderDimensionChange(int dimCode, String code, String name) {
    setState(() {
      _headerCostingCodes[dimCode]?.text = code;
      _headerCostingCodeNames[dimCode]?.text = name;

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
                      'Count Items',
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
                    CountingTableHeader(isPhone: isPhone),
                    if (items.isEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 36, horizontal: 20),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
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
                              "Scan or select an item above to add to this count",
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
                                child: CountingItemRow(
                                  item: item,
                                  index: index,
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
        backgroundColor: PRIMARY_COLOR,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          '${widget.isEdit != null ? 'Edit' : 'Create'} ${widget.isQuickCount ? 'Quick Counting' : 'Cycle Counting'}',
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
              ...[
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
                            _buildCountTextField('Reference', ref),
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
                            _buildQuantityAndUomRow(),
                            const SizedBox(height: 12),
                            if (isEdit != -1 &&
                                activeDimensions.isNotEmpty) ...[
                              ...activeDimensions
                                  .map((dim) => _buildLineDimensionTile(dim)),
                            ],
                            const SizedBox(height: 12),
                            _buildRemarkField(),
                            const SizedBox(height: 16),
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
            const SizedBox(width: 12),
            Expanded(
                child: Button(
                    disabled: isEdit != -1 || items.isEmpty,
                    onPressed: onPostOnlineToSAP,
                    bgColor: Colors.green.shade700,
                    child: Text('Post',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: AppFontSize.button)))),
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
