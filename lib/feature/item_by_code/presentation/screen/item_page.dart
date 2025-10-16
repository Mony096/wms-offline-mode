// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../../../core/enum/global.dart';
// import '../../../../utilies/dialog/dialog.dart';
// import '/helper/helper.dart';
// import '../cubit/item_cubit.dart';
// import '/constant/style.dart';

// class ItemByCodePage extends StatefulWidget {
//   const ItemByCodePage({super.key, required this.type, this.itemCode});
//   final itemCode;
//   final ItemType type;

//   @override
//   State<ItemByCodePage> createState() => _ItemPageState();
// }

// class _ItemPageState extends State<ItemByCodePage> {
//   final ScrollController _scrollController = ScrollController();

//   String query =
//       "?\$top=10&\$skip=0&\$select=ItemCode,ItemName,PurchaseItem,InventoryItem,SalesItem,InventoryUOM,UoMGroupEntry,InventoryUoMEntry,DefaultPurchasingUoMEntry,DefaultSalesUoMEntry, ManageSerialNumbers, ManageBatchNumbers";

//   int _skip = 0;

//   int check = 1;
//   TextEditingController filter = TextEditingController();
//   List<dynamic> data = [];
//   late ItemByCodeCubit _bloc;

//   @override
//   void initState() {
//     super.initState();
//     if (mounted) {
//       _bloc = context.read<ItemByCodeCubit>();
//       setState(() {
//         print(widget.itemCode);
//       });
//       // final state = context.read<ItemByCodeCubit>().state;

//       // if (state is ItemData) {
//       //   data = state.entities;
//       // }

//       if (data.length == 0) {
//         query =
//             "$query&\$filter=${widget.itemCode == null ? "" : "${widget.itemCode} and"}  ${getItemTypeQueryString(widget.type)}";
//         _bloc.get(query).then((value) {
//           setState(() => data = value);
//           _bloc.set(value);
//         });
//       }

//       setState(() {
//         data;
//       });

//       _scrollController.addListener(() {
//         if (_scrollController.position.pixels ==
//             _scrollController.position.maxScrollExtent) {
//           final state = BlocProvider.of<ItemByCodeCubit>(context).state;
//           if (state is ItemData && data.length > 0) {
//             _bloc
//                 .next(
//                     "?\$top=10&\$skip=${data.length}&\$filter=${getItemTypeQueryString(widget.type)} and contains(ItemCode,'${filter.text}')")
//                 .then((value) {
//               if (!mounted) return;
//               _bloc.set([...data, ...value]);
//               setState(() => data = [...data, ...value]);
//             });
//           }
//         }
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     filter.dispose();

//     super.dispose();
//   }

//   void onFilter() async {
//     setState(() {
//       data = [];
//     });
//     _bloc
//         .get(
//             "$query&\$filter=${getItemTypeQueryString(widget.type)} and contains(ItemCode, '${filter.text}')",
//             cache: false)
//         .then((value) {
//       if (!mounted) return;

//       setState(() => data = value);
//     });
//   }

//   void onFind(String code) async {
//     try {
//       if (!mounted) return;

//       MaterialDialog.loading(context);
//       final response = await _bloc.find("('$code')");
//       if (mounted) {
//         MaterialDialog.close(context);

//         Navigator.pop(context, response);
//       }
//     } catch (e) {
//       if (mounted) {
//         MaterialDialog.success(context,
//             title: 'Invalid', body: 'Item not found - $code');
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: PRIMARY_COLOR,
//         iconTheme: IconThemeData(color: Colors.white),
//         title: const Text(
//           'Item Listsa',
//           style: TextStyle(
//               fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
//         ),
//       ),
//       // bottomNavigationBar: MyBottomSheet(),
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
//               child: TextFormField(
//                 controller: filter,
//                 decoration: InputDecoration(
//                   enabledBorder: UnderlineInputBorder(
//                       borderSide: BorderSide(color: Colors.transparent)),
//                   focusedBorder: UnderlineInputBorder(
//                       borderSide: BorderSide(color: Colors.transparent)),
//                   contentPadding: const EdgeInsets.only(top: 15),
//                   hintText: 'Item Code...',
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       Icons.search,
//                       color: PRIMARY_COLOR,
//                     ),
//                     onPressed: onFilter,
//                   ),
//                 ),
//               ),
//             ),
//             // const SizedBox(height: 10),
//             const Divider(thickness: 0.1, height: 15),
//             Expanded(
//               child: BlocConsumer<ItemByCodeCubit, ItemByCodeState>(
//                 listener: (context, state) {},
//                 builder: (context, state) {
//                   if (state is RequestingItem) {
//                     return Center(child: CircularProgressIndicator());
//                   }

//                   return ListView(
//                     controller: _scrollController,
//                     children: [
//                       ...data
//                           .map(
//                             (item) => GestureDetector(
//                               onTap: () =>
//                                   onFind(getDataFromDynamic(item['ItemCode'])),
//                               child: Container(
//                                 padding: const EdgeInsets.all(12),
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                 ),
//                                 margin: const EdgeInsets.only(bottom: 8),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       getDataFromDynamic(item['ItemCode']),
//                                       style: TextStyle(
//                                         fontWeight: FontWeight.w800,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 6),
//                                     Text(getDataFromDynamic(item['ItemName'])),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           )
//                           .toList(),
//                       if (state is RequestingPaginationItem)
//                         Container(
//                           margin: const EdgeInsets.symmetric(vertical: 20),
//                           child: Center(
//                             child: SizedBox(
//                               width: 30,
//                               height: 30,
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 3,
//                               ),
//                             ),
//                           ),
//                         )
//                     ],
//                   );
//                 },
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_mobile/utilies/dio_client.dart';
import '../../../../core/enum/global.dart';
import '../../../../utilies/dialog/dialog.dart';
import '/helper/helper.dart';
import '../cubit/item_cubit.dart';
import '/constant/style.dart';

class ItemByCodePage extends StatefulWidget {
  const ItemByCodePage({super.key, required this.type, this.itemCode});
  final itemCode;
  final ItemType type;

  @override
  State<ItemByCodePage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemByCodePage> {
  final ScrollController _scrollController = ScrollController();

  String query =
      "?\$top=10&\$skip=0&\$select=ItemCode,ItemName,PurchaseItem,InventoryItem,SalesItem,InventoryUOM,UoMGroupEntry,InventoryUoMEntry,DefaultPurchasingUoMEntry,DefaultSalesUoMEntry,ManageSerialNumbers,ManageBatchNumbers";

  TextEditingController filter = TextEditingController();
  List<dynamic> data = [];
  late ItemByCodeCubit _bloc;
  final DioClient dio = DioClient();

  @override
  void initState() {
    super.initState();
    if (mounted) {
      _bloc = context.read<ItemByCodeCubit>();

      if (data.isEmpty) {
        final fullQuery =
            "$query&\$filter=${widget.itemCode == null ? "" : "${widget.itemCode} and"} ${getItemTypeQueryString(widget.type)}";
        _bloc.get(fullQuery).then((value) {
          if (!mounted) return;
          setState(() => data = value);
          _bloc.set(value);
        });
      }

      _scrollController.addListener(() {
        if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          final state = BlocProvider.of<ItemByCodeCubit>(context).state;
          if (state is ItemData && data.isNotEmpty) {
            _bloc
                .next(
                    "?\$top=10&\$skip=${data.length}&\$filter=${getItemTypeQueryString(widget.type)} and contains(ItemCode,'${filter.text}')")
                .then((value) {
              if (!mounted) return;
              _bloc.set([...data, ...value]);
              setState(() => data = [...data, ...value]);
            });
          }
        }
      });
    }
  }

  void onFilter() async {
    setState(() => data = []);
    _bloc
        .get(
            "$query&\$filter=${getItemTypeQueryString(widget.type)} and contains(ItemCode, '${filter.text}')",
            cache: false)
        .then((value) {
      if (!mounted) return;
      setState(() => data = value);
    });
  }

  // void onFind(String code) async {
  void onFind(dynamic item) async {
    try {
      if (!mounted) return;
      MaterialDialog.loading(context);
      // final response = await _bloc.find("('$code')");
      if (mounted) {
        MaterialDialog.loading(context);
        // final response = await _bloc.find("('$code')");
        if (mounted) {
          final uomGroup = await dio.get(
            '/UnitOfMeasurementGroups(${item['UoMGroupEntry']})',
          );
          final itemMappde = {
            ...item,
            "BaseUoM": uomGroup.data['BaseUoM'],
            "UoMGroupDefinitionCollection":
                uomGroup.data['UoMGroupDefinitionCollection'],
          };
          MaterialDialog.close(context);
          Navigator.pop(context, itemMappde);
        }
      }
    } catch (e) {
      if (mounted) {
        MaterialDialog.success(context,
            title: 'Invalid', body: 'Item not found');
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    filter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: PRIMARY_COLOR,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Item Lists',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Column(
          children: [
            SizedBox(
              height: 4,
            ),
            // 🔍 Modern Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: Icon(Icons.search,
                          color: PRIMARY_COLOR.withOpacity(0.8)),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: filter,
                        decoration: const InputDecoration(
                          hintText: 'Search Item Code...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 14, horizontal: 10),
                        ),
                      ),
                    ),
                    Container(
                      height: 45,
                      width: 45,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: PRIMARY_COLOR,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_forward_ios_rounded,
                            size: 18, color: Colors.white),
                        onPressed: onFilter,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // const Divider(thickness: 0.1, height: 10),

            Expanded(
              child: BlocConsumer<ItemByCodeCubit, ItemByCodeState>(
                listener: (context, state) {},
                builder: (context, state) {
                  if (state is RequestingItem) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return ListView(
                    controller: _scrollController,
                    children: [
                      ...data.map((item) {
                        return GestureDetector(
                          onTap: () => onFind(item),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F3F3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  getDataFromDynamic(item['ItemCode']),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  getDataFromDynamic(item['ItemName']),
                                  style: const TextStyle(
                                      fontSize: 13, color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      if (state is RequestingPaginationItem)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: SizedBox(
                              width: 30,
                              height: 30,
                              child: CircularProgressIndicator(strokeWidth: 3),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
