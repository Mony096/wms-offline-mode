import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wms_mobile/feature/bin_location/domain/entity/bin_entity.dart';
import 'package:wms_mobile/feature/bin_location/presentation/cubit/bin_cubit.dart';
import 'package:wms_mobile/feature/inbound/put_away/presentation/create_put_away_screen.dart';
import 'package:wms_mobile/utilies/dialog/dialog.dart';
import 'package:wms_mobile/utilies/dio_client.dart';
import 'package:wms_mobile/utilies/storage/locale_storage.dart';
import '/feature/inbound/good_receipt_po/presentation/create_good_receipt_screen.dart';
import '/feature/inbound/purchase_order/presentation/purchase_order_page.dart';
import 'return_receipt/presentation/create_return_receipt_screen.dart';

import '../../constant/style.dart';
import '../../helper/helper.dart';
import 'good_receipt/presentation/create_good_receipt_screen.dart';

class Inbound extends StatefulWidget {
  const Inbound({super.key});

  @override
  State<Inbound> createState() => _InboundState();
}

class _InboundState extends State<Inbound> {
  final DioClient dio = DioClient();

  List<Map<String, String>> gridList = [
    {"name": "Goods Receipt PO", "img": "receipt_po.svg"},
    {"name": "Quick Goods Receipt", "img": "pen.svg"},
    {"name": "Customer Return Receipt", "img": "return1.svg"},
    {"name": "Goods Receipt", "img": "add_home_work.svg"},
    {"name": "Put Away", "img": "put.svg"},
    
  ];

  final routes = [
    const PurchaseOrderPage(),
    const CreateGoodReceiptPOScreen(quickReceipt: true),
    const CreateReturnReceiptScreen(),
    const CreateGoodReceiptScreen(),
    const CreatePutAwayScreen(),
  ];

  bool _isLoading = true;
  late BinCubit _bloc;
  List<BinEntity> data = [];

  @override
  void initState() {
    super.initState();
    _checkBin();
  }

  Future<void> _checkBin() async {
    try {
      _bloc = context.read<BinCubit>();
      final state = _bloc.state;
      if (state is BinData) {
        // print(state.entities);
        data = state.entities;
      }
      // print(data.where((b) => b.warehouse == "05"));
      // replace 'warehouse.text' with your actual variable or controller
      final warehouse = await LocalStorageManger.getString('warehouse');
      if (mounted) {
        setState(() {
          // remove "Put Away" if no bins found
          if (data.where((b) => b.warehouse == warehouse).isEmpty) {
            gridList.removeWhere((item) => item["name"] == "Put Away");
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      debugPrint('Error checking bins: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // SizedBox(
            //     width: 25,
            //     height: 25,
            //     child: CircularProgressIndicator(
            //       color: Colors.grey,
            //     )),

            Text(
              "Waiting initialize Inbound",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            )
          ],
        )),
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: PRIMARY_COLOR,
        title: const Center(
          child: Padding(
            padding: EdgeInsets.only(right: 65),
            child: Text(
              'Inbound',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        margin: EdgeInsets.only(top: 10),
        color: Colors.white,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: gridList.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                goTo(context, routes[index]);
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(15, 22, 12, 22),
                margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color.fromARGB(255, 242, 243, 244),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset(
                          "images/svg/${gridList[index]["img"]}",
                          color: const Color.fromARGB(255, 18, 22, 157),
                          width: 30,
                          height: 30,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          gridList[index]["name"] ?? "",
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 15.5,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 20,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
