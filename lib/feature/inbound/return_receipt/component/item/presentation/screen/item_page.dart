// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:wms_mobile/feature/inbound/return_receipt/component/item/presentation/cubit/item_cubit.dart';
// import '../../../../../../../core/enum/global.dart';
// import '../../../../../../../utilies/dialog/dialog.dart';
// import '/helper/helper.dart';
// import '/constant/style.dart';

// class ItemPage extends StatefulWidget {
//   const ItemPage({super.key, required this.type});

//   final ItemType type;

//   @override
//   State<ItemPage> createState() => _ItemPageState();
// }

// class _ItemPageState extends State<ItemPage> {
//   final ScrollController _scrollController = ScrollController();

//   String query =
//       "?\$top=10&\$skip=0&\$select=ItemCode,ItemName,PurchaseItem,InventoryItem,SalesItem,InventoryUOM,UoMGroupEntry,InventoryUoMEntry,DefaultPurchasingUoMEntry,DefaultSalesUoMEntry, ManageSerialNumbers, ManageBatchNumbers";

//   int _skip = 0;

//   int check = 1;
//   TextEditingController filter = TextEditingController();
//   List<dynamic> data = [];
//   late ItemCubits _bloc;

//   @override
//   void initState() {
//     super.initState();
//     if (mounted) {
//       _bloc = context.read<ItemCubits>();
//       final state = context.read<ItemCubits>().state;

//       if (state is ItemData) {
//         data = state.entities;
//       }

//       if (data.length == 0) {
//         query = "$query&\$filter=${getItemTypeQueryString(widget.type)}";
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
//           final state = BlocProvider.of<ItemCubits>(context).state;
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
//           'Item Lists',
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
//               child: BlocConsumer<ItemCubits, ItemStates>(
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
import 'package:wms_mobile/feature/inbound/return_receipt/component/item/presentation/cubit/item_cubit.dart';
import '../../../../../../../core/enum/global.dart';
import '../../../../../../../utilies/dialog/dialog.dart';
import '/helper/helper.dart';
import '/constant/style.dart';

class ItemPage extends StatefulWidget {
  const ItemPage({super.key, required this.type});

  final ItemType type;

  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  final ScrollController _scrollController = ScrollController();

  String query =
      "?\$top=10&\$skip=0&\$select=ItemCode,ItemName,PurchaseItem,InventoryItem,SalesItem,InventoryUOM,UoMGroupEntry,InventoryUoMEntry,DefaultPurchasingUoMEntry,DefaultSalesUoMEntry,ManageSerialNumbers,ManageBatchNumbers";

  TextEditingController filter = TextEditingController();
  List<dynamic> data = [];
  late ItemCubits _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<ItemCubits>();
    final state = _bloc.state;

    if (state is ItemData) {
      data = state.entities;
    }

    if (data.isEmpty) {
      query = "$query&\$filter=${getItemTypeQueryString(widget.type)}";
      _bloc.get(query).then((value) {
        setState(() => data = value);
        _bloc.set(value);
      });
    }

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        final state = BlocProvider.of<ItemCubits>(context).state;
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

  @override
  void dispose() {
    _scrollController.dispose();
    filter.dispose();
    super.dispose();
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

  void onFind(String code) async {
    try {
      if (!mounted) return;
      MaterialDialog.loading(context);
      final response = await _bloc.find("('$code')");
      if (mounted) {
        MaterialDialog.close(context);
        Navigator.pop(context, response);
      }
    } catch (e) {
      if (mounted) {
        MaterialDialog.success(context,
            title: 'Invalid', body: 'Item not found - $code');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: PRIMARY_COLOR,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Padding(
          padding: const EdgeInsets.only(right: 60),
          child: Center(
            child: const Text(
              'Item Lists',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Column(
          children: [
            const SizedBox(height: 10),
            // 🔹 Modern Search Bar
            Container(
              padding: const EdgeInsets.all(8),
              width: double.infinity,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: filter,
                      decoration: InputDecoration(
                        hintText: 'Search Item Code...',
                        filled: true,
                        fillColor: const Color.fromARGB(255, 243, 243, 243),
                        prefixIcon: Icon(Icons.search,
                            color: PRIMARY_COLOR), // left icon
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.grey.shade300, width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.grey.shade300, width: 1),
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
                      icon:
                          const Icon(Icons.arrow_forward, color: Colors.white),
                      onPressed: onFilter,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // 🔹 Item List
            Expanded(
              child: BlocConsumer<ItemCubits, ItemStates>(
                listener: (context, state) {},
                builder: (context, state) {
                  if (state is RequestingItem) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return ListView(
                    controller: _scrollController,
                    children: [
                      ...data.map(
                        (item) => GestureDetector(
                          onTap: () =>
                              onFind(getDataFromDynamic(item['ItemCode'])),
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: const Color.fromARGB(255, 243, 243, 243),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  getDataFromDynamic(item['ItemCode']),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  getDataFromDynamic(item['ItemName']),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (state is RequestingPaginationItem)
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 20),
                          child: const Center(
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
