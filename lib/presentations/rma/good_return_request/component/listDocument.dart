
import 'package:flutter/material.dart';
import 'package:wms_mobile/component/blockList.dart';
import 'package:wms_mobile/core/error/failure.dart';
import 'package:wms_mobile/presentations/rma/good_return_request/good_return_request_detail_screen.dart';
import 'package:wms_mobile/utilies/dio_client.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wms_mobile/utilies/formart.dart';

class ListDocument extends StatefulWidget {
  const ListDocument({Key? key}) : super(key: key);

  @override
  State<ListDocument> createState() => _ListDocumentState();
}

class _ListDocumentState extends State<ListDocument> {
  DateTime selectedDate = DateTime.now();
  final DioClient dio = DioClient();
  int check = 0;
  List<dynamic> data = [];
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  int skip = 0;
  int top = 10;

  Future<void> getListPurchaseOrder() async {
    try {
      final response = await dio.get('/GoodsReturnRequest', query: {
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
    getListPurchaseOrder();
  }

  Future<void> _onRefresh() async {
    setState(() {
      data.clear();
      skip = 0;
    });
    await getListPurchaseOrder();
    _refreshController.refreshCompleted();
  }

  Future<void> _onLoading() async {
    setState(() {
      skip += top;
    });
    await getListPurchaseOrder();
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
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
                        builder: (context) => GoodReturnRequestDetailScreens(
                          goodReturnReqById: data[index],
                        ),
                      ),
                    );
                  },
                  child: BlockList(
                    colorStatus: data[index]["DocumentStatus"] == "bost_Close"
                        ? Colors.red
                        : Colors.blue,
                    name:
                        "${data[index]["DocNum"]} - ${data[index]["CardName"]}",
                    date: splitDate(data[index]["DocDate"]),
                    status: replaceStringStatus(data[index]["DocumentStatus"]),
                    qty: "50/300",
                  ),
                );
              },
            ),
    );
  }
}
