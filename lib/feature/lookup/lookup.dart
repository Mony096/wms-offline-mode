import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wms_mobile/feature/lookup/bin_lookup/presentation/bin_lookup_screen.dart';
import 'package:wms_mobile/feature/lookup/product_lookup/presentation/product_lookup_screen.dart';
import 'package:wms_mobile/utilies/dialog/dialog.dart';

import '../../constant/style.dart';
import '../../helper/helper.dart';

const gridList = [
  {"name": "Product Lookup", "img": "product_lookup.svg"},
  {"name": "Bin Lookup", "img": "bin_lookup.svg"},
];

class ProductLookUp extends StatefulWidget {
  const ProductLookUp({super.key});

  @override
  State<ProductLookUp> createState() => _ProductLookUpState();
}

class _ProductLookUpState extends State<ProductLookUp> {
  final routes = [CreateProductLookUpScreen(), CreateBinLookUpScreen()];

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
              'Lookup',
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
