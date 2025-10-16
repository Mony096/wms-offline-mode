import 'package:flutter/material.dart';
import 'package:wms_mobile/component/flexTwo.dart';
import 'package:wms_mobile/form/flexTwoArrowWithText.dart';
import 'package:wms_mobile/form/textFlexTwo.dart';
import 'package:wms_mobile/form/warehouseSelect.dart';
import 'package:wms_mobile/presentations/purchase/purchase_order/purchaseOrderCodeScreen.dart';

class GoodReturnRequestItemCreateScreen extends StatefulWidget {
  GoodReturnRequestItemCreateScreen({super.key, required this.updateItem});
  Map<String, dynamic> updateItem;
  @override
  State<GoodReturnRequestItemCreateScreen> createState() =>
      _PurchaseOrderItemCreateScreenState();
}

class _PurchaseOrderItemCreateScreenState
    extends State<GoodReturnRequestItemCreateScreen> {
  final _itemCode = TextEditingController();
  final _itemDesc = TextEditingController();
  final _quantity = TextEditingController();
  final _unitPrice = TextEditingController();
  final _crossPrice = TextEditingController();
  final _itemPerUnit = TextEditingController();
  final _unitOfMeas = TextEditingController();
  Map<String, dynamic> _warehouse = {};
  @override
  void init() async {
    _itemCode.text = widget.updateItem["ItemCode"] ?? "";
    _itemDesc.text = widget.updateItem["ItemDescription"] ?? widget.updateItem["ItemName"] ?? "";
    _quantity.text = widget.updateItem["Quantity"]?.toString() ?? "";
    _unitPrice.text = widget.updateItem["UnitPrice"]?.toString() ?? "";
    _crossPrice.text = widget.updateItem["GrossPrice"]?.toString() ?? "";
    _itemPerUnit.text = widget.updateItem["ItemPerUnit"]?.toString() ?? "";
    _warehouse["value"] = widget.updateItem["WarehouseCode"] ?? "";
    _unitOfMeas.text = widget.updateItem["UnitsOfMeasurment"]?.toString() ?? "";
  }

  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context, {
              "ItemCode": _itemCode.text,
              "ItemDescription": _itemDesc.text,
              "Quantity": _quantity.text,
              "WarehouseCode": _warehouse["value"],
              "UnitPrice": _unitPrice.text,
              "GrossPrice": _crossPrice.text,
              "UnitsOfMeasurment": _unitOfMeas.text
            });
          },
          icon: const Icon(
            Icons.arrow_back,
            size: 24,
          ),
        ),
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 17, 18, 48),
        title: const Text(
          'Items',
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
            TextFlexTwo(
              title: "Item Code",
              textData: _itemCode,
            ),
            TextFlexTwo(
              title: "Description",
              textData: _itemDesc,
            ),
            GestureDetector(
              // onTap: () {
              //   _navigateWarehouseSelect(context);
              // },
              child: FlexTwoArrowWithText(
                title: "Warehouse",
                textData: _warehouse["name"] ?? _warehouse["value"],
                simple: FontWeight.normal,
                req: "true",
              ),
            ),
            TextFlexTwo(
              req: "true",
              title: "Quantity",
              textData: _quantity,
            ),
            TextFlexTwo(
              title: "Unit Price",
              textData: _unitPrice,
            ),
            TextFlexTwo(
              title: "Gross Price",
              textData: _crossPrice,
            ),
            SizedBox(
              height: 30,
            ),
            TextFlexTwo(
              title: "Item Per Unit",
              textData: _itemPerUnit,
            ),
            TextFlexTwo(
              title: "Unit of Measurement",
              textData: _unitOfMeas,
            ),
            SizedBox(
              height: 30,
            ),
            FlexTwoArrowWithText(
              title: "Line Of Business",
              // textData: "203006",
              simple: FontWeight.normal,
              // req: "true",
            ),
            FlexTwoArrowWithText(
              title: "Revenue Line",
              // textData: "203006",
              simple: FontWeight.normal,
              // req: "true",
            ),
            FlexTwoArrowWithText(
              title: "Product Line",
              // textData: "203006",
              simple: FontWeight.normal,
              // req: "true",
            ),
          ],
        ),
      ),
    );
  }

  num indexWarehouseSeleted = -1;
  Future<void> _navigateWarehouseSelect(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => WarehouseSelect(
                indBack: indexWarehouseSeleted,
              )),
    );
    if (!mounted) return;
    setState(() {
      if (result == null) return;
      _warehouse = {"name": result["name"], "value": result["value"]};
      indexWarehouseSeleted = result["index"];
    });
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(
          content: Text(_warehouse["name"] == null
              ? "Unselected"
              : "Selected ${_warehouse["name"]}")));
  }
}
