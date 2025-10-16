import 'package:flutter/material.dart';
import 'package:wms_mobile/component/flexTwo.dart';
import 'package:wms_mobile/form/flexTwoArrowWithText.dart';
import 'package:wms_mobile/form/textFlexTwo.dart';
import 'package:wms_mobile/form/warehouseSelect.dart';
import 'package:wms_mobile/presentations/inventory/component/uomSelect.dart';
import 'package:wms_mobile/presentations/inventory/good_Issue/component/binlocationSelect.dart';

class GoodIssueItemCreateScreen extends StatefulWidget {
  GoodIssueItemCreateScreen(
      {super.key,
      required this.updateItem,
      required this.ind,
      required this.binList});
  Map<String, dynamic> updateItem;
  List<dynamic> binList;
  final int ind;
  @override
  State<GoodIssueItemCreateScreen> createState() =>
      _GoodIssueItemCreateScreenState();
}

class _GoodIssueItemCreateScreenState extends State<GoodIssueItemCreateScreen> {
  final _itemCode = TextEditingController();
  final _itemDesc = TextEditingController();
  final _quantity = TextEditingController();
  Map<String, dynamic> _binLocation = {};
  Map<String, dynamic> _inventoryUoM = {};
  Map<String, dynamic> _uoMCode = {};
  Map<String, dynamic> _warehouse = {};
  final _lob = TextEditingController();
  final _revl = TextEditingController();
  final _prodl = TextEditingController();
  @override
  void init() async {
    _itemCode.text = widget.updateItem["ItemCode"] ?? "";
    _itemDesc.text = widget.updateItem["ItemDescription"] ??
        widget.updateItem["ItemName"] ??
        "";
    _quantity.text = widget.updateItem["Quantity"]?.toString() ?? "";
    _warehouse["value"] = widget.updateItem["WarehouseCode"] ?? "";
    _uoMCode["name"] = widget.updateItem["UoMCode"] ?? "";
    _uoMCode["value"] = widget.updateItem["UoMEntry"] ?? "";
    _uoMCode["useBaseUnits"] = widget.updateItem["UseBaseUnits"] ?? "";
    _lob.text = widget.updateItem["CostingCode"]?.toString() ?? "";
    _revl.text = widget.updateItem["CostingCode2"]?.toString() ?? "";
    _prodl.text = widget.updateItem["CostingCode3"]?.toString() ?? "";
    if (widget.updateItem["DocumentLinesBinAllocations"] != null &&
        widget.updateItem["DocumentLinesBinAllocations"].isNotEmpty) {
      var firstAllocation = widget.updateItem["DocumentLinesBinAllocations"][0];
      _uoMCode["quantity"] = firstAllocation?["Quantity"] ?? "0";
      _binLocation["value"] = firstAllocation?["BinAbsEntry"];
      _binLocation["allowNegativeQuantity"] =
          firstAllocation?["AllowNegativeQuantity"] ?? "";
      _binLocation["serialAndBatchNumbersBaseLine"] =
          firstAllocation?["SerialAndBatchNumbersBaseLine"] ?? "";
    } else {
      _uoMCode["quantity"] = "";
      _binLocation["value"] = "";
      _binLocation["allowNegativeQuantity"] = "";
      _binLocation["serialAndBatchNumbersBaseLine"] = "";
    }
    if (_binLocation["value"] != null || _binLocation["value"] != "") {
      var bin = widget.binList.firstWhere(
        (e) => e["BinID"] == _binLocation["value"],
        orElse: () => null,
      );
      if (bin == null) {
        _binLocation["name"] = null;
      } else {
        _binLocation["name"] = bin["BinCode"];
      }
    }
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
              "UnitPrice": widget.updateItem["UnitPrice"],
              "WarehouseCode": _warehouse["value"],
              "UoMCode": _uoMCode["name"],
              "UoMEntry": _uoMCode["value"],
              "UseBaseUnits": _uoMCode["useBaseUnits"],
              "CostingCode": _lob.text,
              "CostingCode2": _revl.text,
              "CostingCode3": _prodl.text,
              "DocumentLinesBinAllocations": [
                {
                  "Quantity": _uoMCode["quantity"],
                  "BinAbsEntry": _binLocation["value"],
                  "BaseLineNumber": widget.ind,
                  "AllowNegativeQuantity":
                      _binLocation["allowNegativeQuantity"],
                  "SerialAndBatchNumbersBaseLine":
                      _binLocation["serialAndBatchNumbersBaseLine"]
                }
              ]
            });
          },
          icon: const Icon(
            Icons.arrow_back,
            size: 24,
          ),
        ),
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 17, 18, 48),
        title: GestureDetector(
          child: const Text(
            'Items',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
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
            GestureDetector(
              onTap: () {},
              child: TextFlexTwo(
                title: "Item Code",
                textData: _itemCode,
              ),
            ),
            TextFlexTwo(
              title: "Description",
              textData: _itemDesc,
            ),
            GestureDetector(
              onTap: () {
                _navigateWarehouseSelect(context);
              },
              child: FlexTwoArrowWithText(
                title: "Warehouse",
                textData: _warehouse["name"] ?? _warehouse["value"],
                simple: FontWeight.normal,
                req: "true",
              ),
            ),
            GestureDetector(
              onTap: () {
                _navigateBINSelect(context);
              },
              child: FlexTwoArrowWithText(
                title: "Bin Location",
                textData: _binLocation["name"],
                simple: FontWeight.normal,
                req: "true",
              ),
            ),
            TextFlexTwo(
              // req: "true",
              title: "Quantity",
              textData: _quantity,
            ),
            SizedBox(
              height: 30,
            ),
            FlexTwoArrowWithText(
              title: "Inventory UoM",
              textData: _inventoryUoM["name"] ?? _inventoryUoM["value"],
              simple: FontWeight.normal,
              // req: "true",
            ),
            GestureDetector(
              onTap: () {
                _navigateUOMSelect(context);
              },
              child: FlexTwoArrowWithText(
                title: "UoM Code",
                textData: _uoMCode["name"] ?? _uoMCode["value"],
                simple: FontWeight.normal,
                req: "true",
              ),
            ),
            SizedBox(
              height: 30,
            ),
            FlexTwoArrowWithText(
              title: "Line Of Business",
              textData: _lob.text,
              simple: FontWeight.normal,
              // req: "true",
            ),
            FlexTwoArrowWithText(
              title: "Revenue Line",
              textData: _revl.text,
              simple: FontWeight.normal,
              // req: "true",
            ),
            FlexTwoArrowWithText(
              title: "Product Line",
              textData: _prodl.text,
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
    return;
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

  num indexBINSeleted = -1;
  Future<void> _navigateBINSelect(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => BinlocationSelect(
                itemCode: widget.updateItem["ItemCode"],
                indBack: indexBINSeleted,
                whCode: widget.updateItem["WarehouseCode"],
                // branchId: _branch["value"],
              )),
    );
    if (!mounted) return;
    setState(() {
      if (result == null) return;
      _binLocation = {
        "name": result["name"],
        "value": result["value"],
        "allowNegativeQuantity": "tNO",
        "serialAndBatchNumbersBaseLine": -1
      };
      indexBINSeleted = result["index"];
    });
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(
          content: Text(_binLocation["name"] == null
              ? "Unselected"
              : "Selected ${_binLocation["name"]}")));
  }

  num indexUOMSeleted = -1;
  Future<void> _navigateUOMSelect(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => UoMSelect(
              indBack: indexUOMSeleted,
              item: widget.updateItem["ItemCode"],
              qty: double.tryParse(_quantity.text) ?? 0.00
              // branchId: _branch["value"],
              )),
    );
    if (!mounted) return;
    setState(() {
      if (result == null) return;
      _uoMCode = {
        "name": result["name"],
        "value": result["value"],
        "quantity": result["quantity"],
        "useBaseUnits": "tNO"
      };
      print(_uoMCode);
      indexUOMSeleted = result["index"];
    });
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(
          content: Text(_uoMCode["name"] == null
              ? "Unselected"
              : "Selected ${_uoMCode["name"]}")));
  }
}
