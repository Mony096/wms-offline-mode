import 'package:flutter/material.dart';
import 'package:wms_mobile/component/flexTwo.dart';
import 'package:wms_mobile/form/flexTwoArrowWithText.dart';
import 'package:wms_mobile/presentations/inventory/good_Receipt/component/good_Receipt_item_detail_screen.dart';
import 'package:wms_mobile/presentations/purchase/purchase_order/purchaseOrderCodeScreen.dart';

class GoodReceiptListItemDetailScreen extends StatefulWidget {
  GoodReceiptListItemDetailScreen({super.key, required this.itemList, required this.binList});
  Map<String, dynamic> itemList;
  List<dynamic> binList;
  @override
  State<GoodReceiptListItemDetailScreen> createState() =>
      _GoodReceiptListItemDetailScreenState();
}

class _GoodReceiptListItemDetailScreenState
    extends State<GoodReceiptListItemDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 17, 18, 48),
        title: const Text(
          'Store Request',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          const SizedBox(
            width: 15,
          ),
          const Icon(
            Icons.more_vert,
            size: 25,
          ),
          const SizedBox(
            width: 13,
          ),
        ],
      ),
      body: Container(
        color: const Color.fromARGB(255, 236, 233, 233),
        height: double.infinity,
        width: double.infinity,
        child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
            shrinkWrap: true,
            itemCount: widget.itemList["DocumentLines"].length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => GoodReceiptItemDetailScreen(
                            itemDetail: widget.itemList["DocumentLines"]
                                [index],
                                binList:widget.binList
                                )),
                  );
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
                          color: Color.fromARGB(255, 188, 183, 183),
                          width: 0.5,
                        ),
                        right: BorderSide(
                          color: Color.fromARGB(255, 192, 188, 188),
                          width: 0.5,
                        ),
                      )),
                  padding: const EdgeInsets.all(5),
                  width: double.infinity,
                  height: 75.0,
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                          flex: 6,
                          child: Container(
                            child: Column(children: [
                              Expanded(
                                  flex: 3,
                                  child: Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "${widget.itemList["DocumentLines"][index]["ItemDescription"]}",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15),
                                        ),
                                        Text(
                                            "${widget.itemList["DocumentLines"][index]["Quantity"]} - ${widget.itemList["DocumentLines"][index]["UoMCode"]}",
                                            style: TextStyle(
                                                fontSize: 15.2,
                                                color: Color.fromARGB(
                                                    255, 0, 0, 0)))
                                      ],
                                    ),
                                  )),
                              Expanded(
                                  flex: 3,
                                  child: Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "${widget.itemList["DocumentLines"][index]["ItemCode"]}",
                                          style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 106, 103, 103)),
                                        ),
                                        Text(
                                          "Wh - ${widget.itemList["DocumentLines"][index]["WarehouseCode"]}",
                                          style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 106, 103, 103)),
                                        )
                                      ],
                                    ),
                                  ))
                            ]),
                          )),
                      Expanded(
                          flex: 1,
                          child: Container(
                            child: const Center(
                              child: Icon(
                                Icons.arrow_forward_ios,
                                size: 20,
                              ),
                            ),
                          ))
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }
}
