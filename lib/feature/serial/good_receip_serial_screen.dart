import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wms_mobile/component/form/input_col.dart';
import 'package:wms_mobile/feature/list_serial/presentation/screen/Serial_list_page.dart';
import '/component/button/button.dart';
import '/component/form/input.dart';
import '/helper/helper.dart';
import '/utilies/dialog/dialog.dart';
import '../../constant/style.dart';
// import 'package:iscan_data_plugin/iscan_data_plugin.dart';

class GoodReceiptSerialScreen extends StatefulWidget {
  const GoodReceiptSerialScreen(
      {super.key,
      required this.itemCode,
      required this.quantity,
      this.warehouse,
      this.serials,
      this.isEdit,
      this.listAllSerial,
      this.binCode,
      this.isQuickCount,
      this.itemName});

  final String quantity;
  final String itemCode;
  final List<dynamic>? serials;
  final dynamic isEdit;
  final dynamic listAllSerial;
  final dynamic binCode;
  final dynamic isQuickCount;
  final dynamic itemName;
  final dynamic warehouse;

  @override
  State<GoodReceiptSerialScreen> createState() =>
      _GoodReceiptSerialScreenState();
}

class _GoodReceiptSerialScreenState extends State<GoodReceiptSerialScreen> {
  final itemCode = TextEditingController();
  final itemName = TextEditingController();
  final quantity = TextEditingController();
  final totalSerial = TextEditingController();
  final textSerial = TextEditingController();
  final warehouse = TextEditingController();
  final barCode = TextEditingController();

  int updateIndex = -1;

  List<dynamic> items = [];
  bool isClickScan = false;
  final FocusNode _serial = FocusNode();
  @override
  void initState() {
    itemCode.text = widget.itemCode;
    quantity.text = widget.quantity;
    itemName.text = widget.itemName;
    warehouse.text = widget.warehouse;
    totalSerial.text = items.length.toString();

    items = widget.serials ?? [];
    totalSerial.text = items.length.toString();

    // IscanDataPlugin.methodChannel.setMethodCallHandler((MethodCall call) async {
    //   if (call.method == "onScanResults") {
    //     setState(() {
    //       if (call.arguments['data'] == "decode error") return;
    //       //
    //       textSerial.text = call.arguments['data'];
    //       onEnterSerial();
    //     });
    //   }
    // });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    itemCode.dispose();
    quantity.dispose();
    totalSerial.dispose();
    textSerial.dispose();
  }

  void onEnterSerial() {
    try {
      if (textSerial.text == '') {
        FocusScope.of(context).requestFocus(FocusNode());
        return;
      }
      if (quantity.text.isEmpty) {
        throw Exception(
            "Opps, Quantity not found can't generate serial number!");
      }
      if (items.length >= parseQuantity(quantity.text).toInt()) {
        throw Exception(
            'Serial Number can not be greater than ${widget.quantity}.');
      }

      // final index =
      //     items.indexWhere((e) => e['InternalSerialNumber'] == textSerial.text);

      // if (index >= 0) {
      //   throw Exception('Duplicate serial on row $index');
      // }

      items.add({
        "InternalSerialNumber": textSerial.text,
        "Quantity": "1",
      });
      totalSerial.text = items.length.toString();
      setState(() {
        items;
      });
    } catch (e) {
      MaterialDialog.success(context, title: 'Failed', body: e.toString());
    }
    textSerial.clear();
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void onDelete(String serial) {
    List<dynamic> data = [...items];
    MaterialDialog.warning(
      context,
      body: 'Are you sure want to remove?',
      onConfirm: () {
        data.removeWhere((e) => e['InternalSerialNumber'] == serial);
        setState(() {
          items = data;
        });
      },
    );
  }

  void onNavigateSerialList() async {
    if (quantity.text.isEmpty) {
      MaterialDialog.warning(
        context,
        title: 'Failed',
        body: "Opps, Quantity not found can't generate serial number!",
      );
      return;
    }
    goTo(
      context,
      SerialListPage(
        warehouse: '',
        itemCode: widget.itemCode,
        binCode: widget.binCode,
      ),
    ).then((value) async {
      if (value == null) return;

      // Set to track unique serial numbers
      Set<dynamic> serialNumbers =
          items.map((item) => item["InternalSerialNumber"] ?? "").toSet();

      for (var element in value) {
        String serial = element['Batch_Serial'] ?? "";

        // Check for duplicates
        if (serialNumbers.contains(serial)) {
          MaterialDialog.warning(
            context,
            title: 'Failed',
            body: 'Duplicate found for SerialNumber: $serial.',
          );
          continue; // Skip adding the duplicate
        }

        items.add({
          "InternalSerialNumber": serial,
          "Quantity": "1",
        });
        serialNumbers.add(serial);
        // if (widget.isQuickCount && widget.listAllSerial == true) {
        //   totalSerial.text = "-${items.length}";
        // } else {
        //   totalSerial.text = items.length.toString();
        // }

        setState(() {
          items;
        });
        print(items);
      }

      // Check if the number of serial numbers exceeds the allowed quantity
      if (items.length > parseQuantity(quantity.text).toInt()) {
        items.removeRange(parseQuantity(quantity.text).toInt(), items.length);
        MaterialDialog.success(
          context,
          title: 'Failed',
          body: 'Serial Number cannot be greater than ${widget.quantity}.',
        );
      }
    });
  }

  void onComplete() {
    try {
      if (items.length < parseQuantity(quantity.text).toInt() &&
          widget.isQuickCount != true) {
        throw Exception(
            'Cannot add document without complete selection of serial numbers.');
      }
      Navigator.of(context).pop({
        "items": items,
        "quantity": quantity.text,
      });
    } catch (e) {
      MaterialDialog.success(context, title: 'Failed', body: e.toString());
    }
  }

  // Generic function to request focus on a specific node
  void _requestFocus(FocusNode node) {
    if (!node.hasFocus) {
      // Use microtask for stability with fast, external keyboard input
      Future.microtask(() => node.requestFocus());
    }
  }

  void _handleScanSubmitted(String barcode, FocusNode submittedNode) {
    debugPrint("📦 Scanned Supplier Code: $barcode");

    setState(() {
      // Check which input currently has focus
      if (_serial.hasFocus) {
        // ✅ If filter input is focused → set scanned value
        barCode.text = barcode;
        // textSerial.clear();
        isClickScan = false;
      }
      // else {
      //   // ✅ Optional: fallback behavior if no input focused
      //   debugPrint("⚠️ No input focused, ignoring scan");
      // }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: PRIMARY_COLOR,
        iconTheme: IconThemeData(color: Colors.white),
        title: Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Text(
              "Serial No",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white),
            ),
          ),
        ),
        actions: [IconButton(onPressed: onComplete, icon: Icon(Icons.check))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(5),
                child: Column(
                  children: [
                    Input(
                      label: 'Item Code',
                      placeholder: 'Item',
                      readOnly: true,
                      controller: itemCode,
                      // onPressed: onSelectItem,
                    ),
                    Input(
                      controller: itemName,
                      label: 'Description',
                      placeholder: 'desc',
                      readOnly: true,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                    ),
                    Input(
                      controller: quantity,
                      inputFormatters: [ThousandsSeparatorInputFormatter()],
                      label: 'Quantity',
                      placeholder: 'Qty',
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                    ),
                    Divider(thickness: 1, color: Colors.grey.shade400),
                    // if (widget.po != null)
                    //   Input(
                    //     label: 'PO #',
                    //     placeholder: 'PO DocNum',
                    //     controller: poText,
                    //     readOnly: true,
                    //   ),
                    Input(
                      label: 'Warehouse',
                      placeholder: 'Warehouse',
                      controller: warehouse,
                      readOnly: true,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 23,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text("Qty of Serial"),
                      SizedBox(
                        width: 6,
                      ),
                      Container(
                        width: 40,
                        height: 25,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 236, 238, 239),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Center(
                          child: Text(
                            totalSerial.text,
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Text("Serial No"),
                      SizedBox(
                        width: 6,
                      ),
                      Container(
                        width: 60,
                        height: 25,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 236, 238, 239),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Center(
                          child: Text(
                            "${totalSerial.text}/${quantity.text == "" ? 0 : quantity.text}",
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Divider(thickness: 0.5, color: Colors.grey.shade400),
              SizedBox(
                height: 15,
              ),
              // Row(
              //   children: [
              //     Expanded(
              //       child: InputCol(
              //         controller: textSerial,
              //         label: 'Serial No',
              //         placeholder: 'Serial',
              //         onPressed: () async {
              //           if (widget.listAllSerial != true) return;
              //           onNavigateSerialList();
              //         },
              //         icon: Icons.barcode_reader,
              //         onEditingComplete: onEnterSerial,
              //       ),
              //     ),
              //   ],
              // ),
              Row(
                children: [
                  Expanded(
                    child: InputCol(
                      label: 'Serial Number',
                      placeholder: 'Enter Serial',
                      controller: textSerial,
                      focusNode: _serial,
                      readOnly: widget.listAllSerial != null,
                      onTap: () => {
                        setState(() {
                          isClickScan = false; // turn on scan mode
                          // itemCode.clear();
                        }),
                        // 2. Clear current focus before switching
                        FocusScope.of(context).unfocus()
                      },
                      keyboardType:
                          isClickScan ? TextInputType.none : TextInputType.text,
                      onPressed: widget.listAllSerial != null
                          ? onNavigateSerialList
                          : null,
                      onFieldSubmitted: (value) {
                        _handleScanSubmitted(value, _serial);
                      },
                    ),
                  ),
                  widget.listAllSerial == null
                      ? SizedBox(
                          width: 15,
                        )
                      : SizedBox(),
                  widget.listAllSerial == null
                      ? GestureDetector(
                          onTap: () {
                            // 1. Switch to scan mode
                            setState(() {
                              isClickScan = true; // turn on scan mode
                              textSerial.clear();
                            });

                            // 2. Clear current focus before switching
                            FocusScope.of(context).unfocus();

                            // 3. Focus scanner input
                            Future.delayed(const Duration(milliseconds: 100),
                                () {
                              _requestFocus(_serial);
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.only(top: 30),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F3F4),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isClickScan
                                    ? Colors.green
                                    : Colors
                                        .transparent, // ✅ green border when active
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.document_scanner_outlined,
                              color: Color(0xFF12169D),
                              size: 20,
                            ),
                          ),
                        )
                      : Container(),
                  widget.listAllSerial == null
                      ? const SizedBox(width: 12)
                      : SizedBox(),
                ],
              ),
              const SizedBox(height: 30),
              ContentHeader(),
              items.isEmpty
                  ? Container(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: Text(
                          "No Serial  available",
                          style: TextStyle(fontSize: 15, color: Colors.grey),
                        ),
                      ),
                    )
                  : Container(),
              Column(
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: items
                    .map((item) => GestureDetector(
                          onTap: () => onDelete(item['InternalSerialNumber']),
                          child: ItemRow(item: item),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: Container(
        margin: EdgeInsets.fromLTRB(15, 0, 15, 15),
        child: Button(
          bgColor: PRIMARY_COLOR,
          onPressed: onEnterSerial,
          child: Text(
            updateIndex == -1 ? "Add" : "Edit",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
      //  Container(
      //   height: 70,
      //   padding: const EdgeInsets.all(12),
      //   child: Row(
      //     children: [
      //       Expanded(
      //         child: Button(
      //           variant: ButtonVariant.outline,
      //           onPressed: () {
      //             Navigator.of(context).pop();
      //           },
      //           child: Text(
      //             'Cancel',
      //             style: TextStyle(
      //               color: PRIMARY_COLOR,
      //             ),
      //           ),
      //         ),
      //       ),
      //       const SizedBox(width: 12),
      //       Expanded(
      //         child: Button(
      //           onPressed: onComplete,
      //           bgColor: PRIMARY_COLOR,
      //           child: Text(
      //             'Done',
      //             style: TextStyle(
      //               color: Colors.white,
      //             ),
      //           ),
      //         ),
      //       ),
      //       const SizedBox(width: 12),
      //     ],
      //   ),
      // ),
    );
  }
}

class ContentHeader extends StatelessWidget {
  const ContentHeader({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PRIMARY_COLOR, // Dark navy header
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Row(
        children: const [
          Expanded(
            flex: 3,
            child: Text(
              'Serial No',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ItemRow extends StatelessWidget {
  const ItemRow({super.key, required this.item});

  final dynamic item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(width: 0.1)),
          color: const Color.fromARGB(255, 244, 245, 246)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  getDataFromDynamic(item['InternalSerialNumber']),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Expanded(child: Text(getDataFromDynamic(item['UoMCode']))),
            ],
          ),
          SizedBox(height: 6),
          // Text(getDataFromDynamic(item['ItemDescription']))
        ],
      ),
    );
  }
}
