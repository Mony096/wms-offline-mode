

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_mobile/core/enum/global.dart';
import 'package:wms_mobile/feature/business_partner/presentation/cubit/bussinessPartner_offline_cubit.dart';
import 'package:wms_mobile/feature/inbound/return_receipt_request/presentation/cubit/return_receipt_request_offline_cubit.dart';
import 'package:wms_mobile/helper/helper.dart';
import 'package:wms_mobile/utilies/dialog/dialog.dart';
import '/constant/style.dart';

class ReturnReceiptRequestPage extends StatefulWidget {
  const ReturnReceiptRequestPage({super.key, required this.type});

  final BusinessPartnerType type;

  @override
  State<ReturnReceiptRequestPage> createState() =>
      _ReturnReceiptRequestPageState();
}

class _ReturnReceiptRequestPageState extends State<ReturnReceiptRequestPage> {
  final TextEditingController filter = TextEditingController();
  List<dynamic> filteredData = [];

  @override
  void initState() {
    super.initState();
    // Initial filter on load
    final offlineData = context.read<ReturnReceiptRequestOfflineCubit>().state;
    _applyFilter(offlineData);
  }

  void _applyFilter(List<dynamic> allData) {
    final searchText = filter.text.trim().toLowerCase();
    final cardType = _mapType(widget.type);

    final results = allData.where((bp) {
      // final typeMatch =
      //     getDataFromDynamic(bp['CardType']).toString().toLowerCase() ==
      //         cardType.toLowerCase();
      final code = getDataFromDynamic(bp['CardCode']).toLowerCase();
      final name = getDataFromDynamic(bp['CardName']).toLowerCase();

      // if (searchText.isEmpty) return typeMatch;
      return (code.contains(searchText) || name.contains(searchText));
    }).toList();

    setState(() => filteredData = results);
    debugPrint(
        "🔎 Filter: '$searchText', type: '$cardType' → ${filteredData.length} results");
  }

  // Map enum to SAP CardType
  String _mapType(BusinessPartnerType type) {
    switch (type) {
      case BusinessPartnerType.customer:
        return "cCustomer"; // or 'C' depending on your API data
      case BusinessPartnerType.supplier:
        return "cSupplier";
      default:
        return "";
    }
  }

  void onFilterPressed() {
    final allData = context.read<ReturnReceiptRequestOfflineCubit>().state;
    _applyFilter(allData);
  }

  void onPressed(dynamic bp) async {
    try {
      MaterialDialog.loading(context);
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        MaterialDialog.close(context);
        Navigator.pop(context, bp);
      }
    } catch (_) {
      if (mounted) {
        MaterialDialog.success(context,
            title: 'Invalid', body: 'Return Receipt Request not found.');
      }
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
            padding: EdgeInsets.only(right: 70),
            child: Text(
              "Return Request Lists",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            const SizedBox(height: 10),
            // 🔍 Search Bar
            Container(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: filter,
                      decoration: InputDecoration(
                        hintText: 'Search Return Request',
                        filled: true,
                        fillColor: const Color.fromARGB(255, 243, 243, 243),
                        prefixIcon: Icon(Icons.search, color: PRIMARY_COLOR),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.grey.shade300, width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.grey.shade300, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: PRIMARY_COLOR, width: 0.2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: PRIMARY_COLOR,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon:
                          const Icon(Icons.arrow_forward, color: Colors.white),
                      onPressed: onFilterPressed,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // 🧾 Offline Business Partner List
            Expanded(
              child:
                  BlocBuilder<ReturnReceiptRequestOfflineCubit, List<dynamic>>(
                builder: (context, state) {
                  // final allData = state;
                  // if (filteredData.isEmpty && filter.text.isEmpty) {
                  //   _applyFilter(allData);
                  // }

                  // if (filteredData.isEmpty) {
                  //   return const Center(
                  //     child: Text("No matching business partners found."),
                  //   );
                  // }
                  // Apply filter only once after first frame
                  if (filteredData.isEmpty && filter.text.isEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _applyFilter(state);
                    });
                  }

                  if (filteredData.isEmpty) {
                    return const Center(
                      child: Text("No matching Receipt Request found."),
                    );
                  }
                  return ListView.builder(
                    itemCount: filteredData.length,
                    itemBuilder: (context, index) {
                      final bp = filteredData[index];
                      return GestureDetector(
                        onTap: () => onPressed(bp),
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 243, 243, 243),
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
                                    getDataFromDynamic(bp['CardCode']),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    'Date : ${getDataFromDynamic(bp['DocDate'], isDate: true)}',
                                    style: const TextStyle(
                                        fontSize: 13.5, color: Colors.black54),
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
                                      getDataFromDynamic(bp['CardName']),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 30),
                                  Text(
                                    'Return Date : ${getDataFromDynamic(bp['DocDueDate'], isDate: true)}'
                                    ,
                                    style: const TextStyle(
                                        fontSize: 13.5, color: Colors.black54),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
