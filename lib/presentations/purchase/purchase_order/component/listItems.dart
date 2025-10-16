import 'package:flutter/material.dart';
import 'package:wms_mobile/presentations/inventory/good_receipt/create_screen/good_receipt_item_create_screen.dart';
import 'package:wms_mobile/presentations/purchase/purchase_order/create_screen/purchaseOrderItemCreateScreen.dart';

class ListItems extends StatefulWidget {
  ListItems({super.key, required this.item});
  Map<String, dynamic> item;
  @override
  State<ListItems> createState() => _ListItemsState();
}

class _ListItemsState extends State<ListItems> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
   
  }
  



  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: const BoxDecoration(
          color: Color.fromARGB(255, 255, 255, 255),
          border: Border(
            left: BorderSide(
              color: Color.fromARGB(255, 222, 219, 219),
              width: 0.5,
            ),
            bottom: BorderSide(
              color: Color.fromARGB(255, 207, 202, 202),
              width: 0.5,
            ),
            right: BorderSide(
              color: Color.fromARGB(255, 215, 211, 211),
              width: 0.5,
            ),
          )),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: SizedBox(
              height: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(13, 7, 0, 9),
                    child: Text(
                      "${widget.item["ItemDescription"] ?? widget.item["ItemName"] ?? ""}",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                  Container(
                      margin: const EdgeInsets.only(left: 13),
                      child: Text(
                        "${widget.item["ItemCode"] ?? ""}",
                        style: TextStyle(fontSize: 14.5, color: Colors.grey),
                      )),
                  Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.fromLTRB(13, 16, 0, 0),
                        width: 23,
                        height: 23,
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 31, 33, 47),
                            borderRadius: BorderRadius.circular(5)),
                        child: const Icon(
                          Icons.remove,
                          color: Colors.white,
                          size: 17,
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                        width: 85,
                        height: 23,
                        decoration: const BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: Color.fromARGB(255, 222, 219, 219),
                              width: 0.5,
                            ),
                            bottom: BorderSide(
                              color: Color.fromARGB(255, 207, 202, 202),
                              width: 0.5,
                            ),
                            right: BorderSide(
                              color: Color.fromARGB(255, 215, 211, 211),
                              width: 0.5,
                            ),
                            top: BorderSide(
                              color: Color.fromARGB(255, 215, 211, 211),
                              width: 0.5,
                            ),
                          ),
                        ),
                        // child: const Center(child: Text("5")),
                        child: TextField(
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontWeight: FontWeight.normal,
                            fontSize: 14.5,
                          ),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.only(bottom: 15.0),
                          ),
                          cursorColor: Color.fromARGB(
                              255, 178, 183, 186), // Set cursor color
                          cursorWidth: 1.0,
                          cursorHeight: 15.0,
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 31, 33, 47),
                            borderRadius: BorderRadius.circular(5)),
                        margin: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                        width: 23,
                        height: 23,
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 17,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
                padding: const EdgeInsets.only(right: 13),
                height: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(
                      height: 13,
                    ),
                    GestureDetector(
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        color: Color.fromARGB(255, 122, 119, 119),
                        size: 18,
                      ),
                    ),
                    const SizedBox(
                      height: 14,
                    ),
                    Text(
                      "${widget.item["InventoryUOM"] ?? widget.item["UoMCode"] ?? "N/A"}",
                      style: TextStyle(
                          fontSize: 14.5,
                          color: Color.fromARGB(255, 72, 72, 81)),
                    ),
                    const SizedBox(
                      height: 11,
                    ),
                    Text(
                     "Wh - ${widget.item["WarehouseCode"] == "" || widget.item["WarehouseCode"] == null ? "N/A" : widget.item["WarehouseCode"] ?? "N/A"}",
                      style: TextStyle(
                          fontSize: 14, color: Color.fromARGB(255, 72, 72, 81)),
                    ),
                  ],
                ) // color: const Color.fromARGB(255, 65, 60, 199),
                ),
          ),
        ],
      ),
    );
  }
}
