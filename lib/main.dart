import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_mobile/feature/business_partner/presentation/cubit/business_partner_cubit.dart';
import 'package:wms_mobile/feature/counting/bin_count/presentation/cubit/binlocation_count_cubit.dart';
import 'package:wms_mobile/feature/counting/cos/presentation/cubit/cos_cubit.dart';
import 'package:wms_mobile/feature/counting/physical_count/presentation/cubit/physical_count_cubit.dart';
import 'package:wms_mobile/feature/counting/quick_count/presentation/cubit/quick_count_cubit.dart';
import 'package:wms_mobile/feature/good_isuse_select/presentation/cubit/grt_cubit.dart';
import 'package:wms_mobile/feature/good_receipt_type/presentation/cubit/grt_cubit.dart';
import 'package:wms_mobile/feature/inbound/good_receipt/presentation/cubit/good_receipt_cubit.dart';
import 'package:wms_mobile/feature/inbound/good_receipt_po/presentation/cubit/purchase_good_receipt_cubit.dart';
import 'package:wms_mobile/feature/inbound/purchase_order/presentation/cubit/purchase_order_offline_cubit.dart';
import 'package:wms_mobile/feature/inbound/put_away/presentation/cubit/put_away_cubit.dart';
import 'package:wms_mobile/feature/inbound/return_receipt/component/item/presentation/cubit/item_cubit.dart';
import 'package:wms_mobile/feature/item_by_code/presentation/cubit/item_cubit.dart';
import 'package:wms_mobile/feature/list_batch/presentation/cubit/batch_list_cubit.dart';
import 'package:wms_mobile/feature/list_serial/presentation/cubit/serialNumber_list_cubit.dart';
import 'package:wms_mobile/feature/lookup/bin_lookup/presentation/cubit/binlocation_lookup_cubit.dart';
import 'package:wms_mobile/feature/lookup/product_lookup/presentation/cubit/product_lookup_cubit.dart';
import 'package:wms_mobile/feature/middleware/presentation/bloc/authorization_bloc.dart';
import 'package:wms_mobile/feature/outbounce/purchase_return/presentation/cubit/purchase_return_cubit.dart';
import 'package:wms_mobile/feature/pick_and_pack/bin_transfer/presentation/cubit/bin_transfer_cubit.dart';
import 'package:wms_mobile/feature/pick_and_pack/warehouse_transfer/presentation/cubit/warehouse_transfer_cubit.dart';
import 'package:wms_mobile/feature/unit_of_measurement/presentation/cubit/uom_cubit.dart';
import 'package:wms_mobile/feature/warehouse/presentation/cubit/warehouse_cubit.dart';
import 'package:wms_mobile/main_screen.dart';
import 'package:wms_mobile/download.dart';
import 'core/disble_ssl.dart';
import 'feature/bin_location/presentation/cubit/bin_cubit.dart';
import 'feature/inbound/purchase_order/presentation/cubit/purchase_order_cubit.dart';
import 'feature/inbound/return_receipt/presentation/cubit/return_receipt_cubit.dart';
import 'feature/inbound/return_receipt_request/presentation/cubit/return_receipt_request_cubit.dart';
import 'feature/item/presentation/cubit/item_cubit.dart';
import 'feature/outbounce/delivery/presentation/cubit/delivery_cubit.dart';
import 'feature/outbounce/good_issue/presentation/cubit/good_issue_cubit.dart';
import 'feature/outbounce/purchase_return_request/presentation/cubit/purchase_return_request_cubit.dart';
import 'feature/outbounce/sale_order/presentation/cubit/sale_order_cubit.dart';
import 'injector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  // Ensures Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = DisableSSL();
  await Hive.initFlutter();
  await Hive.openBox("purchase_order");

  // (Optional) Only print directory AFTER Hive init
  final dir = await getApplicationDocumentsDirectory();
  print("📁 App directory: $dir");
  //  IdataScanner.startListening();
  // IdataScanner.startScan();
  container();
  //  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyMainApp());
}

class MyMainApp extends StatefulWidget {
  const MyMainApp({super.key});

  @override
  State<MyMainApp> createState() => _MyMainAppState();
}

class _MyMainAppState extends State<MyMainApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<AuthorizationBloc>()),
        BlocProvider(create: (_) => getIt<PurchaseOrderCubit>()),
        BlocProvider(create: (_) => getIt<WarehouseCubit>()),
        BlocProvider(create: (_) => getIt<BinCubit>()),
        BlocProvider(create: (_) => getIt<ItemByCodeCubit>()),
        BlocProvider(create: (_) => getIt<GrtCubit>()),
        BlocProvider(create: (_) => getIt<GoodIssueSelectCubit>()),
        BlocProvider(create: (_) => getIt<ItemCubit>()),
        BlocProvider(create: (_) => getIt<ItemCubits>()),
        BlocProvider(create: (_) => getIt<CosCubit>()),
        BlocProvider(create: (_) => getIt<BatchListCubit>()),
        BlocProvider(create: (_) => getIt<SerialListCubit>()),
        BlocProvider(create: (_) => getIt<UnitOfMeasurementCubit>()),
        BlocProvider(create: (_) => getIt<BusinessPartnerCubit>()),
        BlocProvider(create: (_) => getIt<PurchaseGoodReceiptCubit>()),
        BlocProvider(create: (_) => getIt<ReturnReceiptCubit>()),
        BlocProvider(create: (_) => getIt<ReturnReceiptRequestCubit>()),
        BlocProvider(create: (_) => getIt<PutAwayCubit>()),
        BlocProvider(create: (_) => getIt<GoodReceiptCubit>()),
        BlocProvider(create: (_) => getIt<QuickCountCubit>()),
        BlocProvider(create: (_) => getIt<PhysicalCountCubit>()),
        BlocProvider(create: (_) => getIt<ProductLookUpCubit>()),
        BlocProvider(create: (_) => getIt<BinLookUpCubit>()),
        BlocProvider(create: (_) => getIt<BinlocationCountCubit>()),
        BlocProvider(create: (_) => getIt<GoodIssueCubit>()),
        BlocProvider(create: (_) => getIt<SaleOrderCubit>()),
        BlocProvider(create: (_) => getIt<DeliveryCubit>()),
        BlocProvider(create: (_) => getIt<PurchaseReturnCubit>()),
        BlocProvider(create: (_) => getIt<PurchaseReturnRequestCubit>()),
        BlocProvider(create: (_) => getIt<BinTransferCubit>()),
        BlocProvider(create: (_) => getIt<WarehouseTransferCubit>()),
        BlocProvider(create: (_) => PurchaseOrderOfflineCubit()),
      ],
      child: const MainScreen(),
    );
  }
}
