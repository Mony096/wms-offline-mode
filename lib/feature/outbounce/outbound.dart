import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wms_mobile/feature/outbounce/purchase_return/presentation/create_purchase_return_screen.dart';
import 'package:wms_mobile/utilies/dialog/dialog.dart';
import '/feature/inbound/good_receipt_po/presentation/create_good_receipt_screen.dart';
import '/feature/inbound/purchase_order/presentation/purchase_order_page.dart';
import '../inbound/return_receipt/presentation/create_return_receipt_screen.dart';

import '../../constant/style.dart';
import '../../helper/helper.dart';
import 'delivery/presentation/create_delivery_screen.dart';
import 'good_issue/presentation/create_good_issue_screen.dart';

const gridList = [
  {"name": "Delivery", "img": "delivery.svg"},
  {"name": "Return To Supplier", "img": "return1.svg"},
  {"name": "Good Issue", "img": "subtract.svg"},
];

class Outbound extends StatefulWidget {
  const Outbound({super.key});

  @override
  State<Outbound> createState() => _OutboundState();
}

class _OutboundState extends State<Outbound> {
  final routes = [
    CreateDeliveryScreen(),
    CreatePurchaseReturnScreen(),
    CreateGoodIssueScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        // automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(
          color: Colors.white, //change your color here
        ),
        backgroundColor: PRIMARY_COLOR,
        title: Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 65),
            child: const Text(
              'Outbound',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white),
            ),
          ),
        ),
      ),
      body: Container(
          // padding: const EdgeInsets.all(12),
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 10,
              ),
              SizedBox(
                child: ListView.builder(
                  // padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                  shrinkWrap: true,
                  itemCount: gridList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                        onTap: () {
                          goTo(context, routes[index]);
                        },
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
                                  .withOpacity(0.2),
                            ),
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
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: SvgPicture.asset(
                                      "images/svg/${gridList[index]["img"]}",
                                      width: 28,
                                      height: 28,
                                      color: const Color.fromARGB(
                                          255, 18, 22, 157),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    gridList[index]["name"] ?? "",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15.5,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ));
                  },
                ),
              )
            ],
          )),
    );
  }
}
