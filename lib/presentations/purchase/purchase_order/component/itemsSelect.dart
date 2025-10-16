import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wms_mobile/core/error/failure.dart';
import 'package:wms_mobile/presentations/purchase/purchase_order/purchaseOrderCodeScreen.dart';
import 'package:wms_mobile/utilies/dio_client.dart';

class ItemsSelect extends StatefulWidget {
  ItemsSelect({
    super.key,
    required this.selectedItems,
  });
  List<dynamic> selectedItems;

  @override
  State<ItemsSelect> createState() => _ItemsSelectState();
}

class _ItemsSelectState extends State<ItemsSelect> {
  Set<int> selectedItems = {};
  DateTime selectedDate = DateTime.now();
  final DioClient dio = DioClient();
  int check = 0;
  List<dynamic> items = [];
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  int skip = 0;
  int top = 10;

  Future<void> getListItems() async {
    try {
      final response = await dio.get('/Items', query: {
        '\$top': top,
        '\$skip': skip,
      });

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            check = 1;
            items.addAll(response.data['value']);
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
    getListItems();
  }

  Future<void> _onRefresh() async {
    setState(() {
      items.clear();
      skip = 0;
    });
    await getListItems();
    _refreshController.refreshCompleted();
  }

  Future<void> _onLoading() async {
    setState(() {
      skip += top;
    });
    await getListItems();
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 17, 18, 48),
        title: const Text(
          "Items",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PurchaseOrderCodeScreen()),
              );
            },
            icon: const Icon(Icons.qr_code_scanner_outlined),
          ),
          const SizedBox(width: 15),
          IconButton(
            onPressed: () {
              Navigator.pop(
                  context, selectedItems.map((index) => items[index]).toList());
            },
            icon: const Text(
              "Done",
              style: TextStyle(fontSize: 15, color: Colors.white),
            ),
          ),
          const SizedBox(width: 13),
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
            : items.length == 0
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
                    itemCount: items.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (selectedItems.contains(index)) {
                              selectedItems.remove(index);
                            } else {
                              selectedItems.add(index);
                            }
                            print(selectedItems);
                          });
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 255, 255, 255),
                            border: Border(
                              left: BorderSide(
                                color: Color.fromARGB(255, 200, 196, 196),
                                width: 0.5,
                              ),
                              bottom: BorderSide(
                                color: Color.fromARGB(255, 202, 197, 197),
                                width: 0.5,
                              ),
                              right: BorderSide(
                                color: Color.fromARGB(255, 205, 201, 201),
                                width: 0.5,
                              ),
                            ),
                          ),
                          width: double.infinity,
                          height: 80,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: SizedBox(
                                  height: double.infinity,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Icon(
                                        selectedItems.contains(index)
                                            ? Icons.check_box
                                            : Icons.check_box_outline_blank,
                                      ),
                                      SvgPicture.asset(
                                        "images/svg/box-3.svg",
                                        width: 50,
                                        color: const Color.fromARGB(
                                            255, 58, 65, 80),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: SizedBox(
                                  height: double.infinity,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        items[index]['ItemName'],
                                        style: TextStyle(fontSize: 14.5),
                                      ),
                                      SizedBox(height: 13),
                                      Text(
                                        items[index]['ItemCode'],
                                        style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 113, 109, 109)),
                                      ),
                                    ],
                                  ),
                                ),
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
