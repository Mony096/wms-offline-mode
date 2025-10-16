import 'package:flutter/material.dart';
import 'package:wms_mobile/component/flexTwo.dart';
import 'package:wms_mobile/form/flexTwoArrowWithText.dart';
import 'package:wms_mobile/presentations/purchase/purchase_order/purchaseOrderCodeScreen.dart';

class GoodIssueItemDetailScreen extends StatefulWidget {
  GoodIssueItemDetailScreen(
      {super.key, required this.itemDetail, required this.binList});
  Map<String, dynamic> itemDetail;
  List<dynamic> binList;
  @override
  State<GoodIssueItemDetailScreen> createState() =>
      _GoodIssueItemDetailScreenState();
}

class _GoodIssueItemDetailScreenState extends State<GoodIssueItemDetailScreen> {
  Map<String, dynamic> binLabel = {};
  @override
  void init() async {
    if (widget.itemDetail["DocumentLinesBinAllocations"] != null &&
        widget.itemDetail["DocumentLinesBinAllocations"].isNotEmpty) {
      var firstAllocation = widget.itemDetail["DocumentLinesBinAllocations"][0];
      binLabel["value"] = firstAllocation?["BinAbsEntry"];
      var bin = widget.binList.firstWhere(
        (e) => e["BinID"] == binLabel["value"],
        orElse: () => null,
      );

      if (bin == null) {
        binLabel["name"] = '';
      } else {
        binLabel["name"] = bin["BinCode"];
      }
    } else {}
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 17, 18, 48),
        title: const Text(
          'Items',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: const [],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color.fromARGB(255, 236, 233, 233),
        child: ListView(
          children: [
            SizedBox(
              height: 30,
            ),
            FlexTwo(
                title: "Item Code",
                values: widget.itemDetail["ItemCode"] ?? ''),
            FlexTwo(
                title: "Description",
                values: widget.itemDetail["ItemDescription"] ?? ''),
            FlexTwo(
                title: "Warehouse",
                values: widget.itemDetail["WarehouseCode"] ?? ''
                // textColor: Color.fromARGB(255, 129, 134, 140),
                ),
            FlexTwo(title: "Bin Location", values: binLabel["name"]),
            FlexTwo(
                title: "Quantity", values: widget.itemDetail["Quantity"] ?? ''),
            SizedBox(
              height: 30,
            ),
            FlexTwo(title: "Inventory UoM", values: ''),
            FlexTwo(
                title: "UoM Code", values: widget.itemDetail["UoMCode"] ?? ''),
            SizedBox(
              height: 30,
            ),
            FlexTwoArrowWithText(
              title: "Line Of Business",
              textData: widget.itemDetail["CostingCode"] ?? '',
              // textColor: Color.fromARGB(255, 129, 134, 140),
              simple: FontWeight.normal,
              // req: "true",
            ),
            FlexTwoArrowWithText(
              title: "Revenue Line",
              textData: widget.itemDetail["CostingCode2"] ?? '',
              // textColor: Color.fromARGB(255, 129, 134, 140),
              simple: FontWeight.normal,
              // req: "true",
            ),
            FlexTwoArrowWithText(
              title: "Product Line",
              textData: widget.itemDetail["CostingCode3"] ?? '',
              // textColor: Color.fromARGB(255, 129, 134, 140),
              simple: FontWeight.normal,
              // req: "true",
            ),
          ],
        ),
      ),
    );
  }
}
