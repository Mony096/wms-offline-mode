import 'package:flutter/material.dart';
import 'package:wms_mobile/component/flexTwo.dart';
import 'package:wms_mobile/form/flexTwoArrowWithText.dart';
import 'package:wms_mobile/presentations/purchase/purchase_order/purchaseOrderCodeScreen.dart';

class GoodReturnRequestItemDetailScreen extends StatefulWidget {
  const GoodReturnRequestItemDetailScreen({super.key, required this.itemDetail});
  final Map<String, dynamic> itemDetail;
  @override
  State<GoodReturnRequestItemDetailScreen> createState() =>
      _GoodReturnRequestItemDetailScreenState();
}

class _GoodReturnRequestItemDetailScreenState
    extends State<GoodReturnRequestItemDetailScreen> {
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
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PurchaseOrderCodeScreen()),
                );
              },
              icon: const Icon(Icons.qr_code_scanner_outlined)),
          const SizedBox(
            width: 15,
          ),
          const Icon(
            Icons.add,
            size: 25,
          ),
          const SizedBox(
            width: 13,
          ),
        ],
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
              values: "${widget.itemDetail["ItemCode"]}",
            ),
            FlexTwo(
              title: "Description",
              values: "${widget.itemDetail["ItemDescription"]}",
            ),
            FlexTwo(
              title: "Warehouse",
             values: "${widget.itemDetail["WarehouseCode"]}",
              // textColor: Color.fromARGB(255, 129, 134, 140),
            ),
            FlexTwo(
              title: "Quantity",
              values: "${widget.itemDetail["Quantity"]}",
            ),
              FlexTwo(
              title: "Unit Price",
              values: widget.itemDetail["UnitPrice"] ?? '',
            ),
            FlexTwo(
              title: "Gross Price",
              values: widget.itemDetail["GrossPrice"] ?? '',
            ),
            FlexTwo(
              title: "Item Per Unit",
             values: "${widget.itemDetail["TaxPerUnit"]}",
            ),
            FlexTwo(
              title: "Unit Of Measurement",
              values: "${widget.itemDetail["UnitsOfMeasurment"]}",
            ),
            SizedBox(
              height: 30,
            ),
            FlexTwoArrowWithText(
              title: "Line Of Business",
             textData: "${widget.itemDetail["CostingCode"]??""}",
              // textColor: Color.fromARGB(255, 129, 134, 140),
              simple: FontWeight.normal,
              // req: "true",
            ),
            FlexTwoArrowWithText(
              title: "Revenue Line",
             textData: "${widget.itemDetail["CostingCode2"] ?? ""}",
              // textColor: Color.fromARGB(255, 129, 134, 140),
              simple: FontWeight.normal,
              // req: "true",
            ),
            FlexTwoArrowWithText(
              title: "Product Line",
            textData: "${widget.itemDetail["CostingCode3"]??""}",
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
