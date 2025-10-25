import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wms_mobile/constant/style.dart';
import 'package:wms_mobile/feature/bin_location/presentation/cubit/bin_offline_cubit.dart';
import 'package:wms_mobile/feature/inbound/good_receipt_po/presentation/create_good_receipt_screen.dart';
import 'package:wms_mobile/feature/inbound/good_receipt_po/presentation/cubit/quick_good_receipt_failed_offline_cubit.dart';
import 'package:wms_mobile/feature/inbound/good_receipt_po/presentation/cubit/quick_good_receipt_offline_cubit.dart';
import 'package:wms_mobile/helper/helper.dart';

class SyncFailLogCycleScreen extends StatelessWidget {
  const SyncFailLogCycleScreen({super.key});
  Future<void> _clearAllData(BuildContext context) async {
    // 1️⃣ Clear all Cubits
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Clear Failed Data?"),
        content: const Text(
            "This will remove all offline failed data. Are you sure?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Clear",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    // User canceled
    if (confirm != true) return;
    context.read<QuickGoodReceiptFailedOfflineCubit>().clearData();
  }

  Future<void> _removeById(BuildContext context, dynamic id) async {
    // 1️⃣ Clear all Cubits
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
          "Remove this data ?",
          style: TextStyle(fontSize: 19),
        ),
        content: const Text(
          "This will remove this offline failed data. Are you sure?",
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Ok",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    // User canceled
    if (confirm != true) return;
    context.read<QuickGoodReceiptFailedOfflineCubit>().removeByFailId(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: PRIMARY_COLOR,
        centerTitle: true,
        title: const Text(
          "Failed Cycle Counting",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.refresh),
          //   tooltip: 'Reset Status',
          //   onPressed: _resetSyncStatus,
          // ),

          IconButton(
            icon: const Icon(
              Icons.delete,
              color: Colors.white,
              size: 25,
            ),
            tooltip: 'Clear Data',
            onPressed: () => _clearAllData(context),
          ),
          SizedBox(
            width: 10,
          )
        ],
        elevation: 3,
      ),
      body: BlocBuilder<QuickGoodReceiptFailedOfflineCubit, List<dynamic>>(
        builder: (context, records) {
          if (records.isEmpty) {
            return const Center(
              child: Text(
                "No faild records.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: records.length,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (context, index) {
              final record = records[index];
              final lines = record['DocumentLines'] ?? [];
              final timestamp = record["timestamp"];

              String formattedTime = '';
              if (timestamp != null && timestamp.toString().isNotEmpty) {
                try {
                  final parsedDate = DateTime.parse(timestamp);
                  formattedTime =
                      DateFormat("yyyy, MMM d • h:mma").format(parsedDate);
                } catch (_) {
                  formattedTime = timestamp.toString();
                }
              }

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // 🔹 Card container
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color.fromARGB(255, 215, 212, 212),
                          width: 0.5,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          )
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🔹 Left border (fixed height now)
                          Container(
                            width: 3,
                            decoration: BoxDecoration(
                              color: PRIMARY_COLOR,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                bottomLeft: Radius.circular(8),
                              ),
                            ),
                          ),

                          // 🔹 Main content
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Timestamp: $formattedTime",
                                    style: const TextStyle(
                                        fontSize: 13, color: Colors.redAccent),
                                  ),
                                  const SizedBox(height: 5),
                                  _buildRow("Supplier Code",
                                      record['CardCode'] ?? 'N/A'),
                                  const SizedBox(height: 5),
                                  _buildRow("Supplier Name",
                                      record['CardName'] ?? 'N/A'),
                                  const SizedBox(height: 5),
                                  _buildRow("Warehouse",
                                      record['WarehouseCode'] ?? ''),
                                  const Padding(
                                    padding: EdgeInsets.only(
                                        left: 0, top: 3, bottom: 12),
                                    child: Divider(
                                        height: 8, color: Colors.black12),
                                  ),
                                  const Text(
                                    "Items:",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  ...lines.map<Widget>((line) {
                                    final binCubit =
                                        context.read<BinOfflineCubit>();

                                    // Try to extract BinAbsEntry safely
                                    final binAllocations =
                                        line['DocumentLinesBinAllocations'];
                                    final binAbsEntry = (binAllocations !=
                                                null &&
                                            binAllocations.isNotEmpty &&
                                            binAllocations[0]?['BinAbsEntry'] !=
                                                null)
                                        ? binAllocations[0]['BinAbsEntry']
                                        : null;

                                    final bin = binCubit.state.firstWhere(
                                      (u) =>
                                          u['AbsEntry'] ==
                                          int.tryParse(binAbsEntry.toString()),
                                      orElse: () =>
                                          {}, // return empty map if not found
                                    );

                                    final displayBin = bin['BinCode'] ?? '';
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  line['ItemDescription'] ??
                                                      line['ItemCode'] ??
                                                      '-',
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ),
                                              Text(
                                                "Qty: ${line['Quantity'] ?? '0'}",
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (line['UoMCode'] != null &&
                                              line['UoMCode']
                                                  .toString()
                                                  .isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 2, left: 2),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    "UoM Code     :",
                                                    style: const TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.black54),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      line['UoMCode'],
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          if (displayBin != "")
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 2, left: 2),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    "Bin Location :",
                                                    style: const TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.black54),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      displayBin,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          SizedBox(
                                            height: 2,
                                          ),
                                          const Divider(
                                              height: 8, color: Colors.black12),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Align(
                                                alignment: Alignment.topRight,
                                                child: Material(
                                                  color: Colors
                                                      .transparent, // keep background transparent outside the button
                                                  child: InkWell(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    onTap: () {
                                                      _removeById(context,
                                                          record['SaveId']);
                                                    },
                                                    child: Ink(
                                                      width: 100,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8,
                                                          vertical: 8),
                                                      decoration: BoxDecoration(
                                                        color: Colors.redAccent,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                      child: Row(
                                                        children: const [
                                                          Icon(
                                                            Icons.remove,
                                                            size: 22,
                                                            color: Colors.white,
                                                          ),
                                                          SizedBox(width: 6),
                                                          Text(
                                                            "Remove",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Align(
                                                alignment: Alignment.topRight,
                                                child: Material(
                                                  color: Colors
                                                      .transparent, // keep background transparent outside the button
                                                  child: InkWell(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    onTap: () {
                                                      goTo(
                                                          context,
                                                          CreateGoodReceiptPOScreen(
                                                              isEdit: record,
                                                              isEditFaildQGR:
                                                                  true,
                                                              quickReceipt:
                                                                  true));
                                                    },
                                                    child: Ink(
                                                      width: 117,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8,
                                                          vertical: 8),
                                                      decoration: BoxDecoration(
                                                        color: Colors.green,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                      child: Row(
                                                        children: const [
                                                          Icon(
                                                            Icons.edit,
                                                            size: 22,
                                                            color: Colors.white,
                                                          ),
                                                          SizedBox(width: 6),
                                                          Text(
                                                            "Resync Data",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 🔹 Index Badge
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          // color: const Color.fromARGB(255, 195, 194, 194),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          "No. ${index + 1}",
                          style: const TextStyle(
                            color: Color.fromARGB(255, 130, 126, 126),
                            // fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 13.5, color: Colors.black54),
              ),
              const Text(":", style: TextStyle(color: Colors.black54)),
            ],
          ),
        ),
        Expanded(
          child: Text(
            " $value",
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
