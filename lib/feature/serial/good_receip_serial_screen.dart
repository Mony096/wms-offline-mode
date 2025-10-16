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

  int updateIndex = -1;

  List<dynamic> items = [];

  @override
  void initState() {
    itemCode.text = widget.itemCode;
    quantity.text = widget.quantity;
    itemName.text = widget.itemName;
    warehouse.text = widget.warehouse;
    totalSerial.text = items.length.toString();
    if (widget.isEdit >= 0) {
      setState(() {
        print(widget.serials);
        items = widget.serials ?? [];
        totalSerial.text = items.length.toString();
      });
    } else {
      setState(() {
        items = [];
      });
    }
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
      if (items.length >= double.parse(quantity.text).toInt()) {
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
      MaterialDialog.success(
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
          MaterialDialog.success(
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
      if (items.length > double.parse(quantity.text).toInt()) {
        items.removeRange(double.parse(quantity.text).toInt(), items.length);
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
      if (items.length < double.parse(quantity.text).toInt() &&
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
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: size(context).height,
              maxHeight: size(context).height,
              minWidth: size(context).width,
              maxWidth: size(context).width,
            ),
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
                Row(
                  children: [
                    Expanded(
                      child: InputCol(
                        controller: textSerial,
                        label: 'Serial No',
                        placeholder: 'Serial',
                        onPressed: () async {
                          if (widget.listAllSerial != true) return;
                          onNavigateSerialList();
                        },
                        icon: Icons.barcode_reader,
                        onEditingComplete: onEnterSerial,
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: InputCol(
                        controller: totalSerial,
                        label: 'Serial Qty',
                        placeholder: '0',
                        readOnly: true,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
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
                Expanded(
                  child: Scrollbar(
                    child: ListView(
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: items
                          .map((item) => GestureDetector(
                                onTap: () =>
                                    onDelete(item['InternalSerialNumber']),
                                child: ItemRow(item: item),
                              ))
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
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
      //   height: size(context).height * 0.09,
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
