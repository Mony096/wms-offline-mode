import 'package:flutter/material.dart';
import 'package:wms_mobile/component/flexTwo.dart';
import 'package:wms_mobile/presentations/inventory/good_issue/component/good_issue_list_item_detail_screen.dart';
import 'package:wms_mobile/utilies/formart.dart';

class General extends StatefulWidget {
  final Map<String, dynamic> gHeader;
  final List<dynamic> seriesList;
  final List<dynamic> employee;
  final List<dynamic> giTypeList;
  final List<dynamic> binlocationList;
  const General(
      {super.key,
      required this.gHeader,
      required this.seriesList,
      required this.employee,
      required this.giTypeList,
      required this.binlocationList});

  @override
  State<General> createState() => _GeneralState();
}

class _GeneralState extends State<General> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color.fromARGB(255, 236, 233, 233),
      child: ListView(
        children: [
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => GoodIssueListItemDetailScreen(
                        itemList: widget.gHeader,
                        binList: widget.binlocationList,
                      )),
            ),
            child: Container(
              margin: const EdgeInsets.fromLTRB(0, 20, 0, 30),
              decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 255, 255, 255),
                  border: Border(
                    left: BorderSide(
                      color: Color.fromARGB(255, 200, 196, 196),
                      width: 0.5,
                    ),
                    bottom: BorderSide(
                      color: Color.fromARGB(255, 188, 183, 183),
                      width: 0.5,
                    ),
                    right: BorderSide(
                      color: Color.fromARGB(255, 192, 188, 188),
                      width: 0.5,
                    ),
                  )),
              padding: const EdgeInsets.all(5),
              width: double.infinity,
              height: 80.0,
              child: Row(
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      flex: 4,
                      child: Container(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 7,
                              ),
                              Text(
                                "Items (${widget.gHeader["DocumentLines"].length})",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              SizedBox(
                                height: 18,
                              ),
                              Text(
                                "Click to View Items",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 106, 103, 103)),
                              ),
                            ]),
                      )),
                  Expanded(
                      flex: 2,
                      child: Container(
                          padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("25/300"),
                              SizedBox(
                                width: 20,
                              ),
                              Icon(
                                Icons.arrow_forward_ios_outlined,
                                size: 20,
                              ),
                            ],
                          )))
                ],
              ),
            ),
          ),
          FlexTwo(
            title: "Series",
            values: (() {
              var value = widget.seriesList.firstWhere(
                (e) => e["Series"] == widget.gHeader["Series"],
                orElse: () => null,
              );
              return value != null ? value["Name"] : "";
            })(),
          ),
          FlexTwo(
            title: "Document Number",
            values: widget.gHeader["DocNum"],
          ),
          FlexTwo(
            title: "Employee No",
            values: (() {
              var value = widget.employee.firstWhere(
                (e) => e["EmployeeID"] == widget.gHeader["U_tl_grempl"],
                orElse: () => null,
              );
              return value != null
                  ? value["FirstName"] + ' ' + value["LastName"]
                  : "";
            })(),
          ),
          FlexTwo(
            title: "Transportation No",
            values: widget.gHeader["U_tl_grtrano"] ?? "",
          ),
          FlexTwo(
            title: "Truck No",
            values: widget.gHeader["U_tl_grtruno"] ?? "",
          ),
          FlexTwo(
            title: "Ship To",
            values: widget.gHeader["U_tl_branc"] ?? "",
          ),
          FlexTwo(
            title: "Revenue Line",
            values: widget.gHeader["U_ti_revenue"] ?? "",
          ),
          SizedBox(
            height: 30,
          ),
          FlexTwo(
            title: "Branch",
            values: widget.gHeader["BPLName"] ?? "",
          ),
          FlexTwo(
            title: "Warehouse",
            values: widget.gHeader["U_tl_whsdesc"] ?? "",
          ),
          FlexTwo(
            title: "Good Issue Type",
            values: (() {
              var value = widget.giTypeList.firstWhere(
                (e) => e["Code"] == widget.gHeader["U_tl_gitype"],
                orElse: () => null,
              );
              return value != null ? value["Name"] : "";
            })(),
          ),
          SizedBox(
            height: 30,
          ),
          FlexTwo(
            title: "Posting Date",
            values: splitDate(widget.gHeader["DocDate"]),
          ),
          FlexTwo(
            title: "Document Date",
            values: splitDate(widget.gHeader["TaxDate"]),
          ),
          FlexTwo(
            title: "Remark",
            values: widget.gHeader["Comments"] ?? "",
          ),
          const SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }
}
