import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wms_mobile/feature/pick_and_pack/bin_transfer/presentation/create_bin_transfer_screen.dart';
import 'package:wms_mobile/feature/pick_and_pack/warehouse_transfer/presentation/create_warehouse_transfer_screen.dart';
import '/utilies/dialog/dialog.dart';

import '../../constant/style.dart';
import '../../helper/helper.dart';
import 'put_away/presentation/create_put_away_screen.dart';

const gridList = [
  {"name": "Picking", "img": "download.svg"},
  {"name": "Put Away", "img": "download.svg"},
  {"name": "Bin Transfer", "img": "return.svg"},
  {"name": "Warehouse Transfer", "img": "return.svg"},
];

class PickAndPack extends StatefulWidget {
  const PickAndPack({super.key});

  @override
  State<PickAndPack> createState() => _PickAndPackState();
}

class _PickAndPackState extends State<PickAndPack> {
  final routes = [
    CreatePutAwayScreen(),
    CreatePutAwayScreen(),
    CreateBinTransferScreen(),
    CreateWarehouseTransferScreen(),
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
        title: Text(
          "PickAndPack",
          style: TextStyle(
            color: Colors.white,
            fontSize: size(context).width * 0.045,
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
                child: ListView.builder(
                  // padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                  shrinkWrap: true,
                  itemCount: gridList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0)),
                      child: ListTile(
                        onTap: () {
                          if (!routes.asMap().containsKey(index) ||
                              index == 0) {
                            MaterialDialog.success(context,
                                title: 'Oop',
                                body:
                                    '${gridList[index]['name']} is not implement yet!');
                            return;
                          }

                          goTo(context, routes[index]);
                        },
                        leading: SvgPicture.asset(
                          color: Color.fromARGB(235, 28, 60, 176),
                          "images/svg/${gridList[index]["img"]}",
                          width: size(context).width * 0.08,
                          height: size(context).width * 0.08,
                        ),
                        title: Text('${gridList[index]['name']}'),
                      ),
                    );
                  },
                ),
              )
            ],
          )),
    );
  }
}
