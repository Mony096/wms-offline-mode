import 'package:flutter/material.dart';
import 'package:wms_mobile/component/flexTwo.dart';
import 'package:wms_mobile/component/flexTwoArrow.dart';
import 'package:wms_mobile/constant/style.dart';
import 'package:wms_mobile/utilies/formart.dart';

class HeaderScreen extends StatefulWidget {
  final Map<String, dynamic> poHeader;
  final List<dynamic> seriesList;
  const HeaderScreen(
      {super.key, required this.poHeader, required this.seriesList});
  @override
  State<HeaderScreen> createState() => _HeaderScreenState();
}

class _HeaderScreenState extends State<HeaderScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: PRIMARY_BG_COLOR,
      child: ListView(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
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
                  top: BorderSide(
                    color: Color.fromARGB(255, 192, 188, 188),
                    width: 0.5,
                  ),
                )),
            padding: const EdgeInsets.all(5),
            width: double.infinity,
            height: 75.0,
            child: Row(
              children: [
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                    flex: 6,
                    child: Container(
                      child: Column(children: [
                        Expanded(
                            flex: 3,
                            child: Container(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${widget.poHeader["DocNum"]} - ${widget.poHeader["CardName"]}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                  ),
                                ],
                              ),
                            )),
                        Expanded(
                            flex: 3,
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Text(
                                  //   "9-04-2023",
                                  //   style: TextStyle(
                                  //       color:
                                  //           Color.fromARGB(255, 106, 103, 103)),
                                  // ),
                                  Text(
                                    splitDate(widget.poHeader["DocDate"]),
                                    style: const TextStyle(
                                        fontSize: 13.5,
                                        color:
                                            Color.fromARGB(255, 106, 103, 103)),
                                  ),
                                  Text(
                                    replaceStringStatus(
                                        widget.poHeader["DocumentStatus"]),
                                    style: TextStyle(
                                      color:
                                          widget.poHeader["DocumentStatus"] ==
                                                  "bost_Close"
                                              ? Colors.red
                                              : Colors.blue,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ))
                      ]),
                    )),
              ],
            ),
          ),
          Container(
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
            height: 75.0,
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
                              "Items (${widget.poHeader["DocumentLines"].length})",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            SizedBox(
                              height: 18,
                            ),
                            Text(
                              "Click to View Items",
                              style: TextStyle(
                                  fontSize: 13.5,
                                  color: Color.fromARGB(255, 106, 103, 103)),
                            ),
                          ]),
                    )),
                Expanded(
                    flex: 2,
                    child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
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
          GestureDetector(
            child: FlexTwo(
              title: "Series",
              values: (() {
                var value = widget.seriesList.firstWhere(
                  (e) => e["Series"] == widget.poHeader["Series"],
                  orElse: () => null,
                );
                return value != null ? value["Name"] : "";
              })(),
            ),
          ),
          FlexTwo(
            title: "Document Number",
            values: widget.poHeader["DocNum"] ?? "",
          ),
          FlexTwo(
            title: "Vendor",
            values: widget.poHeader["CardCode"] ?? "",
          ),
          FlexTwo(
            title: "Name",
            values: widget.poHeader["CardName"] ?? "",
          ),
          FlexTwo(
            title: "Contact Person",
            values: widget.poHeader["ContactPersonCode"] ?? "",
          ),
          SizedBox(
            height: 30,
          ),
          FlexTwo(
            title: "Document Date",
            values: splitDate(widget.poHeader["DocDate"]),
          ),
          FlexTwo(
            title: "Delivery Date",
            values: splitDate(widget.poHeader["DocDueDate"]),
          ),
          FlexTwo(
            title: "Posting Date",
            values: splitDate(widget.poHeader["TaxDate"]),
          ),
          FlexTwo(
            title: "Remark",
            values: widget.poHeader["Comments"] ?? "",
          ),
          FlexTwo(
            title: "Custumer Ref. No",
            values: widget.poHeader["NumAtCard"] ?? "",
          ),
          FlexTwo(
            title: "Status",
            values: replaceStringStatus(widget.poHeader["DocumentStatus"]),
          ),
          FlexTwo(
            title: "Branch",
            values: widget.poHeader["BPLName"] ?? "",
          ),
          SizedBox(
            height: 30,
          ),
          FlexTwoArrow(
            title: "Attachment",
          ),
          SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }
}
