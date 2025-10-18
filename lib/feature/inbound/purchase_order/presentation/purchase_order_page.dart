
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:wms_mobile/feature/inbound/purchase_order/presentation/cubit/purchase_order_offline_cubit.dart';

import '/constant/style.dart';
import '/feature/inbound/good_receipt_po/presentation/create_good_receipt_screen.dart';
import '/helper/helper.dart';
import '/utilies/storage/locale_storage.dart';

class PurchaseOrderPage extends StatefulWidget {
  const PurchaseOrderPage({super.key});

  @override
  State<PurchaseOrderPage> createState() => _PurchaseOrderPageState();
}

class _PurchaseOrderPageState extends State<PurchaseOrderPage> {
  final ScrollController _scrollController = ScrollController();

  TextEditingController filter = TextEditingController();
  TextEditingController filterInput = TextEditingController();

  List<dynamic> filteredData = [];
  late PurchaseOrderOfflineCubit _offlineCubit;
  final FocusNode _focusNode = FocusNode();
  final FocusNode _focusNodeInput = FocusNode();

  bool isClickScan = false;
  bool isBorder = false;

  @override
  void initState() {
    super.initState();
    _offlineCubit = context.read<PurchaseOrderOfflineCubit>();
    _offlineCubit.loadData();

    _scrollController.addListener(_handlePagination);
  }

  void _handlePagination() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      debugPrint("📜 Reached bottom - pagination trigger (offline)");
      // You can simulate pagination or lazy load locally here if needed
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _focusNodeInput.dispose();
    filter.dispose();
    filterInput.dispose();
    super.dispose();
  }

  void onFilter() {
    // Use a local variable to capture the state once.
    final allData = _offlineCubit.state;
    final textScan = filter.text.trim().toLowerCase();
    final textInput = filterInput.text.trim().toLowerCase();

    debugPrint("🔎 Filter scan: '$textScan', input: '$textInput'");

    // ✅ 1. BASE CASE: If both filters are empty, show all data.
    if (textScan.isEmpty && textInput.isEmpty) {
      setState(() => filteredData = allData);
      debugPrint("📋 Showing all data (${filteredData.length} items)");
      return;
    }
    // 2. FILTER LOGIC
    final results = allData.where((po) {
      final cardCode =
          (getDataFromDynamic(po['CardCode'])).toString().toLowerCase();
      final cardName =
          (getDataFromDynamic(po['CardName'])).toString().toLowerCase();
      final comments =
          (getDataFromDynamic(po['Comments'])).toString().toLowerCase();

      // --- Filter A: textScan (Matches if textScan is not empty AND one field contains it) ---
      final matchesScan = textScan.isNotEmpty &&
          (cardCode.contains(textScan) ||
              cardName.contains(textScan) ||
              comments.contains(textScan));

      final matchesInput = textInput.isNotEmpty &&
          (cardCode.contains(textInput) ||
              cardName.contains(textInput) ||
              comments.contains(textInput));
      return matchesScan || matchesInput;
    }).toList();

    setState(() => filteredData = results);
    print(filteredData);
    debugPrint("✅ Filter applied → ${filteredData.length} results found");
  }

  void forward(dynamic po) {
    goTo(
      context,
      CreateGoodReceiptPOScreen(
        po: po,
        quickReceipt: false,
      ),
    ).then((value) {
      if (value == null) return;
      _offlineCubit.loadData();
      setState(() => filteredData = _offlineCubit.state);
    });
  }

  void _handleScanSubmitted(String barcode, FocusNode submittedNode) {
    debugPrint("📦 Scanned Supplier Code: $barcode");
    setState(() {
      filter.text = barcode;
      isBorder = false;
    });
    onFilter();
  }

  void _requestFocus(FocusNode node) {
    if (!node.hasFocus) {
      Future.microtask(() => node.requestFocus());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: PRIMARY_COLOR,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Center(
          child: Padding(
            padding: EdgeInsets.only(right: 65),
            child: Text(
              'Purchase Order Lists - OFFLINE',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white),
            ),
          ),
        ),
      ),
      body: BlocBuilder<PurchaseOrderOfflineCubit, List<dynamic>>(
        builder: (context, state) {
          final displayList = filteredData.isEmpty &&
                  filter.text.isEmpty &&
                  filterInput.text.isEmpty
              ? state
              : filteredData;

          // if (displayList.isEmpty) {
          //   return const Center(
          //     child: Column(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         Icon(Icons.file_copy, size: 50, color: Colors.grey),
          //         SizedBox(height: 20),
          //         Text(
          //           "No purchase order found!",
          //           style: TextStyle(color: Colors.grey, fontSize: 15),
          //         ),
          //       ],
          //     ),
          //   );
          // }

          return Column(
            children: [
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
                child: Row(
                  children: [
                    // 👇 Scan Button
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          filter.clear();
                          isClickScan = true;
                          isBorder = true;
                        });
                        FocusScope.of(context).unfocus();
                        Future.delayed(const Duration(milliseconds: 100), () {
                          _requestFocus(_focusNode);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F3F4),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isClickScan && isBorder
                                ? Colors.green
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.document_scanner_outlined,
                          color: Color(0xFF12169D),
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // 👇 Input (Scan or Manual)
                    Expanded(
                      child: TextFormField(
                        controller: isClickScan ? filter : filterInput,
                        focusNode: isClickScan ? _focusNode : _focusNodeInput,
                        keyboardType: isClickScan
                            ? TextInputType.none
                            : TextInputType.text,
                        cursorColor: Colors.green,
                        onTap: () {
                          if (isClickScan) {
                            setState(() {
                              filter.clear();
                              filterInput.clear();
                              isClickScan = false;
                              isBorder = false;
                            });
                            FocusScope.of(context).unfocus();
                            Future.delayed(const Duration(milliseconds: 100),
                                () => _requestFocus(_focusNodeInput));
                          }
                        },
                        onFieldSubmitted: (barcode) =>
                            _handleScanSubmitted(barcode, _focusNode),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 12),
                          hintText: 'Supplier Code...',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: Colors.transparent),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.transparent,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF2F3F4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // 👇 Search button
                    GestureDetector(
                      onTap: onFilter,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 13),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F3F4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.search,
                                color: Color(0xFF12169D), size: 20),
                            SizedBox(width: 6),
                            Text(
                              "Search",
                              style: TextStyle(
                                color: Color(0xFF12169D),
                                fontSize: 14.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(thickness: 0.1, height: 15),

              // 👇 List
              Expanded(
                child: displayList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.file_copy, size: 50, color: Colors.grey),
                            SizedBox(height: 20),
                            Text(
                              "No purchase order found!",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 15),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: displayList.length,
                        itemBuilder: (context, index) {
                          final po = displayList[index];
                          return GestureDetector(
                            onTap: () => forward(po),
                            child: Container(
                              padding: const EdgeInsets.all(13),
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 242, 243, 244),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${getDataFromDynamic(po['CardCode'])} - ${getDataFromDynamic(po['DocNum'])}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      Text(
                                        'Doc Date : ${getDataFromDynamic(po['DocDueDate'], isDate: true)}',
                                        style: const TextStyle(
                                            fontSize: 13.5,
                                            color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          getDataFromDynamic(po['Comments']),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 30),
                                      Text(
                                        'Delivery Date : ${getDataFromDynamic(po['DocDate'], isDate: true)}',
                                        style: const TextStyle(
                                            fontSize: 13.5,
                                            color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
