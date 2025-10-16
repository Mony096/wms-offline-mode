import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_mobile/feature/bin_location/presentation/cubit/bin_cubit.dart';
import 'package:wms_mobile/helper/helper.dart';
import 'package:wms_mobile/mobile_function/dashboard.dart';
import 'package:wms_mobile/utilies/dialog/dialog.dart';
import 'package:wms_mobile/utilies/storage/locale_storage.dart';
import '/constant/style.dart';
import '/feature/warehouse/domain/entity/warehouse_entity.dart';
import '/feature/warehouse/presentation/cubit/warehouse_cubit.dart';
import 'package:flutter/services.dart'; // Import for SystemNavigator

class WarehousePage extends StatefulWidget {
  const WarehousePage({super.key, this.isPicker = false});

  final bool isPicker;

  @override
  State<WarehousePage> createState() => _WarehousePageState();
}

class _WarehousePageState extends State<WarehousePage> {
  final ScrollController _scrollController = ScrollController();

  String query = "?\$top=10&\$skip=0";

  TextEditingController filter = TextEditingController();
  List<WarehouseEntity> data = [];
  late WarehouseCubit _bloc;
  late BinCubit _blocBin;

  @override
  void initState() {
    super.initState();
    // print("WH");
    _bloc = context.read<WarehouseCubit>();
    _blocBin = context.read<BinCubit>();

    final state = context.read<WarehouseCubit>().state;

    if (state is WarehouseData) {
      data = state.entities;
    }

    if (data.isEmpty) {
      _bloc.get(query).then((value) {
        if (mounted) {
          setState(() => data = value);
          _bloc.set(value);
        }
      });
    }

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        final state = BlocProvider.of<WarehouseCubit>(context).state;
        if (state is WarehouseData && data.isNotEmpty) {
          _bloc
              .next(
                  "?\$top=10&\$skip=${data.length}&\$filter=contains(WarehouseCode,'${filter.text}')")
              .then((value) {
            if (mounted) {
              _bloc.set([...data, ...value]);
              setState(() => data = [...data, ...value]);
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    filter.dispose();

    super.dispose();
  }

  void onFilter() async {
    setState(() {
      data = [];
    });
    _bloc
        .get("$query&\$filter=contains(WarehouseCode, '${filter.text}')")
        .then((value) {
      if (mounted) {
        setState(() => data = value);
      }
    });
  }

  void onPressed(String code, String name) async {
    if (widget.isPicker) {
      MaterialDialog.loading(context);

      await LocalStorageManger.setString('warehouse', code);
      await LocalStorageManger.setString('warehouseName', name);
      await _blocBin.get("?\$filter=Warehouse eq '$code'").then((value) {
        _blocBin.set(value);
        print(value);
      });
      await goTo(context, Dashboard(), removeAllPreviousRoutes: true);
    } else {
      LocalStorageManger.setString('warehouseName', name);
      LocalStorageManger.setString('warehouse', code);
      Navigator.pop(context, code);
    }
  }

  Future<bool> _onWillPop() async {
    if (widget.isPicker) {
      SystemNavigator.pop();
      return false; // Prevent the back navigation
    } else {
      return true; // Allow the back navigation
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              if (widget.isPicker) {
                MaterialDialog.success(context,
                    title: 'Opps.',
                    body:
                        "Please Selecting the warehouse is a prerequisite before proceeding");
                return;
              }
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_back),
          ),
          backgroundColor: PRIMARY_COLOR,
          iconTheme: IconThemeData(color: Colors.white),
          title: Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 65),
              child: const Text(
                'Warehouse Lists',
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
          color: Color.fromARGB(255, 255, 255, 255),
          child: Column(
            children: [
              // if (!widget.isPicker)
              // Container(
              //   padding: const EdgeInsets.only(
              //       left: 14, right: 14, bottom: 6, top: 4),
              //   width: double.infinity,
              //   decoration: BoxDecoration(color: Colors.white),
              //   child: TextFormField(
              //     controller: filter,
              //     decoration: InputDecoration(
              //       enabledBorder: UnderlineInputBorder(
              //           borderSide: BorderSide(color: Colors.transparent)),
              //       focusedBorder: UnderlineInputBorder(
              //           borderSide: BorderSide(color: Colors.transparent)),
              //       contentPadding: const EdgeInsets.only(top: 15),
              //       hintText: 'Warehouse Code...',
              //       suffixIcon: IconButton(
              //         icon: Icon(
              //           Icons.search,
              //           color: PRIMARY_COLOR,
              //         ),
              //         onPressed: onFilter,
              //       ),
              //     ),
              //   ),
              // ),
              const SizedBox(height: 10),
              // 🔍 Search Bar
              Container(
                padding: const EdgeInsets.all(8),
                width: double.infinity,
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: filter,
                        decoration: InputDecoration(
                          hintText: 'Search Warehouse',
                          filled: true,
                          fillColor: const Color.fromARGB(255, 243, 243, 243),
                          prefixIcon: Icon(Icons.search,
                              color: PRIMARY_COLOR), // left icon
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: Colors.grey.shade300, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: Colors.grey.shade300, width: 1),
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
                        icon: const Icon(Icons.arrow_forward,
                            color: Colors.white),
                        onPressed: onFilter,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 5),
              // if (!widget.isPicker) const Divider(thickness: 0.1, height: 15),
              Expanded(
                child: BlocConsumer<WarehouseCubit, WarehouseState>(
                  listener: (context, state) {},
                  builder: (context, state) {
                    if (state is RequestingWarehouse) {
                      return Center(child: CircularProgressIndicator());
                    }

                    return ListView(
                      controller: _scrollController,
                      children: [
                        ...data
                            .map(
                              (warehouse) => GestureDetector(
                                onTap: () =>
                                    onPressed(warehouse.code, warehouse.name),
                                child: Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(15, 25, 12, 25),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: const Color.fromARGB(
                                        255, 242, 243, 244),
                                  ),
                                  margin:
                                      const EdgeInsets.fromLTRB(12, 8, 12, 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          "${warehouse.code} - ${warehouse.name}",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 15.1)),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16,
                                        color: Colors.grey,
                                      )
                                    ],
                                  ),
                                  //  Column(
                                  //   crossAxisAlignment:
                                  //       CrossAxisAlignment.start,
                                  //   children: [
                                  //     Text(
                                  //       warehouse.code,
                                  //       style: TextStyle(
                                  //         fontWeight: FontWeight.w800,
                                  //       ),
                                  //     ),
                                  //     const SizedBox(height: 6),
                                  //     Text(
                                  //       warehouse.name,
                                  //     ),
                                  //   ],
                                  // ),
                                ),
                              ),
                            )
                            .toList(),
                        if (state is RequestingPaginationWarehouse)
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 20),
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
      ),
    );
  }
}
