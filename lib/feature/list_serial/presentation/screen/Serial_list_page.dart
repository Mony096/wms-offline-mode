// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// // import 'package:iscan_data_plugin/iscan_data_plugin.dart';
// import 'package:wms_mobile/component/button/button.dart';
// import 'package:wms_mobile/feature/list_serial/presentation/cubit/serialNumber_list_cubit.dart';
// import 'package:wms_mobile/helper/helper.dart';
// import 'package:wms_mobile/utilies/storage/locale_storage.dart';
// import '../../domain/entity/list_serial_entity.dart';
// import '/constant/style.dart';

// class SerialListPage extends StatefulWidget {
//   const SerialListPage(
//       {super.key,
//       required this.warehouse,
//       required this.itemCode,
//       this.binCode});

//   final String warehouse;
//   final String itemCode;
//   final dynamic binCode;

//   @override
//   State<SerialListPage> createState() => _SerialListPageState();
// }

// class _SerialListPageState extends State<SerialListPage> {
//   final ScrollController _scrollController = ScrollController();

//   String query = "?\$top=10&\$skip=0";
//   int check = 1;
//   List<dynamic> data = [];
//   TextEditingController filter = TextEditingController();

//   late SerialListCubit _bloc;
//   Set<int> selectedIndices = <int>{};
//   bool isFilter = false;

//   bool loading = false;
//   @override
//   void initState() {
//     super.initState();
//     // Initialize controllers
//     try {
//     } catch (e) {
//       print("Error setting method call handler: $e");
//     }
//     init(context);
//   }

//   @override
//   void dispose() {
//     // Dispose controllers
//     super.dispose();
//   }

//   void init(BuildContext context) async {
//     print(widget.binCode);
//     print(widget.itemCode);
//     try {
//       final warehouse = await LocalStorageManger.getString('warehouse');
//       print(warehouse);

//       _bloc = context.read<SerialListCubit>();
//       _bloc
//           .get(
//               "$query&\$filter=ItemCode eq '${widget.itemCode}' ${widget.binCode != "" ? "and AbsEntry eq ${widget.binCode}" : ""} and WhsCode eq '$warehouse'")
//           .then((value) {
//         print(value);
//         if (mounted) {
//           setState(() {
//             data = value;
//             data.sort((a, b) => (a["BinCode"]).compareTo(b["BinCode"]));
//           });
//         }
//       });

//       _scrollController.addListener(() {
//         if (_scrollController.position.pixels ==
//             _scrollController.position.maxScrollExtent) {
//           final state = BlocProvider.of<SerialListCubit>(context).state;
//           if (state is BinData && data.isNotEmpty) {
//             if (isFilter) {
//               _bloc
//                   .next(
//                       "?\$top=10&\$skip=${data.length}&\$filter=ItemCode eq '${widget.itemCode}' ${widget.binCode != "" ? "and BinCode eq '${widget.binCode}'" : ""} and contains(Batch_Serial,'${filter.text}') and WhsCode eq '$warehouse'")
//                   .then((value) {
//                 if (mounted) {
//                   setState(() {
//                     data = [...data, ...value];
//                     // Sort combined list by Bin
//                     data.sort((a, b) => (a["BinCode"]).compareTo(b["BinCode"]));
//                   });
//                 }
//               });
//             } else {
//               _bloc
//                   .next(
//                       "?\$top=10&\$skip=${data.length}&\$filter=ItemCode eq '${widget.itemCode}' ${widget.binCode != "" ? "and BinCode eq '${widget.binCode}'" : ""} and WhsCode eq '$warehouse'")
//                   .then((value) {
//                 if (mounted) {
//                   setState(() {
//                     data = [...data, ...value];
//                     data.sort((a, b) => (a["BinCode"]).compareTo(b["BinCode"]));
//                   });
//                 }
//               });
//             }
//           }
//         }
//       });
//     } catch (err) {
//       print(err);
//     }
//   }

//   void onFilter() async {
//     final warehouse = await LocalStorageManger.getString('warehouse');

//     setState(() {
//       data = [];
//       if (filter.text != "") {
//         isFilter = true;
//       }
//     });
//     _bloc
//         .get(
//       "$query&\$filter=ItemCode eq '${widget.itemCode}' and contains(Batch_Serial,'${filter.text}') ${widget.binCode != "" ? "and BinCode eq '${widget.binCode}'" : ""} and WhsCode eq '$warehouse'",
//     )
//         .then((value) {
//       if (!mounted) return;

//       setState(() {
//         data = value as dynamic;
//         data.sort((a, b) => (a["BinCode"]).compareTo(b["BinCode"]));
//       });
//     });
//   }

//   void _onSelected(bool? selected, int index) {
//     setState(() {
//       if (selected == true) {
//         selectedIndices.add(index);
//       } else {
//         selectedIndices.remove(index);
//       }
//     });
//   }

//   void _onDone() {
//     List<dynamic> selectedData =
//         selectedIndices.map((index) => data[index]).toList();
//     Navigator.of(context).pop(selectedData); // Pass selected data back
//   }

//   void _onChangeQty(String value, int index) {
//     setState(() {
//       data[index]["PickQty"] = value;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // data.sort((a, b) => a["BinCode"].compareTo(b["BinCode"]));
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: PRIMARY_COLOR,
//         iconTheme: IconThemeData(color: Colors.white),
//         title: const Text(
//           'Serial Lists',
//           style: TextStyle(
//               fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
//         ),
//         actions: const [
//           // TextButton(
//           //   onPressed: _onDone,
//           //   child: const Text(
//           //     'Done',
//           //     style: TextStyle(color: Colors.white),
//           //   ),
//           // ),
//         ],
//       ),
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         color: Color.fromARGB(255, 243, 243, 243),
//         child: Column(
//           children: [
//             Container(
//               padding:
//                   const EdgeInsets.only(left: 14, right: 14, bottom: 6, top: 4),
//               width: double.infinity,
//               decoration: BoxDecoration(color: Colors.white),
//               child: Padding(
//                 padding: const EdgeInsets.only(left: 15),
//                 child: TextFormField(
//                   controller: filter,
//                   decoration: InputDecoration(
//                     enabledBorder: UnderlineInputBorder(
//                         borderSide: BorderSide(color: Colors.transparent)),
//                     focusedBorder: UnderlineInputBorder(
//                         borderSide: BorderSide(color: Colors.transparent)),
//                     contentPadding: const EdgeInsets.only(top: 15),
//                     hintText: 'Serial Number...',
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         Icons.search,
//                         color: PRIMARY_COLOR,
//                       ),
//                       onPressed: onFilter,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             const Divider(thickness: 0.001, height: 25),
//             Container(
//               padding: const EdgeInsets.fromLTRB(30, 15, 15, 15),
//               decoration: BoxDecoration(
//                 color: const Color.fromARGB(255, 255, 255, 255),
//                 border: Border(
//                   bottom: BorderSide(width: 0.1),
//                   top: BorderSide(width: 0.1),
//                 ),
//               ),
//               child: Row(
//                 children: const [
//                   Expanded(
//                     flex: 5,
//                     child: Text(
//                       'Serial Number.',
//                       style: TextStyle(
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     flex: 1,
//                     child: Padding(
//                       padding: EdgeInsets.only(left: 5),
//                       child: Text('Qty'),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const Divider(thickness: 0.001, height: 7),
//             Expanded(
//               child: BlocConsumer<SerialListCubit, SerialListState>(
//                 listener: (context, state) {},
//                 builder: (context, state) {
//                   if (state is RequestingBin) {
//                     return Center(child: CircularProgressIndicator());
//                   }

//                   return data.length == 0
//                       ? Column(
//                           children: [
//                             SizedBox(
//                               height: 100,
//                             ),
//                             Container(
//                               child: Text("No Serial"),
//                             ),
//                           ],
//                         )
//                       : ListView(
//                           controller: _scrollController,
//                           children: [
//                             ...data.asMap().entries.map(
//                               (entry) {
//                                 int index = entry.key;
//                                 var Serial = entry.value;
//                                 return GestureDetector(
//                                   child: Container(
//                                     padding: const EdgeInsets.fromLTRB(
//                                         10, 15, 10, 15),
//                                     decoration: BoxDecoration(
//                                       color: Colors.white,
//                                     ),
//                                     margin: const EdgeInsets.only(bottom: 8),
//                                     child: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Expanded(
//                                           flex: 6,
//                                           child: Row(
//                                             children: [
//                                               Padding(
//                                                 padding: const EdgeInsets.only(
//                                                     right: 7),
//                                                 child: Checkbox(
//                                                   value: selectedIndices
//                                                       .contains(index),
//                                                   onChanged: (bool? value) {
//                                                     _onSelected(value, index);
//                                                   },
//                                                   checkColor: Colors
//                                                       .white, // Color of the checkmark
//                                                   activeColor:
//                                                       Colors.green.shade900,
//                                                 ),
//                                               ),
//                                               Column(
//                                                 crossAxisAlignment:
//                                                     CrossAxisAlignment.start,
//                                                 children: [
//                                                   Text(
//                                                     getDataFromDynamic(
//                                                         Serial["Batch_Serial"]),
//                                                     style: TextStyle(
//                                                       fontWeight:
//                                                           FontWeight.w800,
//                                                     ),
//                                                   ),
//                                                   SizedBox(
//                                                     height: 10,
//                                                   ),
//                                                   Text(
//                                                     getDataFromDynamicBin(
//                                                         Serial["BinCode"]),
//                                                     style:
//                                                         TextStyle(fontSize: 13),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                         Expanded(
//                                           flex: 2,
//                                           child: Padding(
//                                             padding:
//                                                 const EdgeInsets.only(left: 40),
//                                             child: Text(
//                                               getDataFromDynamic(
//                                                   Serial["Quantity"]),
//                                               style: TextStyle(fontSize: 13),
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ).toList(),
//                             if (state is RequestingPaginationBin)
//                               Container(
//                                 margin:
//                                     const EdgeInsets.symmetric(vertical: 20),
//                                 child: Center(
//                                   child: SizedBox(
//                                     width: 30,
//                                     height: 30,
//                                     child: CircularProgressIndicator(
//                                       strokeWidth: 3,
//                                     ),
//                                   ),
//                                 ),
//                               )
//                           ],
//                         );
//                 },
//               ),
//             )
//           ],
//         ),
//       ),
//       bottomNavigationBar: Container(
//         height: size(context).height * 0.09,
//         padding: const EdgeInsets.all(12),
//         color: Color.fromARGB(255, 243, 243, 243),
//         child: Row(
//           children: [
//             const SizedBox(width: 12),
//             Expanded(
//               child: Button(
//                 bgColor: Colors.green.shade900,
//                 variant: ButtonVariant.primary,
//                 onPressed: _onDone,
//                 child: Text(
//                   'Done',
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ),
//             ),
//             Expanded(child: Container()),
//             Expanded(child: Container()),
//             const SizedBox(width: 12),
//           ],
//         ),
//       ),
//     );
//   }
// }
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

  List<dynamic> data = [];
  List<dynamic> filteredData = [];
  Set<int> selectedIndices = <int>{};
  bool isFilter = false;

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

  void onFilter() {
    setState(() {
      isFilter = filter.text.isNotEmpty;
      if (isFilter) {
        filteredData = data
            .where((e) => e["Batch_Serial"]
                .toString()
                .toLowerCase()
                .contains(filter.text.toLowerCase()))
            .toList();
      } else {
        filteredData = [];
      }
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              width: double.infinity,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.only(left: 15),
                child: TextFormField(
                  controller: filter,
                  decoration: InputDecoration(
                    enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent)),
                    focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent)),
                    hintText: 'Serial Number...',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search, color: PRIMARY_COLOR),
                      onPressed: onFilter,
                    ),
                  ),
                ),
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
                    flex: 5,
                    child: Text(
                      'Serial Number',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: Text('Qty'),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(thickness: 0.001, height: 7),

            // List
            Expanded(
              child: displayList.isEmpty
                  ? const Center(child: Text("No Serial Found"))
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 6,
                                child: Row(
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 7.0),
                                      child: Checkbox(
                                        value: selectedIndices.contains(index),
                                        onChanged: (val) =>
                                            _onSelected(val, index),
                                        checkColor: Colors.white,
                                        activeColor: Colors.green.shade900,
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          getDataFromDynamic(
                                              serial["Batch_Serial"]),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w800),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          getDataFromDynamicBin(
                                              serial["BinCode"]),
                                          style:
                                              const TextStyle(fontSize: 13.0),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 40),
                                  child: Text(
                                    getDataFromDynamic(serial["Quantity"]),
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              ),
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
        height: MediaQuery.of(context).size.height * 0.09,
        padding: const EdgeInsets.all(12),
        color: const Color.fromARGB(255, 243, 243, 243),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Expanded(
              child: Button(
                bgColor: Colors.green.shade900,
                variant: ButtonVariant.primary,
                onPressed: _onDone,
                child: const Text(
                  'Done',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            Expanded(child: Container()),
            Expanded(child: Container()),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}
