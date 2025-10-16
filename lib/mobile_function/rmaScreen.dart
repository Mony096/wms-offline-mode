import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wms_mobile/feature/middleware/presentation/login_screen.dart';
import 'package:wms_mobile/presentations/rma/good_return_request/good_return_request_list.dart';

import '../constant/style.dart';
// import '../feature/receving/good_receipt/presentation/good_receipt_list_screen.dart';

const gridList = [
  {"name": "Return Request", "img": "request-changes.svg"},
  {"name": "Good Return Request", "img": "document-subtract.svg"},
  {"name": "Quick Return", "img": "document-add.svg"},
];

class MRAScreen extends StatefulWidget {
  const MRAScreen({super.key});

  @override
  State<MRAScreen> createState() => _MRAScreenState();
}

class _MRAScreenState extends State<MRAScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.2,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              icon: const Icon(Icons.logout)),
          const SizedBox(
            width: 15,
          )
        ],
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: const Text(
          "RMA",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: Container(
          padding: const EdgeInsets.all(12),
          width: double.infinity,
          height: double.infinity,
          color: PRIMARY_BG_COLOR,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                child: GridView.builder(
                    shrinkWrap: true, // use
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10.0,
                            mainAxisSpacing: 10.0),
                    itemCount: gridList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          if (index == 0) {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //       builder: (context) =>
                            //           const PurchaseOrderListScreen(
                            //             title: 'Purchase Order',
                            //           )),
                            // );
                          } else if (index == 1) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const GoodReturnRequestListScreen()),
                            );
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5)),
                          child: Center(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                "images/svg/${gridList[index]["img"]}",
                                width: size(context).width * 0.1,
                                height: size(context).width * 0.1,
                              ),
                              const SizedBox(
                                height: 18,
                              ),
                              Text(
                                "${gridList[index]["name"]}",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: size(context).width * 0.035),
                              ),
                            ],
                          )),
                        ),
                      );
                    }),
              )
            ],
          )),
    );
  }
}
