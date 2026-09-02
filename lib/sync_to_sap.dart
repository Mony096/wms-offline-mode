import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:wms_mobile/constant/style.dart';
import 'package:wms_mobile/feature/counting/bin_count/presentation/cubit/bin_count_failed_offline_cubit.dart';
import 'package:wms_mobile/feature/counting/bin_count/presentation/cubit/bin_count_offline_cubit.dart';
import 'package:wms_mobile/feature/counting/bin_count/presentation/review_offline_save.dart';
import 'package:wms_mobile/feature/counting/bin_count/presentation/sync_faild_log.dart';
import 'package:wms_mobile/feature/counting/bin_count/presentation/sync_log.dart';
import 'package:wms_mobile/feature/counting/physical_count/presentation/cubit/physical_count_failed_offline_cubit.dart';
import 'package:wms_mobile/feature/counting/physical_count/presentation/cubit/physical_count_offline_cubit.dart';
import 'package:wms_mobile/feature/counting/physical_count/presentation/review_offline_save.dart';
import 'package:wms_mobile/feature/counting/physical_count/presentation/sync_faild_log.dart';
import 'package:wms_mobile/feature/counting/physical_count/presentation/sync_log.dart';
import 'package:wms_mobile/feature/counting/quick_count/presentation/cubit/cycle_count_failed_offline_cubit.dart';
import 'package:wms_mobile/feature/counting/quick_count/presentation/cubit/cycle_count_offline_cubit.dart';
import 'package:wms_mobile/feature/counting/quick_count/presentation/cubit/quick_count_failed_offline_cubit.dart';
import 'package:wms_mobile/feature/counting/quick_count/presentation/cubit/quick_count_offline_cubit.dart';
import 'package:wms_mobile/feature/counting/quick_count/presentation/review_cycle_count_offline_save.dart';
import 'package:wms_mobile/feature/counting/quick_count/presentation/review_offline_save.dart';
import 'package:wms_mobile/feature/counting/quick_count/presentation/sync_faild_log.dart';
import 'package:wms_mobile/feature/counting/quick_count/presentation/sync_faild_log_cycle.dart';
import 'package:wms_mobile/feature/counting/quick_count/presentation/sync_log.dart';
import 'package:wms_mobile/feature/counting/quick_count/presentation/sync_log_cycle_count.dart';
import 'package:wms_mobile/feature/inbound/good_receipt/presentation/cubit/good_receipt_failed_offline_cubit.dart';
import 'package:wms_mobile/feature/inbound/good_receipt/presentation/cubit/goods_receipt_offline_cubit.dart';
import 'package:wms_mobile/feature/inbound/good_receipt/presentation/review_offline_save.dart';
import 'package:wms_mobile/feature/inbound/good_receipt/presentation/sync_faild_log.dart';
import 'package:wms_mobile/feature/inbound/good_receipt/presentation/sync_log.dart';
import 'package:wms_mobile/feature/inbound/good_receipt_po/presentation/cubit/good_receipt_po_offline_cubit.dart';
import 'package:wms_mobile/feature/inbound/good_receipt_po/presentation/cubit/good_recipt_po_failed_offline_cubit.dart';
import 'package:wms_mobile/feature/inbound/good_receipt_po/presentation/cubit/quick_good_receipt_failed_offline_cubit.dart';
import 'package:wms_mobile/feature/inbound/good_receipt_po/presentation/cubit/quick_good_receipt_offline_cubit.dart';
import 'package:wms_mobile/feature/inbound/good_receipt_po/presentation/review_offline_save.dart';
import 'package:wms_mobile/feature/inbound/good_receipt_po/presentation/review_quick_offline_save.dart';
import 'package:wms_mobile/feature/inbound/good_receipt_po/presentation/sync_faild_log.dart';
import 'package:wms_mobile/feature/inbound/good_receipt_po/presentation/sync_faild_log_quick.dart';
import 'package:wms_mobile/feature/inbound/good_receipt_po/presentation/sync_log.dart';
import 'package:wms_mobile/feature/inbound/good_receipt_po/presentation/sync_log_quick.dart';
import 'package:wms_mobile/feature/inbound/purchase_order/presentation/cubit/purchase_order_offline_cubit.dart';
import 'package:wms_mobile/feature/inbound/put_away/presentation/cubit/put_away_failed_offline_cubit.dart';
import 'package:wms_mobile/feature/inbound/put_away/presentation/cubit/put_away_offline_cubit.dart';
import 'package:wms_mobile/feature/inbound/put_away/presentation/review_offline_save.dart';
import 'package:wms_mobile/feature/inbound/put_away/presentation/sync_faild_log.dart';
import 'package:wms_mobile/feature/inbound/put_away/presentation/sync_log.dart';
import 'package:wms_mobile/feature/inbound/return_receipt/presentation/cubit/return_receipt_failed_offline_cubit.dart';
import 'package:wms_mobile/feature/inbound/return_receipt/presentation/cubit/return_receipt_offline_cubit.dart';
import 'package:wms_mobile/feature/inbound/return_receipt/presentation/review_offline_save.dart';
import 'package:wms_mobile/feature/inbound/return_receipt/presentation/sync_faild_log.dart';
import 'package:wms_mobile/feature/inbound/return_receipt/presentation/sync_log.dart';
import 'package:wms_mobile/feature/inbound/return_receipt_request/presentation/cubit/return_receipt_request_offline_cubit.dart';
import 'package:wms_mobile/feature/outbounce/delivery/presentation/cubit/delivery_failed_offline_cubit.dart';
import 'package:wms_mobile/feature/outbounce/delivery/presentation/cubit/delivery_offline_cubit.dart';
import 'package:wms_mobile/feature/outbounce/delivery/presentation/review_offline_save.dart';
import 'package:wms_mobile/feature/outbounce/delivery/presentation/sync_faild_log.dart';
import 'package:wms_mobile/feature/outbounce/delivery/presentation/sync_log.dart';
import 'package:wms_mobile/feature/outbounce/good_issue/presentation/cubit/good_issue_failed_offline_cubit.dart';
import 'package:wms_mobile/feature/outbounce/good_issue/presentation/cubit/goods_issue_offline_cubit.dart';
import 'package:wms_mobile/feature/outbounce/good_issue/presentation/review_offline_save.dart';
import 'package:wms_mobile/feature/outbounce/good_issue/presentation/sync_faild_log.dart';
import 'package:wms_mobile/feature/outbounce/good_issue/presentation/sync_log.dart';
import 'package:wms_mobile/feature/outbounce/purchase_return/presentation/cubit/purchase_return_cubit.dart';
import 'package:wms_mobile/feature/outbounce/purchase_return/presentation/cubit/purchase_return_failed_offline_cubit.dart';
import 'package:wms_mobile/feature/outbounce/purchase_return/presentation/cubit/purchase_return_offline_cubit.dart';
import 'package:wms_mobile/feature/outbounce/purchase_return/presentation/review_offline_save.dart';
import 'package:wms_mobile/feature/outbounce/purchase_return/presentation/sync_faild_log.dart';
import 'package:wms_mobile/feature/outbounce/purchase_return/presentation/sync_log.dart';
import 'package:wms_mobile/feature/outbounce/purchase_return_request/presentation/cubit/purchase_return_request_offline_cubit.dart';
import 'package:wms_mobile/feature/outbounce/sale_order/presentation/cubit/sale_order_offline_cubit.dart';
import 'package:wms_mobile/helper/helper.dart';
import 'package:wms_mobile/utilies/dialog/dialog.dart';
import 'package:wms_mobile/utilies/storage/locale_storage.dart';

class SyncItem {
  final String name;
  final int Function(BuildContext) getCount;
  final int Function(BuildContext) getLog;
  final int Function(BuildContext) getFaild;

  final Future<void> Function(BuildContext) onSync;
  final void Function(BuildContext) onFailedSync;

  final void Function(BuildContext)? onGotoReview;
  final void Function(BuildContext)? onGotoSyncLog;
  SyncItem(
      {required this.name,
      required this.getCount,
      required this.onSync,
      required this.onFailedSync,
      required this.onGotoReview,
      required this.onGotoSyncLog,
      required this.getLog,
      required this.getFaild});
}

class SyncToSAPScreen extends StatefulWidget {
  const SyncToSAPScreen({super.key});

  @override
  State<SyncToSAPScreen> createState() => _SyncToSAPScreenState();
}

class _SyncToSAPScreenState extends State<SyncToSAPScreen> {
  final List<SyncGroup> _syncGroups = [];
  bool isLoading = false;
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    _syncGroups.addAll([
      SyncGroup(
        title: "Inbound",
        description:
            "Sync inbound documents like GRPO, Quick GRPO, and Return Receipt from suppliers.",
        items: [
          SyncItem(
            name: 'Goods Receipt PO',
            getFaild: (context) =>
                context.read<GoodReciptPoFailedOfflineCubit>().getFailed(),
            getCount: (context) =>
                context.read<GoodReceiptPoOfflineCubit>().getJsonData().length,
            getLog: (context) =>
                context.read<GoodReceiptPoOfflineCubit>().getLog(),
            onSync: (context) async {
              await context.read<GoodReceiptPoOfflineCubit>().post(
                  context.read<GoodReciptPoFailedOfflineCubit>(),
                  context.read<PurchaseOrderOfflineCubit>(),
                  context);
            },
            onGotoReview: (context) {
              goTo(context, ReviewOfflineSave()).then((e) async => {
                    setState(() {
                      isLoading = true;
                      isExpanded = false;
                    }),
                    await Future.delayed(const Duration(milliseconds: 1000)),
                    setState(() {
                      isLoading = false;
                    }),
                  });
            },
            onGotoSyncLog: (context) {
              goTo(context, SyncLogScreen());
            },
            onFailedSync: (context) {
              goTo(context, SyncFailLogScreen()).then((e) async => {
                    setState(() {
                      isLoading = true;
                      isExpanded = false;
                    }),
                    await Future.delayed(const Duration(milliseconds: 1000)),
                    setState(() {
                      isLoading = false;
                    }),
                  });
            },
          ),
          SyncItem(
            name: 'Quick Goods Receipt',
            getFaild: (context) =>
                context.read<QuickGoodReceiptFailedOfflineCubit>().getFailed(),
            getCount: (context) => context
                .read<QuickGoodReceiptOfflineCubit>()
                .getJsonData()
                .length,
            getLog: (context) =>
                context.read<QuickGoodReceiptOfflineCubit>().getLog(),
            onSync: (context) async {
              await context.read<QuickGoodReceiptOfflineCubit>().post(
                    context.read<QuickGoodReceiptFailedOfflineCubit>(),
                  );
            },
            onGotoReview: (context) {
              goTo(context, ReviewQuickOfflineSave()).then((e) async => {
                    setState(() {
                      isLoading = true;
                      isExpanded = false;
                    }),
                    await Future.delayed(const Duration(milliseconds: 1000)),
                    setState(() {
                      isLoading = false;
                    }),
                  });
            },
            onGotoSyncLog: (context) {
              goTo(context, SyncLogQuickScreen());
            },
            onFailedSync: (context) {
              goTo(context, SyncFailLogQuickScreen()).then((e) async => {
                    setState(() {
                      isLoading = true;
                      isExpanded = false;
                    }),
                    await Future.delayed(const Duration(milliseconds: 1000)),
                    setState(() {
                      isLoading = false;
                    }),
                  });
            },
          ),
          SyncItem(
            name: 'Customer Return Receipt',
            getFaild: (context) =>
                context.read<ReturnReceiptFailedOfflineCubit>().getFailed(),
            getCount: (context) =>
                context.read<ReturnReceiptOfflineCubit>().getJsonData().length,
            getLog: (context) =>
                context.read<ReturnReceiptOfflineCubit>().getLog(),
            onSync: (context) async {
              await context.read<ReturnReceiptOfflineCubit>().post(
                  context.read<ReturnReceiptFailedOfflineCubit>(),
                  context.read<ReturnReceiptRequestOfflineCubit>(),
                  context);
            },
            onGotoReview: (context) {
              goTo(context, ReviewReturnReceiptOfflineSave()).then((e) async =>
                  {
                    setState(() {
                      isLoading = true;
                      isExpanded = false;
                    }),
                    await Future.delayed(const Duration(milliseconds: 1000)),
                    setState(() {
                      isLoading = false;
                    }),
                  });
            },
            onGotoSyncLog: (context) {
              goTo(context, SyncLogReturnReceiptScreen());
            },
            onFailedSync: (context) {
              goTo(context, SyncFailLogReturnReceiptScreen()).then((e) async =>
                  {
                    setState(() {
                      isLoading = true;
                      isExpanded = false;
                    }),
                    await Future.delayed(const Duration(milliseconds: 1000)),
                    setState(() {
                      isLoading = false;
                    }),
                  });
            },
          ),
          SyncItem(
            name: 'Goods Receipt',
            getFaild: (context) =>
                context.read<GoodReceiptFailedOfflineCubit>().getFailed(),
            getCount: (context) =>
                context.read<GoodsReceiptOfflineCubit>().getJsonData().length,
            getLog: (context) =>
                context.read<GoodsReceiptOfflineCubit>().getLog(),
            onSync: (context) async {
              await context.read<GoodsReceiptOfflineCubit>().post(
                    context.read<GoodReceiptFailedOfflineCubit>(),
                  );
            },
            onGotoReview: (context) {
              goTo(context, ReviewGoodsReceiptOfflineSave()).then((e) async => {
                    setState(() {
                      isLoading = true;
                    }),
                    await Future.delayed(const Duration(milliseconds: 1000)),
                    setState(() {
                      isLoading = false;
                      isExpanded = false;
                    }),
                  });
            },
            onGotoSyncLog: (context) {
              goTo(context, SyncLogGoodsReceiptScreen());
            },
            onFailedSync: (context) {
              goTo(context, SyncFailLogGoodReceiptScreen()).then((e) async => {
                    setState(() {
                      isLoading = true;
                      isExpanded = false;
                    }),
                    await Future.delayed(const Duration(milliseconds: 1000)),
                    setState(() {
                      isLoading = false;
                    }),
                  });
            },
          ),
          SyncItem(
            name: 'Put Away',
            getFaild: (context) =>
                context.read<PutAwayFailedOfflineCubit>().getFailed(),
            getCount: (context) =>
                context.read<PutAwayOfflineCubit>().getJsonData().length,
            getLog: (context) => context.read<PutAwayOfflineCubit>().getLog(),
            onSync: (context) async {
              await context.read<PutAwayOfflineCubit>().post(
                    context.read<PutAwayFailedOfflineCubit>(),
                  );
            },
            onGotoReview: (context) {
              goTo(context, ReviewPutAwayOfflineSave()).then((e) async => {
                    setState(() {
                      isLoading = true;
                      isExpanded = false;
                    }),
                    await Future.delayed(const Duration(milliseconds: 1000)),
                    setState(() {
                      isLoading = false;
                    }),
                  });
            },
            onGotoSyncLog: (context) {
              goTo(context, SyncLogPutAwayScreen());
            },
            onFailedSync: (context) {
              goTo(context, SyncFailLogPutAwayScreen()).then((e) async => {
                    setState(() {
                      isLoading = true;
                      isExpanded = false;
                    }),
                    await Future.delayed(const Duration(milliseconds: 1000)),
                    setState(() {
                      isLoading = false;
                    }),
                  });
            },
          ),
        ],
      ),
      SyncGroup(
        description:
            "Sync outbound transactions including Delivery, Return Request, and Goods Issue.",
        title: "Outbound",
        items: [
          SyncItem(
            name: 'Delivery',
            getFaild: (context) =>
                context.read<DeliveryFailedOfflineCubit>().getFailed(),
            getCount: (context) =>
                context.read<DeliveryOfflineCubit>().getJsonData().length,
            getLog: (context) => context.read<DeliveryOfflineCubit>().getLog(),
            onSync: (context) async {
              await context.read<DeliveryOfflineCubit>().post(
                  context.read<DeliveryFailedOfflineCubit>(),
                  context.read<SaleOrderOfflineCubit>(),
                  context);
            },
            onGotoReview: (context) {
              goTo(context, ReviewDeiveryOfflineSave()).then((e) async => {
                    setState(() {
                      isLoading = true;
                      isExpanded = false;
                    }),
                    await Future.delayed(const Duration(milliseconds: 1000)),
                    setState(() {
                      isLoading = false;
                    }),
                  });
            },
            onGotoSyncLog: (context) {
              goTo(context, SyncLogDeliveryScreen());
            },
            onFailedSync: (context) {
              goTo(context, SyncFailLogDeliveryScreen()).then((e) async => {
                    setState(() {
                      isLoading = true;
                      isExpanded = false;
                    }),
                    await Future.delayed(const Duration(milliseconds: 1000)),
                    setState(() {
                      isLoading = false;
                    }),
                  });
            },
          ),
          SyncItem(
            name: 'Return To Supplier',
            getFaild: (context) =>
                context.read<PurchaseReturnFailedOfflineCubit>().getFailed(),
            getCount: (context) =>
                context.read<PurchaseReturnOfflineCubit>().getJsonData().length,
            getLog: (context) =>
                context.read<PurchaseReturnOfflineCubit>().getLog(),
            onSync: (context) async {
              await context.read<PurchaseReturnOfflineCubit>().post(
                  context.read<PurchaseReturnFailedOfflineCubit>(),
                  context.read<PurchaseReturnRequestOfflineCubit>(),
                  context);
            },
            onGotoReview: (context) {
              goTo(context, ReviewPurchaseReturnOfflineSave()).then((e) async =>
                  {
                    setState(() {
                      isLoading = true;
                      isExpanded = false;
                    }),
                    await Future.delayed(const Duration(milliseconds: 1000)),
                    setState(() {
                      isLoading = false;
                    }),
                  });
            },
            onGotoSyncLog: (context) {
              goTo(context, SyncLogPurchaseReturnScreen());
            },
            onFailedSync: (context) {
              goTo(context, SyncFailLogPurchaseReturnScreen()).then((e) async =>
                  {
                    setState(() {
                      isLoading = true;
                      isExpanded = false;
                    }),
                    await Future.delayed(const Duration(milliseconds: 1000)),
                    setState(() {
                      isLoading = false;
                    }),
                  });
            },
          ),
          SyncItem(
            name: 'Goods Issue',
            getFaild: (context) =>
                context.read<GoodIssueFailedOfflineCubit>().getFailed(),
            getCount: (context) =>
                context.read<GoodsIssueOfflineCubit>().getJsonData().length,
            getLog: (context) =>
                context.read<GoodsIssueOfflineCubit>().getLog(),
            onSync: (context) async {
              await context.read<GoodsIssueOfflineCubit>().post(
                    context.read<GoodIssueFailedOfflineCubit>(),
                  );
            },
            onGotoReview: (context) {
              goTo(context, ReviewGoodsIssueOfflineSave()).then((e) async => {
                    setState(() {
                      isLoading = true;
                      isExpanded = false;
                    }),
                    await Future.delayed(const Duration(milliseconds: 1000)),
                    setState(() {
                      isLoading = false;
                    }),
                  });
            },
            onGotoSyncLog: (context) {
              goTo(context, SyncLogGoodsIssueScreen());
            },
            onFailedSync: (context) {
              goTo(context, SyncFailLogGoodIssueScreen()).then((e) async => {
                    setState(() {
                      isLoading = true;
                      isExpanded = false;
                    }),
                    await Future.delayed(const Duration(milliseconds: 1000)),
                    setState(() {
                      isLoading = false;
                    }),
                  });
            },
          ),
        ],
      ),
      SyncGroup(
        description:
            "Sync stock counting records to keep warehouse inventory aligned with SAP.",
        title: "Counting",
        items: [
          SyncItem(
            name: 'Quick Count',
            getFaild: (context) =>
                context.read<QuickCountFailedOfflineCubit>().getFailed(),
            getCount: (context) =>
                context.read<QuickCountOfflineCubit>().getJsonData().length,
            getLog: (context) =>
                context.read<QuickCountOfflineCubit>().getLog(),
            onSync: (context) async {
              await context.read<QuickCountOfflineCubit>().post(
                    context.read<QuickCountFailedOfflineCubit>(),
                  );
            },
            onGotoReview: (context) {
              goTo(context, ReviewQuickCountOfflineSave()).then((e) async => {
                    setState(() {
                      isLoading = true;
                      isExpanded = false;
                    }),
                    await Future.delayed(const Duration(milliseconds: 1000)),
                    setState(() {
                      isLoading = false;
                    }),
                  });
            },
            onGotoSyncLog: (context) {
              goTo(context, SyncLogQuickCountScreen());
            },
            onFailedSync: (context) {
              goTo(context, SyncFailLogQuickCountScreen()).then((e) async => {
                    setState(() {
                      isLoading = true;
                      isExpanded = false;
                    }),
                    await Future.delayed(const Duration(milliseconds: 1000)),
                    setState(() {
                      isLoading = false;
                    }),
                  });
            },
          ),
          SyncItem(
            name: 'Cycle Count',
            getFaild: (context) =>
                context.read<CycleCountFailedOfflineCubit>().getFailed(),
            getCount: (context) =>
                context.read<CycleCountOfflineCubit>().getJsonData().length,
            getLog: (context) =>
                context.read<CycleCountOfflineCubit>().getLog(),
            onSync: (context) async {
              await context.read<CycleCountOfflineCubit>().post(
                    context.read<CycleCountFailedOfflineCubit>(),
                  );
            },
            onGotoReview: (context) {
              goTo(context, ReviewCycleCountOfflineSave()).then((e) async => {
                    setState(() {
                      isLoading = true;
                      isExpanded = false;
                    }),
                    await Future.delayed(const Duration(milliseconds: 1000)),
                    setState(() {
                      isLoading = false;
                    }),
                  });
            },
            onGotoSyncLog: (context) {
              goTo(context, SyncLogCycleCountScreen());
            },
            onFailedSync: (context) {
              goTo(context, SyncFailLogCycleScreen()).then((e) async => {
                    setState(() {
                      isLoading = true;
                      isExpanded = false;
                    }),
                    await Future.delayed(const Duration(milliseconds: 1000)),
                    setState(() {
                      isLoading = false;
                    }),
                  });
            },
          ),
          SyncItem(
            name: 'Physical Count',
            getFaild: (context) =>
                context.read<PhysicalCountFailedOfflineCubit>().getFailed(),
            getCount: (context) =>
                context.read<PhysicalCountOfflineCubit>().getJsonData().length,
            getLog: (context) =>
                context.read<PhysicalCountOfflineCubit>().getLog(),
            onSync: (context) async {
              await context.read<PhysicalCountOfflineCubit>().post(
                    context.read<PhysicalCountFailedOfflineCubit>(),
                  );
            },
            onGotoReview: (context) {
              goTo(context, ReviewPhysicalCountOfflineSave()).then((e) async =>
                  {
                    setState(() {
                      isLoading = true;
                      isExpanded = false;
                    }),
                    await Future.delayed(const Duration(milliseconds: 1000)),
                    setState(() {
                      isLoading = false;
                    }),
                  });
            },
            onGotoSyncLog: (context) {
              goTo(context, SyncLogPhysicalCountScreen());
            },
            onFailedSync: (context) {
              goTo(context, SyncFailLogPhysicalCountScreen()).then((e) async =>
                  {
                    setState(() {
                      isLoading = true;
                      isExpanded = false;
                    }),
                    await Future.delayed(const Duration(milliseconds: 1000)),
                    setState(() {
                      isLoading = false;
                    }),
                  });
            },
          ),
          SyncItem(
            name: 'Bin Count',
            getFaild: (context) =>
                context.read<BinCountFailedOfflineCubit>().getFailed(),
            getCount: (context) =>
                context.read<BinCountOfflineCubit>().getJsonData().length,
            getLog: (context) => context.read<BinCountOfflineCubit>().getLog(),
            onSync: (context) async {
              await context.read<BinCountOfflineCubit>().post(
                    context.read<BinCountFailedOfflineCubit>(),
                  );
            },
            onGotoReview: (context) {
              goTo(context, ReviewBinCountOfflineSave()).then((e) async => {
                    setState(() {
                      isLoading = true;
                      isExpanded = false;
                    }),
                    await Future.delayed(const Duration(milliseconds: 1000)),
                    setState(() {
                      isLoading = false;
                    }),
                  });
            },
            onGotoSyncLog: (context) {
              goTo(context, SyncLogBinCountScreen());
            },
            onFailedSync: (context) {
              goTo(context, SyncFailLogBinCountScreen()).then((e) async => {
                    setState(() {
                      isLoading = true;
                      isExpanded = false;
                    }),
                    await Future.delayed(const Duration(milliseconds: 1000)),
                    setState(() {
                      isLoading = false;
                    }),
                  });
            },
          ),
        ],
      ),
    ]);
  }

  Future<void> _syncAll(BuildContext context) async {
    // 1️⃣ Show loading dialog
    final connected = await hasInternet();
    if (!connected) {
      MaterialDialog.warning(context,
          title: "Error Connection",
          body:
              "No internet connection. Please connect to Wi-Fi or mobile data.");

      return;
    }
    final progressNotifier = ValueNotifier<String>("Preparing to sync...");
    MaterialDialog.loading(context, progressNotifier: progressNotifier);

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
      // 3️⃣ Login to SAP
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
      await LocalStorageManger.setString('token', token);
      print("✅ Login successful. Token saved.");

      // 5️⃣ Process each sync group
      final modulesWithData = <SyncItem>[];
      for (final group in _syncGroups) {
        for (final item in group.items) {
          if (item.getCount(context) > 0) {
            modulesWithData.add(item);
          }
        }
      }
      
      int totalModules = modulesWithData.length;
      
      if (totalModules == 0) {
        progressNotifier.value = "No offline data to sync.";
        await Future.delayed(const Duration(milliseconds: 1000));
      } else {
        int currentModule = 0;
        for (final item in modulesWithData) {
          currentModule++;
          try {
            final count = item.getCount(context);
            progressNotifier.value = "Syncing ${item.name}...\n($currentModule of $totalModules)\n$count records";
            print("🔄 Syncing ${item.name} ($count records)...");
            await item.onSync(context);
          } catch (e) {
            print("❌ Failed to sync ${item.name}: $e");
          }
        }
      }

      // 6️⃣ Logout or remove token after all syncs
      await LocalStorageManger.removeString('token');

      // 7️⃣ Close loading dialog and show success message
      MaterialDialog.close(context);
      setState(() {
        isLoading = true;
      });
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        isLoading = false;
        isExpanded = false;
      });
      MaterialDialog.success(
        context,
        title: "Sync Completed",
        body: "All modules have been synced check log for detail.",
      );
    } catch (e) {
      // 8️⃣ Handle any unexpected error
      MaterialDialog.close(context);
      debugPrint("🔥 Unexpected error during sync: $e");
      MaterialDialog.warning(context,
          title: "Sync Error", body: "Something went wrong during sync.");
    }
  }

  Future<void> _clearAllData() async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
          "Clear All saved Data?",
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500),
        ),
        content: const Text(
            "This will remove all your saved offline data. Are you sure?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Clear",
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
    );

    // User canceled
    if (confirm != true) return;
    setState(() {
      isLoading = true;
    });
    // 1️⃣ Clear all Cubits
    final jsonData = context.read<GoodReceiptPoOfflineCubit>().getJsonData();
    for (var element in jsonData.toList()) {
      final refDocEntry = int.tryParse(
          (element["DocumentReferences"]?[0]?["RefDocEntr"]).toString());
      for (var ele in element["DocumentLines"].toList()) {
        context.read<PurchaseOrderOfflineCubit>().increaseQuantityByLine(
            docEntry: refDocEntry ?? -1,
            lineId: int.tryParse(ele["BaseLine"].toString()) ?? -1,
            quantity: double.tryParse(ele["Quantity"].toString()) ?? 0.0,
            context: context);
      }
    }
    context.read<GoodReceiptPoOfflineCubit>().clearData();//
//     context.read<GoodReceiptPoOfflineCubit>().clearCachLog();

    ///////////////
    context.read<QuickGoodReceiptOfflineCubit>().clearData();//
//     context.read<QuickGoodReceiptOfflineCubit>().clearCachLog();

    final jsonDataRRT = context.read<ReturnReceiptOfflineCubit>().getJsonData();
    for (var element in jsonDataRRT.toList()) {
      final refDocEntry =
          int.tryParse((element["DocumentLines"]?[0]?["BaseEntry"]).toString());
      for (var ele in element["DocumentLines"].toList()) {
        context.read<ReturnReceiptRequestOfflineCubit>().increaseQuantityByLine(
            docEntry: refDocEntry ?? -1,
            lineId: int.tryParse(ele["BaseLine"].toString()) ?? -1,
            quantity: double.tryParse(ele["Quantity"].toString()) ?? 0.0,
            context: context);
      }
    }
    context.read<ReturnReceiptOfflineCubit>().clearData();//
//     context.read<ReturnReceiptOfflineCubit>().clearCachLog();

    //////////////
    context.read<GoodsReceiptOfflineCubit>().clearData();//
//     context.read<GoodsReceiptOfflineCubit>().clearCachLog();

    context.read<PutAwayOfflineCubit>().clearData();//
//     context.read<PutAwayOfflineCubit>().clearCachLog();

    final jsonDataSO = context.read<DeliveryOfflineCubit>().getJsonData();
    for (var element in jsonDataSO.toList()) {
      final refDocEntry =
          int.tryParse((element["DocumentLines"]?[0]?["BaseEntry"]).toString());
      for (var ele in element["DocumentLines"].toList()) {
        context.read<SaleOrderOfflineCubit>().increaseQuantityByLine(
            docEntry: refDocEntry ?? -1,
            lineId: int.tryParse(ele["BaseLine"].toString()) ?? -1,
            quantity: double.tryParse(ele["Quantity"].toString()) ?? 0.0,
            context: context);
      }
    }
    context.read<DeliveryOfflineCubit>().clearData();//
//     context.read<DeliveryOfflineCubit>().clearCachLog();

    ///////////
    ///
    final jsonDataPR = context.read<PurchaseReturnOfflineCubit>().getJsonData();
    for (var element in jsonDataPR.toList()) {
      final refDocEntry =
          int.tryParse((element["DocumentLines"]?[0]?["BaseEntry"]).toString());
      for (var ele in element["DocumentLines"].toList()) {
        context
            .read<PurchaseReturnRequestOfflineCubit>()
            .increaseQuantityByLine(
                docEntry: refDocEntry ?? -1,
                lineId: int.tryParse(ele["BaseLine"].toString()) ?? -1,
                quantity: double.tryParse(ele["Quantity"].toString()) ?? 0.0,
                context: context);
      }
    }
    context.read<PurchaseReturnOfflineCubit>().clearData();//
//     context.read<PurchaseReturnOfflineCubit>().clearCachLog();

    /////////////////
    ///
    ///
    context.read<GoodsIssueOfflineCubit>().clearData();//
//     context.read<GoodsIssueOfflineCubit>().clearCachLog();

    context.read<QuickCountOfflineCubit>().clearData();//
//     context.read<QuickCountOfflineCubit>().clearCachLog();

    context.read<PhysicalCountOfflineCubit>().clearData();//
//     context.read<PhysicalCountOfflineCubit>().clearCachLog();

    context.read<CycleCountOfflineCubit>().clearData();//
//     context.read<CycleCountOfflineCubit>().clearCachLog();

    context.read<BinCountOfflineCubit>().clearData();//
//     context.read<BinCountOfflineCubit>().clearCachLog();

    await Future.delayed(const Duration(milliseconds: 1000));

    setState(() {
      isLoading = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: PRIMARY_COLOR,
        centerTitle: true,
        title: GestureDetector(
          onTap: () {
            context.read<GoodReciptPoFailedOfflineCubit>().printAllData();
          },
          child: const Text("Sync to SAP",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17)),
        ),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Clear All Saved Data',
            onPressed: _clearAllData,
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(strokeWidth: 4),
              ),
            )
          : Column(
              children: [
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      colors: [
                        PRIMARY_COLOR.withOpacity(0.9),
                        PRIMARY_COLOR.withOpacity(0.7),
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
                      EdgeInsets.only(right: 20, bottom: 0, left: 20, top: 20),
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
                          Icons.cloud_upload,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          "Synchronize All Modules",
                          style: TextStyle(
                              color: Colors.white, // ⚪ White text
                              fontWeight: FontWeight.bold,
                              fontSize: 14),
                        ),
                      ],
                    ),
                    onPressed: () async {
                      final result = await showDialog<bool>(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text(
                            "Confirm Sync",
                            style: TextStyle(
                                color: Colors.black87,
                                fontSize: 19,
                                fontWeight: FontWeight.w500),
                          ),
                          content: const Text(
                            "Make sure you have internet or Wi-Fi. Do you want to continue syncing all data to SAP?",
                            style: TextStyle(fontSize: 13),
                          ),
                          actions: [
                            // Cancel button
                            TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor:
                                    Colors.grey[200], // light grey background
                                foregroundColor: Colors.black87, // text color
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text(
                                "Cancel",
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),

                            // Sync button
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    PRIMARY_COLOR, // your main color
                                foregroundColor: Colors.white, // text color
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text(
                                "Sync",
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (result == true) {
                        await _syncAll(context);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: _syncGroups.length,
                    itemBuilder: (context, index) {
                      return _buildExpandableGroup(context, _syncGroups[index]);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildExpandableGroup(BuildContext context, SyncGroup group) {
    // Compute total pending items for the group
    int totalAlert;
    int totalPending = group.items.fold(
      0,
      (sum, item) => sum + (item.getCount(context)),
    );
    int totalLog = group.items.fold(
      0,
      (sum, item) => sum + (item.getLog(context)),
    );
    int totalFaild = group.items.fold(
      0,
      (sum, item) => sum + (item.getFaild(context)),
    );
    totalAlert = totalPending + totalLog + totalFaild;
    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              InkWell(
                onTap: () => setState(() => isExpanded = !isExpanded),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Icon badge
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: PRIMARY_COLOR.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.cloud_sync_rounded,
                          color: PRIMARY_COLOR,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Text column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    group.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                // Badge with total pending count
                                if (totalAlert > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '$totalAlert',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            if (group.description != null &&
                                group.description!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  group.description!,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: Colors.black54,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Expand icon
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.black54,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Expandable body
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Column(
                    children: group.items
                        .map((item) => _buildApiCard(context, item))
                        .toList(),
                  ),
                ),
                crossFadeState: isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 250),
              ),
            ],
          ),
        );
      },
    );
  }

  // 🔹 Your same _buildApiCard method (unchanged, but nice design)
  Widget _buildApiCard(BuildContext context, SyncItem item) {
    final count = item.getCount(context);
    final isReady = count > 0;
    final totalLog = item.getLog(context);
    final totalFaild = item.getFaild(context);
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
                                                  left: 5, bottom: 9),
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
                                                    size: 17),
                                                label: const Text(
                                                  "Sync Log",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 11.5),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.orange,
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
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 9, right: 5),
                                              child: ElevatedButton.icon(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  item.onFailedSync(context);
                                                },
                                                icon: const Icon(Icons.warning,
                                                    color: Colors.white,
                                                    size: 17),
                                                label: const Text(
                                                  "Failed",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.redAccent,
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
                              size: 30,
                              color: Color.fromARGB(255, 177, 174, 174),
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
                            ? Colors.green
                            : const Color.fromARGB(255, 126, 133, 126),
                      ),
                    ),
                    totalLog > 0 ? const SizedBox(height: 4) : Container(),
                    totalLog > 0
                        ? Text(
                            '$totalLog synchronization log entries',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.orange,
                            ),
                          )
                        : Container(),
                    totalFaild > 0 ? const SizedBox(height: 4) : Container(),
                    totalFaild > 0
                        ? Text(
                            '$totalFaild record(s) synced failed',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.redAccent,
                            ),
                          )
                        : Container(),
                    // as
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

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: 140,
                child: ElevatedButton.icon(
                  onPressed: item.onGotoReview != null && isReady
                      ? () {
                          item.onGotoReview!(context);
                        }
                      : null,
                  icon: const Icon(Icons.book, color: Colors.white, size: 17),
                  label: const Text(
                    "Ready to Sync",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 12,
              ),
              SizedBox(
                width: 90,
                child: ElevatedButton.icon(
                  onPressed: isReady
                      ? () async {
                          final connected = await hasInternet();
                          if (!connected) {
                            MaterialDialog.warning(context,
                                title: "Error Connection",
                                body:
                                    "No internet connection. Please connect to Wi-Fi or mobile data.");
                            return;
                          }
                          // 🌀 Show loading dialog
                          MaterialDialog.loading(context);
                          try {
                            await item.onSync(context);

                            if (context.mounted) MaterialDialog.close(context);
                            setState(() {
                              isLoading = true;
                            });
                            await Future.delayed(
                                const Duration(milliseconds: 500));
                            setState(() {
                              isLoading = false;
                              isExpanded = false;
                            });
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
                      color: Colors.white, size: 17),
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
  final String? description; // 👈 new field

  SyncGroup({this.description, required this.title, required this.items});
}
