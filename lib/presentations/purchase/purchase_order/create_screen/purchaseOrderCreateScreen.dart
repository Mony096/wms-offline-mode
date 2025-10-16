import 'package:flutter/material.dart';
import 'package:wms_mobile/core/error/failure.dart';
import 'package:wms_mobile/form/contactPersonSelect.dart';
import 'package:wms_mobile/form/datePicker.dart';
import 'package:wms_mobile/component/flexTwoArrow.dart';
import 'package:wms_mobile/form/flexTwoArrowWithText.dart';
import 'package:wms_mobile/form/branchSelect.dart';
import 'package:wms_mobile/form/shippingTypeSelect.dart';
import 'package:wms_mobile/form/textFlexTwo.dart';
import 'package:wms_mobile/form/vendorSelect.dart';
import 'package:wms_mobile/presentations/purchase/purchase_order/component/seriesListSelect.dart';
import 'package:wms_mobile/presentations/purchase/purchase_order/create_screen/PurchaseOrderListItemsScreen.dart';
import 'package:wms_mobile/utilies/dialog/dialog.dart';
import 'package:wms_mobile/utilies/dio_client.dart';

class PurchaseOrderCreateScreen extends StatefulWidget {
  PurchaseOrderCreateScreen(
      {super.key,
      this.id,
      required this.dataById,
      required this.paymentTermList,
      required this.seriesList});
  // ignore: prefer_typing_uninitialized_variables
  Map<String, dynamic> dataById;
  final id;
  List<dynamic> seriesList;
  List<dynamic> paymentTermList;
  @override
  State<PurchaseOrderCreateScreen> createState() =>
      _PurchaseOrderCreateScreenState();
}

class _PurchaseOrderCreateScreenState extends State<PurchaseOrderCreateScreen> {
  // start form field
  final _supplierRefNo = TextEditingController();
  final _remark = TextEditingController();
  Map<String, dynamic> _vendor = {};
  Map<String, dynamic> _branch = {};
  Map<String, dynamic> _contactPerson = {};
  Map<String, dynamic> _series = {};
  Map<String, dynamic> _shippingType = {};

  DateTime? _postingDate;
  DateTime? _deliveryDate;
  DateTime? _documentDate;

  String _shipTo =
      "#C168 Russian Blvd, Phum CPC, Sangkat Tek Thlar Khan Sen Sok, Phnom Penhអាគារលេខ C168 វិថិសហព័ន្ធរុស្សី ភូមិសេប៉ែសេ សង្កាត់ទឹកថ្លារ ខណ្ឌ សែនសុខ រាជធានីភ្នំពេញ";
  // end form field
  List<dynamic> selectedItems = [];

  final DioClient dio = DioClient();
  final String _responseMessage = '';
  int check = 0;

  Future<void> _postData() async {
    Map<String, dynamic> payload = {
      "CardCode": _vendor["cardCode"],
      "CardName": _vendor["cardName"],
      "ContactPersonCode": 0,
      "NumAtCard": _supplierRefNo.text,
      "BPL_IDAssignedToInvoice": _branch["bplId"],
      "JournalMemo": "Purchase Orders - ${_vendor["cardCode"]}",
      "Comments": _remark.text,
      "DocDate": _postingDate.toString(),
      "DocDueDate": _deliveryDate.toString(),
      "TaxDate": _documentDate.toString(),
      "Address2": _shipTo,
      "Address": _vendor["address"],
      "TransportationCode": _shippingType["value"],
      "DocumentLines": selectedItems
          .map((e) => {
                "ItemCode": e["ItemCode"],
                "ItemDescription": e["ItemName"],
                "Quantity": e["Quantity"],
                "WarehouseCode": _branch["defaultWH"],
                "UnitPrice": e["UnitPrice"],
                "GrossPrice": e["GrossPrice"],
                "UoMCode": e["InventoryUOM"] ?? e["UoMCode"],
              })
          .toList()
    };
    // setState(() {
    //   print(payload["DocumentLines"]);
    // });
    // return;
    try {
      MaterialDialog.loading(context, barrierDismissible: false);
      if (widget.id) {
        final response = await dio.patch(
            '/PurchaseOrders(${widget.dataById["DocEntry"]})',
            data: payload);
        if (response.statusCode == 204) {
          MaterialDialog.close(context);
          MaterialDialog.success(context,
              title: 'Success', body: "Updated Successfully !");
        }
      } else {
        final response = await dio.post('/PurchaseOrders', data: payload);
        if (response.statusCode == 201) {
          MaterialDialog.close(context);
          MaterialDialog.success(context,
              title: 'Success', body: "Created Successfully !");
        }
      }
    } catch (e) {
      MaterialDialog.close(context);
      MaterialDialog.success(context, title: 'Error', body: e.toString());
    }
  }

  Future<void> getDefaultSeries() async {
    if (widget.id) return;
    Map<String, dynamic> payload = {
      'DocumentTypeParams': {'Document': '22'},
    };
    try {
      final response =
          await dio.post('/SeriesService_GetDefaultSeries', data: payload);
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _series["value"] = response.data["Series"];
            _series["name"] = response.data["Name"]?.toString() ?? "";
            // series.addAll(response.data['value']);
            check = 1;
          });
        }
      } else {
        throw ServerFailure(message: response.data['msg']);
      }
    } on Failure {
      rethrow;
    }
  }

  @override
  void initState() {
    super.initState();

    init();
    getDefaultSeries();
  }

  Future<void> init() async {
    if (widget.id) {
      var serie = widget.seriesList
          .firstWhere((e) => e["Series"] == widget.dataById["Series"],orElse: ()=>null);
          if(serie == null){
             _series["name"] = null;
          }else{
            _series["name"]=serie["Name"];
          }
      setState(() {
        _series["value"] = widget.dataById["Series"]?.toString() ?? "";
        _vendor["cardCode"] = widget.dataById["CardCode"];
        _vendor["cardName"] = widget.dataById["CardName"];
        _supplierRefNo.text = widget.dataById["NumAtCard"];
        _branch["bplId"] = widget.dataById["BPL_IDAssignedToInvoice"];
        _branch["bplName"] = widget.dataById["BPLName"];
        _postingDate = DateTime.parse(widget.dataById["DocDate"]);
        _deliveryDate = DateTime.parse(widget.dataById["DocDueDate"]);
        _documentDate = DateTime.parse(widget.dataById["TaxDate"]);
        _remark.text = widget.dataById["Comments"];
        selectedItems = widget.dataById["DocumentLines"];
        _shipTo = widget.dataById["Address2"];
        _vendor["address"] = widget.dataById["Address"];
        _shippingType["value"] = widget.dataById["TransportationCode"];
      });
      check = 1;
    } else {
      _postingDate = DateTime.now();
      _deliveryDate = DateTime.now();
      _documentDate = DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 17, 18, 48),
        title: const Text(
          'Purchase Order',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      bottomNavigationBar: GestureDetector(
        onTap: () {
          showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                    title: const Text(
                      'Posting Documents',
                      style: TextStyle(fontSize: 18),
                    ),
                    content: const Row(
                      children: [
                        Text(''),
                        SizedBox(width: 5),
                        Text(
                          '',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => {
                          // Navigator.pop(context, 'Cancel'),
                        },
                        child: const Text('Save Offline Draft',
                            style: TextStyle(color: Colors.black)),
                      ),
                      TextButton(
                        style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                                const Color.fromARGB(255, 17, 18, 48))),
                        onPressed: () async =>
                            {Navigator.pop(context, 'ok'), await _postData()},
                        child: Container(
                          width: 90,
                          // height: 30,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4)),
                          child: const Center(
                            child: Text(
                              'Sync to SAP',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ));
        },
        child: BottomAppBar(
          child: Container(
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 17, 18, 48),
                borderRadius: BorderRadius.circular(50)),
            width: double.infinity,
            child: Center(
              child: widget.id
                  ? Text(
                      "UPDATE",
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    )
                  : Text(
                      "POST",
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
            ),
          ),
        ),
      ),
      body: check == 0
          ? const Center(
              child: CircularProgressIndicator.adaptive(
                strokeWidth: 2.5,
              ),
            )
          : Container(
              width: double.infinity,
              height: double.infinity,
              color: const Color.fromARGB(255, 236, 233, 233),
              child: ListView(
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  GestureDetector(
                    onTap: () {
                      _navigateSeriesSelect(context);
                    },
                    child: FlexTwoArrowWithText(
                        title: "Series",
                        textData: _series["name"] ?? "...",
                        textColor: Color.fromARGB(255, 129, 134, 140),
                        simple: FontWeight.normal,
                        req: "true",
                        requried: "requried"),
                  ),
                  GestureDetector(
                    onTap: () {
                      _navigateVendorSelect(context);
                    },
                    child: FlexTwoArrowWithText(
                        title: "Supplier",
                        textData: _vendor["cardCode"],
                        textColor: Color.fromARGB(255, 129, 134, 140),
                        simple: FontWeight.normal,
                        req: "true",
                        requried: "requried"),
                  ),

                  GestureDetector(
                    onTap: () {
                      _navigateContactPersonSelect(context);
                    },
                    child: FlexTwoArrow(
                      title: "Contact Person",
                      textData: _contactPerson["contactPerson"],
                    ),
                  ),
                  // const FlexTwo(
                  //   title: "Supplier Ref No.",
                  //   values: "S012",
                  // ),
                  TextFlexTwo(
                    title: "Supplier Ref No.",
                    textData: _supplierRefNo,
                  ),
                  GestureDetector(
                    onTap: () {
                      _navigateBranchSelect(context);
                    },
                    child: FlexTwoArrowWithText(
                        title: "Branch",
                        textData: _branch["bplName"],
                        textColor: const Color.fromARGB(255, 129, 134, 140),
                        simple: FontWeight.normal,
                        req: "true",
                        requried: "requried"),
                  ),
                  TextFlexTwo(
                    title: "Remark",
                    textData: _remark,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  DatePicker(
                    title: "Posting Date",
                    restorationId: 'main_date_picker',
                    req: 'true',
                    onDateSelected: _selectPostingDate,
                    defaultValue: _postingDate,
                  ),
                  DatePicker(
                    title: "Delivery Date",
                    onDateSelected: _selectDeliveryDate,
                    defaultValue: _deliveryDate,
                  ),
                  DatePicker(
                    title: "Document Date",
                    onDateSelected: _selectDocumentDate,
                    defaultValue: _documentDate,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PurchaseOrderListItemsScreen(
                            dataFromPrev: selectedItems.map((e) {
                              var newMap = Map<String, dynamic>.from(e);
                              String? warehouseCode = _branch["defaultWH"] ??
                                  widget.dataById["DocumentLines"]?[0]
                                      ?["WarehouseCode"] ??
                                  "";

                              newMap["WarehouseCode"] = warehouseCode;
                              return newMap;
                            }).toList(),
                          ),
                        ),
                      );

                      // Handle the result here
                      if (result != null) {
                        setState(() {
                          selectedItems = List<dynamic>.from(result);
                        });

                        // Do something with the selected items
                      }
                    },
                    child: FlexTwoArrowWithText(
                        title: "Items",
                        textData: "(${selectedItems.length.toString()})",
                        textColor: Color.fromARGB(255, 129, 134, 140),
                        simple: FontWeight.normal,
                        req: "true",
                        requried: "requried"),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  FlexTwoArrow(
                    title: "Ship To",
                    textData: _shipTo,
                  ),
                  FlexTwoArrow(
                    title: "Pay to",
                    textData: _vendor["address"],
                  ),
                  GestureDetector(
                    onTap: () {
                      _navigateShippingTypeSelect(context);
                    },
                    child: FlexTwoArrow(
                      title: "Shiping Type",
                      textData: _shippingType["name"],
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ),
    );
  }

  void _selectPostingDate(DateTime date) async {
    setState(() {
      _postingDate = date;
    });
  }

  void _selectDeliveryDate(DateTime date) {
    setState(() {
      _deliveryDate = date;
    });
  }

  void _selectDocumentDate(DateTime date) {
    setState(() {
      _documentDate = date;
    });
  }

  num indexSeriesSeleted = -1;
  Future<void> _navigateSeriesSelect(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SeriesListSelect(
                indBack: indexSeriesSeleted,
              )),
    );
    if (!mounted) return;
    setState(() {
      if (result == null) return;
      _series = {"name": result["name"], "value": result["value"]};
      indexSeriesSeleted = result["index"];
    });
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(
          content: Text(_series["value"] == null
              ? "Unselected"
              : "Selected ${_series["value"]}")));
  }

  num indexVendorSeleted = -1;
  Future<void> _navigateVendorSelect(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => VendorSelect(
                indBack: indexVendorSeleted,
              )),
    );
    if (!mounted) return;
    setState(() {
      if (result == null) return;
      _vendor = {
        "cardCode": result["cardCode"],
        "cardName": result["cardName"],
        "address": result["address"],
        "contactPersonList": result["contactPersonList"]
      };
      indexVendorSeleted = result["index"];
    });
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(
          content: Text(_vendor["cardCode"] == null
              ? "Unselected"
              : "Selected ${_vendor["cardCode"]}")));
  }

  num indexBranchSeleted = -1;
  Future<void> _navigateBranchSelect(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => BranchSelect(
                indBack: indexBranchSeleted,
              )),
    );
    if (!mounted) return;
    setState(() {
      if (result == null) return;
      _branch = {
        "bplName": result["name"],
        "bplId": result["value"],
        "defaultWH": result["defaultWH"]
      };
      indexBranchSeleted = result["index"];
    });
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(
          content: Text(_branch["bplName"] == null
              ? "Unselected"
              : "Selected ${_branch["bplName"]}")));
  }

  num indexContactPersonSeleted = -1;
  Future<void> _navigateContactPersonSelect(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ContactPersonSelect(
                indBack: indexContactPersonSeleted,
                data: _vendor["contactPersonList"] ?? [],
              )),
    );
    if (!mounted) return;
    setState(() {
      if (result == null) return;
      _contactPerson = {"name": result["name"], "value": result["value"]};
      indexContactPersonSeleted = result["index"];
    });
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(
          content: Text(_contactPerson["name"] == null
              ? "Unselected"
              : "Selected ${_contactPerson["name"]}")));
  }

  num indexShippingTypeSeleted = -1;
  Future<void> _navigateShippingTypeSelect(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ShippingTypes(
                indBack: indexShippingTypeSeleted,
              )),
    );
    if (!mounted) return;
    setState(() {
      if (result == null) return;
      _shippingType = {"name": result["name"], "value": result["value"]};
      indexShippingTypeSeleted = result["index"];
    });
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(
          content: Text(_shippingType["name"] == null
              ? "Unselected"
              : "Selected ${_shippingType["name"]}")));
  }
}
