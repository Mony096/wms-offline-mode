import 'package:flutter/material.dart';
import 'package:wms_mobile/core/error/failure.dart';
import 'package:wms_mobile/component/flexTwoArrow.dart';
import 'package:wms_mobile/form/branchSelect.dart';
import 'package:wms_mobile/form/employeeSelect.dart';
import 'package:wms_mobile/form/flexTwoArrowWithText.dart';
import 'package:wms_mobile/form/goodReceiptTypeSelect.dart';
import 'package:wms_mobile/form/revenueLine.dart';
import 'package:wms_mobile/form/textFlexTwo.dart';
import 'package:wms_mobile/form/warehouseSelect.dart';
import 'package:wms_mobile/presentations/inventory/good_Receipt/create_screen/good_Receipt_list_item_screen.dart';
import 'package:wms_mobile/presentations/inventory/good_receipt/component/seriesListSelect.dart';
import 'package:wms_mobile/utilies/dialog/dialog.dart';
import 'package:wms_mobile/utilies/dio_client.dart';

class GoodReceiptCreateScreen extends StatefulWidget {
  GoodReceiptCreateScreen(
      {super.key,
      this.id,
      required this.seriesList,
      required this.dataById,
      required this.listIssueType,
      required this.employeeList,
      required this.binlocationList});
  // ignore: prefer_typing_uninitialized_variables
  final id;
  List<dynamic> seriesList;
  List<dynamic> listIssueType;
  List<dynamic> employeeList;
  Map<String, dynamic> dataById;
  List<dynamic> binlocationList;
  @override
  State<GoodReceiptCreateScreen> createState() =>
      _GoodReceiptCreateScreenState();
}

class _GoodReceiptCreateScreenState extends State<GoodReceiptCreateScreen> {
  final TextEditingController _supplier = TextEditingController();
  Map<String, dynamic> _series = {};
  Map<String, dynamic> _employee = {};
  final TextEditingController _transportationNo = TextEditingController();
  final TextEditingController _truckNo = TextEditingController();
  Map<String, dynamic> _shipFrom = {};
  Map<String, dynamic> _revenueLine = {};
  Map<String, dynamic> _branch = {};
  Map<String, dynamic> _warehouse = {};
  Map<String, dynamic> _giType = {};
  List<dynamic> selectedItems = [];
  List<dynamic> binLocationList = [];

  final TextEditingController _remark = TextEditingController();

  final DioClient dio = DioClient();
  final String _responseMessage = '';

  int check = 0;
  Future<void> _postData() async {
    Map<String, dynamic> payload = {
      "Series": _series["value"],
      "BPL_IDAssignedToInvoice": _branch["value"],
      "U_tl_whsdesc": _warehouse["value"],
      "U_tl_grempl": _employee["value"],
      "U_tl_grtrano": _transportationNo.text,
      "U_tl_grtruno": _truckNo.text,
      "U_ti_revenue": _revenueLine["value"],
      "U_tl_grsuppo": _shipFrom["value"],
      "U_tl_grtype": _giType["value"],
      "Comments": _remark.text,
      "DocumentLines": selectedItems.map((e) {
        var documentLinesBinAllocations =
            (e["DocumentLinesBinAllocations"] != null &&
                    e["DocumentLinesBinAllocations"].isNotEmpty)
                ? e["DocumentLinesBinAllocations"][0]
                : null;

        return {
          "ItemCode": e["ItemCode"],
          "ItemDescription": e["ItemName"] ?? e["ItemDescription"],
          "Quantity": e["Quantity"],
          "WarehouseCode": e["WarehouseCode"],
          "UnitPrice": e["UnitPrice"],
          "GrossPrice": e["GrossPrice"],
          "UoMCode": e["UoMCode"],
          "CostingCode": e["CostingCode"] ?? "",
          "CostingCode2": e["CostingCode2"] ?? "",
          "CostingCode3": e["CostingCode3"] ?? "",
          "DocumentLinesBinAllocations": [
            if (documentLinesBinAllocations != null)
              {
                "Quantity": documentLinesBinAllocations["Quantity"] ?? "",
                "BinAbsEntry": documentLinesBinAllocations["BinAbsEntry"] ?? "",
                "BaseLineNumber":
                    documentLinesBinAllocations["BaseLineNumber"] ?? "",
                "AllowNegativeQuantity":
                    documentLinesBinAllocations["AllowNegativeQuantity"] ?? "",
                "SerialAndBatchNumbersBaseLine": documentLinesBinAllocations[
                        "SerialAndBatchNumbersBaseLine"] ??
                    ""
              }
          ]
        };
      }).toList()
    };
    try {
      MaterialDialog.loading(context, barrierDismissible: false);
      if (widget.id) {
        final response = await dio.patch(
            '/InventoryGenEntries(${widget.dataById["DocEntry"]})',
            data: payload);
        if (response.statusCode == 204) {
          MaterialDialog.close(context);
          MaterialDialog.success(context,
              title: 'Success', body: "Updated Successfully !");
        }
      } else {
        final response = await dio.post('/InventoryGenEntries', data: payload);
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
      'DocumentTypeParams': {'Document': '59'},
    };
    try {
      final response =
          await dio.post('/SeriesService_GetDefaultSeries', data: payload);
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            check = 1;
            _series["value"] = response.data["Series"];
            _series["name"] = response.data["Name"].toString();
            // series.addAll(response.data['value']);
          });
        }
      } else {
        throw ServerFailure(message: response.data['msg']);
      }
    } on Failure {
      rethrow;
    }
  }

  List<dynamic> series = [];

  Future<void> getListSeries() async {
    Map<String, dynamic> payload = {
      'DocumentTypeParams': {'Document': '59'},
    };
    try {
      final response =
          await dio.post('/SeriesService_GetDocumentSeries', data: payload);
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            series.addAll(response.data['value']);
          });
          // print(response.data["value"]);
        }
      } else {
        throw ServerFailure(message: response.data['msg']);
      }
    } on Failure {
      rethrow;
    }
  }

  Future<void> init() async {
    if (widget.id) {
       var serie = widget.seriesList.firstWhere(
          (e) => e["Series"] == widget.dataById["Series"],
          orElse: () => null);
      if (serie == null) {
        _series["name"] = null;
      } else {
        _series["name"] = serie["Name"];
      }
      var emp = widget.employeeList.firstWhere(
          (e) => e["EmployeeID"] == widget.dataById["U_tl_grempl"],
          orElse: () => null);
      if (emp == null) {
        _employee["name"] = null;
      } else {
        _employee["name"] = emp["FirstName"] + ' ' + emp["LastName"];
      }
      var rt = widget.listIssueType.firstWhere(
          (e) => e["Code"] == widget.dataById["U_tl_grtype"],
          orElse: () => null);
      if (rt == null) {
        _giType["name"] = null;
      } else {
        _giType["name"] = rt["Name"];
      }
      setState(() {
        _series["value"] = widget.dataById["Series"];
        _employee["value"] = widget.dataById["U_tl_grempl"]?.toString();
        _transportationNo.text =
            widget.dataById["U_tl_grtrano"]?.toString() ?? "";
        _truckNo.text = widget.dataById["U_tl_grtruno"]?.toString() ?? "";
        _shipFrom["value"] = widget.dataById["U_tl_grsuppo"]?.toString();
        _revenueLine["value"] = widget.dataById["U_ti_revenue"]?.toString();
        _branch["value"] = widget.dataById["BPL_IDAssignedToInvoice"];
        _branch["name"] = widget.dataById["BPLName"]?.toString();
        _warehouse["value"] = widget.dataById["U_tl_whsdesc"]?.toString();
        _giType["value"] = widget.dataById["U_tl_grtype"]?.toString();
        _remark.text = widget.dataById["Comments"] ?? "";
        selectedItems = widget.dataById["DocumentLines"];
      });
      check = 1;
    }
  }

  @override
  void initState() {
    super.initState();
    init();
    getDefaultSeries();
    getListSeries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 17, 18, 48),
        title: GestureDetector(
          child: const Text(
            'Good Receipt',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
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
                        onPressed: () => {Navigator.pop(context, 'Cancel')},
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
                      )),
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
                        textData: _series["name"] ??"---",
                        textColor: Color.fromARGB(255, 129, 134, 140),
                        simple: FontWeight.normal,
                        req: "true",
                        requried: "requried"),
                  ),
                  GestureDetector(
                    onTap: () {
                      _navigateEmployeeSelect(context);
                    },
                    child: FlexTwoArrowWithText(
                        title: "Employee",
                        textData: _employee["name"] ?? _employee["value"],
                        textColor: const Color.fromARGB(255, 129, 134, 140),
                        simple: FontWeight.normal,
                        req: "true",
                        requried: "requried"),
                  ),
                  TextFlexTwo(
                    title: "Transportation No",
                    textData: _transportationNo,
                    req: "true",
                  ),
                  TextFlexTwo(
                    title: "Truck No",
                    textData: _truckNo,
                    req: "true",
                  ),
                  GestureDetector(
                    onTap: () {
                      _navigateShipFromSelect(context);
                    },
                    child: FlexTwoArrowWithText(
                        title: "Ship From",
                        textData: _shipFrom["name"] ?? _shipFrom["value"],
                        textColor: const Color.fromARGB(255, 129, 134, 140),
                        simple: FontWeight.normal,
                        req: "true",
                        requried: "requried"),
                  ),
                  GestureDetector(
                    onTap: () {
                      _navigateRevenueLineSelect(context);
                    },
                    child: FlexTwoArrowWithText(
                        title: "Revenue Line",
                        textData: _revenueLine["name"] ?? _revenueLine["value"],
                        textColor: const Color.fromARGB(255, 129, 134, 140),
                        simple: FontWeight.normal,
                        req: "true",
                        requried: "requried"),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  GestureDetector(
                    onTap: () {
                      _navigateBranchSelect(context);
                    },
                    child: FlexTwoArrowWithText(
                        title: "Branch",
                        textData: _branch["name"] ?? _branch["value"],
                        textColor: const Color.fromARGB(255, 129, 134, 140),
                        simple: FontWeight.normal,
                        req: "true",
                        requried: "requried"),
                  ),
                  GestureDetector(
                    onTap: () {
                      _navigateWarehouseSelect(context);
                    },
                    child: FlexTwoArrowWithText(
                        title: "Warehouse",
                        textData: _warehouse["name"] ?? _warehouse["value"],
                        textColor: const Color.fromARGB(255, 129, 134, 140),
                        simple: FontWeight.normal,
                        req: "true",
                        requried: "requried"),
                  ),
                  GestureDetector(
                    onTap: () {
                      _navigateGISelect(context);
                    },
                    child: FlexTwoArrowWithText(
                        title: "Good Receipt Type",
                        textData: _giType["name"] ?? _giType["value"],
                        textColor: const Color.fromARGB(255, 129, 134, 140),
                        simple: FontWeight.normal,
                        req: "true",
                        requried: "requried"),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  // const DatePicker(
                  //   title: "Posting Date",
                  //   req: "true",
                  // ),
                  // const DatePicker(
                  //   title: "Document Date",
                  //   req: "true",
                  // ),
                  TextFlexTwo(
                    title: "Remark",
                    textData: _remark,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GoodReceiptListItemsScreen(
                              binList: widget.binlocationList,
                            dataFromPrev: selectedItems.map((e) {
                              var newMap = Map<String, dynamic>.from(e);
                              String? warehouseCode = _warehouse["value"] ??
                                  widget.dataById?["DocumentLines"]?[0]
                                      ?["WarehouseCode"] ??
                                  "";
                              String? rev = _revenueLine["value"] ??
                                  widget.dataById?["DocumentLines"]?[0]
                                      ?["CostingCode2"] ??
                                  "";
                              newMap["WarehouseCode"] = warehouseCode;
                              newMap["U_ti_revenue"] = rev;
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
                        textData: "(${selectedItems.length})",
                        textColor: Color.fromARGB(255, 129, 134, 140),
                        simple: FontWeight.normal,
                        req: "true",
                        requried: "requried"),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  FlexTwoArrow(
                    title: "Reference Documents ",
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ),
    );
  }

  num indexSeriesSeleted = -1;
  Future<void> _navigateSeriesSelect(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SeriesListSelect(
                indBack: indexSeriesSeleted,
                branchId: _branch["value"],
              )),
    );
    if (!mounted) return;
    setState(() {
      if (result == null) return;
      _series = {
        "name": result["name"].toString(),
        "value": result["value"].toString()
      };
      indexSeriesSeleted = result["index"];
    });
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(
          content: Text(_series["value"] == null
              ? "Unselected"
              : "Selected ${_series["value"]}")));
  }

  num indexEmployeeSeleted = -1;
  Future<void> _navigateEmployeeSelect(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EmployeeSelect(
                indBack: indexEmployeeSeleted,
              )),
    );
    if (!mounted) return;
    setState(() {
      if (result == null) return;
      _employee = {"name": result["name"], "value": result["value"]};
      indexEmployeeSeleted = result["index"];
    });
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(
          content: Text(_employee["name"] == null
              ? "Unselected"
              : "Selected ${_employee["name"]}")));
  }

  num indexShipFromSeleted = -1;
  Future<void> _navigateShipFromSelect(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => WarehouseSelect(
                indBack: indexShipFromSeleted,
                allWH: "true",
              )),
    );
    if (!mounted) return;
    setState(() {
      if (result == null) return;
      _shipFrom = {"name": result["name"], "value": result["value"]};
      indexShipFromSeleted = result["index"];
    });
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(
          content: Text(_warehouse["name"] == null
              ? "Unselected"
              : "Selected ${_warehouse["name"]}")));
  }

  num indexRevenueLineSeleted = -1;
  Future<void> _navigateRevenueLineSelect(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => RevenueLineSelect(
                indBack: indexRevenueLineSeleted,
              )),
    );
    if (!mounted) return;
    setState(() {
      if (result == null) return;
      _revenueLine = {"name": result["name"], "value": result["value"]};
      indexRevenueLineSeleted = result["index"];
    });
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(
          content: Text(_revenueLine["name"] == null
              ? "Unselected"
              : "Selected ${_revenueLine["name"]}")));
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
    String currentYear = DateTime.now().year.toString();
    setState(() {
      if (result == null) return;

      _branch = {"name": result["name"], "value": result["value"]};

      var seriesItem = series.firstWhere(
        (e) =>
            e["PeriodIndicator"] == currentYear &&
            e["BPLID"] == _branch["value"],
        orElse: () => null,
      );

      if (seriesItem != null) {
        _series["value"] = seriesItem["Series"];
        _series["name"] = seriesItem["Name"];
      } else {
        _series["value"] = null; // or some default value
        _series["name"] = null; // or some default value
      }

      indexBranchSeleted = result["index"];
    });

    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(
          content: Text(_branch["name"] == null
              ? "Unselected"
              : "Selected ${_branch["name"]}")));
  }

  num indexWarehouseSeleted = -1;
  Future<void> _navigateWarehouseSelect(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => WarehouseSelect(
                branchId: _branch["value"],
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

  num indexGISeleted = -1;
  Future<void> _navigateGISelect(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => GoodReceiptTypeSelect(
                indBack: indexGISeleted,
              )),
    );
    if (!mounted) return;
    setState(() {
      if (result == null) return;
      _giType = {"name": result["name"], "value": result["value"]};
      indexGISeleted = result["index"];
    });
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(
          content: Text(_giType["name"] == null
              ? "Unselected"
              : "Selected ${_giType["name"]}")));
  }
}
