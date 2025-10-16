import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wms_mobile/feature/middleware/presentation/login_screen.dart';

import '../constant/style.dart';
// import '../feature/receving/good_receipt/presentation/good_receipt_list_screen.dart';

const gridList = [
  {"name": "Packing Pallet", "img": "request-changes.svg"},
  {"name": "Pallet Print", "img": "printer.svg"},
  {"name": "Pallet Break", "img": "file-earmark-break.svg"},
  {"name": "Pallet Inquiry", "img": "document-preliminary.svg"},
];

class PackingScreen extends StatefulWidget {
  const PackingScreen({super.key});

  @override
  State<PackingScreen> createState() => _PackingScreenState();
}

class _PackingScreenState extends State<PackingScreen> {
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
          "Packing",
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
              // const Text(
              //   "Function",
              //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              // ),
              // const SizedBox(
              //   height: 20,
              // ),
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
                      return Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5)),
                        child: GestureDetector(
                          // onTap: () {
                          //   Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) => GoodReceiptListScreen(
                          //               title: gridList[index]["name"] ?? '',
                          //             )),
                          //   );
                          // },
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
