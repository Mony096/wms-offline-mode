import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wms_mobile/feature/inbound/good_receipt_po/presentation/cubit/good_receipt_po_offline_cubit.dart';

class ReviewOfflineSave extends StatelessWidget {
  const ReviewOfflineSave({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Saved Records"),
        backgroundColor: Colors.blueAccent,
        elevation: 3,
      ),
      body: BlocBuilder<GoodReceiptPoOfflineCubit, List<dynamic>>(
        builder: (context, records) {
          if (records.isEmpty) {
            return const Center(
              child: Text(
                "✅ No saved or failed records.",
                style: TextStyle(fontSize: 16, color: Colors.green),
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

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(
                    color: Color.fromARGB(255, 215, 212, 212), // Border color
                    width: 0.5, // Border width
                  ),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔹 Timestamp
                      if (formattedTime.isNotEmpty)
                        Text(
                          "📅 $formattedTime",
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      const SizedBox(height: 6),

                      // 🔹 Header Info
                      Row(
                        children: [
                          SizedBox(
                            width: 110,
                            child: SizedBox(
                              width: 122,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Supplier Code",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Text(
                                    ":",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Text(
                            " ${record['CardCode'] ?? ''}",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 110,
                            child: SizedBox(
                              width: 122,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Supplier Name",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Text(
                                    ":",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Text(
                            " ${record['CardName'] ?? ''}",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          SizedBox(
                            width: 110,
                            child: SizedBox(
                              width: 122,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Warehouse",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Text(
                                    ":",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Text(
                            " ${record['WarehouseCode'] ?? ''}",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 0, top: 3, bottom: 12),
                        child: const Divider(height: 8, color: Colors.black12),
                      ),
                      // 🔹 Items
                      const Text(
                        "Items:",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),

                      ...lines.map<Widget>((line) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 🔹 Row: Item name + Quantity
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),

                              // 🔹 Row: UoM (underneath)
                              if (line['UoMCode'] != null &&
                                  line['UoMCode'].toString().isNotEmpty)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 2, left: 2),
                                  child: Text(
                                    "Unit Of Measurement : ${line['UoMCode']}",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                      // fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),

                              const Divider(height: 8, color: Colors.black12),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
