// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wms_mobile/constant/style.dart';
import 'package:wms_mobile/presentations/purchase/purchase_order/component/account.dart';
import 'package:wms_mobile/presentations/purchase/purchase_order/component/content.dart';
import 'package:wms_mobile/presentations/purchase/purchase_order/component/header.dart';
import 'package:wms_mobile/presentations/purchase/purchase_order/component/logistics.dart';
import 'package:wms_mobile/presentations/purchase/purchase_order/create_screen/purchaseOrderCreateScreen.dart';
import 'package:wms_mobile/utilies/dialog/dialog.dart';
import 'package:wms_mobile/utilies/dio_client.dart';

const borderStyle = BoxDecoration(
  color: Color.fromARGB(255, 255, 255, 255),
  border: Border(
    left: BorderSide(
      color: Color.fromARGB(255, 200, 196, 196),
      width: 0.5,
    ),
    bottom: BorderSide(
      color: Color.fromARGB(255, 188, 183, 183),
      width: 0.5,
    ),
    right: BorderSide(
      color: Color.fromARGB(255, 192, 188, 188),
      width: 0.5,
    ),
    top: BorderSide(
      color: Color.fromARGB(255, 192, 188, 188),
      width: 0.5,
    ),
  ),
);

class PurchaseOrderDetailScreen extends StatefulWidget {
  final Map<String, dynamic> purchaseOrderById;
  final String title;
  const PurchaseOrderDetailScreen(
      {super.key, required this.purchaseOrderById, required this.title});

  @override
  State<PurchaseOrderDetailScreen> createState() =>
      _PurchaseOrderDetailScreenState();
}

/// [AnimationController]s can be created with `vsync: this` because of
/// [TickerProviderStateMixin].
class _PurchaseOrderDetailScreenState extends State<PurchaseOrderDetailScreen>
    with TickerProviderStateMixin {
  // late final TabController _tabController;
  final DioClient dio = DioClient();
  final List<dynamic> _seriesList = [];
  final List<dynamic> _paymentTermList = [];
  int check = 0;
  void init() async {
    Map<String, dynamic> payload = {
      'DocumentTypeParams': {'Document': '22'},
    };
    await dio
        .post('/SeriesService_GetDocumentSeries', data: payload)
        .then((res) => {
              if (mounted)
                {
                  setState(() {
                    _seriesList.addAll(res.data["value"]);
                  })
                }
            })
        .catchError((e) => throw e);
    await dio
        .get('/PaymentTermsTypes?\$select=PaymentTermsGroupName,GroupNumber')
        .then((res) => {
              if (mounted)
                {
                  setState(() {
                    _paymentTermList.addAll(res.data["value"]);
                  })
                }
            })
        .catchError((e) => throw e);
    check = 1;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  @override
  // void dispose() {
  //   _tabController.dispose();
  //   super.dispose();
  // }
  TabBar get _tabBar => const TabBar(
        // isScrollable: true,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            width: 2.0, // Set the thickness of the underline
            color: Color.fromARGB(255, 17, 18, 48),
          ),
          insets: EdgeInsets.symmetric(
              horizontal:
                  60.0), // Adjust this value to make the underline shorter
        ),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        labelColor: const Color.fromARGB(255, 17, 18, 48),
        indicatorWeight: 3,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        tabs: [
          Tab(
            child: Text(
              "Header",
              // style: TextStyle(color: Colors.black),
            ),
          ),
          Tab(
            child: Text(
              "Contents",
              // style: TextStyle(color: Colors.black),
            ),
          ),
          Tab(
            child: Text(
              "Logistics",
              // style: TextStyle(color: Colors.black),
            ),
          ),
          Tab(
            child: Text(
              "Accounts",
              // style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      );
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.white,
          backgroundColor: const Color.fromARGB(255, 17, 18, 48),
          title: Text(
            widget.title,
            style: TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontWeight: FontWeight.bold,
                fontSize: size(context).width * 0.045),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.copy_all_outlined),
              onPressed: _copyToDocuments,
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: _setting,
            ),
          ],
          // bottom: PreferredSize(
          //   preferredSize: _tabBar.preferredSize,
          //   child: Material(
          //     color: const Color.fromARGB(255, 255, 255, 255),
          //     child: Theme(
          //         //<-- SEE HERE
          //         data: ThemeData().copyWith(
          //             splashColor: const Color.fromARGB(255, 221, 221, 225)),
          //         child: _tabBar),
          //   ),
          // ),
          bottom: PreferredSize(
            preferredSize: _tabBar.preferredSize,
            child: Material(
              color: const Color.fromARGB(255, 255, 255, 255),
              child: Theme(
                  //<-- SEE HERE
                  data: ThemeData().copyWith(
                      splashColor: const Color.fromARGB(255, 221, 221, 225)),
                  child: _tabBar),
            ),
          ),
        ),
        body: check == 0
            ? const Center(
                child: CircularProgressIndicator.adaptive(
                  strokeWidth: 2.5,
                ),
              )
            : TabBarView(
                // controller: _tabController,
                children: <Widget>[
                  HeaderScreen(
                      seriesList: _seriesList,
                      poHeader: widget.purchaseOrderById),
                  ContentScreen(poContent: widget.purchaseOrderById),
                  LogisticScreen(poLogistics: widget.purchaseOrderById),
                  AccountScreen(
                      paymentTermList: _paymentTermList,
                      poAccount: widget.purchaseOrderById)
                ],
              ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: PRIMARY_COLOR,
          onPressed: () => createDocument(),
          child: SvgPicture.asset(
            "images/svg/edit.svg",
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<void> createDocument() async {
    if (mounted) MaterialDialog.loading(context, barrierDismissible: false);
    // await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      MaterialDialog.close(context);
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PurchaseOrderCreateScreen(
              seriesList:_seriesList,
              paymentTermList:_paymentTermList,
                id: true, dataById: widget.purchaseOrderById)),
      );
      // MaterialDialog.success(context,
      //     title: 'Oop', body: 'Internal Error Occur(1)');
    }
  }

  void _copyToDocuments() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 181,
          color: const Color.fromARGB(255, 237, 236, 236),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    createDocument;
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: borderStyle,
                    child: const Center(
                        child: Text(
                      "Good Receipt PO",
                      style: TextStyle(fontSize: 15),
                    )),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    createDocument;
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: borderStyle,
                    child: const Center(
                        child: Text(
                      "Direct Put It Away",
                      style: TextStyle(fontSize: 15),
                    )),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: borderStyle,
                    child: const Center(
                        child: Text(
                      "Cancel",
                      style: TextStyle(fontSize: 15),
                    )),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _setting() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 181,
          color: const Color.fromARGB(255, 237, 236, 236),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                GestureDetector(
                  onTap: createDocument,
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: borderStyle,
                    child: const Center(
                        child: Text(
                      "Approve",
                      style: TextStyle(fontSize: 15),
                    )),
                  ),
                ),
                GestureDetector(
                  onTap: createDocument,
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: borderStyle,
                    child: const Center(
                        child: Text(
                      "Cancel Purchase Order",
                      style: TextStyle(fontSize: 15),
                    )),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: borderStyle,
                    child: const Center(
                        child: Text(
                      "Cancel",
                      style: TextStyle(fontSize: 15),
                    )),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
