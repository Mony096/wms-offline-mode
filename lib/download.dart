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
  bool isLoading;
  bool success;
  bool failed;

  DownloadItem({
    required this.name,
    required this.url,
    required this.onSave,
    this.queryParams,
    this.isLoading = false,
    this.success = false,
    this.failed = false,
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
      onSave: (context, data) async =>
          context.read<ReturnReceiptRequestOfflineCubit>().addData(data),
    ),
    DownloadItem(
      name: 'Business Partners',
      url: 'BusinessPartners',
      queryParams: {'\$select': "CardCode,CardName,CardType"},
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
      onSave: (context, data) async =>
          context.read<COSOfflineCubit>().addData(data),
    ),
    DownloadItem(
      name: 'Warehouses',
      url: 'Warehouses',
      queryParams: {'\$select': "WarehouseCode,WarehouseName"},
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
      onSave: (context, data) async =>
          context.read<ItemOfflineCubit>().addData(data),
    ),
    DownloadItem(
      name: 'UoM Groups',
      url: 'UnitOfMeasurementGroups',
      onSave: (context, data) async =>
          context.read<UOMGroupOfflineCubit>().addData(data),
    ),
    DownloadItem(
      name: 'UoM',
      url: 'UnitOfMeasurements',
      onSave: (context, data) async =>
          context.read<UOMOfflineCubit>().addData(data),
    ),
    DownloadItem(
      name: 'Item Barcode',
      url: 'view.svc/WMS_ITEM_BARCODEB1SLQuery',
      onSave: (context, data) async =>
          context.read<ItemBarcodeOfflineCubit>().addData(data),
    ),
    DownloadItem(
      name: 'Item Cycle Count',
      url: 'view.svc/CycleItemCountB1SLQuery',
      onSave: (context, data) async =>
          context.read<ItemCycleCountOfflineCubit>().addData(data),
    ),
    DownloadItem(
      name: 'Item Stock',
      url: 'view.svc/ItemB1SLQuery',
      onSave: (context, data) async =>
          context.read<ItemFindStockOfflineCubit>().addData(data),
    ),
    DownloadItem(
      name: 'Serial Batch Lists',
      url: 'view.svc/WMS_SERIAL_BATCHB1SLQuery',
      onSave: (context, data) async =>
          context.read<BatchListOfflineCubit>().addData(data),
    ),
    DownloadItem(
      name: 'Bin Locations',
      url: 'BinLocations',
      queryParams: {
        '\$select': "AbsEntry,Warehouse,Sublevel1,Sublevel2,Sublevel3,BinCode"
      },
      onSave: (context, data) async =>
          context.read<BinOfflineCubit>().addData(data),
    ),
    DownloadItem(
      name: 'Goods Issue Type',
      url: 'LK_OIGE',
      onSave: (context, data) async =>
          context.read<IssueTypeOfflineCubit>().addData(data),
    ),
    DownloadItem(
      name: 'Goods Receipt Type',
      url: 'LK_OIGN',
      onSave: (context, data) async =>
          context.read<ReceiptTypeOfflineCubit>().addData(data),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadDownloadState();
  }

  void _logout() {
    MaterialDialog.loading(context);
    _clearAllDataFromCatchError();
    const timeoutDuration = Duration(milliseconds: 200);
    Future.delayed(timeoutDuration, () {
      BlocProvider.of<AuthorizationBloc>(context)
          .add(const RequestLogoutEvent());
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
      if (isDownloadedString == "false") {
        for (var item in _downloads) {
          item.success = false;
          item.failed = false;
          item.isLoading = false;
        }
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

  // Future<bool> _fetchAndSave(
  //     DownloadItem item, dynamic token, dynamic host, dynamic port) async {
  //   setState(() {
  //     item.isLoading = true;
  //     item.failed = false;
  //     item.success = false;
  //   });
  //   await _saveDownloadState();

  //   try {
  //     final data = await getFromSAP(
  //       host: host,
  //       port: port,
  //       token: token,
  //       endpoint: item.url,
  //       queryParams: item.queryParams,
  //     );

  //     await item.onSave(context, data["value"]);

  //     setState(() {
  //       item.success = true;
  //       item.isLoading = false;
  //       item.failed = false;
  //     });
  //     await _saveDownloadState();
  //     return true;
  //   } catch (e) {
  //     debugPrint('❌ Fetch failed for ${item.url}: $e');
  //     setState(() {
  //       item.failed = true;
  //       item.isLoading = false;
  //       item.success = false;
  //     });
  //     await _saveDownloadState();
  //     return false;
  //   }
  // }
  Future<bool> _fetchAndSave(
      DownloadItem item, dynamic token, dynamic host, dynamic port) async {
    setState(() {
      item.isLoading = true;
      item.failed = false;
      item.success = false;
    });
    await _saveDownloadState();

    try {
      // Step 1️⃣ — Get list from SAP
      final data = await getFromSAP(
        host: host,
        port: port,
        token: token,
        endpoint: item.url,
        queryParams: item.queryParams,
      );

      var values = data["value"];

      // Step 2️⃣ — Special case for InventoryCountings
      if (item.url == "InventoryCountings") {
        List<dynamic> detailedList = [];

        // Loop through each item and fetch details by ID
        for (final inv in values) {
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
        await item.onSave(context, detailedList);
      } else {
        // Normal behavior for other endpoints
        await item.onSave(context, values);
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

    // 5️⃣ Update UI
    setState(() {
      LocalStorageManger.setString('isDownloaded', 'false');
      LocalStorageManger.setString('warehouse', "");
      LocalStorageManger.setString('warehouseName', "No Warehouse");
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

    // 5️⃣ Update UI
    setState(() {
      LocalStorageManger.setString('isDownloaded', 'false');
      LocalStorageManger.setString('warehouse', "");
      LocalStorageManger.setString('warehouseName', "No Warehouse");
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: widget.fromDashboard
                    ? const EdgeInsets.only(left: 8, top: 30, bottom: 5)
                    : const EdgeInsets.only(left: 8, top: 15),
                child: Row(
                  children: const [
                    Icon(
                      Icons.cloud_download,
                      size: 2,
                      color: PRIMARY_COLOR,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      "Data Synchronization",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: PRIMARY_COLOR),
                    ),
                  ],
                ),
              ),
              widget.fromDashboard
                  ? Container()
                  : Container(
                      width: 120,
                      margin:
                          const EdgeInsets.only(right: 15, top: 15, bottom: 4),
                      child: InkWell(
                        onTap: () async {
                          if (isDownloadedString != "true") {
                            MaterialDialog.warning(
                              onConfirm: () => _downloadAllSequentially(),
                              confirmLabel: "Download",
                              context,
                              title: 'Failed',
                              body:
                                  "Data must be downloaded before proceeding.",
                            );
                            return;
                          }
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const WarehousePage(isPicker: true),
                            ),
                            (Route<dynamic> route) => false,
                          );
                        },
                        borderRadius: BorderRadius.circular(4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: const [
                            Expanded(
                              child: Text(
                                "Go Dashboard",
                                style: TextStyle(
                                  color: Colors.blue, // 🔵 Blue text
                                  decoration:
                                      TextDecoration.underline, // underline
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_right,
                              color: Colors.blue, // match text color
                              size: 23,
                            ),
                          ],
                        ),
                      ),
                    ),
            ],
          ),
          downloadStatus.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(top: 6, bottom: 8, left: 20),
                  child: Text(
                    'Error:  $downloadStatus',
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ),
                )
              : Container(),
          Row(
            children: [
              Expanded(
                flex: 4,
                child:
                    // Container(
                    //   margin:
                    //       const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    //   child: ElevatedButton.icon(
                    //     style: ElevatedButton.styleFrom(
                    //       backgroundColor:
                    //           isDownloadingAll || isDownloadedString == "true"
                    //               ? Colors.grey
                    //               : PRIMARY_COLOR,
                    //       shape: RoundedRectangleBorder(
                    //           borderRadius: BorderRadius.circular(10)),
                    //       padding: const EdgeInsets.symmetric(vertical: 14),
                    //     ),
                    //     onPressed:
                    //         isDownloadingAll ? null : _downloadAllSequentially,
                    //     icon: const Icon(Icons.cloud_download, color: Colors.white),
                    //     label: Text(
                    //       isDownloadingAll
                    //           ? 'Downloading...'
                    //           : isDownloadedString == "true"
                    //               ? "Downloaded"
                    //               : 'Download ',
                    //       style: const TextStyle(
                    //           fontSize: 16,
                    //           fontWeight: FontWeight.w600,
                    //           color: Colors.white),
                    //     ),
                    //   ),
                    // ),
                    Container(
                  height: 47,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      colors: [
                        isDownloadingAll || isDownloadedString == "true"
                            ? const Color.fromARGB(255, 192, 190, 190)
                            : PRIMARY_COLOR.withOpacity(0.9),
                        isDownloadingAll || isDownloadedString == "true"
                            ? const Color.fromARGB(255, 192, 190, 190)
                            : PRIMARY_COLOR.withOpacity(0.7),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  margin:
                      EdgeInsets.only(right: 15, left: 20, bottom: 10, top: 15),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors
                          .transparent, // Make button background transparent
                      shadowColor: Colors.transparent, // Remove default shadow
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 17, vertical: 0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.download,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          isDownloadingAll
                              ? 'Downloading...'
                              : isDownloadedString == "true"
                                  ? "Downloaded"
                                  : 'Download ',
                          style: TextStyle(
                              color: Colors.white, // ⚪ White text
                              fontWeight: FontWeight.bold,
                              fontSize: 14),
                        ),
                      ],
                    ),
                    onPressed: () async {
                      if (isDownloadedString == "true") return;
                      final connected = await hasInternet();
                      if (!connected) {
                        MaterialDialog.warning(context,
                            title: "Error Connection",
                            body:
                                "No internet connection. Please connect to Wi-Fi or mobile data.");

                        return;
                      }
                      _downloadAllSequentially();
                    },
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  height: 47,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      colors: [
                        context.read<UOMGroupOfflineCubit>().state.isEmpty
                            ? const Color.fromARGB(255, 192, 190, 190)
                            : PRIMARY_COLOR.withOpacity(0.9),
                        context.read<UOMGroupOfflineCubit>().state.isEmpty
                            ? const Color.fromARGB(255, 192, 190, 190)
                            : PRIMARY_COLOR.withOpacity(0.7),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  margin: EdgeInsets.only(right: 20, bottom: 10, top: 15),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors
                          .transparent, // Make button background transparent
                      shadowColor: Colors.transparent, // Remove default shadow
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 17, vertical: 0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          "Clear",
                          style: TextStyle(
                              color: Colors.white, // ⚪ White text
                              fontWeight: FontWeight.bold,
                              fontSize: 14),
                        ),
                      ],
                    ),
                    onPressed: () async {
                      _clearAllData();
                    },
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _downloads.length,
              itemBuilder: (context, index) => _buildApiCard(_downloads[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApiCard(DownloadItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 6,
            color: Colors.black.withOpacity(0.06),
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: item.success
              ? const Color.fromARGB(255, 146, 149, 149)
              : item.failed
                  ? Colors.redAccent
                  : item.isLoading
                      ? Colors.blueAccent
                      : Colors.grey.shade400,
          child: Icon(
            item.success
                ? Icons.check_circle
                : item.failed
                    ? Icons.error
                    : item.isLoading
                        ? Icons.hourglass_top
                        : Icons.cloud_download,
            color: Colors.white,
          ),
        ),
        title: Text(
          item.name,
          style: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87),
        ),
        // CircularProgressIndicator
        subtitle: item.isLoading
            ? Row(
                children: const [
                  SizedBox(
                      width: 17,
                      height: 17,
                      child: CircularProgressIndicator(
                        color: Colors.blue,
                        strokeWidth: 2,
                      )),
                  SizedBox(
                    width: 7,
                  ),
                  Text(
                    'Downloading data...',
                    style: TextStyle(fontSize: 14),
                  )
                ],
              )
            : Text(
                item.success
                    ? 'Downloaded successfully'
                    : item.failed
                        ? '❌ Failed to download'
                        : 'Ready to sync',
                style: TextStyle(
                  fontSize: 13,
                  color: item.success
                      ? Colors.green
                      : item.failed
                          ? Colors.redAccent
                          : Colors.grey[700],
                ),
              ),
        trailing: IconButton(
          icon: Icon(
            item.isLoading
                ? Icons.hourglass_empty
                : item.success
                    ? Icons.download_done_outlined
                    : Icons.download,
            color: item.isLoading
                ? Colors.blueAccent
                : item.success
                    ? Colors.green
                    : Colors.blueAccent,
          ),
          onPressed: () {},
        ),
      ),
    );
  }
}
