import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:wms_mobile/component/form/input_col.dart';
import 'package:wms_mobile/feature/bin_location/presentation/cubit/bin_offline_cubit.dart';
import 'package:wms_mobile/feature/counting/cos/presentation/cubit/cos_offline_cubit.dart';
import 'package:wms_mobile/feature/counting/cos/presentation/screen/cos_page.dart';
import 'package:wms_mobile/feature/counting/physical_count/presentation/cubit/physical_count_cubit.dart';
import 'package:wms_mobile/feature/counting/physical_count/presentation/cubit/physical_count_failed_offline_cubit.dart';
import 'package:wms_mobile/feature/counting/physical_count/presentation/cubit/physical_count_offline_cubit.dart';
import 'package:wms_mobile/feature/item/presentation/cubit/items_barcode_offline_cubit.dart';
import 'package:wms_mobile/feature/item/presentation/cubit/items_find_stock_offline_cubit.dart';
import 'package:wms_mobile/feature/item/presentation/cubit/items_offline_cubit.dart';
import 'package:wms_mobile/feature/outbounce/delivery/presentation/duplicateItem_DLR_Screen.dart';
import 'package:wms_mobile/feature/unit_of_measurement/presentation/cubit/uom_group_offline_cubit.dart';
import 'package:wms_mobile/feature/warehouse/presentation/screen/warehouse_page.dart';
import 'package:wms_mobile/utilies/dio_client.dart';
import 'package:wms_mobile/utilies/storage/locale_storage.dart';
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
import 'package:wms_mobile/helper/helper.dart';

class CreatePhysicalCountScreen extends StatefulWidget {
  const CreatePhysicalCountScreen({
    super.key,
    this.isEdit,
    this.isEditFaild,
  });
  final dynamic isEdit;
  final dynamic isEditFaild;
  @override
  State<CreatePhysicalCountScreen> createState() =>
      _CreatePhysicalCountScreenState();
}

class _CreatePhysicalCountScreenState extends State<CreatePhysicalCountScreen> {
  final uomText = TextEditingController();
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
  final cosDocEntry = TextEditingController();
  final cos = TextEditingController();
  int isEdit = -1;
  late PhysicalCountCubit _bloc;

  bool isSerialOrBatch = false;
  List<dynamic> isSerialOrBatchs = [{}];
  List<dynamic> items = [];
  final DioClient dio = DioClient();
  bool loading = false;
  final barCode = TextEditingController();
  final saveId = TextEditingController();
  bool isClickScanItem = false;
  bool isClickScanBin = false;
  final FocusNode _itemCode = FocusNode();
  final FocusNode _quantity = FocusNode();
  final FocusNode _bin = FocusNode();
  final variance = TextEditingController();
  final inWhsQty = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bloc = context.read<PhysicalCountCubit>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      fromEdit();
    });
  }

  void fromEdit() async {
    try {
      if (widget.isEdit == null) return;
      print(widget.isEdit);
      // ✅ Populate text fields safely
      cosDocEntry.text = getDataFromDynamic(widget.isEdit['DocumentEntry']);
      cos.text = getDataFromDynamic(widget.isEdit['DocumentNumber']);
      warehouse.text = getDataFromDynamic(
          widget.isEdit['InventoryCountingLines'][0]["WarehouseCode"]);
      saveId.text = getDataFromDynamic(widget.isEdit['SaveId']);
      if (mounted) MaterialDialog.loading(context);

      final barcodeList = context.read<ItemBarcodeOfflineCubit>().state;
      // final coss = context.read<COSOfflineCubit>().state;

      final List<Map<String, dynamic>> rawItems = [];
      final List<dynamic> lines =
          (widget.isEdit['InventoryCountingLines'] as List?) ?? [];

      // final refDocEntry = getDataFromDynamic(widget.isEdit["DocumentNumber"]);
      // docEntry.text = refDocEntry;
      // final matchedCos = coss.firstWhere(
      //   (cs) => cs['DocumentNumber'] == refDocEntry,
      //   orElse: () => {},
      // );
      // if (matchedCos.isEmpty) {
      //   if (mounted) MaterialDialog.close(context);

      //   MaterialDialog.warning(
      //     context,
      //     title: 'Error',
      //     body: "Counting Sheet Not Found!",
      //   );
      //   return;
      // }

      for (var element in lines) {
        final itemList = context.read<ItemOfflineCubit>().state;
        final binList = context.read<BinOfflineCubit>().state;

        final itemCode = getDataFromDynamic(element["ItemCode"]);

        // ✅ Find matching barcode record
        final matchedBarcode = barcodeList.firstWhere(
          (b) =>
              b['ItemCode'] == itemCode &&
              b['UoMCode'] == getDataFromDynamic(element["UoMCode"]),
          orElse: () => {},
        );

        // final matchedPOLine =
        //     (matchedCos.isNotEmpty && matchedCos["InventoryCountingLines"] != null)
        //         ? (matchedCos["InventoryCountingLines"] as List).firstWhere(
        //             (b) =>
        //                 b['ItemCode'] == itemCode && b['UoMCode'] == getDataFromDynamic(element["UoMCode"]),
        //             orElse: () => {},
        //           )
        //         : {};

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
        final binCodeFind = binList.firstWhere(
          (u) =>
              u['AbsEntry'] ==
              int.tryParse(getDataFromDynamic(element["BinEntry"])),
          orElse: () => {},
        );

        rawItems.add({
          "ItemCode": element['ItemCode'],
          "ItemDescription": element['ItemName'] ?? element['ItemDescription'],
          "Quantity": element['CountedQuantity'],
          // "TotalQuantity": matchedPOLine["Quantity"],
          "WarehouseCode": warehouse.text,
          "UoMEntry": getDataFromDynamic(element['UoMEntry']),
          "UoMCode": element['UoMCode'],
          "UoMGroupDefinitionCollection":
              itemMapped['UoMGroupDefinitionCollection'],
          "BaseUoM": itemMapped['BaseUoM'],
          "BinEntry": element["BinEntry"] ?? -1,
          "BinCode": binCodeFind["BinCode"],
          "BaseLine": element['BaseLine'],
          "ManageSerialNumbers": itemMapped["ManageSerialNumbers"],
          "ManageBatchNumbers": itemMapped["ManageBatchNumbers"],
          "Serials": element["SerialNumbers"] ?? [],
          "Batches": element["BatchNumbers"] ?? [],
          "InventoryCountingLineUoMs": isSerialOrBatchs,
          if (matchedBarcode.isNotEmpty) "BarCode": matchedBarcode['BarCode'],
        });

        // itemCodeFilter.add(element['ItemCode']);
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

  void onAddItem({bool force = false}) {
    try {
      List<dynamic> data = [...items];

      if (itemCode.text == '') {
        throw Exception('Item is missing.');
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
        "InventoryCountingLineUoMs": isSerialOrBatchs,
        "Serials":
            serialsInput.text == "" ? [] : jsonDecode(serialsInput.text) ?? [],
        "Batches":
            batchesInput.text == "" ? [] : jsonDecode(batchesInput.text) ?? [],
        "InWhsQty": inWhsQty.text.replaceAll(',', ''),
        "Variance": variance.text.replaceAll(',', ''),
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
        quantity.text = formatQuantity(getDataFromDynamic(item['Quantity']));
        uom.text = getDataFromDynamic(item['UoMCode']);
        uomAbEntry.text = getDataFromDynamic(item['UoMEntry']);
        binCode.text = getDataFromDynamic(item['BinCode']);
        binId.text = getDataFromDynamic(item['BinId']);
        baseUoM.text = getDataFromDynamic(item['BaseUoM']);
        docEntry.text = getDataFromDynamic(item['DocEntry']);
        refLineNo.text = getDataFromDynamic(item['BaseLine']);
        variance.text = formatQuantity(getDataFromDynamic(item["Variance"]));
        uoMGroupDefinitionCollection.text = jsonEncode(
          item['UoMGroupDefinitionCollection'],
        );
        final binCubit = context.read<BinOfflineCubit>();
        final itemStockCubit = context.read<ItemFindStockOfflineCubit>();

        final binList = binCubit.state;
        final itemStockList = itemStockCubit.getJsonData();

        // 🧩 Step 1: Filter bin by warehouse
        final filteredBin =
            binList.where((b) => b['Warehouse'] == warehouse.text).toList();
        if (filteredBin.isEmpty) {
          final matchedItemStock = itemStockList.firstWhere(
            (i) =>
                i['ItemCode'] == item['ItemCode'] &&
                i['WhsCode'] == warehouse.text,
            orElse: () => {},
          );
          print(matchedItemStock);
          // 🧩 Step 3: Update stock quantity (offline)
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
        } else {
          final matchedItemStock = itemStockList.firstWhere(
            (i) =>
                i['ItemCode'] == item['ItemCode'] &&
                i['WhsCode'] == warehouse.text &&
                i['BinID'] == int.tryParse(binId.text),
            orElse: () => {},
          );
          print(item['ItemCode']);
          print(warehouse.text);
          print(binId.text);
          // 🧩 Step 3: Update stock quantity (offline)
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
    goTo(context, BinPage(warehouse: warehouse.text, itemCode: itemCode.text))
        .then((value) {
      if (value == null) return;

      binId.text = getDataFromDynamic((value as BinEntity).id);
      binCode.text = getDataFromDynamic(value.code);

      if (value == null) return;
      print("✅ onChangeBin started");

      binId.text =
          getDataFromDynamic((value as BinEntity).id).toString().trim();
      binCode.text = getDataFromDynamic(value.code).toString().trim();

      final item = itemCode.text.trim();
      final whs = warehouse.text.trim();
      final bin = binId.text.trim();

      print("🧾 Item: $item");
      print("🏭 Warehouse: $whs");
      print("📦 BinID: $bin");

      try {
        if (item.isNotEmpty && whs.isNotEmpty && bin.isNotEmpty) {
          // 🧠 Get offline data
          final itemStockCubit = context.read<ItemFindStockOfflineCubit>();
          final stockData = itemStockCubit.getJsonData();

          // 🔍 Find matching item in offline stock
          final matched = stockData.firstWhere(
            (e) =>
                e['ItemCode'].toString().trim() == item &&
                e['WhsCode'].toString().trim() == whs &&
                e['BinID'].toString().trim() == bin,
            orElse: () => {},
          );

          if (matched.isNotEmpty) {
            final onHandQty = matched['OnHandQty'] ?? 0;
            setState(() {
              inWhsQty.text = formatQuantity(onHandQty);
            });
          } else {
            // ❌ Not found in offline data
            setState(() {
              inWhsQty.text = "0";
            });
            MaterialDialog.warning(
              context,
              title: "Not Found",
              body: "No offline stock found for this item in the selected bin.",
            );
          }
        }

        print("📦 In-warehouse quantity: ${inWhsQty.text}");
      } catch (e, stack) {
        print("❌ Error during offline lookup: $e");
        print("📜 Stack trace: $stack");
        setState(() {
          inWhsQty.text = "0";
        });
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

      MaterialDialog.loading(context);
      Map<String, dynamic> data = {
        // "BranchID": 1,
        "SaveId": widget.isEdit != null && widget.isEditFaild == true
            ? saveId.text
            : widget.isEdit != null
                ? saveId.text
                : uuid.v4(),
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
            "BinEntry": item["BinEntry"],
            "CountedQuantity": item["Quantity"],
            "WarehouseCode": warehouse.text,
            "InventoryCountingSerialNumbers": item['Serials'] ?? [],
            "InventoryCountingBatchNumbers": item['Batches'] ?? [],
            "InventoryCountingLineUoMs": inventoryCountingLineUoMs
          };
        }).toList(),
      };
      // context.read<PhysicalCountOfflineCubit>().addData(data);
      if (widget.isEdit != null && widget.isEditFaild == true) {
        context
            .read<PhysicalCountFailedOfflineCubit>()
            .removeByFailId(saveId.text);
        context.read<PhysicalCountOfflineCubit>().addData(data);
      } else if (widget.isEdit != null) {
        context
            .read<PhysicalCountOfflineCubit>()
            .updateBySaveId(saveId.text, data);
      } else {
        context.read<PhysicalCountOfflineCubit>().addData(data);
      }
      if (mounted) {
        Navigator.of(context).pop();
        MaterialDialog.success(
          context,
          title: 'Successfully',
          body: widget.isEdit != null && widget.isEditFaild == true
              ? "Edited Faild Physical Count"
              : widget.isEdit != null
                  ? "Edited Physical Count"
                  : "Saved Physical Count",
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
    if (items.isEmpty) {
      MaterialDialog.warning(context,
          title: 'Error', body: "Opps, Items is required");
      return;
    }
    final connected = await hasInternet();
    if (!connected) {
      MaterialDialog.warning(context,
          title: "Error Connection",
          body:
              "No internet connection. Please connect to Wi-Fi or mobile data.");
      return;
    }

    // 2️⃣ Load stored credentials
    final username = await LocalStorageManger.getString('username');
    final password = await LocalStorageManger.getString('password');
    final host = await LocalStorageManger.getString('host');
    final port = await LocalStorageManger.getString('port');
    final company = await LocalStorageManger.getString('db');

    if (username.isEmpty || password.isEmpty || company.isEmpty) {
      MaterialDialog.close(context);
      MaterialDialog.warning(context,
          title: "Missing Credentials",
          body: "Please check your SAP login configuration.");
      return;
    }
    try {
      MaterialDialog.loading(context);
      print("🌐 Logging in to SAP...");
      final loginResponse = await http.post(
        Uri.parse('$host:$port/b1s/v1/Login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "CompanyDB": company,
          "UserName": username,
          "Password": password,
        }),
      );

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

      // 4️⃣ Save token before starting sync
      await LocalStorageManger.setString('SessionId', token);
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
            "BinEntry": item["BinEntry"],
            "CountedQuantity": item["Quantity"],
            "WarehouseCode": warehouse.text,
            "InventoryCountingSerialNumbers": item['Serials'] ?? [],
            "InventoryCountingBatchNumbers": item['Batches'] ?? [],
            "InventoryCountingLineUoMs": inventoryCountingLineUoMs
          };
        }).toList(),
      };
      final response = await _bloc.put(data, int.tryParse(cosDocEntry.text)!);
      if (mounted) {
        Navigator.of(context).pop();
        MaterialDialog.success(
          context,
          title: 'Successfully',
          body: "Physical Count - ${cos.text}.",
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
    inWhsQty.clear();
    variance.clear();
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

  void onCompleteQuantiyInput() {
    FocusScope.of(context).requestFocus(FocusNode());
    variance.text = (parseQuantity(quantity.text) -
            parseQuantity(inWhsQty.text))
        .toString();
    // onNavigateSerialOrBatch();
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
              InputCol(
                label: 'Input Qty',
                placeholder: 'Quantity',
                controller: quantity,
                
                inputFormatters: [ThousandsSeparatorInputFormatter()],
focusNode: _quantity,
                onFieldSubmitted: (value) {
                  _handleScanSubmitted(value, _quantity);
                },
                onChanged: (value) {
                  variance.text = (double.parse(value.isEmpty ? "0" : value) -
                          parseQuantity(inWhsQty.text))
                      .toString();
                },
                readOnly: isSerialOrBatch ? true : false, // simpler
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
              const SizedBox(height: 7),

              // ====== Input Qty & UoM ======
              Row(
                children: [
                  Expanded(
                    child: InputCol(
                      label: 'Variance',
                      placeholder: 'Variance',
                      controller: variance,
                      readOnly: true, // simpler

                      // onTap: isSerialOrBatch
                      //     ? () {
                      //         onNavigateSerialOrBatch(force: true);
                      //       }
                      //     : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InputCol(
                      label: 'In Whs Qty',
                      placeholder: 'In Whs Qty',
                      controller: inWhsQty,
                      readOnly: true,
                      // onPressed: onChangeUoM,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),

              InputCol(
                label: 'Input UoM',
                placeholder: 'UoM',
                controller: uom,
                readOnly: true,
                onPressed: onChangeUoM,
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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isPhone = constraints.maxWidth < 600;
                    final content = Column(
                      children: [
                        ContentHeader(isPhone: isPhone),
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
                              isPhone: isPhone,
                            ),
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
            // Expanded(
            //   child: Button(
            //     variant: ButtonVariant.primary,
            //     disabled: isEdit != -1,
            //     onPressed: onPostToSAP,
            //     child: Text(
            //       'Save',
            //       style: TextStyle(color: Colors.white),
            //     ),
            //   ),
            // ),
            // const SizedBox(width: 12),
            // Expanded(
            //   child: Button(
            //     variant: ButtonVariant.outline,
            //     onPressed: () {
            //       if (items.length > 0) {
            //         MaterialDialog.warning(
            //           context,
            //           title: 'Warning',
            //           body:
            //               'Are you sure leave? once you pressed ok the data will be ereas.',
            //           confirmLabel: 'Ok',
            //           cancelLabel: 'Cancel',
            //           onConfirm: () {
            //             Navigator.of(context).pop();
            //           },
            //           onCancel: () {},
            //         );
            //       } else {
            //         Navigator.of(context).pop();
            //       }
            //     },
            //     child: Text(
            //       'Cancel',
            //       style: TextStyle(
            //         color: PRIMARY_COLOR,
            //       ),
            //     ),
            //   ),
            // )
            Expanded(
              child: Button(
                variant: ButtonVariant.primary,
                disabled: isEdit != -1,
                onPressed: onPostToSAP,
                child: Text(
                  'Save ',
                  style: TextStyle(color: Colors.white, fontSize: 12.5),
                ),
              ),
            ),
            const SizedBox(width: 5),

            Expanded(
              child: Button(
                onPressed: onPostOnlineToSAP,
                disabled: isEdit != -1,
                bgColor: Colors.green.shade700,
                child: Text(
                  "Post",
                  style: TextStyle(color: Colors.white, fontSize: 12.5),
                ),
              ),
            ),
            const SizedBox(width: 5),
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
  const ContentHeader({super.key, this.hideOpenQty, this.isPhone = false});
  final dynamic hideOpenQty;
  final bool isPhone;

  Widget _buildColumn(Widget child, int flex, double fixedWidth) {
    if (isPhone) return SizedBox(width: fixedWidth, child: child);
    return Expanded(flex: flex, child: child);
  }

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
        children: [
          _buildColumn(
            const Text(
              'Item No',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            3,
            220,
          ),
          _buildColumn(
            const Text(
              'UoM',
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            1,
            60,
          ),
          _buildColumn(
            const Text(
              'QTY',
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            1,
            90,
          ),
        ],
      ),
    );
  }
}

class ItemRow extends StatelessWidget {
  const ItemRow({super.key, required this.item, this.po, this.hideOpenQty, this.isPhone = false});
  final dynamic po;
  final dynamic item;
  final dynamic hideOpenQty;
  final bool isPhone;

  String getDataFromDynamic(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  Widget _buildColumn(Widget child, int flex, double fixedWidth) {
    if (isPhone) return SizedBox(width: fixedWidth, child: child);
    return Expanded(flex: flex, child: child);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade50,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildColumn(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      getDataFromDynamic(item['ItemCode']),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      getDataFromDynamic(item['ItemDescription']),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                3,
                220,
              ),
              _buildColumn(
                Text(
                  getDataFromDynamic(item['UoMCode']),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13),
                ),
                1,
                60,
              ),
              _buildColumn(
                Text(
                  formatQuantity(getDataFromDynamic(item['Quantity'] ?? "0")),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13),
                ),
                1,
                90,
              ),
            ],
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
