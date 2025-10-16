import 'package:flutter/material.dart';
import 'package:wms_mobile/constant/style.dart';
import 'package:wms_mobile/presentations/purchase/purchase_order/component/purchaseOrderItemsDetailScreen.dart';

class ContentScreen extends StatefulWidget {
  final Map<String, dynamic> poContent;

  const ContentScreen({super.key, required this.poContent});
  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: PRIMARY_BG_COLOR,
        height: double.infinity,
        width: double.infinity,
        child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
            shrinkWrap: true,
            itemCount: widget.poContent["DocumentLines"].length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PurchaseOrderItemsScreen(
                            itemDetail: widget.poContent["DocumentLines"][index],)),
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
                                          "${widget.poContent["DocumentLines"][index]["ItemDescription"]}",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14),
                                        ),
                                        Text(
                                            "Quantity: ${widget.poContent["DocumentLines"][index]["Quantity"]}",
                                            style: TextStyle(
                                                fontSize: 14,
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
                                          "${widget.poContent["DocumentLines"][index]["ItemCode"]}",
                                          style: TextStyle(
                                              fontSize: 13.5,
                                              color: Color.fromARGB(
                                                  255, 106, 103, 103)),
                                        ),
                                        Text(
                                          "${widget.poContent["DocumentLines"][index]["UoMCode"]}",
                                          style: TextStyle(
                                              fontSize: 14,
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
