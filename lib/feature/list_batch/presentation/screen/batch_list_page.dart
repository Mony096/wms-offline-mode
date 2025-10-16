import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_mobile/component/button/button.dart';
import 'package:wms_mobile/helper/helper.dart';
import 'package:wms_mobile/utilies/storage/locale_storage.dart';
// import 'package:iscan_data_plugin/iscan_data_plugin.dart';
import '../cubit/batch_list_cubit.dart';
import '/constant/style.dart';

class BatchListPage extends StatefulWidget {
  const BatchListPage({super.key, required this.itemCode, this.binCode});

  final String itemCode;
  final dynamic binCode;
  @override
  State<BatchListPage> createState() => _BatchListPageState();
}

class _BatchListPageState extends State<BatchListPage> {
  final ScrollController _scrollController = ScrollController();

  String query = "?\$top=10&\$skip=0";
  List<dynamic> data = [];
  List<TextEditingController> controllers = [];
  Set<int> selectedIndices = <int>{};
  TextEditingController filter = TextEditingController();
  late BatchListCubit _bloc;
  bool loading = false;
  bool isFilter = false;

  @override
  void initState() {
    super.initState();
    try {
      // IscanDataPlugin.methodChannel
      //     .setMethodCallHandler((MethodCall call) async {
      //   if (call.method == "onScanResults") {
      //     if (loading) return;

      //     setState(() {
      //       if (call.arguments['data'] == "decode error") return;
      //       filter.text = call.arguments['data'];
      //     });
      //   }
      // });
    } catch (e) {
      print("Error setting method call handler: $e");
    }
    init(context);
  }

  @override
  void dispose() {
    // Dispose controllers
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void init(BuildContext context) async {
    try {
      final warehouse = await LocalStorageManger.getString('warehouse');
      setState(() {
        print(warehouse);
        print(widget.binCode);
        print(widget.itemCode);
        print("asas");
      });
      _bloc = context.read<BatchListCubit>();
      _bloc
          .get(
              "$query&\$filter=ItemCode eq '${widget.itemCode}' ${widget.binCode != "" ? "and AbsEntry eq ${widget.binCode}" : ""} and WhsCode eq '$warehouse'")
          .then((value) {
        if (mounted) {
          setState(() {
            data = value;
            // Assuming each item has a `quantity` field for sorting
            data.sort((a, b) => (b["Quantity"]).compareTo(a["Quantity"]));
            controllers = List.generate(
              data.length,
              (index) => TextEditingController(),
            );
          });
        }
      });

      _scrollController.addListener(() {
        if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          final state = BlocProvider.of<BatchListCubit>(context).state;
          if (state is BinData && data.isNotEmpty) {
            if (isFilter) {
              _bloc
                  .next(
                      "?\$top=10&\$skip=${data.length}&\$filter=ItemCode eq '${widget.itemCode}' ${widget.binCode != "" ? "and BinCode eq '${widget.binCode}'" : ""} and contains(Batch_Serial,'${filter.text}') and WhsCode eq '$warehouse'")
                  .then((value) {
                if (mounted) {
                  setState(() {
                    data = [...data, ...value];
                    // Sort combined list by quantity
                    data.sort(
                        (a, b) => (b["Quantity"]).compareTo(a["Quantity"]));
                    controllers.addAll(List.generate(
                      value.length,
                      (index) => TextEditingController(),
                    ));
                  });
                }
              });
            } else {
              _bloc
                  .next(
                      "?\$top=10&\$skip=${data.length}&\$filter=ItemCode eq '${widget.itemCode}' ${widget.binCode != "" ? "and BinCode eq '${widget.binCode}'" : ""} and WhsCode eq '$warehouse'")
                  .then((value) {
                if (mounted) {
                  setState(() {
                    data = [...data, ...value];
                    // Sort combined list by quantity
                    data.sort(
                        (a, b) => (b["Quantity"]).compareTo(a["Quantity"]));
                    controllers.addAll(List.generate(
                      value.length,
                      (index) => TextEditingController(),
                    ));
                  });
                }
              });
            }
          }
        }
      });
    } catch (err) {
      print(err);
    }
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
    List<dynamic> selectedData =
        selectedIndices.map((index) => data[index]).toList();
    Navigator.of(context).pop(selectedData); // Pass selected data back
  }

  void _onChangeQty(String value, int index) {
    setState(() {
      data[index]["PickQty"] = value;
    });
  }

  void onFilter() async {
    final warehouse = await LocalStorageManger.getString('warehouse');

    setState(() {
      data = [];
      if (filter.text != "") {
        isFilter = true;
      }
    });
    _bloc
        .get(
      "$query&\$filter=ItemCode eq '${widget.itemCode}' and contains(Batch_Serial,'${filter.text}') ${widget.binCode != "" ? "and BinCode eq '${widget.binCode}'" : ""} and WhsCode eq '$warehouse'",
    )
        .then((value) {
      if (!mounted) return;

      setState(() {
        data = value as dynamic;
        data.sort((a, b) => (b["Quantity"]).compareTo(a["Quantity"]));
        controllers = List.generate(
          data.length,
          (index) => TextEditingController(),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Sort data by Qty in descending order
    // data.sort((a, b) => (b["Quantity"]).compareTo((a["Quantity"])));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: PRIMARY_COLOR,
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text(
          'Batches Lists',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Color.fromARGB(255, 243, 243, 243),
        child: Column(
          children: [
            Container(
              padding:
                  const EdgeInsets.only(left: 14, right: 14, bottom: 6, top: 4),
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.white),
              child: Padding(
                padding: const EdgeInsets.only(left: 15),
                child: TextFormField(
                  controller: filter,
                  decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent)),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent)),
                    contentPadding: const EdgeInsets.only(top: 15),
                    hintText: 'Batch Number...',
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.search,
                        color: PRIMARY_COLOR,
                      ),
                      onPressed: onFilter,
                    ),
                  ),
                ),
              ),
            ),
            const Divider(thickness: 0.001, height: 25),
            Container(
              padding: const EdgeInsets.fromLTRB(30, 15, 15, 15),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                border: Border(
                  bottom: BorderSide(width: 0.1),
                  top: BorderSide(width: 0.1),
                ),
              ),
              child: Row(
                children: const [
                  Expanded(
                    flex: 4,
                    child: Text(
                      'Batch Number.',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text('Available Qty'),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text('Alc.Qty'),
                  ),
                ],
              ),
            ),
            const Divider(thickness: 0.001, height: 7),
            Expanded(
              child: BlocConsumer<BatchListCubit, BatchListState>(
                listener: (context, state) {},
                builder: (context, state) {
                  if (state is RequestingBin) {
                    return Center(child: CircularProgressIndicator());
                  }

                  return data.length == 0
                      ? Column(
                          children: [
                            SizedBox(
                              height: 100,
                            ),
                            Container(
                              child: Text("No Batch"),
                            ),
                          ],
                        )
                      : ListView(
                          controller: _scrollController,
                          children: [
                            ...data.asMap().entries.map(
                              (entry) {
                                int index = entry.key;
                                var batch = entry.value;
                                return GestureDetector(
                                  child: Container(
                                    padding: const EdgeInsets.fromLTRB(
                                        10, 15, 10, 15),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                    ),
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          flex: 5,
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 7),
                                                child: Checkbox(
                                                  value: selectedIndices
                                                      .contains(index),
                                                  onChanged: (bool? value) {
                                                    _onSelected(value, index);
                                                  },
                                                  checkColor: Colors
                                                      .white, // Color of the checkmark
                                                  activeColor:
                                                      Colors.green.shade900,
                                                ),
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    getDataFromDynamic(
                                                        batch["Batch_Serial"]),
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Text(
                                                    getDataFromDynamicBin(
                                                        batch["BinCode"]),
                                                    style:
                                                        TextStyle(fontSize: 13),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        "Expiry Date  :",
                                                        style: TextStyle(
                                                            fontSize: 13,
                                                            color: Colors.grey),
                                                      ),
                                                      SizedBox(
                                                        width: 7,
                                                      ),
                                                      Text(
                                                        getDataFromDynamic(
                                                            batch["ExpDate"]),
                                                        style: TextStyle(
                                                            fontSize: 13,
                                                            color: Colors.red),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            getDataFromDynamic(
                                                batch["Quantity"]),
                                            style: TextStyle(
                                                // fontWeight: FontWeight.w800,
                                                ),
                                          ),
                                        ),
                                        // Input field here
                                        Expanded(
                                          flex: 2,
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(left: 40),
                                            child: SizedBox(
                                              width: 85,
                                              child: TextField(
                                                style: TextStyle(fontSize: 14),
                                                controller: controllers.length >
                                                        index
                                                    ? controllers[index]
                                                    : TextEditingController(),
                                                onChanged: (value) {
                                                  _onChangeQty(value, index);
                                                },
                                                decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  hintText: 'Qty',
                                                  hintStyle: TextStyle(
                                                    fontSize: 14.0,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          vertical: 10,
                                                          horizontal: 10),
                                                ),
                                                keyboardType:
                                                    TextInputType.number,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ).toList(),
                            if (state is RequestingPaginationBin)
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: Center(
                                  child: SizedBox(
                                    width: 30,
                                    height: 30,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                    ),
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
      bottomNavigationBar: Container(
        height: MediaQuery.of(context).size.height * 0.09,
        padding: const EdgeInsets.all(12),
        color: Color.fromARGB(255, 243, 243, 243),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Expanded(
              child: Button(
                bgColor: Colors.green.shade900,
                variant: ButtonVariant.primary,
                onPressed: _onDone,
                child: Text(
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
