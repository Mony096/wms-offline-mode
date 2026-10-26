import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:wms_mobile/feature/bin_location/presentation/cubit/bin_offline_cubit.dart';
import 'package:wms_mobile/feature/good_receipt_type/presentation/screen/grt_page.dart';
import 'package:wms_mobile/feature/lk_act/presentation/screen/lk_act_page.dart';
import 'package:wms_mobile/feature/inbound/good_receipt/presentation/cubit/good_receipt_failed_offline_cubit.dart';
import 'package:wms_mobile/feature/inbound/good_receipt/presentation/cubit/goods_receipt_offline_cubit.dart';
import 'package:wms_mobile/feature/item/presentation/cubit/items_barcode_offline_cubit.dart';
import 'package:wms_mobile/feature/item/presentation/cubit/items_offline_cubit.dart';
import 'package:wms_mobile/feature/item_by_code/presentation/screen/item_page.dart';
import 'package:wms_mobile/feature/unit_of_measurement/presentation/cubit/uom_group_offline_cubit.dart';
import 'package:wms_mobile/feature/warehouse/presentation/screen/warehouse_page.dart';
import 'package:wms_mobile/utilies/dio_client.dart';
import '/feature/batch/good_receip_batch_screen.dart';
import '/feature/serial/good_receip_serial_screen.dart';
import '/feature/bin_location/domain/entity/bin_entity.dart';
import '/feature/bin_location/presentation/screen/bin_page.dart';
import '/feature/business_partner/presentation/screen/business_partner_page.dart';
import '../../../../core/error/failure.dart';
import '/component/button/button.dart';
import '/core/enum/global.dart';
import '/feature/item/presentation/screen/item_page.dart';
import '/feature/unit_of_measurement/presentation/screen/unit_of_measurement_page.dart';
import '/helper/helper.dart';
import '/utilies/dialog/dialog.dart';
import '/utilies/storage/locale_storage.dart';
import '../../../../constant/style.dart';

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
  final warehouseNameUI = TextEditingController();
  final uom = TextEditingController();
  final uomAbEntry = TextEditingController();
  final itemCode = TextEditingController();
  final itemName = TextEditingController();
  final baseUoM = TextEditingController();
  final uoMGroupDefinitionCollection = TextEditingController();
  final binId = TextEditingController();
  final binCode = TextEditingController();
  final accountCode = TextEditingController();
  final grType = TextEditingController();
  final grTypeName = TextEditingController();
  final remark = TextEditingController();

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
  final ScrollController _scrollController = ScrollController();

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
  final Map<int, TextEditingController> _costingCodes = {
    1: TextEditingController(),
    2: TextEditingController(),
    3: TextEditingController(),
    4: TextEditingController(),
    5: TextEditingController(),
  };
  final Map<int, TextEditingController> _costingCodeNames = {
    1: TextEditingController(),
    2: TextEditingController(),
    3: TextEditingController(),
    4: TextEditingController(),
    5: TextEditingController(),
  };

  @override
  void dispose() {
    _scrollController.dispose();
    for (var ctrl in _headerCostingCodes.values) {
      ctrl.dispose();
    }
    for (var ctrl in _headerCostingCodeNames.values) {
      ctrl.dispose();
    }
    for (var ctrl in _costingCodes.values) {
      ctrl.dispose();
    }
    for (var ctrl in _costingCodeNames.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    init();
    _loadDimensions();

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
      grType.text = getDataFromDynamic(widget.isEdit['U_LK_Type_GR']);
      remark.text = getDataFromDynamic(widget.isEdit['Comments']);
      warehouse.text = getDataFromDynamic(widget.isEdit['U_lk_whsdesc']);
      warehouseNameUI.text = warehouse.text;
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
          "AccountCode": getDataFromDynamic(element["AccountCode"]),
          "CostingCode": getDataFromDynamic(element["CostingCode"]),
          "CostingCode2": getDataFromDynamic(element["CostingCode2"]),
          "CostingCode3": getDataFromDynamic(element["CostingCode3"]),
          "CostingCode4": getDataFromDynamic(element["CostingCode4"]),
          "CostingCode5": getDataFromDynamic(element["CostingCode5"]),
          "CostingCodeName": getDataFromDynamic(element["CostingCodeName"]),
          "CostingCode2Name": getDataFromDynamic(element["CostingCode2Name"]),
          "CostingCode3Name": getDataFromDynamic(element["CostingCode3Name"]),
          "CostingCode4Name": getDataFromDynamic(element["CostingCode4Name"]),
          "CostingCode5Name": getDataFromDynamic(element["CostingCode5Name"]),
          if (matchedBarcode.isNotEmpty) "BarCode": matchedBarcode['BarCode'],
        });

        itemCodeFilter.add(element['ItemCode']);
      }
      // ✅ Update items
      items = rawItems;

      for (int d = 1; d <= 5; d++) {
        final codeKey = d == 1 ? 'CostingCode' : 'CostingCode$d';
        final nameKey = d == 1 ? 'CostingCodeName' : 'CostingCode${d}Name';
        String headerCode = getDataFromDynamic(widget.isEdit[codeKey]);
        String headerName = getDataFromDynamic(widget.isEdit[nameKey]);
        if (headerCode.isEmpty && rawItems.isNotEmpty) {
          headerCode = getDataFromDynamic(rawItems[0][codeKey]);
          headerName = getDataFromDynamic(rawItems[0][nameKey]);
        }
        _headerCostingCodes[d]?.text = headerCode;
        _headerCostingCodeNames[d]?.text = headerName;
      }

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
    final whsName = await LocalStorageManger.getString('warehouseName');
    warehouseNameUI.text = whsName.isNotEmpty ? whsName : warehouse.text;
  }

  Future<void> _loadDimensions() async {
    try {
      // 1. Try local cache first for instant offline responsiveness
      final cachedStr = await LocalStorageManger.getString('dimension_v2');
      if (cachedStr.isNotEmpty) {
        try {
          final decoded = jsonDecode(cachedStr) as List<dynamic>;
          if (decoded.isNotEmpty && mounted) {
            setState(() {
              activeDimensions = List<Map<String, dynamic>>.from(
                decoded.map((e) => Map<String, dynamic>.from(e)),
              );
            });
          }
        } catch (_) {}
      }

      // If dimension_v2 not found, try reading cached distribution_rules from initial download
      if (activeDimensions.isEmpty) {
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
              fallbackDims.add({
                'DimensionCode': dimCode,
                'DimensionDescription':
                    dimCode == 1 ? 'Cost Center' : 'Dimension $dimCode',
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
      }

      // 2. Fetch fresh active distribution rules from SAP
      List<dynamic> rawRules = [];
      try {
        final rulesResponse = await dio.get(
          "DistributionRules?\$filter=Active eq 'tYES'&\$select=FactorCode,FactorDescription,TotalFactor,Direct,InWhichDimension,Active,IsFixedAmount,DistributionRuleLines&\$top=5000",
        );
        if (rulesResponse.statusCode == 200 && rulesResponse.data != null) {
          rawRules = rulesResponse.data['value'] ?? [];
        }
      } catch (e) {
        try {
          final allRulesRes = await dio.get("DistributionRules?\$top=5000");
          if (allRulesRes.statusCode == 200 && allRulesRes.data != null) {
            rawRules = (allRulesRes.data['value'] as List? ?? []).where((r) {
              final active = r['Active'];
              return active == 'tYES' || active == 'Y' || active == true;
            }).toList();
          }
        } catch (_) {}
      }

      // 3. Try to fetch dimension descriptions from SAP
      List<dynamic> rawDims = [];
      try {
        final dimsResponse = await dio.get(
          "Dimensions?\$filter=IsActive eq 'tYES'&\$select=DimensionCode,DimensionDescription,IsActive",
        );
        if (dimsResponse.statusCode == 200 && dimsResponse.data != null) {
          rawDims = dimsResponse.data['value'] ?? [];
        }
      } catch (_) {
        try {
          final allDimsRes = await dio.get("Dimensions");
          if (allDimsRes.statusCode == 200 && allDimsRes.data != null) {
            rawDims = (allDimsRes.data['value'] as List? ?? []).where((d) {
              final active = d['IsActive'] ?? d['Active'];
              return active == 'tYES' || active == 'Y' || active == true;
            }).toList();
          }
        } catch (_) {}
      }

      final List<Map<String, dynamic>> parsedDims = [];
      final Set<int> allDimCodes = {};
      if (rawDims.isNotEmpty) {
        for (var d in rawDims) {
          final code = int.tryParse(d['DimensionCode']?.toString() ?? '') ?? 0;
          if (code >= 1 && code <= 5) allDimCodes.add(code);
        }
      } else {
        for (var r in rawRules) {
          final code =
              int.tryParse(r['InWhichDimension']?.toString() ?? '') ?? 0;
          if (code >= 1 && code <= 5) allDimCodes.add(code);
        }
      }

      final sortedCodes = allDimCodes.toList()..sort();
      for (var dimCode in sortedCodes) {
        final matchedDim = rawDims.firstWhere(
          (d) =>
              (int.tryParse(d['DimensionCode']?.toString() ?? '') ?? 0) ==
              dimCode,
          orElse: () => null,
        );

        final dimDesc = matchedDim?['DimensionDescription'] ??
            (dimCode == 1 ? 'Cost Center' : 'Dimension $dimCode');

        final dimRules = rawRules.where((r) {
          final ruleDim =
              int.tryParse(r['InWhichDimension']?.toString() ?? '') ?? 0;
          return ruleDim == dimCode;
        }).toList();

        if (dimRules.isNotEmpty || matchedDim != null) {
          parsedDims.add({
            'DimensionCode': dimCode,
            'DimensionDescription': dimDesc,
            'IsActive': matchedDim?['IsActive'] ?? 'tYES',
            'rules': dimRules,
          });
        }
      }

      if (parsedDims.isNotEmpty) {
        await LocalStorageManger.setString(
            'dimension_v2', jsonEncode(parsedDims));
        if (rawRules.isNotEmpty) {
          await LocalStorageManger.setString(
              'distribution_rules', jsonEncode(rawRules));
        }
        if (mounted) {
          setState(() {
            activeDimensions = parsedDims;
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading dimensions: $e");
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

        uom.text = value["Code"];
        uomAbEntry.text = value["AbsEntry"].toString();
      });
    } catch (e) {
      print(e);
    }
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

      if (quantity.text == '' || quantity.text == '0') {
        throw Exception('Quantity must be greater than zero.');
      }

      final item = {
        "ItemCode": itemCode.text,
        "ItemDescription": itemName.text,
        "Quantity": quantity.text.replaceAll(',', ''),
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
        "AccountCode": accountCode.text,
        "CostingCode": _costingCodes[1]?.text ?? '',
        "CostingCode2": _costingCodes[2]?.text ?? '',
        "CostingCode3": _costingCodes[3]?.text ?? '',
        "CostingCode4": _costingCodes[4]?.text ?? '',
        "CostingCode5": _costingCodes[5]?.text ?? '',
        "CostingCodeName": _costingCodeNames[1]?.text ?? '',
        "CostingCode2Name": _costingCodeNames[2]?.text ?? '',
        "CostingCode3Name": _costingCodeNames[3]?.text ?? '',
        "CostingCode4Name": _costingCodeNames[4]?.text ?? '',
        "CostingCode5Name": _costingCodeNames[5]?.text ?? '',
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
    binCode.text = getDataFromDynamic(item['BinCode']);
    binId.text = getDataFromDynamic(item['BinId']);
    baseUoM.text = getDataFromDynamic(item['BaseUoM']);
    docEntry.text = getDataFromDynamic(item['DocEntry']);
    refLineNo.text = getDataFromDynamic(item['BaseLine']);
    uoMGroupDefinitionCollection.text = jsonEncode(
      item['UoMGroupDefinitionCollection'] ?? [],
    );
    isSerial.text = getDataFromDynamic(item['ManageSerialNumbers']);
    isBatch.text = getDataFromDynamic(item['ManageBatchNumbers']);
    batchesInput.text = jsonEncode(item['Batches'] ?? []);
    serialsInput.text = jsonEncode(item['Serials'] ?? []);
    accountCode.text = getDataFromDynamic(item['AccountCode']);
    _costingCodes[1]?.text = getDataFromDynamic(item['CostingCode']);
    _costingCodes[2]?.text = getDataFromDynamic(item['CostingCode2']);
    _costingCodes[3]?.text = getDataFromDynamic(item['CostingCode3']);
    _costingCodes[4]?.text = getDataFromDynamic(item['CostingCode4']);
    _costingCodes[5]?.text = getDataFromDynamic(item['CostingCode5']);

    for (int d = 1; d <= 5; d++) {
      final codeKey = d == 1 ? 'CostingCode' : 'CostingCode$d';
      final nameKey = d == 1 ? 'CostingCodeName' : 'CostingCode${d}Name';
      String name = getDataFromDynamic(item[nameKey]);
      final code = getDataFromDynamic(item[codeKey]);
      if (name.isEmpty && code.isNotEmpty) {
        final dim = activeDimensions.firstWhere(
          (element) => element['DimensionCode'] == d,
          orElse: () => {},
        );
        final rules = (dim['rules'] as List<dynamic>?) ?? [];
        final rule = rules.firstWhere(
          (r) => r['FactorCode']?.toString() == code,
          orElse: () => null,
        );
        if (rule != null) {
          name = rule['FactorDescription']?.toString() ?? code;
        } else {
          name = code;
        }
      }
      _costingCodeNames[d]?.text = name;
    }

    setState(() {
      isEdit = targetIndex;

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
            Icon(Icons.delete_outline_rounded, color: Colors.red.shade600, size: 24),
            const SizedBox(width: 8),
            const Text('Remove Item', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Are you sure you want to remove "$itemCodeStr" from receipt list?',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _unfocusAll();
            },
            child: Text('Cancel', style: TextStyle(color: Colors.grey.shade700)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (mounted) {
      _unfocusAll();
    }
  }

  void _showItemActionDialog(dynamic item, int index) async {
    _unfocusAll();

    final itemCodeStr = getDataFromDynamic(item['ItemCode']);
    final itemDescStr = getDataFromDynamic(item['ItemDescription']);
    final qtyStr = formatQuantity(getDataFromDynamic(item['Quantity']));
    final uomStr = getDataFromDynamic(item['UoMCode']);

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
              child: const Icon(Icons.inventory_2_outlined, size: 20, color: PRIMARY_COLOR),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    itemCodeStr.isEmpty ? 'Item Details' : itemCodeStr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (itemDescStr.isNotEmpty)
                    Text(
                      itemDescStr,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Quantity: $qtyStr ${uomStr.isNotEmpty ? uomStr : ''}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                    ),
                  ),
                  Text(
                    'Row #${index + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Builder(
              builder: (_) {
                final List<Widget> dimChips = [];
                for (int d = 1; d <= 5; d++) {
                  final codeKey = d == 1 ? 'CostingCode' : 'CostingCode$d';
                  final nameKey = d == 1 ? 'CostingCodeName' : 'CostingCode${d}Name';
                  final code = getDataFromDynamic(item[codeKey]);
                  if (code.isNotEmpty) {
                    final dim = activeDimensions.firstWhere(
                      (e) => e['DimensionCode'] == d,
                      orElse: () => {},
                    );
                    final dimLabel = dim['DimensionDescription'] ?? 'Dim $d';
                    final name = getDataFromDynamic(item[nameKey]);
                    final display = name.isNotEmpty && name != code ? '$code ($name)' : code;
                    dimChips.add(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Text(
                          '$dimLabel: $display',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                    );
                  }
                }
                if (dimChips.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: dimChips,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: PRIMARY_COLOR,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                _unfocusAll();
                _startEditItem(index);
              },
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text(
                'Edit Item',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade700,
                side: BorderSide(color: Colors.red.shade300),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                _unfocusAll();
                _deleteItem(index);
              },
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              label: const Text(
                'Delete Item',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ),
          ],
        ),
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

      accountCode.clear();
      
      setState(() {
        items.clear();
      });
    });
  }

  void onChangeAccount() async {
    if (grType.text.isEmpty) {
      MaterialDialog.warning(context,
          title: 'Warning', body: "Please select Goods Receipt Type first.");
      return;
    }

    goTo(context, LkActPage(typeCode: grType.text)).then((value) {
      if (value == null) return;
      accountCode.text = getDataFromDynamic(value['U_LK_Acct']);
    });
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
        "U_LK_Type_GR": grType.text,
        "Comments": remark.text,
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
            "AccountCode": item['AccountCode'],
            if (item['CostingCode'] != null && item['CostingCode'].toString().isNotEmpty)
              "CostingCode": item['CostingCode'],
            if (item['CostingCode2'] != null && item['CostingCode2'].toString().isNotEmpty)
              "CostingCode2": item['CostingCode2'],
            if (item['CostingCode3'] != null && item['CostingCode3'].toString().isNotEmpty)
              "CostingCode3": item['CostingCode3'],
            if (item['CostingCode4'] != null && item['CostingCode4'].toString().isNotEmpty)
              "CostingCode4": item['CostingCode4'],
            if (item['CostingCode5'] != null && item['CostingCode5'].toString().isNotEmpty)
              "CostingCode5": item['CostingCode5'],
            "DocumentLinesBinAllocations":
                item['BinId'] != "" ? binAllocations : []
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
    accountCode.text = '';
    docEntry.text = '';
    refLineNo.text = '';
    isEdit = -1;
    for (int d = 1; d <= 5; d++) {
      _costingCodes[d]?.text = _headerCostingCodes[d]?.text ?? '';
      _costingCodeNames[d]?.text = _headerCostingCodeNames[d]?.text ?? '';
    }
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
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
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
                  Icon(icon, size: 18, color: PRIMARY_COLOR),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: isEmpty ? FontWeight.normal : FontWeight.w600,
                        color: isEmpty ? Colors.grey.shade400 : const Color(0xFF0F172A),
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
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            if (isScanning)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.shade400, width: 0.5),
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
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ],
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
                    color: isScanning ? Colors.green.shade600 : Colors.grey.shade300,
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
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                        onTap: onTapField,
                        onFieldSubmitted: onSubmitted,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          hintText: placeholder,
                          hintStyle: TextStyle(
                            fontSize: 13,
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
              color: isScanning ? const Color(0xFFE8F5E9) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: onStartScan,
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isScanning ? Colors.green.shade600 : Colors.grey.shade300,
                      width: isScanning ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.qr_code_scanner_rounded,
                        color: isScanning ? Colors.green.shade700 : PRIMARY_COLOR,
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
                  fontSize: 13,
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
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [ThousandsSeparatorInputFormatter()],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                        onTap: isSerialOrBatch ? () => onNavigateSerialOrBatch(force: true) : null,
                        onEditingComplete: onCompleteQuantiyInput,
                        onFieldSubmitted: (value) => _handleScanSubmitted(value, _quantity),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          hintText: '0.00',
                          hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
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
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: PRIMARY_COLOR.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.format_list_bulleted_rounded, size: 14, color: PRIMARY_COLOR),
                              SizedBox(width: 4),
                              Text(
                                'Manage',
                                style: TextStyle(
                                  fontSize: 11,
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
                  fontSize: 13,
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
                            uom.text.isEmpty ? 'Select UoM' : uom.text,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: uom.text.isEmpty ? FontWeight.normal : FontWeight.w600,
                              color: uom.text.isEmpty ? Colors.grey.shade400 : const Color(0xFF0F172A),
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

  Widget _buildAccountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account',
          style: TextStyle(
            fontSize: 13,
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
            onTap: onChangeAccount,
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.account_balance_wallet_outlined, size: 18, color: PRIMARY_COLOR),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      accountCode.text.isEmpty ? 'Select Account' : accountCode.text,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: accountCode.text.isEmpty ? FontWeight.normal : FontWeight.w600,
                        color: accountCode.text.isEmpty ? Colors.grey.shade400 : const Color(0xFF0F172A),
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
    );
  }

  void onHeaderDimensionChange(int dimCode, String code, String name) {
    setState(() {
      _headerCostingCodes[dimCode]?.text = code;
      _headerCostingCodeNames[dimCode]?.text = name;

      // Set default for current line item entry
      _costingCodes[dimCode]?.text = code;
      _costingCodeNames[dimCode]?.text = name;

      // Update all existing items in items list (matching Form.controller.js)
      final key = dimCode == 1 ? 'CostingCode' : 'CostingCode$dimCode';
      final nameKey = dimCode == 1 ? 'CostingCodeName' : 'CostingCode${dimCode}Name';
      for (var item in items) {
        item[key] = code;
        item[nameKey] = name;
      }
    });
  }

  Widget _buildHeaderDimensionTile(Map<String, dynamic> dim) {
    final dimCode = int.tryParse(dim['DimensionCode']?.toString() ?? '') ?? 0;
    if (dimCode < 1 || dimCode > 5) return const SizedBox.shrink();

    final dimName = dim['DimensionDescription']?.toString() ?? 'Dimension $dimCode';
    final selectedCode = _headerCostingCodes[dimCode]?.text ?? '';
    final selectedName = _headerCostingCodeNames[dimCode]?.text ?? '';

    String displayText = 'Select $dimName';
    final bool isEmpty = selectedCode.isEmpty;
    if (!isEmpty) {
      displayText = selectedName.isNotEmpty && selectedName != selectedCode
          ? '$selectedCode - $selectedName'
          : selectedCode;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dimName,
            style: TextStyle(
              fontSize: 13,
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
                  border: Border.all(
                    color: !isEmpty
                        ? PRIMARY_COLOR.withValues(alpha: 0.5)
                        : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.account_tree_outlined,
                      size: 18,
                      color: !isEmpty ? PRIMARY_COLOR : Colors.grey.shade500,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        displayText,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: isEmpty ? FontWeight.normal : FontWeight.w600,
                          color: isEmpty ? Colors.grey.shade400 : const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!isEmpty)
                      GestureDetector(
                        onTap: () {
                          onHeaderDimensionChange(dimCode, '', '');
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      )
                    else
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

  Widget _buildDimensionFields() {
    if (activeDimensions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: activeDimensions.map((dim) {
        final dimCode = int.tryParse(dim['DimensionCode']?.toString() ?? '') ?? 0;
        if (dimCode < 1 || dimCode > 5) return const SizedBox.shrink();

        final dimName = dim['DimensionDescription']?.toString() ?? 'Dimension $dimCode';
        final selectedCode = _costingCodes[dimCode]?.text ?? '';
        final selectedName = _costingCodeNames[dimCode]?.text ?? '';

        String displayText = 'Select $dimName';
        if (selectedCode.isNotEmpty) {
          displayText = selectedName.isNotEmpty && selectedName != selectedCode
              ? '$selectedCode - $selectedName'
              : selectedCode;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dimName,
                style: TextStyle(
                  fontSize: 13,
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
                  onTap: () => _openDimensionPicker(dim),
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selectedCode.isNotEmpty
                            ? PRIMARY_COLOR.withValues(alpha: 0.5)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.pie_chart_outline_rounded,
                          size: 18,
                          color: selectedCode.isNotEmpty ? PRIMARY_COLOR : Colors.grey.shade500,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            displayText,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: selectedCode.isEmpty ? FontWeight.normal : FontWeight.w600,
                              color: selectedCode.isEmpty ? Colors.grey.shade400 : const Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (selectedCode.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _costingCodes[dimCode]?.text = '';
                                _costingCodeNames[dimCode]?.text = '';
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.close_rounded,
                                size: 16,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          )
                        else
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
      }).toList(),
    );
  }

  void _openHeaderDimensionPicker(Map<String, dynamic> dim) {
    _openDimensionPickerCommon(dim, isHeader: true);
  }

  void _openDimensionPicker(Map<String, dynamic> dim) {
    _openDimensionPickerCommon(dim, isHeader: false);
  }

  void _openDimensionPickerCommon(Map<String, dynamic> dim, {required bool isHeader}) {
    final dimCode = int.tryParse(dim['DimensionCode']?.toString() ?? '') ?? 0;
    final dimName = dim['DimensionDescription']?.toString() ?? 'Dimension $dimCode';
    final rules = (dim['rules'] as List<dynamic>?) ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomCtx) {
        String query = '';
        final searchCtrl = TextEditingController();

        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredRules = rules.where((r) {
              final code = r['FactorCode']?.toString().toLowerCase() ?? '';
              final desc = r['FactorDescription']?.toString().toLowerCase() ?? '';
              final q = query.trim().toLowerCase();
              return q.isEmpty || code.contains(q) || desc.contains(q);
            }).toList();

            final currentCode = isHeader
                ? (_headerCostingCodes[dimCode]?.text ?? '')
                : (_costingCodes[dimCode]?.text ?? '');

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: PRIMARY_COLOR.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.account_tree_outlined,
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
                                'Select $dimName',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                isHeader
                                    ? 'Document Header (applies to all line items)'
                                    : 'Line Item Entry',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Search by code or description...',
                          hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                          prefixIcon: Icon(Icons.search_rounded, size: 20, color: Colors.grey.shade500),
                          suffixIcon: query.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 18),
                                  onPressed: () {
                                    searchCtrl.clear();
                                    setModalState(() {
                                      query = '';
                                    });
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1, thickness: 0.5),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      children: [
                        ListTile(
                          dense: true,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          leading: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(Icons.block_rounded, size: 16, color: Colors.grey.shade600),
                          ),
                          title: const Text(
                            '- None - (Clear selection)',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          trailing: currentCode.isEmpty
                              ? const Icon(Icons.check_circle_rounded, color: PRIMARY_COLOR, size: 20)
                              : null,
                          onTap: () {
                            if (isHeader) {
                              onHeaderDimensionChange(dimCode, '', '');
                            } else {
                              setState(() {
                                _costingCodes[dimCode]?.text = '';
                                _costingCodeNames[dimCode]?.text = '';
                              });
                            }
                            Navigator.of(bottomCtx).pop();
                            _unfocusAll();
                          },
                        ),
                        const Divider(height: 1, thickness: 0.5),
                        if (filteredRules.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(Icons.search_off_rounded, size: 40, color: Colors.grey.shade300),
                                  const SizedBox(height: 8),
                                  Text(
                                    query.isEmpty
                                        ? 'No distribution rules loaded yet'
                                        : 'No rules matching "$query"',
                                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                                  ),
                                  const SizedBox(height: 12),
                                  OutlinedButton.icon(
                                    icon: const Icon(Icons.sync_rounded, size: 16),
                                    label: const Text('Fetch Rules from SAP'),
                                    onPressed: () async {
                                      await _loadDimensions();
                                      setModalState(() {});
                                      setState(() {});
                                    },
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ...filteredRules.map((rule) {
                            final code = rule['FactorCode']?.toString() ?? '';
                            final desc = rule['FactorDescription']?.toString() ?? '';
                            final isSelected = currentCode == code;

                            return ListTile(
                              dense: true,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              tileColor: isSelected ? PRIMARY_COLOR.withValues(alpha: 0.06) : null,
                              leading: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isSelected ? PRIMARY_COLOR : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  code,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : const Color(0xFF1E293B),
                                  ),
                                ),
                              ),
                              title: Text(
                                desc.isNotEmpty ? desc : code,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? PRIMARY_COLOR : const Color(0xFF0F172A),
                                ),
                              ),
                              trailing: isSelected
                                  ? const Icon(Icons.check_circle_rounded, color: PRIMARY_COLOR, size: 20)
                                  : null,
                              onTap: () {
                                if (isHeader) {
                                  onHeaderDimensionChange(dimCode, code, desc);
                                } else {
                                  setState(() {
                                    _costingCodes[dimCode]?.text = code;
                                    _costingCodeNames[dimCode]?.text = desc.isNotEmpty ? desc : code;
                                  });
                                }
                                Navigator.of(bottomCtx).pop();
                                _unfocusAll();
                              },
                            );
                          }).toList(),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
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
            fontSize: 13,
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
          alignment: Alignment.centerLeft,
          child: TextFormField(
            controller: remark,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Enter optional remark or notes...',
              hintStyle: TextStyle(
                fontSize: 13,
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
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_rounded, size: 20),
              SizedBox(width: 6),
              Text(
                'Add Item',
                style: TextStyle(
                  fontSize: 14,
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
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_rounded, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Update Item',
                    style: TextStyle(
                      fontSize: 14,
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
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.close_rounded, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 13.5,
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: PRIMARY_COLOR.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.table_chart_outlined,
                        size: 18,
                        color: PRIMARY_COLOR,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Receipt Items',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: PRIMARY_COLOR.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${items.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: PRIMARY_COLOR,
                        ),
                      ),
                    ),
                  ],
                ),
                if (items.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      'Total Qty: ${_calculateTotalQuantity()}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
              ],
            ),
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
                    ContentHeader(isPhone: isPhone),
                    if (items.isEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 44,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "No Items Added Yet",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Scan or select an item above to add to this goods receipt",
                              style: TextStyle(
                                fontSize: 12.5,
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
        elevation: 0.5,
        centerTitle: true,
        title: Text(
          widget.isEdit != null ? 'Edit Goods Receipt' : 'Create Goods Receipt',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
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
            // Card 1: Document Header Card
            Container(
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
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: PRIMARY_COLOR.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.receipt_long_rounded,
                          size: 18,
                          color: PRIMARY_COLOR,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Document Header',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildSelectorTile(
                    label: 'Goods Receipt Type',
                    value: grTypeName.text.isEmpty
                        ? 'Select Goods Receipt Type'
                        : grTypeName.text,
                    isEmpty: grTypeName.text.isEmpty,
                    icon: Icons.category_outlined,
                    onTap: onChangeGrt,
                  ),
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
                  if (activeDimensions.isNotEmpty) ...[
                    ...activeDimensions.map((dim) => _buildHeaderDimensionTile(dim)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Card 2: Item Entry & Scanner Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isEdit != -1 ? Colors.amber.shade400 : const Color(0xFFE2E8F0),
                  width: isEdit != -1 ? 1.5 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: PRIMARY_COLOR.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.playlist_add_rounded,
                              size: 18,
                              color: PRIMARY_COLOR,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Line Item Entry',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                      if (isEdit != -1)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber.shade400),
                          ),
                          child: Text(
                            'Editing Row #${isEdit + 1}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),

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
                      Future.delayed(const Duration(milliseconds: 100), () {
                        _requestFocus(_bin);
                      });
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
                      Future.delayed(const Duration(milliseconds: 100), () {
                        _requestFocus(_itemCode);
                      });
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

                  // Item details banner if item is selected
                  if (itemCode.text.isNotEmpty && itemName.text.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 16, color: PRIMARY_COLOR),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  itemName.text,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                if (baseUoM.text.isNotEmpty ||
                                    isBatch.text == 'tYES' ||
                                    isSerial.text == 'tYES') ...[
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: [
                                      if (baseUoM.text.isNotEmpty)
                                        Text(
                                          'Base UoM: ${baseUoM.text}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      if (isBatch.text == 'tYES')
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade50,
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: Colors.blue.shade200, width: 0.5),
                                          ),
                                          child: Text(
                                            'BATCH',
                                            style: TextStyle(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.blue.shade800,
                                            ),
                                          ),
                                        ),
                                      if (isSerial.text == 'tYES')
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: Colors.purple.shade50,
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: Colors.purple.shade200, width: 0.5),
                                          ),
                                          child: Text(
                                            'SERIAL',
                                            style: TextStyle(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.purple.shade800,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Quantity & UoM
                  _buildQuantityAndUomRow(),
                  const SizedBox(height: 12),

                  // Account
                  _buildAccountField(),
                  const SizedBox(height: 12),

                  // Dynamic Dimensions (Cost Centers)
                  _buildDimensionFields(),

                  // Remark
                  _buildRemarkField(),
                  const SizedBox(height: 16),

                  // Add / Update item action buttons
                  _buildItemActionButtons(),
                ],
              ),
            ),
            const SizedBox(height: 14),

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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_upload_outlined, size: 20, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      items.isNotEmpty ? 'Save (${items.length})' : 'Save',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Button(
                variant: ButtonVariant.outline,
                onPressed: () {
                  if (items.isNotEmpty) {
                    MaterialDialog.warning(
                      context,
                      title: 'Warning',
                      body: 'Are you sure you want to leave? Once you leave, unsaved data will be erased.',
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
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.close_rounded, size: 18, color: PRIMARY_COLOR),
                    SizedBox(width: 6),
                    Text(
                      'Cancel',
                      style: TextStyle(
                        color: PRIMARY_COLOR,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ContentHeader extends StatelessWidget {
  const ContentHeader({super.key, this.hideOpenQty, this.isPhone = false});
  final dynamic hideOpenQty;
  final bool isPhone;

  Widget _buildColumn(Widget child, int flex, double fixedWidth, {Alignment alignment = Alignment.center}) {
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
    const textStyle = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w700,
      fontSize: 12,
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
            const Text('#', style: textStyle),
            1,
            34,
            alignment: Alignment.center,
          ),
          const SizedBox(width: 8),
          _buildColumn(
            const Text('Item No / Description', style: textStyle),
            5,
            200,
            alignment: Alignment.centerLeft,
          ),
          _buildColumn(
            const Text('UoM', style: textStyle),
            2,
            65,
            alignment: Alignment.center,
          ),
          _buildColumn(
            const Text('Account', style: textStyle),
            2,
            85,
            alignment: Alignment.center,
          ),
          _buildColumn(
            const Text('QTY Received', style: textStyle),
            2,
            95,
            alignment: Alignment.centerRight,
          ),
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
    this.hideOpenQty,
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

  Widget _buildColumn(Widget child, int flex, double fixedWidth, {Alignment alignment = Alignment.center}) {
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
    final accountStr = getDataFromDynamic(item['AccountCode']);
    final qtyStr = formatQuantity(getDataFromDynamic(item['Quantity']));
    final isBatch = getDataFromDynamic(item['ManageBatchNumbers']) == 'tYES';
    final isSerial = getDataFromDynamic(item['ManageSerialNumbers']) == 'tYES';
    final costingCode1 = getDataFromDynamic(item['CostingCode']);

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
                color: isBeingEdited ? Colors.amber.shade200 : const Color(0xFFE2E8F0),
                shape: BoxShape.circle,
              ),
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: isBeingEdited ? Colors.amber.shade900 : const Color(0xFF475569),
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
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (itemDescStr.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    itemDescStr,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 11.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (isBatch || isSerial || costingCode1.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isBatch)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.blue.shade200, width: 0.5),
                          ),
                          child: Text(
                            'BATCH',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ),
                      if (isSerial) ...[
                        if (isBatch) const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.purple.shade200, width: 0.5),
                          ),
                          child: Text(
                            'SERIAL',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.purple.shade800,
                            ),
                          ),
                        ),
                      ],
                      ...List.generate(5, (i) {
                        final d = i + 1;
                        final codeKey = d == 1 ? 'CostingCode' : 'CostingCode$d';
                        final code = getDataFromDynamic(item[codeKey]);
                        if (code.isEmpty) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.teal.shade50,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.teal.shade200, width: 0.5),
                            ),
                            child: Text(
                              'D$d: $code',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Colors.teal.shade800,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ],
            ),
            5,
            200,
            alignment: Alignment.centerLeft,
          ),

          // UoM
          _buildColumn(
            Text(
              uomStr.isEmpty ? '-' : uomStr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF334155),
              ),
            ),
            2,
            65,
            alignment: Alignment.center,
          ),

          // Account
          _buildColumn(
            Text(
              accountStr.isEmpty ? '-' : accountStr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF475569),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            2,
            85,
            alignment: Alignment.center,
          ),

          // Quantity Received
          _buildColumn(
            Text(
              qtyStr.isEmpty ? '0' : qtyStr,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: PRIMARY_COLOR,
              ),
            ),
            2,
            95,
            alignment: Alignment.centerRight,
          ),
        ],
      ),
    );
  }
}

