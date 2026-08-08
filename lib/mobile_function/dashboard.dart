import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:wms_mobile/download.dart';
import 'package:wms_mobile/feature/bin_location/presentation/cubit/bin_offline_cubit.dart';
import 'package:wms_mobile/feature/business_partner/presentation/cubit/bussinessPartner_offline_cubit.dart';
import 'package:wms_mobile/feature/counting/bin_count/presentation/cubit/bin_count_offline_cubit.dart';
import 'package:wms_mobile/feature/counting/cos/presentation/cubit/cos_offline_cubit.dart';
import 'package:wms_mobile/feature/counting/counting.dart';
import 'package:wms_mobile/feature/counting/physical_count/presentation/cubit/physical_count_offline_cubit.dart';
import 'package:wms_mobile/feature/counting/quick_count/presentation/cubit/cycle_count_offline_cubit.dart';
import 'package:wms_mobile/feature/counting/quick_count/presentation/cubit/quick_count_offline_cubit.dart';
import 'package:wms_mobile/feature/good_isuse_select/presentation/cubit/isuse_type_offline_cubit.dart';
import 'package:wms_mobile/feature/good_receipt_type/presentation/cubit/receipt_type_offline_cubit.dart';
import 'package:wms_mobile/feature/inbound/good_receipt/presentation/cubit/goods_receipt_offline_cubit.dart';
import 'package:wms_mobile/feature/inbound/good_receipt_po/presentation/cubit/good_receipt_po_offline_cubit.dart';
import 'package:wms_mobile/feature/inbound/good_receipt_po/presentation/cubit/quick_good_receipt_offline_cubit.dart';
import 'package:wms_mobile/feature/inbound/purchase_order/presentation/cubit/purchase_order_offline_cubit.dart';
import 'package:wms_mobile/feature/inbound/put_away/presentation/cubit/put_away_offline_cubit.dart';
import 'package:wms_mobile/feature/inbound/return_receipt/presentation/cubit/return_receipt_offline_cubit.dart';
import 'package:wms_mobile/feature/inbound/return_receipt_request/presentation/cubit/return_receipt_request_offline_cubit.dart';
import 'package:wms_mobile/feature/item/presentation/cubit/items_barcode_offline_cubit.dart';
import 'package:wms_mobile/feature/item/presentation/cubit/items_cycle_count_offline_cubit.dart';
import 'package:wms_mobile/feature/item/presentation/cubit/items_find_stock_offline_cubit.dart';
import 'package:wms_mobile/feature/item/presentation/cubit/items_offline_cubit.dart';
import 'package:wms_mobile/feature/list_batch/presentation/cubit/batch_list_offline_cubit.dart';
import 'package:wms_mobile/feature/list_batch/presentation/screen/batch_list_page.dart';
import 'package:wms_mobile/feature/list_serial/presentation/screen/Serial_list_page.dart';
import 'package:wms_mobile/feature/lookup/lookup.dart';
import 'package:wms_mobile/feature/middleware/presentation/bloc/authorization_bloc.dart';
import 'package:wms_mobile/feature/outbounce/delivery/presentation/cubit/delivery_offline_cubit.dart';
import 'package:wms_mobile/feature/outbounce/good_issue/presentation/cubit/goods_issue_offline_cubit.dart';
import 'package:wms_mobile/feature/outbounce/outbound.dart';
import 'package:wms_mobile/feature/outbounce/purchase_return/presentation/cubit/purchase_return_offline_cubit.dart';
import 'package:wms_mobile/feature/outbounce/purchase_return_request/presentation/cubit/purchase_return_request_offline_cubit.dart';
import 'package:wms_mobile/feature/outbounce/sale_order/presentation/cubit/sale_order_offline_cubit.dart';
import 'package:wms_mobile/feature/serial/good_receip_serial_screen.dart';
import 'package:wms_mobile/feature/unit_of_measurement/presentation/cubit/uom_group_offline_cubit.dart';
import 'package:wms_mobile/feature/unit_of_measurement/presentation/cubit/uom_offline_cubit.dart';
import 'package:wms_mobile/feature/warehouse/presentation/cubit/warhouse_offline_cubit.dart';
import 'package:wms_mobile/feature/warehouse/presentation/screen/warehouse_page.dart';
import 'package:wms_mobile/form/datePicker.dart';
import 'package:wms_mobile/feature/middleware/presentation/login_screen.dart';
import 'package:wms_mobile/helper/helper.dart';
import 'package:wms_mobile/mobile_function/countingScreen.dart';
import 'package:wms_mobile/feature/inbound/inbound.dart';
import 'package:wms_mobile/mobile_function/inventoryScreen.dart';
import 'package:wms_mobile/mobile_function/packingScreen.dart';
import 'package:wms_mobile/mobile_function/receivingScreen.dart';
import 'package:wms_mobile/mobile_function/rmaScreen.dart';
import 'package:wms_mobile/sync_to_sap.dart';
import 'package:wms_mobile/utilies/dialog/dialog.dart';
import 'package:wms_mobile/utilies/storage/locale_storage.dart';
import 'package:wms_mobile/feature/pick_and_pack/pick_and_pack.dart';
import 'package:wms_mobile/feature/item/presentation/screen/product_list_screen.dart';
import 'package:wms_mobile/config/company_config.dart';

import '../constant/style.dart';



class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String warehouseCode = '';
  String warehouseName = '';

  List<Map<String, String>> get _activeMenus {
    List<Map<String, String>> menus = [];
    if (CompanyConfig.showProductMenu) {
      menus.add({"name": "Product", "img": "box.svg"});
    }
    menus.addAll([
      {"name": "Inbound", "img": "download.svg"},
      {"name": "Outbound", "img": "upload.svg"},
      {"name": "Pick and Pack", "img": "heigth.svg"},
      {"name": "Counting", "img": "counting1.svg"},
      {"name": "Lookup", "img": "look.svg"},
      {"name": "Log Out", "img": "logout1.svg"}
    ]);
    return menus;
  }
  void _logout(BuildContext context) {
    MaterialDialog.loading(context);
    _clearAllData();
    const timeoutDuration = Duration(milliseconds: 200);
    Future.delayed(timeoutDuration, () {
      BlocProvider.of<AuthorizationBloc>(context)
          .add(const RequestLogoutEvent());
    });
  }

  void onPressMenu(BuildContext context, String menuName) {
    switch (menuName) {
      case "Product":
        goTo(context, const ProductListScreen());
        break;
      case "Inbound":
        goTo(context, const Inbound());
        break;
      case "Outbound":
        goTo(context, const Outbound());
        break;
      case "Pick and Pack":
        goTo(context, const PickAndPack());
        break;
      case "Counting":
        goTo(context, const Counting());
        break;
      case "Lookup":
        goTo(context, const ProductLookUp());
        break;
      case "Log Out":
        _logout(context);
        break;
      default:
    }
  }

  @override
  void initState() {
    super.initState();

    init();
  }

  void init() async {
    final value = await LocalStorageManger.getString('warehouse');
    final name = await LocalStorageManger.getString('warehouseName');
    if (mounted) {
      setState(() {
        warehouseCode = value;
        warehouseName = name;
      });
    }
  }

  Future<void> _clearAllData() async {
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
    context.read<GoodReceiptPoOfflineCubit>().clearData();
    context.read<QuickGoodReceiptOfflineCubit>().clearData();
    context.read<ReturnReceiptOfflineCubit>().clearData();
    context.read<GoodsReceiptOfflineCubit>().clearData();
    context.read<PutAwayOfflineCubit>().clearData();
    context.read<DeliveryOfflineCubit>().clearData();
    context.read<PurchaseReturnOfflineCubit>().clearData();
    context.read<GoodsIssueOfflineCubit>().clearData();
    context.read<QuickCountOfflineCubit>().clearData();
    context.read<PhysicalCountOfflineCubit>().clearData();
    context.read<CycleCountOfflineCubit>().clearData();
    context.read<BinCountOfflineCubit>().clearData();
    // 5️⃣ Update UI
    setState(() {
      LocalStorageManger.setString('isDownloaded', 'false');
      LocalStorageManger.setString('warehouse', "");
      LocalStorageManger.setString('warehouseName', "No Warehouse");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0.2,
          automaticallyImplyLeading: false,
          leading: Container(
            padding: EdgeInsets.all(14), // Add some padding if necessary
            child: GestureDetector(
                onTap: () {
                  // goTo(
                  //     context,
                  //     const BatchListPage(
                  //       warehouse: '',
                  //     ));
                },
                child: Icon(Icons.dashboard, color: Colors.white)),
          ),
          iconTheme: const IconThemeData(
            color: Colors.black, //change your color here
          ),
          backgroundColor: PRIMARY_COLOR,
          title: Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Text(
                warehouseName,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white),
              ),
            ),
          ),
          actions: [
            IconButton(
                onPressed: () async {
                  goTo(
                    context,
                    DownloadScreen(fromDashboard: true),
                  ).then((_) async {
                    final orders =
                        context.read<ItemBarcodeOfflineCubit>().getJsonData();
                    final warehouse =
                        await LocalStorageManger.getString('warehouse');

                    if (warehouse.isEmpty && orders.length > 0) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WarehousePage(isPicker: true),
                        ),
                        (Route<dynamic> route) => false,
                      );
                    } else {
                      init();
                    }
                  });
                },
                icon: Icon(
                  Icons.download,
                  size: 25,
                  color: Colors.white,
                )),
            SizedBox(width: 10),
          ],
        ),
        body: Container(
          width: double.infinity,
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 20, 0, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.circle,
                            color: Color.fromARGB(255, 217, 217, 222)),
                        SizedBox(width: 8),
                        Text(
                          "Main Menu",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 20,
                            color: PRIMARY_COLOR,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 43,
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
                      margin: EdgeInsets.only(right: 15),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors
                              .transparent, // Make button background transparent
                          shadowColor:
                              Colors.transparent, // Remove default shadow
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 17, vertical: 0),
                        ),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.cloud_upload,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "Sync to SAP",
                              style: TextStyle(
                                  color: Colors.white, // ⚪ White text
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13),
                            ),
                          ],
                        ),
                        onPressed: () async {
                          goTo(context, SyncToSAPScreen());
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // ElevatedButton(
              //   child: Text("Download & Save"),
              //   onPressed: () async {
              //     // await Future.delayed(Duration(seconds: 2));
              //     // context.read<PurchaseOrderOfflineCubit>().addData("asasas");
              //     goTo(context, DownloadScreen());
              //     // Navigator.pop(context);
              //   },
              // ),
              // ElevatedButton(
              //   child: Text("Show"),
              //   onPressed: () async {
              //     context.read<GoodReceiptPoOfflineCubit>().printAllData();

              //     // Navigator.pop(context);
              //   },
              // ),
              // ElevatedButton(
              //   child: Text("Clear"),
              //   onPressed: () async {
              //     context.read<GoodReceiptPoOfflineCubit>().clearData();
              //     // context.read<BusinessOfflineCubit>().clearData();
              //     // context.read<WarehouseOfflineCubit>().clearData();
              //     // context.read<BinOfflineCubit>().clearData();
              //     // context.read<ItemOfflineCubit>().clearData();
              //     // context.read<UOMGroupOfflineCubit>().clearData();
              //     // context.read<UOMOfflineCubit>().clearData();
              //     // context.read<ItemBarcodeOfflineCubit>().clearData();
              //     // context.read<BatchListOfflineCubit>().clearData();
              //     // context.read<ReceiptTypeOfflineCubit>().clearData();
              //     // context.read<IssueTypeOfflineCubit>().clearData();
              //     // context.read<ReturnReceiptRequestOfflineCubit>().clearData();
              //     // context.read<SaleOrderOfflineCubit>().clearData();
              //     // context.read<PurchaseReturnRequestOfflineCubit>().clearData();

              //     // Navigator.pop(context);
              //   },
              // ),
              Expanded(
                child: ListView.builder(
                  itemCount: _activeMenus.length,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemBuilder: (BuildContext context, int index) {
                    final isLast = index == _activeMenus.length - 1;
                    return GestureDetector(
                      onTap: () => onPressMenu(context, _activeMenus[index]['name']!),
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 15),
                        decoration: BoxDecoration(
                          color: Colors.grey[100], // light slate background
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: const Color.fromARGB(255, 207, 207, 217)
                                  .withOpacity(0.2)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isLast
                                        ? Colors.red.withOpacity(0.1)
                                        : Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: SvgPicture.asset(
                                    "images/svg/${_activeMenus[index]["img"]}",
                                    width: 28,
                                    height: 28,
                                    color: isLast
                                        ? Colors.red
                                        : const Color.fromARGB(
                                            255, 18, 22, 157),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "${_activeMenus[index]['name']}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15.5,
                                    color: isLast ? Colors.red : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            if (!isLast)
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 18,
                                color: Colors.grey,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ));
  }
}
