import 'package:flutter/material.dart';
import 'package:wms_mobile/component/flex_two_field.dart';
import 'package:wms_mobile/feature/inbound/quick_good_receipt/component/list_to_do_item.dart';

class QuickGoodReceiptCreateScreen extends StatefulWidget {
  QuickGoodReceiptCreateScreen({super.key, required this.data});
  Map<String, dynamic> data;
  // ignore: prefer_typing_uninitialized_variables

  @override
  State<QuickGoodReceiptCreateScreen> createState() =>
      _QuickGoodReceiptCreateScreenState();
}

class _QuickGoodReceiptCreateScreenState
    extends State<QuickGoodReceiptCreateScreen> {
  // start form field
  TextEditingController whs = TextEditingController();
  TextEditingController sub = TextEditingController();
  TextEditingController item = TextEditingController();
  TextEditingController uom = TextEditingController();
  TextEditingController qty = TextEditingController();
  List<dynamic> document = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  void init() async {
    whs.text = "1";
    if (widget.data.isNotEmpty) {
      sub.text = widget.data["DocNum"]?.toString() ?? "";
    }
  }

  void addDocument() {
    int total = 0;

    Map<String, dynamic> newRow = {
      "ItemCode": item.text,
      "UoM": uom.text,
      "Quantity": qty.text,
      "TotalQty": "",
      "ItemDescription": "",
    };
    if (item.text != "") {
      newRow["TotalQty"] = widget.data["DocumentLines"]
          .firstWhere((e) => e["ItemCode"] == item.text)["Quantity"];
      newRow["ItemDescription"] = widget.data["DocumentLines"]
          .firstWhere((e) => e["ItemCode"] == item.text)["ItemDescription"];
    }

    setState(() {
      document = [...document, newRow];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(238, 16, 50, 171),
        title: const Text(
          'Quick Receipt',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        height: 70,
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(0)),
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  addDocument();
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Color.fromARGB(255, 12, 112, 32),
                      borderRadius: BorderRadius.circular(5)),
                  width: 110,
                  child: Center(
                    child: Text(
                      "Add",
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    color: Color.fromARGB(238, 16, 50, 171),
                    borderRadius: BorderRadius.circular(5)),
                width: 110,
                child: Center(
                  child: Text(
                    "Finish",
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    color: Color.fromARGB(238, 16, 50, 171),
                    borderRadius: BorderRadius.circular(5)),
                width: 110,
                child: Center(
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      body: Container(
          padding: EdgeInsets.all(20),
          width: double.infinity,
          height: double.infinity,
          color: Color.fromARGB(255, 255, 255, 255),
          child: ListView(
            children: [
              FlexTwoField(title: "Whs", values: whs),
              SizedBox(
                height: 10,
              ),
              FlexTwoField(title: "Sup", values: sub),
              SizedBox(
                height: 10,
              ),
              FlexTwoField(title: "Item", values: item),
              SizedBox(
                height: 10,
              ),
              FlexTwoField(title: "UOM", values: uom),
              SizedBox(
                height: 10,
              ),
              FlexTwoField(title: "Qty", values: qty),
              SizedBox(
                height: 20,
              ),
              Container(
                height: 40,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.black, width: 1.0),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(flex: 7, child: Text("Item Number")),
                    Expanded(flex: 2, child: Text("UoM")),
                    Expanded(flex: 2, child: Text("Qty/Open")),
                  ],
                ),
              ),
              Container(
                // height: d,
                child: ListView.builder(
                  // padding: const EdgeInsets.fromLTRB(0, 13, 0, 0),
                  shrinkWrap: true,
                  itemCount: document.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                        onTap: () {},
                        child: ListToDoItem(
                          itemCode: document[index]["ItemCode"],
                          desc: document[index]["ItemDescription"],
                          uom: document[index]["UoM"],
                          qty: document[index]["Quantity"],
                          openQty: document[index]["TotalQty"],
                        ));
                  },
                ),
              ),
            ],
          )),

      // Column(
      //   children: [
      //     Expanded(
      //         flex: 3,
      //         child: ListView(
      //           children: [
      //             FlexTwoField(title: "Whs", values: ''),
      //             SizedBox(
      //               height: 10,
      //             ),
      //             FlexTwoField(title: "PO. #", values: ''),
      //             SizedBox(
      //               height: 10,
      //             ),
      //             FlexTwoField(title: "Item", values: ''),
      //             SizedBox(
      //               height: 10,
      //             ),
      //             FlexTwoField(title: "UOM", values: ''),
      //             SizedBox(
      //               height: 10,
      //             ),
      //             FlexTwoField(title: "Qty", values: ''),
      //           ],
      //         )),
      //     Expanded(
      //       flex: 4,
      //       child: Container(
      //         height: double.infinity,
      //           child: Column(
      //         children: [
      //           Expanded(
      //               flex: 1,
      //               child: Container(
      //                 width: double.infinity,
      //                 height: 100,
      //                 color: Colors.red,
      //                 child: Text("12"),
      //               )),
      //           Expanded(
      //             flex: 6,
      //             child: ListView.builder(
      //               padding: const EdgeInsets.fromLTRB(0, 13, 0, 0),
      //               shrinkWrap: true,
      //               itemCount: 400,
      //               itemBuilder: (BuildContext context, int index) {
      //                 return GestureDetector(onTap: () {}, child: Text("11"));
      //               },
      //             ),
      //           ),
      //         ],
      //       )),
      //     ),
      //   ],
      // ),
    );
  }
}
