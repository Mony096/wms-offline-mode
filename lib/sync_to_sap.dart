import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_mobile/constant/style.dart';
import 'package:wms_mobile/feature/counting/bin_count/presentation/cubit/bin_count_offline_cubit.dart';
import 'package:wms_mobile/feature/counting/bin_count/presentation/review_offline_save.dart';
import 'package:wms_mobile/feature/counting/bin_count/presentation/sync_log.dart';
import 'package:wms_mobile/feature/counting/physical_count/presentation/cubit/physical_count_offline_cubit.dart';
import 'package:wms_mobile/feature/counting/physical_count/presentation/review_offline_save.dart';
import 'package:wms_mobile/feature/counting/physical_count/presentation/sync_log.dart';
import 'package:wms_mobile/feature/counting/quick_count/presentation/cubit/cycle_count_offline_cubit.dart';
import 'package:wms_mobile/feature/counting/quick_count/presentation/cubit/quick_count_offline_cubit.dart';
import 'package:wms_mobile/feature/counting/quick_count/presentation/review_cycle_count_offline_save.dart';
import 'package:wms_mobile/feature/counting/quick_count/presentation/review_offline_save.dart';
import 'package:wms_mobile/feature/counting/quick_count/presentation/sync_log.dart';
import 'package:wms_mobile/feature/counting/quick_count/presentation/sync_log_cycle_count.dart';
import 'package:wms_mobile/feature/inbound/good_receipt/presentation/cubit/goods_receipt_offline_cubit.dart';
import 'package:wms_mobile/feature/inbound/good_receipt/presentation/review_offline_save.dart';
import 'package:wms_mobile/feature/inbound/good_receipt/presentation/sync_log.dart';
import 'package:wms_mobile/feature/inbound/good_receipt_po/presentation/cubit/good_receipt_po_offline_cubit.dart';
import 'package:wms_mobile/feature/inbound/good_receipt_po/presentation/cubit/quick_good_receipt_offline_cubit.dart';
import 'package:wms_mobile/feature/inbound/good_receipt_po/presentation/review_offline_save.dart';
import 'package:wms_mobile/feature/inbound/good_receipt_po/presentation/review_quick_offline_save.dart';
import 'package:wms_mobile/feature/inbound/good_receipt_po/presentation/sync_log.dart';
import 'package:wms_mobile/feature/inbound/good_receipt_po/presentation/sync_log_quick.dart';
import 'package:wms_mobile/feature/inbound/put_away/presentation/cubit/put_away_offline_cubit.dart';
import 'package:wms_mobile/feature/inbound/put_away/presentation/review_offline_save.dart';
import 'package:wms_mobile/feature/inbound/put_away/presentation/sync_log.dart';
import 'package:wms_mobile/feature/inbound/return_receipt/presentation/cubit/return_receipt_offline_cubit.dart';
import 'package:wms_mobile/feature/inbound/return_receipt/presentation/review_offline_save.dart';
import 'package:wms_mobile/feature/inbound/return_receipt/presentation/sync_log.dart';
import 'package:wms_mobile/feature/outbounce/delivery/presentation/cubit/delivery_offline_cubit.dart';
import 'package:wms_mobile/feature/outbounce/delivery/presentation/review_offline_save.dart';
import 'package:wms_mobile/feature/outbounce/delivery/presentation/sync_log.dart';
import 'package:wms_mobile/feature/outbounce/good_issue/presentation/cubit/goods_issue_offline_cubit.dart';
import 'package:wms_mobile/feature/outbounce/good_issue/presentation/review_offline_save.dart';
import 'package:wms_mobile/feature/outbounce/good_issue/presentation/sync_log.dart';
import 'package:wms_mobile/feature/outbounce/purchase_return/presentation/cubit/purchase_return_cubit.dart';
import 'package:wms_mobile/feature/outbounce/purchase_return/presentation/cubit/purchase_return_offline_cubit.dart';
import 'package:wms_mobile/feature/outbounce/purchase_return/presentation/review_offline_save.dart';
import 'package:wms_mobile/feature/outbounce/purchase_return/presentation/sync_log.dart';
import 'package:wms_mobile/helper/helper.dart';
import 'package:wms_mobile/utilies/dialog/dialog.dart';

class SyncItem {
  final String name;
  final int Function(BuildContext) getCount;
  final Future<void> Function(BuildContext) onSync;
  final void Function(BuildContext)? onGotoReview;
  final void Function(BuildContext)? onGotoSyncLog;
  SyncItem({
    required this.name,
    required this.getCount,
    required this.onSync,
    required this.onGotoReview,
    required this.onGotoSyncLog,
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
            onGotoReview: (context) {
              goTo(context, ReviewOfflineSave());
            },
            onGotoSyncLog: (context) {
              goTo(context, SyncLogScreen());
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
            onGotoReview: (context) {
              goTo(context, ReviewQuickOfflineSave());
            },
            onGotoSyncLog: (context) {
              goTo(context, SyncLogQuickScreen());
            },
          ),
          SyncItem(
            name: 'Customer Return Receipt',
            getCount: (context) =>
                context.read<ReturnReceiptOfflineCubit>().getJsonData().length,
            onSync: (context) async {
              await context.read<ReturnReceiptOfflineCubit>().post();
            },
            onGotoReview: (context) {
              goTo(context, ReviewReturnReceiptOfflineSave());
            },
            onGotoSyncLog: (context) {
              goTo(context, SyncLogReturnReceiptScreen());
            },
          ),
          SyncItem(
            name: 'Goods Receipt',
            getCount: (context) =>
                context.read<GoodsReceiptOfflineCubit>().getJsonData().length,
            onSync: (context) async {
              await context.read<GoodsReceiptOfflineCubit>().post();
            },
            onGotoReview: (context) {
              goTo(context, ReviewGoodsReceiptOfflineSave());
            },
            onGotoSyncLog: (context) {
              goTo(context, SyncLogGoodsReceiptScreen());
            },
          ),
          SyncItem(
            name: 'Put Away',
            getCount: (context) =>
                context.read<PutAwayOfflineCubit>().getJsonData().length,
            onSync: (context) async {
              await context.read<PutAwayOfflineCubit>().post();
            },
            onGotoReview: (context) {
              goTo(context, ReviewPutAwayOfflineSave());
            },
            onGotoSyncLog: (context) {
              goTo(context, SyncLogPutAwayScreen());
            },
          ),
        ],
      ),
      SyncGroup(
        title: "Outbound",
        items: [
          SyncItem(
            name: 'Delivery',
            getCount: (context) =>
                context.read<DeliveryOfflineCubit>().getJsonData().length,
            onSync: (context) async {
              await context.read<DeliveryOfflineCubit>().post();
            },
            onGotoReview: (context) {
              goTo(context, ReviewDeiveryOfflineSave());
            },
            onGotoSyncLog: (context) {
              goTo(context, SyncLogDeliveryScreen());
            },
          ),
          SyncItem(
            name: 'Return To Supplier',
            getCount: (context) =>
                context.read<PurchaseReturnOfflineCubit>().getJsonData().length,
            onSync: (context) async {
              await context.read<PurchaseReturnOfflineCubit>().post();
            },
            onGotoReview: (context) {
              goTo(context, ReviewPurchaseReturnOfflineSave());
            },
            onGotoSyncLog: (context) {
              goTo(context, SyncLogPurchaseReturnScreen());
            },
          ),
          SyncItem(
            name: 'Goods Issue',
            getCount: (context) =>
                context.read<GoodsIssueOfflineCubit>().getJsonData().length,
            onSync: (context) async {
              await context.read<GoodsIssueOfflineCubit>().post();
            },
            onGotoReview: (context) {
              goTo(context, ReviewGoodsIssueOfflineSave());
            },
            onGotoSyncLog: (context) {
              goTo(context, SyncLogGoodsIssueScreen());
            },
          ),
        ],
      ),
      SyncGroup(
        title: "Counting",
        items: [
          SyncItem(
            name: 'Quick Count',
            getCount: (context) =>
                context.read<QuickCountOfflineCubit>().getJsonData().length,
            onSync: (context) async {
              await context.read<QuickCountOfflineCubit>().post();
            },
            onGotoReview: (context) {
              goTo(context, ReviewQuickCountOfflineSave());
            },
            onGotoSyncLog: (context) {
              goTo(context, SyncLogQuickCountScreen());
            },
          ),
          SyncItem(
            name: 'Cycle Count',
            getCount: (context) =>
                context.read<CycleCountOfflineCubit>().getJsonData().length,
            onSync: (context) async {
              await context.read<CycleCountOfflineCubit>().post();
            },
            onGotoReview: (context) {
              goTo(context, ReviewCycleCountOfflineSave());
            },
            onGotoSyncLog: (context) {
              goTo(context, SyncLogCycleCountScreen());
            },
          ),
          SyncItem(
            name: 'Physical Count',
            getCount: (context) =>
                context.read<PhysicalCountOfflineCubit>().getJsonData().length,
            onSync: (context) async {
              await context.read<PhysicalCountOfflineCubit>().post();
            },
            onGotoReview: (context) {
              goTo(context, ReviewPhysicalCountOfflineSave());
            },
            onGotoSyncLog: (context) {
              goTo(context, SyncLogPhysicalCountScreen());
            },
          ),
          SyncItem(
            name: 'Bin Count',
            getCount: (context) =>
                context.read<BinCountOfflineCubit>().getJsonData().length,
            onSync: (context) async {
              await context.read<BinCountOfflineCubit>().post();
            },
            onGotoReview: (context) {
              goTo(context, ReviewBinCountOfflineSave());
            },
            onGotoSyncLog: (context) {
              goTo(context, SyncLogBinCountScreen());
            },
          ),
          // SyncItem(
          //   name: 'Goods Issue',
          //   getCount: (context) =>
          //       context.read<GoodsIssueOfflineCubit>().getJsonData().length,
          //   onSync: (context) async {
          //     await context.read<GoodsIssueOfflineCubit>().post();
          //   },
          //   onGotoReview: (context) {
          //     goTo(context, ReviewGoodsIssueOfflineSave());
          //   },
          //   onGotoSyncLog: (context) {
          //     goTo(context, SyncLogGoodsIssueScreen());
          //   },
          // ),
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
    context.read<ReturnReceiptOfflineCubit>().clearData();

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
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 17)),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Clear All Data',
            onPressed: _clearAllData,
          ),
        ],
      ),
      body: Container(
        margin: EdgeInsets.only(top: 10),
        child: ListView.builder(
          itemCount: _syncGroups.length,
          itemBuilder: (context, index) {
            return _buildExpandableGroup(context, _syncGroups[index]);
          },
        ),
      ),
    );
  }

  // 🔹 Build expandable group (slide down)
  Widget _buildExpandableGroup(BuildContext context, SyncGroup group) {
    return StatefulBuilder(
      builder: (context, setInnerState) {
        bool isExpanded = false;
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
                          horizontal: 16, vertical: 17),
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
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
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
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isReady ? PRIMARY_COLOR : Colors.grey.shade400,
                ),
                child: const Icon(
                  Icons.sync,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 15)),
                        Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    title: const Text(
                                      "Select Action",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17),
                                    ),
                                    content:
                                        const Text("Choose an action below."),
                                    actionsPadding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 8),
                                    actionsAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    actions: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10, bottom: 9),
                                              child: ElevatedButton.icon(
                                                onPressed:
                                                    item.onGotoSyncLog != null
                                                        ? () {
                                                            Navigator.pop(
                                                                context); // close dialog
                                                            item.onGotoSyncLog!(
                                                                context);
                                                          }
                                                        : null,
                                                icon: const Icon(Icons.history,
                                                    color: Colors.white,
                                                    size: 18),
                                                label: const Text(
                                                  "Sync Log",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.blueGrey,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 12,
                                                      vertical: 10),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 9, right: 10),
                                              child: ElevatedButton.icon(
                                                onPressed:
                                                    item.onGotoReview != null
                                                        ? () {
                                                            Navigator.pop(
                                                                context); // close dialog
                                                            item.onGotoReview!(
                                                                context);
                                                          }
                                                        : null,
                                                icon: const Icon(Icons.book,
                                                    color: Colors.white,
                                                    size: 18),
                                                label: const Text(
                                                  "Review",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 12,
                                                      vertical: 10),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: const Icon(
                              Icons.more_horiz,
                              size: 24,
                              color: Color.fromARGB(255, 134, 131, 131),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isReady
                          ? '$count record(s) ready to sync'
                          : 'No data ready to sync SAP',
                      style: TextStyle(
                        fontSize: 13,
                        color: isReady
                            ? Colors.orange
                            : const Color.fromARGB(255, 126, 133, 126),
                      ),
                    ),
                    const SizedBox(height: 3),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: Colors.grey.shade300),
          const SizedBox(height: 7),

          // --- Action Buttons ---

          // Expanded(
          //   child: ElevatedButton.icon(
          //     onPressed: item.onGotoReview != null
          //         ? () => item.onGotoReview!(context)
          //         : null,
          //     icon: const Icon(Icons.book, color: Colors.white, size: 18),
          //     label: const Text(
          //       "Review",
          //       style: TextStyle(color: Colors.white),
          //     ),
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: Colors.green,
          //       padding:
          //           const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(8),
          //       ),
          //     ),
          //   ),
          // ),
          // const SizedBox(width: 8),
          // Expanded(
          //   child: ElevatedButton.icon(
          //     onPressed: item.onGotoSyncLog != null
          //         ? () => item.onGotoSyncLog!(context)
          //         : null,
          //     icon:
          //         const Icon(Icons.history, color: Colors.white, size: 18),
          //     label: const Text(
          //       "Sync Log",
          //       style: TextStyle(color: Colors.white),
          //     ),
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: Colors.blueGrey,
          //       padding:
          //           const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(8),
          //       ),
          //     ),
          //   ),
          // ),
          // const SizedBox(width: 8),
          Align(
            alignment: Alignment.topRight,
            child: SizedBox(
              width: 90,
              child: ElevatedButton.icon(
                onPressed: isReady
                    ? () async {
                        // 🌀 Show loading dialog
                        MaterialDialog.loading(context);
                        try {
                          await item.onSync(context);
                          if (context.mounted)
                            Navigator.pop(context); // close loading

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Sync completed!",
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: PRIMARY_COLOR,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        } catch (e) {
                          if (context.mounted) Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Sync failed: $e",
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.redAccent,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }

                        if (context.mounted) setState(() {});
                      }
                    : null,
                icon: const Icon(Icons.cloud_upload,
                    color: Colors.white, size: 18),
                label: const Text(
                  "Sync",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isReady ? PRIMARY_COLOR : Colors.grey.shade400,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
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
