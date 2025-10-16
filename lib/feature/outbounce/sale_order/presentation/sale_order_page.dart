// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '/constant/style.dart';
// import '/feature/inbound/good_receipt_po/presentation/create_good_receipt_screen.dart';
// import '/utilies/storage/locale_storage.dart';

// import '../../../../helper/helper.dart';
// import 'cubit/sale_order_cubit.dart';

// class SaleOrderPage extends StatefulWidget {
//   const SaleOrderPage({
//     super.key,
//   });

//   @override
//   State<SaleOrderPage> createState() => _SaleOrderPageState();
// }

// class _SaleOrderPageState extends State<SaleOrderPage> {
//   final ScrollController _scrollController = ScrollController();

//   String query = "?\$top=10&\$skip=0";

//   int check = 1;
//   TextEditingController filter = TextEditingController();
//   List<dynamic> data = [];
//   late SaleOrderCubit _bloc;

//   @override
//   void initState() {
//     super.initState();
//     init(context);
//   }

//   void init(BuildContext context) async {
//     try {
//       final warehouse = await LocalStorageManger.getString('warehouse');

//       // _bloc = context.read<SaleOrderCubit>();
//       // _bloc
//       //     .get(
//       //         "$query&\$filter=DocumentStatus eq 'bost_Open' and U_tl_whsdesc= eq '$warehouse'")
//       //     .then((value) => setState(() => data = value));
//       _bloc = context.read<SaleOrderCubit>();
//       _bloc
//           .get("$query&\$filter=DocumentStatus eq 'bost_Open'")
//           .then((value) => setState(() => data = value));
//       _scrollController.addListener(() {
//         if (_scrollController.position.pixels ==
//             _scrollController.position.maxScrollExtent) {
//           final state = BlocProvider.of<SaleOrderCubit>(context).state;
//           if (state is SaleOrderData && data.length > 0) {
//             // _bloc
//             //     .next(
//             //         "?\$top=10&\$skip=${data.length}&\$filter=DocumentStatus eq 'bost_Open' and U_tl_whsdesc eq '$warehouse' and contains(CardCode,'${filter.text}')")
//             //     .then((value) {
//             //   if (!mounted) return;

//             //   setState(() => data = [...data, ...value]);
//             // });
//              _bloc
//                 .next(
//                     "?\$top=10&\$skip=${data.length}&\$filter=DocumentStatus eq 'bost_Open' and contains(CardCode,'${filter.text}')")
//                 .then((value) {
//               if (!mounted) return;

//               setState(() => data = [...data, ...value]);
//             });
//           }
//         }
//       });
//     } catch (err) {
//       print(err);
//     }
//   }

//   @override
//   void dispose() {
//     // TODO: implement dispose
//     _scrollController.dispose();
//     filter.dispose();

//     super.dispose();
//   }

//   void onFilter() async {
//     setState(() {
//       data = [];
//     });

//     // final warehouse = await LocalStorageManger.getString('warehouse');
//     // _bloc
//     //     .get(
//     //         "$query&\$filter=DocumentStatus eq 'bost_Open' and U_tl_whsdesc eq '$warehouse' and contains(CardCode, '${filter.text}')")
//     //     .then((value) {
//     //   if (!mounted) return;

//     //   setState(() => data = value);
//     // });
//       // final warehouse = await LocalStorageManger.getString('warehouse');
//     _bloc
//         .get(
//             "$query&\$filter=DocumentStatus eq 'bost_Open' and contains(CardCode, '${filter.text}') & \$orderby = DocEntry desc")
//         .then((value) {
//       if (!mounted) return;

//       setState(() => data = value);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: PRIMARY_COLOR,
//         iconTheme: IconThemeData(color: Colors.white),
//         title: const Text(
//           'Sale Order Lists - OPEN',
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
//                   hintText: 'Customer Code',
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
//               child: BlocConsumer<SaleOrderCubit, SaleOrderState>(
//                 listener: (context, state) {},
//                 builder: (context, state) {
//                   if (state is RequestingSaleOrder) {
//                     return Center(child: CircularProgressIndicator());
//                   }

//                   return ListView(
//                     controller: _scrollController,
//                     children: [
//                       ...data
//                           .map(
//                             (po) => GestureDetector(
//                               onTap: () => Navigator.of(context).pop(po),
//                               child: Container(
//                                 padding: const EdgeInsets.all(12),
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                 ),
//                                 margin: const EdgeInsets.only(bottom: 8),
//                                 child: Column(
//                                   children: [
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Text(
//                                           "${getDataFromDynamic(po['CardCode'])} - ${getDataFromDynamic(po['DocNum'])}",
//                                           style: TextStyle(
//                                             fontWeight: FontWeight.w800,
//                                           ),
//                                         ),
//                                         Text(
//                                           'Doc Date : ${getDataFromDynamic(po['DocDueDate'], isDate: true)}',
//                                           style: TextStyle(fontSize: 13),
//                                         ),
//                                       ],
//                                     ),
//                                     const SizedBox(height: 6),
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Expanded(
//                                           child: Text(
//                                             getDataFromDynamic(po['Comments']),
//                                             overflow: TextOverflow.ellipsis,
//                                           ),
//                                         ),
//                                         const SizedBox(width: 30),
//                                         Text(
//                                           'Dilvery Date : ${getDataFromDynamic(po['DocDate'], isDate: true)}',
//                                           style: TextStyle(fontSize: 13),
//                                         ),
//                                       ],
//                                     )
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           )
//                           .toList(),
//                       if (state is RequestingPaginationSaleOrder)
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
import '/constant/style.dart';
import '/feature/inbound/good_receipt_po/presentation/create_good_receipt_screen.dart';
import '/utilies/storage/locale_storage.dart';
import '../../../../helper/helper.dart';
import 'cubit/sale_order_cubit.dart';

class SaleOrderPage extends StatefulWidget {
  const SaleOrderPage({super.key});

  @override
  State<SaleOrderPage> createState() => _SaleOrderPageState();
}

class _SaleOrderPageState extends State<SaleOrderPage> {
  final ScrollController _scrollController = ScrollController();
  String query = "?\$top=10&\$skip=0";
  TextEditingController filter = TextEditingController();
  List<dynamic> data = [];
  late SaleOrderCubit _bloc;

  @override
  void initState() {
    super.initState();
    init(context);
  }

  void init(BuildContext context) async {
    try {
      _bloc = context.read<SaleOrderCubit>();
      _bloc
          .get("$query&\$filter=DocumentStatus eq 'bost_Open'")
          .then((value) => setState(() => data = value));

      _scrollController.addListener(() {
        if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          final state = BlocProvider.of<SaleOrderCubit>(context).state;
          if (state is SaleOrderData && data.isNotEmpty) {
            _bloc
                .next(
                    "?\$top=10&\$skip=${data.length}&\$filter=DocumentStatus eq 'bost_Open' and contains(CardCode,'${filter.text}')")
                .then((value) {
              if (!mounted) return;
              setState(() => data = [...data, ...value]);
            });
          }
        }
      });
    } catch (err) {
      print(err);
    }
  }

  void onFilter() async {
    setState(() => data = []);
    _bloc
        .get(
            "$query&\$filter=DocumentStatus eq 'bost_Open' and contains(CardCode, '${filter.text}')&\$orderby=DocEntry desc")
        .then((value) {
      if (!mounted) return;
      setState(() => data = value);
    });
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
          'Sale Order Lists - OPEN',
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
                        hintText: 'Search Customer Code...',
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
                              BorderSide(color: PRIMARY_COLOR, width: 0.5),
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

            // 🔹 Sale Order List
            Expanded(
              child: BlocConsumer<SaleOrderCubit, SaleOrderState>(
                listener: (context, state) {},
                builder: (context, state) {
                  if (state is RequestingSaleOrder) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (data.isEmpty) {
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
                                  "No sale order found !",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 15),
                                ),
                              ],
                            ),
                          ],
                        ));
                  }
                  return ListView(
                    controller: _scrollController,
                    children: [
                      ...data.map(
                        (po) => GestureDetector(
                          onTap: () => Navigator.of(context).pop(po),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: const Color.fromARGB(255, 243, 243, 243),
                              boxShadow: const [
                                // BoxShadow(
                                //   color: Colors.grey.withOpacity(0.15),
                                //   spreadRadius: 1,
                                //   blurRadius: 3,
                                //   offset: const Offset(0, 2),
                                // ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 🔸 Header row
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${getDataFromDynamic(po['CardCode'])} - ${getDataFromDynamic(po['DocNum'])}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      'Doc Date: ${getDataFromDynamic(po['DocDueDate'], isDate: true)}',
                                      style: const TextStyle(
                                          fontSize: 13, color: Colors.black54),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),

                                // 🔸 Comment + Date
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        getDataFromDynamic(po['Comments']),
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Text(
                                      'Delivery: ${getDataFromDynamic(po['DocDate'], isDate: true)}',
                                      style: const TextStyle(
                                          fontSize: 13, color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (state is RequestingPaginationSaleOrder)
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
