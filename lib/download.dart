import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:wms_mobile/constant/style.dart';
import 'package:wms_mobile/feature/bin_location/presentation/cubit/bin_offline_cubit.dart';
import 'package:wms_mobile/feature/business_partner/presentation/cubit/bussinessPartner_offline_cubit.dart';
import 'package:wms_mobile/feature/counting/cos/presentation/cubit/cos_offline_cubit.dart';
import 'package:wms_mobile/feature/good_isuse_select/presentation/cubit/isuse_type_offline_cubit.dart';
import 'package:wms_mobile/feature/good_receipt_type/presentation/cubit/receipt_type_offline_cubit.dart';
import 'package:wms_mobile/feature/inbound/purchase_order/presentation/cubit/purchase_order_offline_cubit.dart';
import 'package:wms_mobile/feature/inbound/return_receipt_request/presentation/cubit/return_receipt_request_offline_cubit.dart';
import 'package:wms_mobile/feature/item/presentation/cubit/items_barcode_offline_cubit.dart';
import 'package:wms_mobile/feature/item/presentation/cubit/items_cycle_count_offline_cubit.dart';
import 'package:wms_mobile/feature/item/presentation/cubit/items_find_stock_offline_cubit.dart';
import 'package:wms_mobile/feature/item/presentation/cubit/items_offline_cubit.dart';
import 'package:wms_mobile/feature/list_batch/presentation/cubit/batch_list_offline_cubit.dart';
import 'package:wms_mobile/feature/middleware/presentation/bloc/authorization_bloc.dart';
import 'package:wms_mobile/feature/outbounce/purchase_return_request/presentation/cubit/purchase_return_request_offline_cubit.dart';
import 'package:wms_mobile/feature/outbounce/sale_order/presentation/cubit/sale_order_offline_cubit.dart';
import 'package:wms_mobile/feature/unit_of_measurement/presentation/cubit/uom_group_offline_cubit.dart';
import 'package:wms_mobile/feature/unit_of_measurement/presentation/cubit/uom_offline_cubit.dart';
import 'package:wms_mobile/feature/warehouse/presentation/cubit/warhouse_offline_cubit.dart';
import 'package:wms_mobile/feature/warehouse/presentation/screen/warehouse_page.dart';
import 'package:wms_mobile/utilies/dialog/dialog.dart';
import 'package:wms_mobile/utilies/storage/locale_storage.dart';
import '/helper/helper.dart';

class DownloadItem {
  final String name;
  final String url;
  final Map<String, String>? queryParams;
  final Future<void> Function(BuildContext, dynamic) onSave;
  final void Function(BuildContext)? onClear;
  bool isLoading;
  bool success;
  bool failed;
  int downloadedCount;
  String progressText;
  double progressValue;

  DownloadItem({
    required this.name,
    required this.url,
    required this.onSave,
    this.onClear,
    this.queryParams,
    this.isLoading = false,
    this.success = false,
    this.failed = false,
    this.downloadedCount = 0,
    this.progressText = "",
    this.progressValue = 0.0,
  });
}

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({super.key, required this.fromDashboard});
  final bool fromDashboard;
  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  bool isDownloadingAll = false;
  String isDownloadedString = "";
  String downloadStatus = "";

  final List<DownloadItem> _downloads = [
    DownloadItem(
      name: 'Purchase Orders',
      url: 'PurchaseOrders',
      queryParams: {
        '\$filter': "DocumentStatus eq 'bost_Open'",
        '\$select':
            "DocEntry,CardCode,CardName,DocNum,DocDueDate,Comments,DocDate,DocumentLines,DocumentStatus"
      },
      onClear: (context) =>
          context.read<PurchaseOrderOfflineCubit>().clearData(),
      onSave: (context, data) async =>
          context.read<PurchaseOrderOfflineCubit>().addData(data),
    ),
    DownloadItem(
      name: 'Sale Orders',
      url: 'Orders',
      queryParams: {
        '\$filter': "DocumentStatus eq 'bost_Open'",
        '\$select':
            "DocEntry,CardCode,CardName,DocNum,DocDueDate,Comments,DocDate,DocumentLines,DocumentStatus"
      },
      onClear: (context) => context.read<SaleOrderOfflineCubit>().clearData(),
      onSave: (context, data) async =>
          context.read<SaleOrderOfflineCubit>().addData(data),
    ),
    DownloadItem(
      name: 'Goods Return Request',
      url: 'GoodsReturnRequest',
      queryParams: {
        '\$filter': "DocumentStatus eq 'bost_Open'",
        '\$select':
            "DocEntry,CardCode,CardName,DocNum,DocDueDate,Comments,DocDate,DocumentLines,DocumentStatus"
      },
      onClear: (context) =>
          context.read<PurchaseReturnRequestOfflineCubit>().clearData(),
      onSave: (context, data) async =>
          context.read<PurchaseReturnRequestOfflineCubit>().addData(data),
    ),
    DownloadItem(
      name: 'Return Request',
      url: 'ReturnRequest',
      queryParams: {
        '\$filter': "DocumentStatus eq 'bost_Open'",
        '\$select':
            "DocEntry,CardCode,CardName,DocNum,DocDueDate,Comments,DocDate,DocumentLines,DocumentStatus"
      },
      onClear: (context) =>
          context.read<ReturnReceiptRequestOfflineCubit>().clearData(),
      onSave: (context, data) async =>
          context.read<ReturnReceiptRequestOfflineCubit>().addData(data),
    ),
    DownloadItem(
      name: 'Business Partners',
      url: 'BusinessPartners',
      queryParams: {
        '\$select': "CardCode,CardName,CardType,CurrentAccountBalance"
      },
      onClear: (context) => context.read<BusinessOfflineCubit>().clearData(),
      onSave: (context, data) async =>
          context.read<BusinessOfflineCubit>().addData(data),
    ),
    DownloadItem(
      name: 'Counting Sheets',
      url: 'InventoryCountings',
      queryParams: {
        '\$select': "DocumentNumber,DocumentStatus,DocumentEntry",
        '\$filter': "DocumentStatus eq 'cdsOpen'"
      },
      onClear: (context) => context.read<COSOfflineCubit>().clearData(),
      onSave: (context, data) async =>
          context.read<COSOfflineCubit>().addData(data),
    ),
    DownloadItem(
      name: 'Warehouses',
      url: 'Warehouses',
      queryParams: {'\$select': "WarehouseCode,WarehouseName"},
      onClear: (context) => context.read<WarehouseOfflineCubit>().clearData(),
      onSave: (context, data) async =>
          context.read<WarehouseOfflineCubit>().addData(data),
    ),
    DownloadItem(
      name: 'Items',
      url: 'Items',
      queryParams: {
        '\$select':
            "ItemCode,ItemName,PurchaseItem,InventoryItem,SalesItem,InventoryUOM,UoMGroupEntry,InventoryUoMEntry,DefaultPurchasingUoMEntry,DefaultSalesUoMEntry, ManageSerialNumbers, ManageBatchNumbers"
      },
      onClear: (context) => context.read<ItemOfflineCubit>().clearData(),
      onSave: (context, data) async =>
          context.read<ItemOfflineCubit>().addData(data),
    ),
    DownloadItem(
      name: 'UoM Groups',
      url: 'UnitOfMeasurementGroups',
      onClear: (context) => context.read<UOMGroupOfflineCubit>().clearData(),
      onSave: (context, data) async =>
          context.read<UOMGroupOfflineCubit>().addData(data),
    ),
    DownloadItem(
      name: 'UoM',
      url: 'UnitOfMeasurements',
      onClear: (context) => context.read<UOMOfflineCubit>().clearData(),
      onSave: (context, data) async =>
          context.read<UOMOfflineCubit>().addData(data),
    ),
    DownloadItem(
      name: 'Item Barcode',
      url: 'view.svc/WMS_ITEM_BARCODEB1SLQuery',
      onClear: (context) => context.read<ItemBarcodeOfflineCubit>().clearData(),
      onSave: (context, data) async =>
          context.read<ItemBarcodeOfflineCubit>().addData(data),
    ),
    DownloadItem(
      name: 'Item Cycle Count',
      url: 'view.svc/CycleItemCountB1SLQuery',
      onClear: (context) =>
          context.read<ItemCycleCountOfflineCubit>().clearData(),
      onSave: (context, data) async =>
          context.read<ItemCycleCountOfflineCubit>().addData(data),
    ),
    DownloadItem(
      name: 'Item Stock',
      url: 'view.svc/ItemB1SLQuery',
      onClear: (context) =>
          context.read<ItemFindStockOfflineCubit>().clearData(),
      onSave: (context, data) async =>
          context.read<ItemFindStockOfflineCubit>().addData(data),
    ),
    DownloadItem(
      name: 'Serial Batch Lists',
      url: 'view.svc/WMS_SERIAL_BATCHB1SLQuery',
      onClear: (context) => context.read<BatchListOfflineCubit>().clearData(),
      onSave: (context, data) async =>
          context.read<BatchListOfflineCubit>().addData(data),
    ),
    DownloadItem(
      name: 'Bin Locations',
      url: 'BinLocations',
      queryParams: {
        '\$select': "AbsEntry,Warehouse,Sublevel1,Sublevel2,Sublevel3,BinCode"
      },
      onClear: (context) => context.read<BinOfflineCubit>().clearData(),
      onSave: (context, data) async =>
          context.read<BinOfflineCubit>().addData(data),
    ),
    DownloadItem(
      name: 'Goods Issue Type',
      url: 'LK_OIGE',
      onClear: (context) => context.read<IssueTypeOfflineCubit>().clearData(),
      onSave: (context, data) async =>
          context.read<IssueTypeOfflineCubit>().addData(data),
    ),
    DownloadItem(
      name: 'Goods Receipt Type',
      url: 'LK_OIGN',
      onClear: (context) => context.read<ReceiptTypeOfflineCubit>().clearData(),
      onSave: (context, data) async =>
          context.read<ReceiptTypeOfflineCubit>().addData(data),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadDownloadState();
  }

  Future<void> _logout() async {
    MaterialDialog.loading(context);
    await _clearAllDataFromCatchError();
    const timeoutDuration = Duration(milliseconds: 200);
    Future.delayed(timeoutDuration, () {
      if (mounted) {
        BlocProvider.of<AuthorizationBloc>(context)
            .add(const RequestLogoutEvent());
      }
    });
  }

  /// -----------------------------
  /// 💾 Save & Load State
  /// -----------------------------
  Future<void> _saveDownloadState() async {
    final List<Map<String, dynamic>> stateList = _downloads.map((e) {
      return {
        'name': e.name,
        'isLoading': e.isLoading,
        'success': e.success,
        'failed': e.failed,
      };
    }).toList();

    await LocalStorageManger.setString(
      'download_status',
      jsonEncode(stateList),
    );
  }

  Future<void> _loadDownloadState() async {
    final jsonString = await LocalStorageManger.getString('download_status');
    final isDownloaded = await LocalStorageManger.getString('isDownloaded');
    isDownloadedString = isDownloaded;
    try {
      final List<dynamic> stateList = jsonDecode(jsonString);
      for (final state in stateList) {
        final item = _downloads.firstWhere(
          (d) => d.name == state['name'],
          orElse: () => _downloads.first,
        );
        item.isLoading = state['isLoading'] ?? false;
        item.success = state['success'] ?? false;
        item.failed = state['failed'] ?? false;
      }
      setState(() {});
    } catch (e) {
      debugPrint('⚠️ Failed to load download state: $e');
    }
  }

  /// -----------------------------
  /// 🔄 Sync Functions
  /// -----------------------------
  Future<void> _downloadAllSequentially() async {
    if (isDownloadedString == "true") return;

    setState(() => isDownloadingAll = true);
    await LocalStorageManger.setString('isDownloaded', 'false');
    isDownloadedString = "false";

    // 1️⃣ Load offline credentials
    final username = await LocalStorageManger.getString('username');
    final password = await LocalStorageManger.getString('password');
    final host = await LocalStorageManger.getString('host');
    final port = await LocalStorageManger.getString('port');
    final company = await LocalStorageManger.getString('db');

    if (username.isEmpty || password.isEmpty || company.isEmpty) {
      MaterialDialog.warning(
        context,
        title: "Error",
        body: "No stored credentials found.",
      );
      setState(() => isDownloadingAll = false);
      return;
    }
    print(company);
    print(username);
    print(password);
    print("Login....");
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
      debugPrint("❌ Login failed: ${loginResponse.body}");
      await LocalStorageManger.setString('isDownloaded', 'false');
      isDownloadedString = "false";
      setState(() {
        isDownloadingAll = false;
        downloadStatus = "Failed Login to SAP";
      });
      return;
    }

    final loginData = jsonDecode(loginResponse.body);
    final token = loginData['SessionId'];
    if (token == null) {
      debugPrint("❌ Token not found in login response");
      await LocalStorageManger.setString('isDownloaded', 'false');
      isDownloadedString = "false";
      setState(() {
        isDownloadingAll = false;
        downloadStatus = "Token not found in login response";
      });
      return;
    }

    print("✅ Login Successfully..");

    bool allSuccess = true;

    for (final item in _downloads) {
      if (item.success) continue; // Skip if already synced successfully
      final success = await _fetchAndSave(item, token, host, port);
      if (!success) {
        print(success);
        allSuccess = false;
        debugPrint('❌ Failed to download ${item.name}');
        // immediately mark as not downloaded
        await LocalStorageManger.setString('isDownloaded', 'false');
        setState(() {
          isDownloadedString = "false";
          downloadStatus = "Failed to download ${item.name}";
        });
        await _clearAllDataFromCatchError();
        break;
      }
    }

    if (allSuccess) {
      await LocalStorageManger.setString('isDownloaded', 'true');
      isDownloadedString = "true";
    } else {
      await LocalStorageManger.setString('isDownloaded', 'false');
      setState(() {
        isDownloadedString = "false";
      });
      await _clearAllDataFromCatchError();
    }

    setState(() => isDownloadingAll = false);
  }

  Future<void> _syncSingleItem(DownloadItem item) async {
    if (isDownloadingAll || item.isLoading) return;

    final connected = await hasInternet();
    if (!connected) {
      MaterialDialog.warning(context,
          title: "No Connection",
          body: "Please connect to Wi-Fi or mobile data.");
      return;
    }

    final username = await LocalStorageManger.getString('username');
    final password = await LocalStorageManger.getString('password');
    final host = await LocalStorageManger.getString('host');
    final port = await LocalStorageManger.getString('port');
    final company = await LocalStorageManger.getString('db');

    if (username.isEmpty || password.isEmpty || company.isEmpty) {
      MaterialDialog.warning(
        context,
        title: "Error",
        body: "No stored credentials found.",
      );
      return;
    }

    setState(() {
      item.isLoading = true;
      item.failed = false;
      downloadStatus = "";
    });

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
      debugPrint("❌ Login failed: ${loginResponse.body}");
      setState(() {
        item.isLoading = false;
        item.failed = true;
        downloadStatus = "Failed Login to SAP";
      });
      return;
    }

    final loginData = jsonDecode(loginResponse.body);
    final token = loginData['SessionId'];
    if (token == null) {
      setState(() {
        item.isLoading = false;
        item.failed = true;
        downloadStatus = "Token not found in login response";
      });
      return;
    }

    final success = await _fetchAndSave(item, token, host, port);

    // Evaluate global status
    bool allSuccess = _downloads.every((element) => element.success);
    if (allSuccess) {
      await LocalStorageManger.setString('isDownloaded', 'true');
      setState(() {
        isDownloadedString = "true";
      });
    } else {
      await LocalStorageManger.setString('isDownloaded', 'false');
      setState(() {
        isDownloadedString = "false";
      });
    }
  }

  Future<bool> _fetchAndSave(
      DownloadItem item, dynamic token, dynamic host, dynamic port) async {
    setState(() {
      item.isLoading = true;
      item.failed = false;
      item.success = false;
    });
    await _saveDownloadState();

    try {
      int skip = 0;
      int top = 3000;
      List<dynamic> allValues = [];
      bool hasMore = true;
      int totalCount = 0;

      // Step 1️⃣ — Get list from SAP with pagination loop
      while (hasMore) {
        Map<String, String> currentParams = Map.from(item.queryParams ?? {});
        currentParams['\$top'] = top.toString();
        currentParams['\$skip'] = skip.toString();

        if (skip == 0) {
          currentParams['\$inlinecount'] = 'allpages';
        }

        final data = await getFromSAP(
          host: host,
          port: port,
          token: token,
          endpoint: item.url,
          queryParams: currentParams,
        );

        if (skip == 0) {
          final countRaw = data["odata.count"] ?? data["@odata.count"];
          totalCount = int.tryParse(countRaw?.toString() ?? "0") ?? 0;
        }

        List<dynamic> values = data["value"] ?? [];
        allValues.addAll(values);

        setState(() {
          item.downloadedCount = allValues.length;
          if (totalCount > 0) {
            item.progressText =
                "Downloading ${item.downloadedCount}/$totalCount...";
            item.progressValue = item.downloadedCount / totalCount;
          } else {
            item.progressText = "Downloading ${item.downloadedCount}...";
          }
        });

        if (values.length < top) {
          hasMore = false;
        } else {
          skip += top;
        }
      }

      // Step 2️⃣ — Special case for InventoryCountings
      if (item.url == "InventoryCountings") {
        List<dynamic> detailedList = [];

        // Loop through each item and fetch details by ID
        for (final inv in allValues) {
          final docEntry = inv["DocumentEntry"];
          if (docEntry == null) continue;

          try {
            final detail = await getFromSAP(
              host: host,
              port: port,
              token: token,
              endpoint: "InventoryCountings($docEntry)",
            );

            detailedList.add(detail);
            debugPrint("✅ Loaded detail for InventoryCounting $docEntry");
          } catch (e) {
            debugPrint("⚠️ Failed to fetch detail for $docEntry: $e");
          }
        }
        // Optionally also call item.onSave if needed
        item.onClear?.call(context);
        await item.onSave(context, detailedList);
      } else {
        // Normal behavior for other endpoints
        item.onClear?.call(context);
        await item.onSave(context, allValues);
      }

      setState(() {
        item.success = true;
        item.isLoading = false;
        item.failed = false;
      });
      await _saveDownloadState();
      return true;
    } catch (e) {
      debugPrint('❌ Fetch failed for ${item.url}: $e');
      setState(() {
        item.failed = true;
        item.isLoading = false;
        item.success = false;
      });
      await _saveDownloadState();
      return false;
    }
  }

  Future<void> _clearAllData() async {
    if (context.read<ItemOfflineCubit>().state.isEmpty) return;
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Clear All Data?"),
        content: const Text(
            "This will remove all offline data and reset download states. Are you sure?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Clear",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    // User canceled
    if (confirm != true) return;

    // 1️⃣ Clear all Cubits
    context.read<PurchaseOrderOfflineCubit>().clearData();
    context.read<BusinessOfflineCubit>().clearData();
    context.read<WarehouseOfflineCubit>().clearData();
    context.read<BinOfflineCubit>().clearData();
    context.read<ItemOfflineCubit>().clearData();
    context.read<UOMGroupOfflineCubit>().clearData();
    context.read<UOMOfflineCubit>().clearData();
    context.read<ItemBarcodeOfflineCubit>().clearData();
    context.read<BatchListOfflineCubit>().clearData();
    context.read<ReceiptTypeOfflineCubit>().clearData();
    context.read<IssueTypeOfflineCubit>().clearData();
    context.read<ReturnReceiptRequestOfflineCubit>().clearData();
    context.read<SaleOrderOfflineCubit>().clearData();
    context.read<PurchaseReturnRequestOfflineCubit>().clearData();
    context.read<ItemFindStockOfflineCubit>().clearData();
    context.read<ItemCycleCountOfflineCubit>().clearData();
    context.read<COSOfflineCubit>().clearData();

    // 3️⃣ Reset all download states
    for (var item in _downloads) {
      item.success = false;
      item.failed = false;
      item.isLoading = false;
    }

    // 4️⃣ Save cleared download state
    await _saveDownloadState();

    // 5️⃣ Update storage
    await LocalStorageManger.setString('isDownloaded', 'false');
    await LocalStorageManger.setString('warehouse', "");
    await LocalStorageManger.setString('warehouseName', "No Warehouse");

    setState(() {
      isDownloadedString = "false";
    });

    // 6️⃣ Optional: feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "All offline data cleared",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 49, 49, 51),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _clearAllDataFromCatchError() async {
    // 1️⃣ Clear all Cubits
    context.read<PurchaseOrderOfflineCubit>().clearData();
    context.read<BusinessOfflineCubit>().clearData();
    context.read<WarehouseOfflineCubit>().clearData();
    context.read<BinOfflineCubit>().clearData();
    context.read<ItemOfflineCubit>().clearData();
    context.read<UOMGroupOfflineCubit>().clearData();
    context.read<UOMOfflineCubit>().clearData();
    context.read<ItemBarcodeOfflineCubit>().clearData();
    context.read<BatchListOfflineCubit>().clearData();
    context.read<ReceiptTypeOfflineCubit>().clearData();
    context.read<IssueTypeOfflineCubit>().clearData();
    context.read<ReturnReceiptRequestOfflineCubit>().clearData();
    context.read<SaleOrderOfflineCubit>().clearData();
    context.read<PurchaseReturnRequestOfflineCubit>().clearData();
    context.read<ItemFindStockOfflineCubit>().clearData();
    context.read<ItemCycleCountOfflineCubit>().clearData();
    context.read<COSOfflineCubit>().clearData();

    // 3️⃣ Reset all download states
    for (var item in _downloads) {
      item.success = false;
      item.failed = false;
      item.isLoading = false;
    }

    // 4️⃣ Save cleared download state
    await _saveDownloadState();

    // 5️⃣ Update storage
    await LocalStorageManger.setString('isDownloaded', 'false');
    await LocalStorageManger.setString('warehouse', "");
    await LocalStorageManger.setString('warehouseName', "No Warehouse");

    // 6️⃣ Update UI
    setState(() {
      isDownloadedString = "false";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        leading: null,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: widget.fromDashboard ? true : false,
        title: Center(
            child: const Text(
          'Data ',
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        )),
        backgroundColor: PRIMARY_COLOR,
        elevation: 3,
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.refresh),
          //   tooltip: 'Reset Status',
          //   onPressed: _resetSyncStatus,
          // ),

          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
              size: 28,
            ),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
          SizedBox(
            width: 10,
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Modern Header & Dashboard Link
          Padding(
            padding: widget.fromDashboard
                ? const EdgeInsets.fromLTRB(20, 30, 20, 10)
                : const EdgeInsets.fromLTRB(20, 15, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(
                      Icons.cloud_sync,
                      size: 28,
                      color: PRIMARY_COLOR,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Data Sync",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: PRIMARY_COLOR,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                if (!widget.fromDashboard)
                  InkWell(
                    onTap: () async {
                      if (isDownloadedString != "true") {
                        MaterialDialog.warning(
                          onConfirm: () => _downloadAllSequentially(),
                          confirmLabel: "Download",
                          context,
                          title: 'Failed',
                          body: "Data must be downloaded before proceeding.",
                        );
                        return;
                      }
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WarehousePage(isPicker: true),
                        ),
                        (Route<dynamic> route) => false,
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: Row(
                        children: const [
                          Text(
                            "Dashboard",
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.blueAccent,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Error Message Display
          if (downloadStatus.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10, left: 20, right: 20),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        downloadStatus,
                        style: const TextStyle(
                            color: Colors.red, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Modern Action Buttons (Download & Clear)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isDownloadingAll || isDownloadedString == "true"
                              ? Colors.grey.shade400
                              : PRIMARY_COLOR,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: isDownloadingAll
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5),
                          )
                        : Icon(
                            isDownloadedString == "true"
                                ? Icons.cloud_done
                                : Icons.cloud_download,
                            size: 22,
                          ),
                    label: Text(
                      isDownloadingAll
                          ? 'Syncing...'
                          : isDownloadedString == "true"
                              ? "Up to Date"
                              : 'Sync All Data',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onPressed: () async {
                      if (isDownloadedString == "true" || isDownloadingAll)
                        return;
                      final connected = await hasInternet();
                      if (!connected) {
                        MaterialDialog.warning(context,
                            title: "No Connection",
                            body: "Please connect to Wi-Fi or mobile data.");
                        return;
                      }
                      _downloadAllSequentially();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.redAccent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                            color: Colors.redAccent.shade100, width: 1.5),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: isDownloadingAll ? null : _clearAllData,
                    child: const Icon(Icons.delete_sweep, size: 24),
                  ),
                ),
              ],
            ),
          ),

          // Overall Progress Indicator
          if (isDownloadingAll)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Downloading data...",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, color: Colors.black54),
                      ),
                      Text(
                        "${_downloads.where((e) => e.success).length} / ${_downloads.length}",
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, color: PRIMARY_COLOR),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: _downloads.isEmpty
                          ? 0
                          : _downloads.where((e) => e.success).length /
                              _downloads.length,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade300,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(PRIMARY_COLOR),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 10),

          // List of Sync Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 20),
              itemCount: _downloads.length,
              itemBuilder: (context, index) => _buildApiCard(_downloads[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApiCard(DownloadItem item) {
    // Determine visual state
    Color cardColor = Colors.white;
    Color iconBgColor = Colors.grey.shade100;
    Color iconColor = Colors.grey.shade600;
    IconData iconData = Icons.cloud_download_outlined;

    if (item.success) {
      cardColor = Colors.green.shade50;
      iconBgColor = Colors.green.shade100;
      iconColor = Colors.green;
      iconData = Icons.check_circle_rounded;
    } else if (item.failed) {
      cardColor = Colors.red.shade50;
      iconBgColor = Colors.red.shade100;
      iconColor = Colors.red;
      iconData = Icons.error_rounded;
    } else if (item.isLoading) {
      cardColor = Colors.blue.shade50;
      iconBgColor = Colors.blue.shade100;
      iconColor = Colors.blueAccent;
      // iconData will be replaced with progress indicator
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.isLoading
              ? Colors.blueAccent.withOpacity(0.3)
              : item.success
                  ? Colors.green.withOpacity(0.3)
                  : item.failed
                      ? Colors.red.withOpacity(0.3)
                      : Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconBgColor,
            shape: BoxShape.circle,
          ),
          child: item.isLoading
              ? const Padding(
                  padding: EdgeInsets.all(14.0),
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: Colors.blueAccent),
                )
              : Icon(iconData, color: iconColor, size: 24),
        ),
        title: Text(
          item.name,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: item.success ? Colors.green.shade800 : Colors.black87,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            item.isLoading
                ? 'Syncing data...'
                : item.success
                    ? 'Successfully synced'
                    : item.failed
                        ? 'Failed. Will retry.'
                        : 'Waiting to sync',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: item.isLoading
                  ? Colors.blueAccent
                  : item.success
                      ? Colors.green.shade700
                      : item.failed
                          ? Colors.red.shade700
                          : Colors.grey.shade600,
            ),
          ),
        ),
        trailing: IconButton(
          tooltip: 'Sync this item',
          icon: Icon(
            Icons.sync,
            color: item.isLoading || isDownloadingAll
                ? Colors.grey
                : Colors.blueAccent,
          ),
          onPressed: item.isLoading || isDownloadingAll
              ? null
              : () => _syncSingleItem(item),
        ),
      ),
    );
  }
}
