import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_mobile/feature/bin_location/presentation/cubit/bin_offline_cubit.dart';
import 'package:wms_mobile/feature/business_partner/presentation/cubit/bussinessPartner_offline_cubit.dart';
import 'package:wms_mobile/feature/good_isuse_select/presentation/cubit/isuse_type_offline_cubit.dart';
import 'package:wms_mobile/feature/good_receipt_type/presentation/cubit/receipt_type_offline_cubit.dart';

// 🧱 Example Cubits (replace with your real ones)
import 'package:wms_mobile/feature/inbound/purchase_order/presentation/cubit/purchase_order_offline_cubit.dart';
import 'package:wms_mobile/feature/item/presentation/cubit/items_barcode_offline_cubit.dart';
import 'package:wms_mobile/feature/item/presentation/cubit/items_offline_cubit.dart';
import 'package:wms_mobile/feature/list_batch/presentation/cubit/batch_list_offline_cubit.dart';
import 'package:wms_mobile/feature/unit_of_measurement/presentation/cubit/uom_group_offline_cubit.dart';
import 'package:wms_mobile/feature/unit_of_measurement/presentation/cubit/uom_offline_cubit.dart';
import 'package:wms_mobile/feature/warehouse/presentation/cubit/warhouse_offline_cubit.dart';
import 'package:wms_mobile/feature/warehouse/presentation/screen/warehouse_page.dart';
import 'package:wms_mobile/helper/helper.dart';
import 'package:wms_mobile/utilies/storage/locale_storage.dart';

class DownloadItem {
  final String name;
  final String url;
  final Map<String, String>? queryParams;

  /// 🔹 The function that knows how to save data
  final Future<void> Function(BuildContext context, dynamic data) onSave;

  bool isLoading;
  bool success;
  bool failed;

  DownloadItem({
    required this.name,
    required this.url,
    this.queryParams,
    required this.onSave,
    this.isLoading = false,
    this.success = false,
    this.failed = false,
  });
}

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({super.key});

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  bool isDownloadingAll = false;

  /// 🔹 Define your APIs + which Cubit handles each
  late final List<DownloadItem> _downloads = [
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
      // queryParams: {
      //   '\$select':
      //       "ItemCode,ItemName,PurchaseItem,InventoryItem,SalesItem,InventoryUOM,UoMGroupEntry,InventoryUoMEntry,DefaultPurchasingUoMEntry,DefaultSalesUoMEntry, ManageSerialNumbers, ManageBatchNumbers"
      // },
      onSave: (context, data) async =>
          context.read<UOMGroupOfflineCubit>().addData(data),
    ),
    DownloadItem(
      name: 'UnitOfMeasurements',
      url: 'UnitOfMeasurements',
      // queryParams: {
      //   '\$select':
      //       "ItemCode,ItemName,PurchaseItem,InventoryItem,SalesItem,InventoryUOM,UoMGroupEntry,InventoryUoMEntry,DefaultPurchasingUoMEntry,DefaultSalesUoMEntry, ManageSerialNumbers, ManageBatchNumbers"
      // },
      onSave: (context, data) async =>
          context.read<UOMOfflineCubit>().addData(data),
    ),
      DownloadItem(
      name: 'Item Barcode',
      url: 'view.svc/WMS_ITEM_BARCODEB1SLQuery',
      // queryParams: {
      //   '\$select':
      //       "ItemCode,ItemName,PurchaseItem,InventoryItem,SalesItem,InventoryUOM,UoMGroupEntry,InventoryUoMEntry,DefaultPurchasingUoMEntry,DefaultSalesUoMEntry, ManageSerialNumbers, ManageBatchNumbers"
      // },
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

  /// -----------------------------
  /// 🌐 Fetch + Save Dynamically
  /// -----------------------------
  Future<bool> _fetchAndSave(DownloadItem item) async {
    setState(() {
      item.isLoading = true;
      item.failed = false;
      item.success = false;
    });

    try {
      final host = await LocalStorageManger.getString('host');
      final port = await LocalStorageManger.getString('port');
      final token = await LocalStorageManger.getString('SessionId');

      // ✅ Use the SAP GET helper instead of raw http.get
      final data = await getFromSAP(
        host: host, // your SAP host (e.g., http://192.168.1.10)
        port: port, // your SAP port (e.g., 50000)
        token: token, // your SAP session token
        endpoint: item.url, // e.g., 'PurchaseOrders'
        queryParams: item.queryParams, // optional map like {'\$top': '10'}
      );
      // 🔹 Dynamically call your Cubit’s save method
      await item.onSave(context, data["value"]);

      setState(() {
        item.success = true;
      });

      return true;
    } catch (e) {
      debugPrint('❌ Fetch failed for ${item.url}: $e');
      setState(() {
        item.failed = true;
      });
      return false;
    } finally {
      setState(() {
        item.isLoading = false;
      });
    }
  }

  /// -----------------------------
  /// 📦 Download All Sequentially
  /// -----------------------------
  Future<void> _downloadAllSequentially() async {
    if (isDownloadingAll) return;

    setState(() {
      isDownloadingAll = true;
    });

    for (var item in _downloads) {
      bool ok = await _fetchAndSave(item);

      if (!ok) {
        _showErrorSnack(item.name);
        break; // ❌ stop if any fails
      }
    }

    setState(() {
      isDownloadingAll = false;
    });
  }

  void _showErrorSnack(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text('❌ Failed to sync "$name". Stopped remaining.'),
      ),
    );
  }

  /// -----------------------------
  /// 🧱 Build UI
  /// -----------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text('Sync Multiple APIs'),
        backgroundColor: Colors.blueAccent,
        elevation: 3,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              for (var item in _downloads) {
                item.isLoading = false;
                item.success = false;
                item.failed = false;
              }
              setState(() {});
            },
          ),
        ],
      ),
      body: Column(
        children: [
          GestureDetector(
              onTap: () => goTo(context, WarehousePage(isPicker: true)),
              child: Text("Go")),
          Container(
            margin: const EdgeInsets.all(16),
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isDownloadingAll ? Colors.grey : Colors.blueAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: isDownloadingAll ? null : _downloadAllSequentially,
              icon: const Icon(Icons.cloud_download, color: Colors.white),
              label: Text(
                isDownloadingAll ? 'Syncing...' : 'Sync All APIs',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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

  /// -----------------------------
  /// 💡 API Download Card
  /// -----------------------------
  Widget _buildApiCard(DownloadItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 5,
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: item.success
              ? Colors.green
              : item.failed
                  ? Colors.redAccent
                  : item.isLoading
                      ? Colors.blueAccent
                      : Colors.grey.shade400,
          child: Icon(
            item.success
                ? Icons.check
                : item.failed
                    ? Icons.error
                    : Icons.cloud_download,
            color: Colors.white,
          ),
        ),
        title: Text(item.name,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          item.isLoading
              ? 'Downloading data...'
              : item.success
                  ? '✅ Downloaded successfully'
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
                ? Icons.hourglass_top
                : item.success
                    ? Icons.refresh
                    : Icons.download,
            color: item.isLoading
                ? Colors.blueAccent
                : item.success
                    ? Colors.orange
                    : Colors.blueAccent,
          ),
          onPressed: item.isLoading ? null : () => _fetchAndSave(item),
        ),
      ),
    );
  }
}
