import 'package:flutter/material.dart';
import 'package:wms_mobile/helper/helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wms_mobile/constant/style.dart';
import 'package:wms_mobile/feature/bin_location/presentation/cubit/bin_offline_cubit.dart';
import 'package:wms_mobile/feature/inbound/good_receipt/presentation/cubit/goods_receipt_offline_cubit.dart';
import 'package:wms_mobile/feature/inbound/put_away/presentation/cubit/put_away_offline_cubit.dart';
import 'package:wms_mobile/feature/warehouse/presentation/cubit/warhouse_offline_cubit.dart';

class SyncLogPutAwayScreen extends StatelessWidget {
  const SyncLogPutAwayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<PutAwayOfflineCubit>();
    final failed =
        cubit.failedRecords.map((e) => {...e, "status": "failed"}).toList();
    final success =
        cubit.successRecords.map((e) => {...e, "status": "success"}).toList();
    final loginFail = cubit.loginFail;
    final loginFailTime = cubit.loginFailTime;

    // Combine and sort by timestamp (latest first)
    final allRecords = [...failed, ...success]..sort((a, b) {
        final aTime = DateTime.tryParse(a["timestamp"] ?? "") ?? DateTime(0);
        final bTime = DateTime.tryParse(b["timestamp"] ?? "") ?? DateTime(0);
        return bTime.compareTo(aTime);
      });
    String formattedTime = '-';
    final parsedDate = DateTime.tryParse(loginFailTime);
    if (parsedDate != null) {
      formattedTime = DateFormat("yyyy, MMM d - h:mma").format(parsedDate);
    }
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: PRIMARY_COLOR,
        centerTitle: true,
        title: const Text(
          "Sync Log",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
        ),
        elevation: 3,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear All Logs'),
                  content: const Text(
                      'Are you sure you want to clear all sync logs?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        cubit.clearCachLog();
                      },
                      child: const Text('Clear',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: allRecords.isEmpty
          ? const Center(
              child: Text(
                "No sync records.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : loginFail != ""
              ? Container(
                  height: 290,
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color.fromARGB(255, 250, 248, 248),
                      width: 1,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 3,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.warning,
                            size: 18,
                            color: Colors.redAccent,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            "Failed Login to SAP :",
                            style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Timestamp : $formattedTime",
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Text(
                          loginFail,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: allRecords.length,
                  itemBuilder: (context, index) {
                    final record = allRecords[index];
                    final lines = record['StockTransferLines'] ?? [];
                    final status = record["status"];
                    final timeStamp = record["timestamp"];

                    // Format timestamp
                    String formattedTime = '-';
                    final parsedDate = DateTime.tryParse(timeStamp ?? '');
                    if (parsedDate != null) {
                      formattedTime =
                          DateFormat("yyyy, MMM d - h:mma").format(parsedDate);
                    }

                    // Status color/icon
                    final isFailed = status == "failed";
                    final icon = isFailed
                        ? Icons.error_outline
                        : Icons.check_circle_outline;
                    final color = isFailed ? Colors.redAccent : Colors.green;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10), // rounded corners
                        side: BorderSide(
                          color: const Color.fromARGB(
                              255, 233, 236, 237), // border color
                          width: 1, // border thickness
                        ),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // --- Header Row (timestamp + icon)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Timestamp : $formattedTime",
                                  style: const TextStyle(
                                      fontSize: 13, color: Colors.grey),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(Icons.close,
                                          color: Colors.grey, size: 20),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Remove Log'),
                                            content: const Text(
                                                'Are you sure you want to remove this log?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  if (record['logId'] != null) {
                                                    cubit.removeMemoryLog(
                                                        record['logId']);
                                                  }
                                                },
                                                child: const Text('Remove',
                                                    style: TextStyle(
                                                        color: Colors.red)),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () {
                                        showJsonDialog(context, record);
                                      },
                                      child: Icon(icon, color: color, size: 20),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 7),

                            // --- Partner + Warehouse

                            // Text(
                            //   "Warehouse : ${record['FromWarehouse'] ?? '-'}",
                            //   style: const TextStyle(
                            //       fontSize: 13, color: Colors.black54),
                            // ),
                            Row(
                              children: [
                                Text(
                                  "Warehouse :",
                                  style: const TextStyle(
                                      fontSize: 13, color: Colors.black54),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Builder(
                                    builder: (context) {
                                      final whsList = context
                                          .read<WarehouseOfflineCubit>()
                                          .state;
                                      final code =
                                          record['FromWarehouse'] ?? '';
                                      var name = '';
                                      if (code.isNotEmpty) {
                                        try {
                                          final whs = whsList.firstWhere((w) =>
                                              w['WarehouseCode'] == code);
                                          name = whs['WarehouseName'] ?? '';
                                        } catch (_) {}
                                      }
                                      final display = (name.isNotEmpty)
                                          ? name
                                          : (code.isNotEmpty ? code : '-');
                                      return Text(
                                        display,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Remark : ${record['Comments'] ?? '-'}",
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.black54),
                            ),
                            const SizedBox(height: 10),
                            // --- Items list
                            const Text(
                              "Items:",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                            const SizedBox(height: 4),

                            ...lines.map<Widget>((line) {
                              final binAllocations =
                                  line['StockTransferLinesBinAllocations'];
                              final sBinAbsEntry = (binAllocations != null &&
                                      binAllocations.isNotEmpty &&
                                      binAllocations[0]?['BinAbsEntry'] != null)
                                  ? binAllocations[0]['BinAbsEntry']
                                  : null;
                              final tBinAbsEntry = (binAllocations != null &&
                                      binAllocations.isNotEmpty &&
                                      binAllocations[1]?['BinAbsEntry'] != null)
                                  ? binAllocations[1]['BinAbsEntry']
                                  : null;
                              final binCubit = context.read<BinOfflineCubit>();
                              final sbin = binCubit.state.firstWhere(
                                (u) =>
                                    u['AbsEntry'] ==
                                    int.tryParse(sBinAbsEntry.toString()),
                                orElse: () =>
                                    {}, // return empty map if not found
                              );
                              final tbin = binCubit.state.firstWhere(
                                (u) =>
                                    u['AbsEntry'] ==
                                    int.tryParse(tBinAbsEntry.toString()),
                                orElse: () =>
                                    {}, // return empty map if not found
                              );

                              final displaySBin = sbin['BinCode'] ?? '';
                              final displayTBin = tbin['BinCode'] ?? '';
                              return Container(
                                padding: EdgeInsets.only(top: 3, bottom: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: const Border(
                                    bottom: BorderSide(
                                      color: Color.fromARGB(
                                          255, 218, 216, 216), // border color
                                      width: 1, // thickness
                                    ),
                                  ),
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              line['ItemDescription'] ??
                                                  line['ItemCode'] ??
                                                  '-',
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black),
                                            ),
                                            const SizedBox(height: 5),
                                            Row(
                                              children: [
                                                Text(
                                                  "UoM Code  :",
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
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  "Source Bin  :",
                                                  style: const TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.black54),
                                                ),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    displaySBin,
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
                                            SizedBox(
                                              height: 7,
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  "To Bin          :",
                                                  style: const TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.black54),
                                                ),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    displayTBin,
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
                                          ],
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
                                ),
                              );
                            }).toList(),

                            // Divider(
                            //   height: 18,
                            //   thickness: 0.8,
                            //   color: Colors.grey,
                            // ),
                            SizedBox(
                              height: 10,
                            ),
                            // --- Status Message
                            if (isFailed)
                              Text(
                                "❌ Error: ${record['error'] ?? 'Unknown error'}",
                                style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500),
                              )
                            else
                              const Text(
                                "Synced successfully",
                                style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      children: [
        Text(
          "$label :",
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
