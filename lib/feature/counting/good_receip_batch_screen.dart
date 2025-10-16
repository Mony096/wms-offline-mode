import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
// import 'package:iscan_data_plugin/iscan_data_plugin.dart';
import 'package:wms_mobile/component/form/input_col.dart';
import 'package:wms_mobile/feature/list_batch/presentation/screen/batch_list_page.dart';
import 'package:wms_mobile/utilies/formart.dart';

import '../../form/datePicker.dart';
import '/component/button/button.dart';
import '/component/form/input.dart';
import '/helper/helper.dart';
import '/utilies/dialog/dialog.dart';

import '../../constant/style.dart';

class GoodReceiptBatchScreen extends StatefulWidget {
  const GoodReceiptBatchScreen(
      {super.key,
      required this.itemCode,
      required this.quantity,
      this.serials,
      this.isEdit,
      this.listAllBatch,
      this.binCode,
      this.isQuickCount,
      this.alcQty,
      this.itemName,
      this.inWhsQty,
      this.warehouse});

  final String quantity;
  final dynamic listAllBatch;
  final String itemCode;
  final List<dynamic>? serials;
  final dynamic isEdit;
  final dynamic binCode;
  final dynamic isQuickCount;
  final dynamic alcQty;
  final dynamic warehouse;
  final dynamic itemName;
  final dynamic inWhsQty;

  @override
  State<GoodReceiptBatchScreen> createState() => _GoodReceiptBatchScreenState();
}

class _GoodReceiptBatchScreenState extends State<GoodReceiptBatchScreen> {
  final itemCode = TextEditingController();
  final quantity = TextEditingController();
  final totalSerial = TextEditingController();
  final textSerial = TextEditingController();
  final quantityPerBatch = TextEditingController();
  final warehouse = TextEditingController();
  final itemName = TextEditingController();
  final inWhsQty = TextEditingController();

  DateTime? expDate;
  List<dynamic> items = [];
  int updateIndex = -1;
  bool clear = false;
  DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  final GlobalKey<DatePickerState> _datePickerKey =
      GlobalKey<DatePickerState>();
  @override
  void initState() {
    itemCode.text = widget.itemCode;
    quantity.text = widget.quantity;
    warehouse.text = widget.warehouse;
    itemName.text = widget.itemName;
    inWhsQty.text = widget.inWhsQty;
    // if (widget.isQuickCount == true) {
    //   quantityPerBatch.text = widget.alcQty.toString();
    // } else {
    // quantityPerBatch.text = widget.alcQty.toString();
    // }
    if (widget.isEdit >= 0) {
      setState(() {
        items = widget.serials ?? [];
      });
    } else {
      setState(() {
        items = [];
      });
    }
    final totalQty = items.fold<int>(0, (sum, item) {
      final qty = int.tryParse(item["Quantity"].toString()) ?? 0;
      return sum + qty;
    });
    totalSerial.text = totalQty.toString();
    // IscanDataPlugin.methodChannel.setMethodCallHandler((MethodCall call) async {
    //   if (call.method == "onScanResults") {
    //     setState(() {
    //       if (call.arguments['data'] == "decode error") return;
    //       //
    //       textSerial.text = call.arguments['data'];
    //       // onEnterSerial();
    //       FocusScope.of(context).requestFocus(FocusNode());
    //     });
    //   }
    // });

    super.initState();
  }

  void onEnterSerial() {
    try {
      // print(quantityPerBatch.text);
      // print(textSerial.text);
      if (textSerial.text == '') return;
      // final index =
      //     items.indexWhere((e) => e['BatchNumber'] == textSerial.text);
      // Calculate the total added quantity so far
      int totalAddedQuantity = items.fold(
          0, (sum, item) => sum + double.parse(item['Quantity']).toInt());

      // Check if the current quantityPerBatch exceeds the remaining quantity
      int currentQuantity = double.parse(quantityPerBatch.text).toInt();
      if (currentQuantity <= 0) {
        throw Exception('Quantity must be greater than 0');
      }
      if (widget.listAllBatch != true) {
        if (expDate == null) {
          throw Exception('Expiry Date is missing');
        }
      }

      if (totalAddedQuantity + currentQuantity >
              double.parse(quantity.text).toInt() &&
          updateIndex < 0) {
        throw Exception(
            'Quantity exceeds available. Remaining quantity is ${double.parse(quantity.text).toInt() - totalAddedQuantity}.');
      }

      if (updateIndex < 0) {
        items.add({
          "BatchNumber": textSerial.text,
          "Quantity": quantityPerBatch.text,
          "ExpiryDate": expDate.toString() == "null" ? "" : expDate.toString()
        });
      } else {
        final temps = [...items];

        temps[updateIndex] = {
          "BatchNumber": textSerial.text,
          "Quantity": quantityPerBatch.text,
          "ExpiryDate": expDate.toString() == "null" ? "" : expDate.toString()
        };
        items = temps;
        if (items.fold(
                    0,
                    (sum, item) =>
                        sum + double.parse(item['Quantity']).toInt()) >
                double.parse(quantity.text).toInt() &&
            updateIndex >= 0) {
          updateIndex = -1;
          quantityPerBatch.text = quantity.text;
          textSerial.text = "";

          items = [];
          throw Exception(
              'Quantity exceeds available. Remaining quantity is ${double.parse(widget.quantity).toInt() - totalAddedQuantity}.');
        }
      }
      totalSerial.text = items.length.toString();
      textSerial.text = "";
      quantityPerBatch.text = "0";
      setState(() {
        expDate = null;
        _datePickerKey.currentState?.clearDate();
        items;
        updateIndex = -1;
      });
      final totalQty = items.fold<int>(0, (sum, item) {
        final qty = int.tryParse(item["Quantity"].toString()) ?? 0;
        return sum + qty;
      });
      totalSerial.text = totalQty.toString();
      FocusScope.of(context).requestFocus(FocusNode());
    } catch (e) {
      FocusScope.of(context).requestFocus(FocusNode());
      MaterialDialog.success(context, title: 'Failed', body: e.toString());
    }
  }

  void onEditOrDelete(String serial) {
    List<dynamic> data = [...items];
    MaterialDialog.warning(
      title: "Opps.",
      context,
      body: 'Are you sure want to remove?',
      confirmLabel: 'Edit',
      onConfirm: () {
        final index = data.indexWhere((e) => e['BatchNumber'] == serial);

        updateIndex = index;

        if (index < 0) return;

        textSerial.text = items[index]['BatchNumber'] ?? "";
        quantityPerBatch.text = items[index]['Quantity'] ?? "";
        if (widget.listAllBatch != true) {
          expDate = DateTime.parse(items[index]['ExpiryDate']);
          _datePickerKey.currentState?.updateDate(expDate);
        }
        if (items[index]['ExpiryDate'] != "") {
          expDate = DateTime.parse(items[index]['ExpiryDate']);
          _datePickerKey.currentState?.updateDate(expDate);
        }
        setState(() {
          updateIndex;
        });
      },
      cancelLabel: 'Remove',
      onCancel: () {
        data.removeWhere((e) => e['BatchNumber'] == serial);
        setState(() {
          items = data;
        });
      },
    );
  }

  void onComplete() {
    try {
      final qty = double.parse(quantity.text).toInt();
      int totalAddedQuantity = items.fold(
          0, (sum, item) => sum + double.parse(item['Quantity']).toInt());
      if (qty == 0) {
        throw Exception("Quantity must be greater than 0.");
      }
      if (totalAddedQuantity < qty && widget.isQuickCount != true) {
        throw Exception("Can't generate document without complete batch.");
      }
      Navigator.of(context)
          .pop({"items": items, "quantity": quantity.text, "expDate": expDate});
    } catch (e) {
      MaterialDialog.success(context, title: 'Failed', body: e.toString());
    }
  }

  void onNavigateBatchList() async {
    if (widget.alcQty > 0 && widget.isQuickCount) return;
    if (quantity.text.isEmpty) {
      MaterialDialog.success(
        context,
        title: 'Failed',
        body: "Opps, Quantity not found can't generate batch number!",
      );
      return;
    }
    goTo(context,
            BatchListPage(itemCode: itemCode.text, binCode: widget.binCode))
        .then((value) async {
      if (value == null) return;

      for (var element in value) {
        items.add({
          "BatchNumber": element['Batch_Serial'] ?? "",
          "Quantity": element['PickQty'] ?? "0",
          "ExpiryDate": element["ExpDate"] ?? ""
        });
      }
      int totalAddedQuantity = items.fold(
          0, (sum, item) => sum + double.parse(item['Quantity']).toInt());
      if (totalAddedQuantity > double.parse(widget.quantity).toInt()) {
        items = [];
        MaterialDialog.success(context,
            title: 'Failed',
            body:
                'Quantity exceeds available. Remaining quantity is ${double.parse(widget.quantity).toInt() - totalAddedQuantity}.');
      }
      setState(() {
        items;
      });
    });
  }

  void _selectPostingDate(DateTime date) async {
    setState(() {
      expDate = date;
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
              "Batch No",
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
                // Input(
                //   label: 'Item.',
                //   placeholder: 'Item',
                //   readOnly: true,
                //   controller: itemCode,
                //   // onPressed: onSelectItem,
                // ),
                // Input(
                //   controller: quantity,
                //   label: 'Qty.',
                //   placeholder: '0',
                //   readOnly: true,
                //   keyboardType: TextInputType.numberWithOptions(decimal: true),
                // ),
                // Input(
                //   controller: quantityPerBatch,
                //   label: 'Alc.Bt',
                //   placeholder: '0',
                //   keyboardType: TextInputType.numberWithOptions(decimal: true),
                // ),
                // Input(
                //   controller: textSerial,
                //   label: 'Batch.',
                //   placeholder: 'Batch',
                //   onPressed: () async {
                //     if (widget.listAllBatch == null) return;
                //     onNavigateBatchList();
                //   },
                //   icon: Icons.barcode_reader,
                //   onEditingComplete: onEnterSerial,
                // ),
                // widget.listAllBatch == true
                //     ? Container()
                //     : DatePicker(
                //         key: _datePickerKey,
                //         title: "Expiry Date",
                //         restorationId: 'main_date_picker',
                //         req: 'true',
                //         onDateSelected: _selectPostingDate,
                //         defaultValue: expDate,
                //       ),
                // const SizedBox(height: 12),
                // // Text('Batch No.'),
                // Button(
                //   bgColor: Colors.green.shade700,
                //   onPressed: onEnterSerial,
                //   child: Text(
                //     updateIndex == -1 ? "Add" : "Update",
                //     style: TextStyle(
                //       color: Colors.white,
                //     ),
                //   ),
                // ),
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
                      Input(
                        controller: inWhsQty,
                        label: 'In Whs Qty',
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
                    Container(),
                    Row(
                      children: [
                        Text("Batch No"),
                        SizedBox(
                          width: 8,
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
                              "${totalSerial.text == "" ? 0 : totalSerial.text}/${quantity.text == "" ? 0 : quantity.text}",
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
                InputCol(
                  controller: textSerial,
                  label: 'Batch',
                  placeholder: 'Enter Batch',
                  onPressed: () async {
                    if (widget.listAllBatch == null) return;
                    onNavigateBatchList();
                  },
                  icon: Icons.barcode_reader,
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: InputCol(
                        controller: quantityPerBatch,
                        label: 'Qty',
                        placeholder: 'qty',
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          widget.listAllBatch == true &&
                                  widget.alcQty < 0 &&
                                  widget.isQuickCount
                              ? Container()
                              : DatePicker(
                                  key: _datePickerKey,
                                  title: "Expiry Date",
                                  restorationId: 'main_date_picker',
                                  req: 'true',
                                  onDateSelected: _selectPostingDate,
                                  defaultValue: expDate,
                                ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
                // const SizedBox(height: 40),
                ContentHeader(),
                items.isEmpty
                    ? Container(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: Text(
                            "No Batch available",
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
                                    onEditOrDelete(item['BatchNumber']),
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
    );
  }
}

class ContentHeader extends StatelessWidget {
  const ContentHeader({
    super.key,
  });
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
            flex: 2,
            child: Text(
              'Batch No',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Qty',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.only(left: 60),
              child: Text(
                'Exp. Date',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ItemRow extends StatelessWidget {
  const ItemRow({super.key, required this.item, this.po});
  final dynamic po;
  final dynamic item;
  String getDataFromDynamic(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade100,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // First Row (Item, UoM, Qty, Open Qty)
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  getDataFromDynamic(item['BatchNumber']),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  getDataFromDynamic(item['Quantity']),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.only(left: 50),
                  child: Text(
                    getDataFromDynamic(item['ExpiryDate']?.split(" ")[0]),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ],
          ),

          // const SizedBox(height: 4),

          // // Second Row (Description)
          // Text(
          //   getDataFromDynamic(item['ItemDescription']),
          //   style: const TextStyle(
          //     color: Colors.black87,
          //     fontSize: 13,
          //   ),
          // ),

          // // Divider
          // const SizedBox(height: 8),
          // Divider(
          //   height: 1,
          //   thickness: 0.6,
          //   color: Colors.grey.shade300,
          // ),
        ],
      ),
    );
  }
}
