import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wms_mobile/core/error/failure.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wms_mobile/presentations/inventory/good_Receipt/component/listDocument.dart';
import 'package:wms_mobile/presentations/inventory/good_Receipt/component/listOffLineDocument.dart';
import 'package:wms_mobile/presentations/inventory/good_Receipt/create_screen/good_Receipt_create_screen.dart';
import 'package:wms_mobile/utilies/dialog/dialog.dart';
import 'package:wms_mobile/utilies/dio_client.dart';

class GoodReceiptListScreen extends StatefulWidget {
  const GoodReceiptListScreen({super.key});

  @override
  State<GoodReceiptListScreen> createState() => _GoodReceiptListScreenState();
}

class _GoodReceiptListScreenState extends State<GoodReceiptListScreen>
    with TickerProviderStateMixin {
  DateTime selectedDate = DateTime.now();
  final DioClient dio = DioClient();
  int check = 0;
  List<dynamic> data = [];
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  int skip = 0;
  int top = 10;
  var filter = null;

  Future<void> getListGR(pick) async {
    try {
      final response = await dio.get(
          '/InventoryGenEntries${pick != null && pick != selectedDate ? "?\$filter=DocDate eq '$pick'" : ''}',
          query: {'\$top': top, '\$skip': skip, '\$orderby': "DocEntry desc"});
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
    getListGR(null);
  }

  Future<void> _onRefresh() async {
    setState(() {
      filter = null;
      data.clear();
      skip = 0;
    });
    await getListGR(null);
    _refreshController.refreshCompleted();
  }

  Future<void> _onLoading() async {
    setState(() {
      skip += top;
    });
    if (filter != null) {
      await getListGR(filter);
    } else {
      await getListGR(null);
    }
    _refreshController.loadComplete();
  }

  @override
  // void dispose() {
  //   _tabController.dispose();
  //   super.dispose();
  // }
  TabBar get _tabBar => TabBar(
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            width: 2.0, // Set the thickness of the underline
            color: Color.fromARGB(255, 17, 18, 48),
          ),
          insets: EdgeInsets.symmetric(
              horizontal:
                  35.0), // Adjust this value to make the underline shorter
        ),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        labelColor: const Color.fromARGB(255, 17, 18, 48),
        indicatorWeight: 3,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        tabs: [
          Tab(
            child: Center(
              child: Row(
                mainAxisSize:
                    MainAxisSize.min, // Centers the content within the tab
                children: [
                  SvgPicture.asset(
                    "images/svg/document-preliminary.svg",
                    width: 25,
                  ),
                  SizedBox(
                      width: 8), // Adds space between the icon and the text
                  Text("SAP"),
                ],
              ),
            ),
          ),
          Tab(
            child: Center(
              child: Row(
                mainAxisSize:
                    MainAxisSize.min, // Centers the content within the tab
                children: [
                  SvgPicture.asset(
                    "images/svg/cloud-offline-outline.svg",
                    width: 25,
                  ),
                  SizedBox(
                      width: 8), // Adds space between the icon and the text
                  Text("Offline"),
                ],
              ),
            ),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.white,
          backgroundColor: const Color.fromARGB(255, 17, 18, 48),
          title: const Text(
            'Good Receipt',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
        body: Stack(
          children: [
            TabBarView(
              // controller: _tabController,
              children: <Widget>[
                ListDocument(
                  refreshController: _refreshController,
                  onRefresh: _onRefresh,
                  onLoading: _onLoading,
                  check: check,
                  data: data,
                ),
                ListOffLineDocument(),
              ],
            ),
            Positioned(
                bottom: 30,
                right: 30,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => GoodReceiptCreateScreen(id: false, dataById: {}, seriesList: [], listIssueType: [], employeeList: [], binlocationList: [],)),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromARGB(255, 111, 115, 119),
                            blurRadius: 10,
                            offset: Offset(2, 5), // Shadow position
                          ),
                        ],
                        color: const Color.fromARGB(255, 17, 18, 48),
                        borderRadius: BorderRadius.circular(100.0)),
                    width: 60,
                    height: 60,
                    child: const Center(
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ))
          ],
        ),
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
      await getListGR(picked);
      setState(() {
        check = 1;
      });
    }
  }
}
