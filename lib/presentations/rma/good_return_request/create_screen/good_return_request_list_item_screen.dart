import 'package:flutter/material.dart';
import 'package:wms_mobile/presentations/rma/good_return_request/component/listItems.dart';
import 'package:wms_mobile/presentations/purchase/purchase_order/purchaseOrderCodeScreen.dart';
import 'package:wms_mobile/presentations/rma/good_return_request/component/itemsSelect.dart';
import 'package:wms_mobile/presentations/rma/good_return_request/create_screen/good_return_request_item_create_screen.dart';

class GoodReturnRequestListItemsScreen extends StatefulWidget {
  GoodReturnRequestListItemsScreen({super.key, required this.dataFromPrev});
  List<dynamic> dataFromPrev;

  @override
  State<GoodReturnRequestListItemsScreen> createState() =>
      _GoodReturnRequestListItemsScreenState();
}

class _GoodReturnRequestListItemsScreenState
    extends State<GoodReturnRequestListItemsScreen> {
  List<dynamic> selectedItems = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.dataFromPrev.length > 0) {
      selectedItems.addAll(widget.dataFromPrev);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context, selectedItems);
          },
          icon: const Icon(
            Icons.arrow_back,
            size: 24,
          ),
        ),
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 17, 18, 48),
        title: const Text(
          "Items",
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
          IconButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ItemsSelect(selectedItems: selectedItems),
                ),
              );
              if (result != null) {
                setState(() {
                  selectedItems = [
                    ...selectedItems,
                    ...List<dynamic>.from(result)
                  ];
                });
              }
            },
            icon: const Icon(
              Icons.add,
              size: 25,
            ),
          ),
          const SizedBox(
            width: 13,
          ),
        ],
      ),
      body: selectedItems.length == 0
          ? Container(
              margin: const EdgeInsets.only(bottom: 50.0),
              child: Center(
                  child: Text(
                "No Record",
                style: TextStyle(fontSize: 15),
              )),
            )
          : Container(
              color: const Color.fromARGB(255, 236, 233, 233),
              height: double.infinity,
              width: double.infinity,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                shrinkWrap: true,
                itemCount: selectedItems.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              GoodReturnRequestItemCreateScreen(
                                  updateItem: selectedItems[index]),
                        ),
                      );
                      if (result != null) {
                        setState(() {
                          selectedItems[index] = result;
                        
                        });
                      }
                    },
                    child: ListItems(
                      item: selectedItems[index],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
