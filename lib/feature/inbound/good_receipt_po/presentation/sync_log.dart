import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wms_mobile/feature/inbound/good_receipt_po/presentation/cubit/good_receipt_po_offline_cubit.dart';

class SyncLogScreen extends StatelessWidget {
  const SyncLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GoodReceiptPoOfflineCubit>();
    final failed = cubit.failedRecords;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sync Log"),
        backgroundColor: Colors.blueAccent,
      ),
      body: failed.isEmpty
          ? const Center(
              child: Text(
                "✅ No failed sync records.",
                style: TextStyle(fontSize: 16, color: Colors.green),
              ),
            )
          : ListView.builder(
              itemCount: failed.length,
              itemBuilder: (context, index) {
                final record = failed[index];
                final lines = record['DocumentLines'] ?? [];
                final timeStamp = failed[index]["timestamp"];
                String formattedTime = '';
                if (timeStamp != null && timeStamp.toString().isNotEmpty) {
                  final parsedDate = DateTime.parse(timeStamp);
                  formattedTime =
                      DateFormat("yyyy, MMMM, d, h:mma").format(parsedDate);
                }
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Header info ---
                        Text(
                          "Time Stamp: $formattedTime",
                          style: const TextStyle(fontSize: 14),
                        ),
                        SizedBox(
                          height: 7,
                        ),
                        Text(
                          "Business Partner: ${record['CardCode'] ?? '-'} (${record['CardName'] ?? ''})",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          "Warehouse: ${record['WarehouseCode'] ?? '-'}",
                          style: const TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 8),

                        // --- DocumentLines ---
                        const Text(
                          "Items:",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        ...lines.map<Widget>((line) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    line['ItemDescription'] ??
                                        line['ItemCode'] ??
                                        '-',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                Text(
                                  "Qty: ${line['Quantity'] ?? '0'}",
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          );
                        }).toList(),

                        const Divider(height: 16),

                        // --- Error info ---
                        Text(
                          "❌ Error: ${record['error'] ?? 'Unknown error'}",
                          style: const TextStyle(
                              color: Colors.redAccent, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
