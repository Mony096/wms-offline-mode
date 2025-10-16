import 'package:flutter/material.dart';
import 'package:wms_mobile/component/flexTwo.dart';
import 'package:wms_mobile/component/flexTwoArrow.dart';
import 'package:wms_mobile/form/flexTwoArrowWithText.dart';

class PurchaseOrderItemsScreen extends StatefulWidget {
  final Map<String, dynamic> itemDetail;
  const PurchaseOrderItemsScreen({
    super.key,
    required this.itemDetail,
  });

  @override
  State<PurchaseOrderItemsScreen> createState() =>
      _PurchaseOrderItemsScreenState();
}

class _PurchaseOrderItemsScreenState extends State<PurchaseOrderItemsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 17, 18, 48),
        title: const Text(
          'Purchase Orders',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
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
              values: widget.itemDetail["ItemCode"] ?? "",
            ),
            FlexTwo(
              title: "Description",
              values: widget.itemDetail["ItemDescription"] ?? '',
            ),
            FlexTwo(
              title: "Warehouse",
              values: widget.itemDetail["WarehouseCode"] ?? '',
            ),
            FlexTwo(
              title: "Quantity",
              values: widget.itemDetail["Quantity"] ?? '',
            ),
              FlexTwo(
              title: "Unit Price",
              values: widget.itemDetail["UnitPrice"] ?? '',
            ),
            FlexTwo(
              title: "Gross Price",
              values: widget.itemDetail["GrossPrice"] ?? '',
            ),
            SizedBox(
              height: 30,
            ),
            FlexTwo(
              title: "Item Per Unit",
              values: widget.itemDetail["TaxPerUnit"] ?? '',
            ),
            FlexTwo(
              title: "Unit Of Measurement",
              values: widget.itemDetail["UnitsOfMeasurment"] ?? '',
            ),
            SizedBox(
              height: 30,
            ),
            FlexTwoArrowWithText(
              title: "Line Of Business",
              textData: "${widget.itemDetail["CostingCode"] ?? ""}",
            ),
            FlexTwoArrow(
              title: "Revenue Line",
              textData: "${widget.itemDetail["CostingCode2"] ?? ""}",
            ),
            FlexTwoArrowWithText(
              title: "Product Line",
              textData: "${widget.itemDetail["CostingCode3"] ?? ""}",
            ),
          ],
        ),
      ),
    );
  }
}
