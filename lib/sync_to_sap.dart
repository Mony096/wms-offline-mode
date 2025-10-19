import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_mobile/constant/style.dart';
import 'package:wms_mobile/feature/inbound/good_receipt_po/presentation/cubit/good_receipt_po_offline_cubit.dart';
import 'package:wms_mobile/feature/inbound/good_receipt_po/presentation/cubit/quick_good_receipt_offline_cubit.dart';
import 'package:wms_mobile/feature/inbound/good_receipt_po/presentation/sync_log.dart';

class SyncItem {
  final String name;
  final int Function(BuildContext) getCount;
  final Future<void> Function(BuildContext) onSync;

  SyncItem({
    required this.name,
    required this.getCount,
    required this.onSync,
  });
}

class SyncToSAPScreen extends StatefulWidget {
  const SyncToSAPScreen({super.key});

  @override
  State<SyncToSAPScreen> createState() => _SyncToSAPScreenState();
}

class _SyncToSAPScreenState extends State<SyncToSAPScreen> {
  final List<SyncGroup> _syncGroups = [];

  @override
  void initState() {
    super.initState();

    _syncGroups.addAll([
      SyncGroup(
        title: "Inbound",
        items: [
          SyncItem(
            name: 'Goods Receipt PO',
            getCount: (context) =>
                context.read<GoodReceiptPoOfflineCubit>().getJsonData().length,
            onSync: (context) async {
              await context.read<GoodReceiptPoOfflineCubit>().post();
            },
          ),
          SyncItem(
            name: 'Quick Goods Receipt',
            getCount: (context) => context
                .read<QuickGoodReceiptOfflineCubit>()
                .getJsonData()
                .length,
            onSync: (context) async {
              await context.read<QuickGoodReceiptOfflineCubit>().post();
            },
          ),
        ],
      ),
      SyncGroup(
        title: "Outbound",
        items: [
          // Add more group items later if needed
        ],
      ),
    ]);
  }

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
    context.read<GoodReceiptPoOfflineCubit>().clearData();
    context.read<QuickGoodReceiptOfflineCubit>().clearData();
    context.read<GoodReceiptPoOfflineCubit>().loadData();
    context.read<QuickGoodReceiptOfflineCubit>().loadData();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: PRIMARY_COLOR,
        centerTitle: true,
        title: const Text("Sync to SAP",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: 19)),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Clear All Data',
            onPressed: _clearAllData,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _syncGroups.length,
        itemBuilder: (context, index) {
          return _buildExpandableGroup(context, _syncGroups[index]);
        },
      ),
    );
  }

  // 🔹 Build expandable group (slide down)
  Widget _buildExpandableGroup(BuildContext context, SyncGroup group) {
    return StatefulBuilder(
      builder: (context, setInnerState) {
        bool isExpanded = true;
        return StatefulBuilder(
          builder: (context, innerSetState) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      innerSetState(() => isExpanded = !isExpanded);
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(
                          colors: [
                            PRIMARY_COLOR.withOpacity(0.9),
                            PRIMARY_COLOR.withOpacity(0.7),
                          ],
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.folder_copy,
                                  color: Colors.white),
                              const SizedBox(width: 10),
                              Text(
                                group.title,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          AnimatedRotation(
                            turns: isExpanded ? 0.5 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            child: const Icon(Icons.keyboard_arrow_down,
                                color: Colors.white, size: 28),
                          ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: Column(
                      children: group.items
                          .map((item) => _buildApiCard(context, item))
                          .toList(),
                    ),
                    crossFadeState: isExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 🔹 Your same _buildApiCard method (unchanged, but nice design)
  Widget _buildApiCard(BuildContext context, SyncItem item) {
    final count = item.getCount(context);
    final isReady = count > 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isReady ? PRIMARY_COLOR.withOpacity(0.3) : Colors.grey.shade300,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isReady ? PRIMARY_COLOR : Colors.grey.shade400,
                ),
                child: const Icon(Icons.sync, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(
                      isReady
                          ? '$count record(s) ready to sync'
                          : 'No data ready to sync SAP',
                      style: TextStyle(
                        fontSize: 13,
                        color: isReady ? Colors.orange : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: Colors.grey.shade300),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
               ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SyncLogScreen()),
                  );
                },
                icon: const Icon(Icons.book, color: Colors.white, size: 18),
                label: const Text("Review",
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SyncLogScreen()),
                  );
                },
                icon: const Icon(Icons.history, color: Colors.white, size: 18),
                label: const Text("Sync Log",
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: isReady
                    ? () async {
                        await item.onSync(context);
                        setState(() {});
                      }
                    : null,
                icon: const Icon(Icons.cloud_upload,
                    color: Colors.white, size: 18),
                label:
                    const Text("Sync", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isReady ? PRIMARY_COLOR : Colors.grey.shade400,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 🔸 Group model
class SyncGroup {
  final String title;
  final List<SyncItem> items;
  SyncGroup({required this.title, required this.items});
}
