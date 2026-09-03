import 'package:flutter/material.dart';
import 'package:wms_mobile/feature/warehouse/presentation/cubit/warhouse_offline_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wms_mobile/component/button/button.dart';
import 'package:wms_mobile/constant/style.dart';
import 'package:wms_mobile/feature/bin_location/domain/entity/bin_entity.dart';
import 'package:wms_mobile/feature/bin_location/presentation/cubit/bin_offline_cubit.dart';
import 'package:wms_mobile/feature/counting/bin_count/presentation/create_bin_count_screen.dart';
import 'package:wms_mobile/feature/counting/bin_count/presentation/cubit/bin_count_offline_cubit.dart';
import 'package:wms_mobile/feature/counting/physical_count/presentation/create_physical_count_screen.dart';
import 'package:wms_mobile/feature/counting/physical_count/presentation/cubit/physical_count_offline_cubit.dart';
import 'package:wms_mobile/feature/counting/quick_count/presentation/create_quick_count_screen.dart';
import 'package:wms_mobile/feature/counting/quick_count/presentation/cubit/quick_count_offline_cubit.dart';
import 'package:wms_mobile/helper/helper.dart';

class BinCountLists extends StatefulWidget {
  const BinCountLists({super.key});

  @override
  State<BinCountLists> createState() => _BinCountListsState();
}

class _BinCountListsState extends State<BinCountLists> {
  List<dynamic> data = [];
  List<dynamic> filteredData = [];
  final TextEditingController _filter = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Listen to filter changes
    // _filter.addListener(() {
    //   final text = _filter.text.toLowerCase();
    //   setState(() {
    //     filteredData = data
    //         .where((bin) =>
    //             bin.code.toLowerCase().contains(text) ||
    //             bin.subLevel1.toLowerCase().contains(text))
    //         .toList();
    //   });
    // });

    // Load data from offline cubit
    final offlineCubit = context.read<BinCountOfflineCubit>();
    final offlineData = offlineCubit.state;
    print(offlineData);
    //     .where((e) => e['Warehouse'] == widget.warehouse)
    //     .map((e) => BinEntity(
    //           code: e['BinCode'],
    //           warehouse: e['Warehouse'],
    //           subLevel1: e['Sublevel1'],
    //           id: e['AbsEntry'],
    //         ))
    //     .toList();

    setState(() {
      // data = offlineCubit.state;
      filteredData = offlineData;
    });
  }

  @override
  void dispose() {
    _filter.dispose();
    super.dispose();
  }

  Future<void> _removeById(BuildContext context, dynamic id) async {
    // 1️⃣ Clear all Cubits
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
          "Delete this data ?",
          style: TextStyle(fontSize: 19),
        ),
        content: const Text(
          "This will delete this offline data. Are you sure?",
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
    context.read<BinCountOfflineCubit>().removeByFailId(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white, //change your color here
        ),
        backgroundColor: PRIMARY_COLOR,
        title: Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 65),
            child: const Text(
              'Bin Count Saved',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white),
            ),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color.fromRGBO(255, 255, 255, 1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 10),

            // Column(
            //   children: [
            //     Padding(
            //       padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            //       child: Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         children: [
            //           Row(
            //             children: [
            //               Icon(Icons.bookmark, color: PRIMARY_COLOR, size: 27),
            //               SizedBox(
            //                 width: 7,
            //               ),
            //               const Text(
            //                 "Quick Count Saved",
            //                 style: TextStyle(
            //                     fontSize: 18, fontWeight: FontWeight.bold),
            //               ),
            //             ],
            //           ),
            //           const SizedBox(width: 20),
            //           Container(
            //             width: 120,
            //             height: 40,
            //             margin: EdgeInsets.fromLTRB(0, 15, 0, 20),
            //             child: Button(
            //               bgColor: PRIMARY_COLOR,
            //               onPressed: () {
            //                 goTo(context,
            //                     CreateQuickCountScreen(isQuickCount: true));
            //               },
            //               child: Text(
            //                 "New",
            //                 style: TextStyle(
            //                   color: Colors.white,
            //                 ),
            //               ),
            //             ),
            //           )

            //         ],
            //       ),
            //     ),
            //     Container(
            //       margin: const EdgeInsets.only(left: 20,right: 20),
            //       decoration: BoxDecoration(
            //         color: Colors.grey[100],
            //         borderRadius: BorderRadius.circular(12),
            //         border: Border.all(color: Colors.grey[300]!),
            //       ),
            //       child: TextField(
            //         controller: _filter,
            //         decoration: InputDecoration(
            //           prefixIcon: const Icon(Icons.search),
            //           hintText: 'Search...',
            //           suffixIcon: _filter.text.isNotEmpty
            //               ? IconButton(
            //                   icon: const Icon(Icons.clear),
            //                   onPressed: () {
            //                     _filter.clear();
            //                     setState(() {
            //                       filteredData = data;
            //                     });
            //                   },
            //                 )
            //               : null,
            //           border: InputBorder.none,
            //           contentPadding: const EdgeInsets.symmetric(vertical: 13),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),

            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.bookmark, color: PRIMARY_COLOR, size: 27),
                      SizedBox(
                        width: 7,
                      ),
                      const Text(
                        "Data Listing",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Container(
                    width: 110,
                    height: 40,
                    margin: EdgeInsets.fromLTRB(0, 15, 0, 20),
                    child: Button(
                      bgColor: PRIMARY_COLOR,
                      onPressed: () {
                        goTo(context, CreateBinCountScreen());
                      },
                      child: Row(
                        children: [
                          Icon(Icons.add, color: Colors.white),
                          SizedBox(width: 6),
                          Text(
                            "New",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),

            Expanded(
              child: BlocBuilder<BinCountOfflineCubit, List<dynamic>>(
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
                      final lines = record['InventoryCountingLines'] ?? [];
                      final timestamp = record["timestamp"];

                      String formattedTime = '';
                      if (timestamp != null &&
                          timestamp.toString().isNotEmpty) {
                        try {
                          final parsedDate = DateTime.parse(timestamp);
                          formattedTime = DateFormat("yyyy, MMM d • h:mma")
                              .format(parsedDate);
                        } catch (_) {
                          formattedTime = timestamp.toString();
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // 🔹 Card container
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color:
                                      const Color.fromARGB(255, 215, 212, 212),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          (() {
                                            final code =
                                                record['InventoryCountingLines']
                                                            ?[0]
                                                        ?["WarehouseCode"] ??
                                                    '';
                                            final whsList = context
                                                .read<WarehouseOfflineCubit>()
                                                .state;
                                            final whs = whsList.firstWhere(
                                              (w) => w['WarehouseCode'] == code,
                                              orElse: () => null,
                                            );
                                            final name = (whs != null &&
                                                    whs['WarehouseName'] !=
                                                        null &&
                                                    whs['WarehouseName']
                                                        .toString()
                                                        .trim()
                                                        .isNotEmpty)
                                                ? whs['WarehouseName']
                                                    .toString()
                                                    .trim()
                                                : code;
                                            return _buildRow("Warehouse", name);
                                          })(),
                                          const Padding(
                                            padding: EdgeInsets.only(
                                                left: 0, top: 3, bottom: 12),
                                            child: Divider(
                                                height: 8,
                                                color: Colors.black12),
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

                                            final bin =
                                                binCubit.state.firstWhere(
                                              (u) =>
                                                  u['AbsEntry'] ==
                                                  int.tryParse(line["BinEntry"]
                                                      .toString()),
                                              orElse: () =>
                                                  {}, // return empty map if not found
                                            );

                                            final displayBin =
                                                bin['BinCode'] ?? '';
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 4),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          line['ItemDescription'] ??
                                                              line[
                                                                  'ItemCode'] ??
                                                              '-',
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 14),
                                                        ),
                                                      ),
                                                      Text(
                                                        "Qty: ${formatQuantity(line['CountedQuantity'] ?? '0')}",
                                                        style: const TextStyle(
                                                          fontSize: 13,
                                                          color: Colors.black87,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  if (line['UoMCode'] != null &&
                                                      line['UoMCode']
                                                          .toString()
                                                          .isNotEmpty)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 2, left: 2),
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            "UoM Code     :",
                                                            style: const TextStyle(
                                                                fontSize: 13,
                                                                color: Colors
                                                                    .black54),
                                                          ),
                                                          const SizedBox(
                                                              width: 4),
                                                          Expanded(
                                                            child: Text(
                                                              line['UoMCode'],
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: Colors
                                                                    .black87,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  if (displayBin != "")
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 2, left: 2),
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            "Bin Location :",
                                                            style: const TextStyle(
                                                                fontSize: 13,
                                                                color: Colors
                                                                    .black54),
                                                          ),
                                                          const SizedBox(
                                                              width: 4),
                                                          Expanded(
                                                            child: Text(
                                                              displayBin,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: Colors
                                                                    .black87,
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
                                                      height: 8,
                                                      color: Colors.black12),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                          SizedBox(
                                            height: 6,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Align(
                                                alignment: Alignment.topRight,
                                                child: Material(
                                                  color: Colors.transparent,
                                                  child: InkWell(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    onTap: () {
                                                      _removeById(context,
                                                          record['SaveId']);
                                                    },
                                                    child: Ink(
                                                      width: 90,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8,
                                                          vertical: 6),
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: Colors
                                                                .redAccent,
                                                            width: 1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        color:
                                                            Colors.transparent,
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: const [
                                                          Icon(
                                                            Icons.remove,
                                                            size: 22,
                                                            color: Colors
                                                                .redAccent,
                                                          ),
                                                          SizedBox(width: 6),
                                                          Text(
                                                            "Delete",
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .redAccent,
                                                              // fontWeight:
                                                              //     FontWeight
                                                              //         .bold,
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
                                                  color: Colors.transparent,
                                                  child: InkWell(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    onTap: () {
                                                      goTo(
                                                        context,
                                                        CreateBinCountScreen(
                                                          isEdit: record,
                                                        ),
                                                      );
                                                    },
                                                    child: Ink(
                                                      width: 90,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8,
                                                          vertical: 6),
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color:
                                                                PRIMARY_COLOR,
                                                            width: 1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        color:
                                                            Colors.transparent,
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons.edit,
                                                            size: 22,
                                                            color:
                                                                PRIMARY_COLOR,
                                                          ),
                                                          const SizedBox(
                                                              width: 6),
                                                          Text(
                                                            "Edit",
                                                            style: TextStyle(
                                                              color:
                                                                  PRIMARY_COLOR,
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
                                              )
                                            ],
                                          ),
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
            ),
          ],
        ),
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
