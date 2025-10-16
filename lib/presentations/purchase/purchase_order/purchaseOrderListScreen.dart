import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:wms_mobile/component/blockList.dart';
import 'package:wms_mobile/constant/style.dart';
import 'package:wms_mobile/core/error/failure.dart';
import 'package:wms_mobile/presentations/purchase/purchase_order/create_screen/purchaseOrderCreateScreen.dart';
import 'package:wms_mobile/presentations/purchase/purchase_order/purchaseOrderDetailScreen.dart';
import 'package:wms_mobile/utilies/dialog/dialog.dart';
import 'package:wms_mobile/utilies/dio_client.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wms_mobile/utilies/formart.dart';

class PurchaseOrderListScreen extends StatefulWidget {
  const PurchaseOrderListScreen({Key? key, required this.title})
      : super(key: key);

  final String title;

  @override
  State<PurchaseOrderListScreen> createState() =>
      _PurchaseOrderListScreenState();
}

class _PurchaseOrderListScreenState extends State<PurchaseOrderListScreen> {
  DateTime selectedDate = DateTime.now();
  final DioClient dio = DioClient();
  int check = 0;
  List<dynamic> data = [];
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  int skip = 0;
  int top = 10;
  var filter = null;

  Future<void> getListPurchaseOrder(pick) async {
    try {
      final response = await dio.get(
          '/PurchaseOrders${pick != null && pick != selectedDate ? "?\$filter=DocDate eq '$pick'" : ''}',
          query: {
            '\$top': top,
            '\$skip': skip,
            '\$orderby': "DocEntry desc"
          });

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            check = 1;
            data.addAll(response.data['value']);
          });
        }
      } else {
        throw ServerFailure(message: response.data['msg']);
      }
    } on Failure {
      rethrow;
    }
  }

  @override
  void initState() {
    super.initState();
    getListPurchaseOrder(null);
  }

  Future<void> _onRefresh() async {
    setState(() {
      filter = null;
      data.clear();
      skip = 0;
    });
    await getListPurchaseOrder(null);
    _refreshController.refreshCompleted();
  }

  Future<void> _onLoading() async {
    setState(() {
      skip += top;
    });
    if (filter != null) {
      await getListPurchaseOrder(filter);
    } else {
      await getListPurchaseOrder(null);
    }
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 17, 18, 48),
        foregroundColor: Colors.white,
        title: Text(
          widget.title,
          style: TextStyle(
            color: const Color.fromARGB(255, 255, 255, 255),
            fontWeight: FontWeight.bold,
            fontSize: size(context).width * 0.045,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              MaterialDialog.success(context,
                  title: 'Oop', body: 'Scanner undermantain!');
            },
            color: Colors.white,
            icon: const Icon(Icons.qr_code_scanner_outlined),
          ),
          const SizedBox(
            width: 20,
          ),
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.calendar_today_outlined),
            onPressed: () => _selectDate(context),
          ),
          const SizedBox(
            width: 13,
          ),
        ],
      ),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: const WaterDropHeader(),
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: check == 0
            ? const Center(
                child: CircularProgressIndicator.adaptive(
                  strokeWidth: 2.5,
                ),
              )
            : data.length == 0
                ? Container(
                  margin: const EdgeInsets.only(bottom: 150.0),
                    child: Center(
                        child: Text(
                      "No Record",
                      style: TextStyle(fontSize: 15),
                    )),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                    shrinkWrap: true,
                    itemCount: data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PurchaseOrderDetailScreen(
                                purchaseOrderById: data[index],
                                title: widget.title,
                              ),
                            ),
                          );
                        },
                        child: BlockList(
                          colorStatus:
                              data[index]["DocumentStatus"] == "bost_Close"
                                  ? Colors.red
                                  : Colors.blue,
                          name:
                              "${data[index]["DocNum"]} - ${data[index]["CardName"]}",
                          date: splitDate(data[index]["DocDate"]),
                          status: replaceStringStatus(
                              data[index]["DocumentStatus"]),
                          qty: "50/300",
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: PRIMARY_COLOR,
        onPressed: createDocument,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2010),
      lastDate: DateTime(2101),
    );
    setState(() {
      filter = picked;
    });
    if (picked != null && picked != selectedDate) {
      data.clear();
      setState(() {
        check = 0;
      });
      await getListPurchaseOrder(picked);
      setState(() {
        check = 1;
      });
    }
  }

  Future<void> createDocument() async {
    // await Future.delayed(const Duration(milliseconds: 50));

    if (mounted) MaterialDialog.loading(context, barrierDismissible: false);
    // await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      MaterialDialog.close(context);
       Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>  PurchaseOrderCreateScreen(dataById: {},id: false, paymentTermList: [], seriesList: [],)),
      );
      // MaterialDialog.success(context,
      //     title: 'Oop', body: 'Internal Error Occur(1)');
    }
  }
}
