import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_mobile/helper/helper.dart';
import 'package:wms_mobile/utilies/dio_client.dart';
import '../../domain/entity/bin_entity.dart';
import '../cubit/bin_cubit.dart';
import '/constant/style.dart';

class BinPage extends StatefulWidget {
  const BinPage(
      {super.key, required this.warehouse, this.itemCode, this.fromBinlookUp});

  final String warehouse;
  final dynamic itemCode;
  final dynamic fromBinlookUp;
  @override
  State<BinPage> createState() => _BinPageState();
}

class _BinPageState extends State<BinPage> {
  String query = "?\$top=100&\$select=AbsEntry,BinCode,Warehouse,Sublevel1";
  // int check = -1;
  int check = 1;
  List<BinEntity> data = [];
  List<BinEntity> filteredData = []; // NEW: filtered list
  late BinCubit _bloc;
  final DioClient dio = DioClient();
  List<dynamic> qty = [];
  final TextEditingController _filter = TextEditingController();

  @override
  void initState() {
    super.initState();

    _bloc = context.read<BinCubit>();
    final state = _bloc.state;

    if (state is BinData) {
      data = state.entities;
      filteredData = data; // initialize filteredData
    }

    final exists = data.where((e) => e.warehouse == widget.warehouse);
    if (data.isEmpty || exists.isEmpty) {
      _bloc
          .get("$query&\$filter=Warehouse eq '${widget.warehouse}'")
          .then((value) {
        setState(() {
          data = value;
          filteredData = value; // initialize filteredData
        });
        _bloc.set(value);
      });
    }

    // getGetdataInit();

    // Listen to filter changes
    _filter.addListener(() {
      final text = _filter.text.toLowerCase();
      setState(() {
        filteredData = data
            .where((bin) =>
                bin.code.toLowerCase().contains(text) ||
                bin.subLevel1.toLowerCase().contains(text))
            .toList();
      });
    });
  }

  // void getGetdataInit() async {
  //   if (widget.itemCode == "") {
  //     setState(() {
  //       check = 1;
  //     });
  //     return;
  //   }

  //   final response = await dio.get(
  //       "/view.svc/ItemB1SLQuery?\$filter=ItemCode eq '${widget.itemCode}' and WhsCode eq '${widget.warehouse}'");

  //   if (response.statusCode == 200) {
  //     setState(() {
  //       qty.addAll(response.data["value"]);
  //       check = 1;
  //     });
  //   }
  // }

  @override
  void dispose() {
    _filter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Column(
          children: [
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
              child: Row(
                children: [
                  const Text(
                    "Bin Location",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(left: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextField(
                        controller: _filter,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          hintText: 'Search...',
                          suffixIcon: _filter.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _filter.clear();
                                    setState(() {
                                      filteredData = data;
                                    });
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 13),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocConsumer<BinCubit, BinState>(
                listener: (context, state) {},
                builder: (context, state) {
                  if (state is RequestingBin) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final displayList = filteredData; // use filtered data
                  if (displayList.isEmpty) {
                    return Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.file_copy,
                              size: 50,
                              color: Colors.grey,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Column(
                              children: [
                                Text(
                                  "No Bin Location found !",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 15),
                                ),
                                // SizedBox(
                                //   height: 5,
                                // ),
                                // Text(
                                //   "adjusting your search terms",
                                //   style: TextStyle(
                                //       color: Colors.grey, fontSize: 15),
                                // ),
                              ],
                            ),
                          ],
                        ));
                  }
                  return check == -1
                      ? const Center(
                          child: SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(strokeWidth: 3),
                          ),
                        )
                      : ListView(
                          children: [
                            ...displayList.map(
                              (bin) => GestureDetector(
                                onTap: () => Navigator.of(context).pop(bin),
                                child: Container(
                                  padding: const EdgeInsets.all(15),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: const Color.fromARGB(
                                        255, 243, 243, 243),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 6,
                                        child: Text(
                                          bin.code,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w800),
                                        ),
                                      ),
                                      // Expanded(
                                      //   flex: 2,
                                      //   child: widget.fromBinlookUp == true
                                      //       ? const Text('')
                                      //       : Text(
                                      //           getDataFromDynamic(
                                      //               qty.firstWhere(
                                      //             (e) =>
                                      //                 e["BinCode"] == bin.code,
                                      //             orElse: () =>
                                      //                 {"OnHandQty": 0},
                                      //           )["OnHandQty"]),
                                      //           style: const TextStyle(
                                      //               fontWeight:
                                      //                   FontWeight.w800),
                                      //         ),
                                      // ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if (state is RequestingPaginationBin)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Center(
                                  child: SizedBox(
                                    width: 30,
                                    height: 30,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 3),
                                  ),
                                ),
                              )
                          ],
                        );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
