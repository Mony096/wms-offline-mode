import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_mobile/component/button/button.dart';
import 'package:wms_mobile/feature/list_batch/presentation/cubit/batch_list_offline_cubit.dart';
import 'package:wms_mobile/helper/helper.dart';
import 'package:wms_mobile/utilies/storage/locale_storage.dart';
import '/constant/style.dart';

class SerialListPage extends StatefulWidget {
  const SerialListPage({
    super.key,
    required this.warehouse,
    required this.itemCode,
    this.binCode,
  });

  final String warehouse;
  final String itemCode;
  final dynamic binCode;

  @override
  State<SerialListPage> createState() => _SerialListPageState();
}

class _SerialListPageState extends State<SerialListPage> {
  final ScrollController _scrollController = ScrollController();
  TextEditingController filter = TextEditingController();
  TextEditingController filterInput = TextEditingController();

  List<dynamic> data = [];
  List<dynamic> filteredData = [];
  Set<int> selectedIndices = <int>{};
  bool isFilter = false;
  final FocusNode _focusNode = FocusNode();
  final FocusNode _focusNodeInput = FocusNode();

  bool isClickScan = false;
  bool isBorder = false;

  @override
  void initState() {
    super.initState();
    _initOfflineData();
  }

  Future<void> _initOfflineData() async {
    final warehouse = await LocalStorageManger.getString('warehouse');
    final offlineCubit = context.read<BatchListOfflineCubit>();

    // Get data from offline cubit state
    final offlineData = offlineCubit.state;

    // Convert binCode to int safely if possible
    int? parsedBinCode;
    if (widget.binCode != null && widget.binCode.toString().isNotEmpty) {
      parsedBinCode = int.tryParse(widget.binCode.toString());
    }

    // ✅ Filter data for specific warehouse, itemCode, and optional binCode
    final filtered = offlineData.where((e) {
      final matchesItem = e['ItemCode'] == widget.itemCode;
      final matchesWarehouse = e['WhsCode'] == warehouse;
      final matchesBin =
          parsedBinCode != null ? e['AbsEntry'] == parsedBinCode : true;
      return matchesItem && matchesWarehouse && matchesBin;
    }).toList();

    setState(() {
      data = filtered;
      data.sort((a, b) => (a["BinCode"]).compareTo(b["BinCode"]));
    });
  }

  void onFilter() async {
    final warehouse = await LocalStorageManger.getString('warehouse');
    final offlineCubit = context.read<BatchListOfflineCubit>();
    final offlineData = offlineCubit.state;

    final search1 = filter.text.trim().toLowerCase();
    final search2 = filterInput.text.trim().toLowerCase();

    // ✅ Safely parse bin code
    final parsedBinCode = int.tryParse(widget.binCode ?? '');

    // ✅ If all filters are empty → return everything (refresh behavior)
    final noFilters = search1.isEmpty && search2.isEmpty;

    if (noFilters) {
      _initOfflineData();
      return;
    }

    // ✅ Apply filters
    final filtered = offlineData.where((e) {
      final matchesItem = e['ItemCode'] == widget.itemCode;
      final matchesWarehouse = e['WhsCode'] == warehouse;

      // ✅ Safe BinCode check (handles null, string, or int)
      final binCodeValue = e['AbsEntry'];
      final matchesBin = widget.binCode.isNotEmpty
          ? (binCodeValue != null &&
              (binCodeValue.toString() == widget.binCode ||
                  binCodeValue == parsedBinCode))
          : true;

      // ✅ OR condition for batch filters
      final matchesBatch = (search1.isNotEmpty &&
              e['Batch_Serial'].toString().toLowerCase().contains(search1)) ||
          (search2.isNotEmpty &&
              e['Batch_Serial'].toString().toLowerCase().contains(search2));

      return matchesItem && matchesWarehouse && matchesBin && matchesBatch;
    }).toList();
    setState(() {
      data = filtered;
    });
  }

  void _onSelected(bool? selected, int index) {
    setState(() {
      if (selected == true) {
        selectedIndices.add(index);
      } else {
        selectedIndices.remove(index);
      }
    });
  }

  void _onDone() {
    List<dynamic> sourceList = isFilter ? filteredData : data;
    List<dynamic> selectedData =
        selectedIndices.map((index) => sourceList[index]).toList();
    Navigator.of(context).pop(selectedData);
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
    final displayList = isFilter ? filteredData : data;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: PRIMARY_COLOR,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Serial Lists',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color.fromARGB(255, 243, 243, 243),
        child: Column(
          children: [
            // 🔍 Search Bar
            SizedBox(
              height: 12,
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
              child: Row(
                children: [
                  // 👇 Scan Button
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        filter.clear();
                        filterInput.clear();
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
                        color: const Color.fromARGB(255, 255, 255, 255),
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
                      keyboardType:
                          isClickScan ? TextInputType.none : TextInputType.text,
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
                          onFilter();
                        }
                      },
                      onFieldSubmitted: (barcode) =>
                          _handleScanSubmitted(barcode, _focusNode),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 12),
                        hintText: 'Serial Number...',
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
                        fillColor: const Color.fromARGB(255, 255, 255, 255),
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
                        color: const Color.fromARGB(255, 255, 255, 255),
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

            const Divider(thickness: 0.001, height: 25),

            // Table Header
            Container(
              padding: const EdgeInsets.fromLTRB(30, 15, 15, 15),
              color: Colors.white,
              child: const Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: Text(
                      'Serial Number',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(thickness: 0.001, height: 7),

            // List
            Expanded(
              child: displayList.isEmpty
                  ? const Center(
                      child: Text(
                      "No Serial Found",
                      style: TextStyle(fontSize: 14),
                    ))
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: displayList.length,
                      itemBuilder: (context, index) {
                        final serial = displayList[index];
                        return Container(
                          padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
                          margin: const EdgeInsets.only(bottom: 8),
                          color: Colors.white,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // ✅ Left section (Checkbox + Info)
                              Expanded(
                                flex: 6,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 7.0),
                                      child: Checkbox(
                                        value: selectedIndices.contains(index),
                                        onChanged: (val) =>
                                            _onSelected(val, index),
                                        checkColor: Colors.white,
                                        activeColor: PRIMARY_COLOR,
                                      ),
                                    ),
                                    // ✅ Info Section
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Batch Serial
                                          Text(
                                            getDataFromDynamic(
                                                serial["Batch_Serial"]),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 12, // dynamic
                                            ),
                                            softWrap: true,
                                            overflow: TextOverflow.visible,
                                          ),
                                          const SizedBox(height: 8),

                                          // Bin Code
                                          Text(
                                            getDataFromDynamicBin(
                                                serial["BinCode"]),
                                            style: TextStyle(
                                              fontSize: 12, // dynamic
                                              color: Colors.black87,
                                            ),
                                            softWrap: true,
                                            overflow: TextOverflow.visible,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // ✅ Right Section (Quantity)
                              // Expanded(
                              //   flex: 2,
                              //   child: Align(
                              //     alignment: Alignment.centerRight,
                              //     child: Text(
                              //       getDataFromDynamic(serial["Quantity"]),
                              //       style: TextStyle(
                              //         fontSize: 12, // dynamic
                              //         fontWeight: FontWeight.w500,
                              //       ),
                              //       textAlign: TextAlign.right,
                              //       softWrap: true,
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      // ✅ Done Button
      bottomNavigationBar: Container(
        height: 70,
        padding: const EdgeInsets.all(12),
        color: const Color.fromARGB(255, 243, 243, 243),
        child: Row(
          children: [
            // const SizedBox(width: 12),
            Expanded(
              child: Button(
                bgColor: PRIMARY_COLOR,
                variant: ButtonVariant.primary,
                onPressed: _onDone,
                child:
                    const Text('Done', style: TextStyle(color: Colors.white)),
              ),
            ),
            // const Expanded(child: SizedBox()),
            // const Expanded(child: SizedBox()),
            // const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}
