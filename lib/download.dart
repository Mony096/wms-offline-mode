import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';

// 🧱 Example Cubits (replace with your real ones)
import 'package:wms_mobile/feature/inbound/purchase_order/presentation/cubit/purchase_order_offline_cubit.dart';

class DownloadItem {
  final String name;
  final String url;

  /// 🔹 The function that knows how to save data
  final Future<void> Function(BuildContext context, dynamic data) onSave;

  bool isLoading;
  bool success;
  bool failed;

  DownloadItem({
    required this.name,
    required this.url,
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
      url: 'https://jsonplaceholder.typicode.com/posts',
      onSave: (context, data) async =>
          context.read<PurchaseOrderOfflineCubit>().addData(data),
    ),
    // DownloadItem(
    //   name: 'Suppliers',
    //   url: 'https://jsonplaceholder.typicode.com/users',
    //   onSave: (context, data) async =>
    //       context.read<SupplierOfflineCubit>().addData(data),
    // ),
    // DownloadItem(
    //   name: 'Products',
    //   url: 'https://jsonplaceholder.typicode.com/todos',
    //   onSave: (context, data) async =>
    //       context.read<ProductOfflineCubit>().addData(data),
    // ),
    // DownloadItem(
    //   name: 'Categories',
    //   url: 'https://jsonplaceholder.typicode.com/comments',
    //   onSave: (context, data) async =>
    //       context.read<CategoryOfflineCubit>().addData(data),
    // ),
    // DownloadItem(
    //   name: 'Warehouses',
    //   url: 'https://jsonplaceholder.typicode.com/albums',
    //   onSave: (context, data) async =>
    //       context.read<WarehouseOfflineCubit>().addData(data),
    // ),
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
      final response = await http.get(Uri.parse(item.url));

      if (response.statusCode == 200) {
        //  if (true) {
        final data = jsonDecode(response.body);

        // ✅ Handle both list and map
        final parsedData = (data is List) ? data : [data];

        // 🔹 Dynamically call the correct Cubit function
        await item.onSave(context, parsedData);
        // await item.onSave(context, parsedData);
        setState(() {
          item.success = true;
        });

        return true;
      } else {
        setState(() {
          item.failed = true;
        });
        return false;
      }
    } catch (e) {
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
