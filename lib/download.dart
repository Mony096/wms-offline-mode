import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_mobile/constant/style.dart';
import 'package:wms_mobile/feature/bin_location/presentation/cubit/bin_offline_cubit.dart';
import 'package:wms_mobile/feature/business_partner/presentation/cubit/bussinessPartner_offline_cubit.dart';
import 'package:wms_mobile/feature/good_isuse_select/presentation/cubit/isuse_type_offline_cubit.dart';
import 'package:wms_mobile/feature/good_receipt_type/presentation/cubit/receipt_type_offline_cubit.dart';
import 'package:wms_mobile/feature/inbound/purchase_order/presentation/cubit/purchase_order_offline_cubit.dart';
import 'package:wms_mobile/feature/inbound/return_receipt_request/presentation/cubit/return_receipt_request_offline_cubit.dart';
import 'package:wms_mobile/feature/item/presentation/cubit/items_barcode_offline_cubit.dart';
import 'package:wms_mobile/feature/item/presentation/cubit/items_offline_cubit.dart';
import 'package:wms_mobile/feature/list_batch/presentation/cubit/batch_list_offline_cubit.dart';
import 'package:wms_mobile/feature/outbounce/purchase_return_request/presentation/cubit/purchase_return_request_offline_cubit.dart';
import 'package:wms_mobile/feature/outbounce/sale_order/presentation/cubit/sale_order_offline_cubit.dart';
import 'package:wms_mobile/feature/unit_of_measurement/presentation/cubit/uom_group_offline_cubit.dart';
import 'package:wms_mobile/feature/unit_of_measurement/presentation/cubit/uom_offline_cubit.dart';
import 'package:wms_mobile/feature/warehouse/presentation/cubit/warhouse_offline_cubit.dart';
import 'package:wms_mobile/feature/warehouse/presentation/screen/warehouse_page.dart';
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
  final List<DownloadItem> _downloads = [
    DownloadItem(
      name: 'Purchase Orders',
      url: 'PurchaseOrders',
      queryParams: {
        '\$filter': "DocumentStatus eq 'bost_Open'",
        '\$select':
            "CardCode,CardName,DocNum,DocDueDate,Comments,DocDate,DocumentLines,DocumentStatus"
      },
      onSave: (context, data) async =>
          context.read<PurchaseOrderOfflineCubit>().addData(data),
    ),
    DownloadItem(
      name: 'Return Receipt Request',
      url: 'ReturnRequest',
      queryParams: {
        '\$filter': "DocumentStatus eq 'bost_Open'",
        '\$select':
            "CardCode,CardName,DocNum,DocDueDate,Comments,DocDate,DocumentLines,DocumentStatus"
      },
      onSave: (context, data) async =>
          context.read<ReturnReceiptRequestOfflineCubit>().addData(data),
    ),
    DownloadItem(
      name: 'Sale Orders',
      url: 'Orders',
      queryParams: {
        '\$filter': "DocumentStatus eq 'bost_Open'",
        '\$select':
            "CardCode,CardName,DocNum,DocDueDate,Comments,DocDate,DocumentLines,DocumentStatus"
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
            "CardCode,CardName,DocNum,DocDueDate,Comments,DocDate,DocumentLines,DocumentStatus"
      },
      onSave: (context, data) async =>
          context.read<PurchaseReturnRequestOfflineCubit>().addData(data),
    ),
    DownloadItem(
      name: 'Suppliers',
      url: 'BusinessPartners',
      queryParams: {'\$select': "CardCode,CardName,CardType"},
      onSave: (context, data) async =>
          context.read<BusinessOfflineCubit>().addData(data),
    ),
    DownloadItem(
      name: 'Warehouses',
      url: 'Warehouses',
      queryParams: {'\$select': "WarehouseCode,WarehouseName"},
      onSave: (context, data) async =>
          context.read<WarehouseOfflineCubit>().addData(data),
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
      name: 'UnitOfMeasurementGroups',
      url: 'UnitOfMeasurementGroups',
      onSave: (context, data) async =>
          context.read<UOMGroupOfflineCubit>().addData(data),
    ),
    DownloadItem(
      name: 'UnitOfMeasurements',
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
      name: 'Batch Lists',
      url: 'view.svc/WMS_SERIAL_BATCHB1SLQuery',
      onSave: (context, data) async =>
          context.read<BatchListOfflineCubit>().addData(data),
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

    for (final item in _downloads) {
      final success = await _fetchAndSave(item);
      if (!success) {
        debugPrint('❌ Failed to download ${item.name}');
      }
    }
    await LocalStorageManger.setString('isDownloaded', 'true');
    isDownloadedString = "true";
    setState(() => isDownloadingAll = false);
  }

  Future<bool> _fetchAndSave(DownloadItem item) async {
    setState(() {
      item.isLoading = true;
      item.failed = false;
      item.success = false;
    });
    await _saveDownloadState();

    try {
      final host = await LocalStorageManger.getString('host');
      final port = await LocalStorageManger.getString('port');
      final token = await LocalStorageManger.getString('SessionId');

      final data = await getFromSAP(
        host: host,
        port: port,
        token: token,
        endpoint: item.url,
        queryParams: item.queryParams,
      );

      await item.onSave(context, data["value"]);

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

  /// -----------------------------
  /// 🧹 Clear & Reset
  /// -----------------------------
  Future<void> _clearAllData() async {
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
            child: const Text("Clear"),
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

    // 2️⃣ Remove all keys from LocalStorage
    await LocalStorageManger.removeString("warehouse");
    await LocalStorageManger.removeString("businessPartners");
    await LocalStorageManger.removeString("items");
    await LocalStorageManger.removeString("batches");
    await LocalStorageManger.removeString("uomGroups");
    await LocalStorageManger.removeString("uoms");
    await LocalStorageManger.removeString("barcodes");
    await LocalStorageManger.removeString("receiptTypes");
    await LocalStorageManger.removeString("issueTypes");
    await LocalStorageManger.removeString("returnReceipts");
    await LocalStorageManger.removeString("saleOrders");
    await LocalStorageManger.removeString("purchaseReturnRequests");

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
        content: Text("✅ All offline data cleared"),
        backgroundColor: Colors.blueAccent,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _resetSyncStatus() async {
    for (var item in _downloads) {
      item.isLoading = false;
      item.success = false;
      item.failed = false;
    }
    await _saveDownloadState();
    setState(() {});
  }

  /// -----------------------------
  /// 🧱 UI
  /// -----------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        leading: null,
        automaticallyImplyLeading: widget.fromDashboard ? true : false,
        title: Center(child: const Text('Sync Multiple APIs')),
        backgroundColor: Colors.blueAccent,
        elevation: 3,
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.refresh),
          //   tooltip: 'Reset Status',
          //   onPressed: _resetSyncStatus,
          // ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Clear All Data',
            onPressed: _clearAllData,
          ),
        ],
      ),
      body: Column(
        children: [
          GestureDetector(
            onTap: () {
              if (isDownloadedString != "true") return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const WarehousePage(isPicker: true),
                ),
                (Route<dynamic> route) => false, // removes all previous routes
              );
            },
            child: const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                "Go to Warehouse Page",
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isDownloadingAll || isDownloadedString == "true"
                        ? Colors.grey
                        : const Color.fromARGB(255, 120, 120, 125),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: isDownloadingAll ? null : _downloadAllSequentially,
              icon: const Icon(Icons.cloud_download, color: Colors.white),
              label: Text(
                isDownloadingAll
                    ? 'Syncing...'
                    : isDownloadedString == "true"
                        ? "Downloaded"
                        : 'Download ',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
            ),
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
              fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black87),
        ),
        subtitle: Text(
          item.isLoading
              ? 'Downloading data...'
              : item.success
                  ? 'Downloaded successfully'
                  : item.failed
                      ? '❌ Failed to download'
                      : 'Ready to sync',
          style: TextStyle(
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
