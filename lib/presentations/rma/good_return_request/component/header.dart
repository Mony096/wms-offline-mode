import 'package:flutter/material.dart';
import 'package:wms_mobile/component/flexTwo.dart';
import 'package:wms_mobile/component/flexTwoArrow.dart';
import 'package:wms_mobile/utilies/formart.dart';

class HeaderScreen extends StatefulWidget {
  const HeaderScreen(
      {super.key, required this.grrHeader, required this.seriesList});
  final Map<String, dynamic> grrHeader;
  final List<dynamic> seriesList;

  @override
  State<HeaderScreen> createState() => _HeaderScreenState();
}

class _HeaderScreenState extends State<HeaderScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color.fromARGB(255, 236, 233, 233),
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
                              padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${widget.grrHeader["DocNum"]} - ${widget.grrHeader["CardCode"]}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                  Text(
                                    " ${replaceStringStatus(widget.grrHeader["DocumentStatus"])}",
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
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
                                  Text(
                                    "${splitDate(widget.grrHeader["DocDate"])}",
                                    style: const TextStyle(
                                        color:
                                            Color.fromARGB(255, 106, 103, 103)),
                                  ),
                                  Text(
                                    "${widget.grrHeader["DocTotal"]} USD",
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 97, 99, 100),
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
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              "Items (${widget.grrHeader["DocumentLines"].length})",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(
                              height: 18,
                            ),
                            const Text(
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
          FlexTwo(
            title: "Series",
           values: (() {
              var value = widget.seriesList.firstWhere(
                (e) => e["Series"] == widget.grrHeader["Series"],
                orElse: () => null,
              );
              return value != null ? value["Name"] : "...";
            })(),
          ),
          FlexTwo(
            title: "Document Number",
            values: "${widget.grrHeader["DocNum"]}",
          ),
          FlexTwo(
            title: "Vendor",
            values: "${widget.grrHeader["CardCode"]}",
          ),
          FlexTwo(
            title: "Name",
            values: "${widget.grrHeader["CardName"]}",
          ),
          FlexTwo(
            title: "Contact Person",
            values: "${widget.grrHeader["ContactPersonCode"]}",
          ),
          FlexTwo(
            title: "Currency",
            values: "${widget.grrHeader["DocCurrency"]}",
          ),
          FlexTwo(
            title: "Document Date",
            values: splitDate(widget.grrHeader["TaxDate"]),
          ),
          FlexTwo(
            title: "Delivery Date",
            values: splitDate(widget.grrHeader["DocDueDate"]),
          ),
          FlexTwo(
            title: "Posting Date",
            values: splitDate(widget.grrHeader["DocDate"]),
          ),
          FlexTwo(
            title: "Remark",
            values: "${widget.grrHeader["Comments"]}",
          ),
          FlexTwo(
            title: "Custumer Ref. No",
            values: "${widget.grrHeader["NumAtCard"] ?? ""}",
          ),
          FlexTwo(
            title: "Status",
            values: replaceStringStatus(widget.grrHeader["DocumentStatus"]),
          ),
          FlexTwo(
            title: "Branch",
            values: "${widget.grrHeader["BPLName"] ?? ""}",
          ),
          SizedBox(
            height: 30,
          ),
          FlexTwoArrow(
            title: "References",
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
