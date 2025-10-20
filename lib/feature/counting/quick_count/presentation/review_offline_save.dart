import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wms_mobile/constant/style.dart';
import 'package:wms_mobile/feature/bin_location/presentation/cubit/bin_offline_cubit.dart';
import 'package:wms_mobile/feature/counting/quick_count/presentation/cubit/quick_count_offline_cubit.dart';
import 'package:wms_mobile/feature/inbound/good_receipt/presentation/cubit/goods_receipt_offline_cubit.dart';
import 'package:wms_mobile/feature/outbounce/good_issue/presentation/cubit/goods_issue_offline_cubit.dart';

class ReviewQuickCountOfflineSave extends StatelessWidget {
  const ReviewQuickCountOfflineSave({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: PRIMARY_COLOR,
        centerTitle: true,
        title: const Text(
          "Data Saved",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        elevation: 3,
      ),
      body: BlocBuilder<QuickCountOfflineCubit, List<dynamic>>(
        builder: (context, records) {
          if (records.isEmpty) {
            return const Center(
              child: Text(
                "No saved records.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: records.length,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (context, index) {
              final record = records[index];
              final lines = record['InventoryPostingLines'] ?? [];
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
                                  _buildRow("Goods Receipt Type",
                                      record['U_lk_gitype'] ?? 'N/A'),
                                  const SizedBox(height: 5),
                                  _buildRow("Warehouse",
                                      record['U_lk_whsdesc'] ?? ''),
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

                                    final bin = binCubit.state.firstWhere(
                                      (u) =>
                                          u['AbsEntry'] ==
                                          int.tryParse(
                                              (line["BinEntry"] ?? -1).toString()),
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
                                                "Qty: ${line['CountedQuantity'] ?? '0'}",
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
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "No. ${index + 1}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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
          width: 140,
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
