// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:wms_mobile/feature/outbounce/purchase_return_request/presentation/cubit/purchase_return_request_cubit.dart';
// import '/constant/style.dart';
// import '/utilies/storage/locale_storage.dart';

// import '../../../../helper/helper.dart';

// class PurchaseReturnRequestPage extends StatefulWidget {
//   const PurchaseReturnRequestPage({
//     super.key,
//   });

//   @override
//   State<PurchaseReturnRequestPage> createState() =>
//       _PurchaseReturnRequestPageState();
// }

// class _PurchaseReturnRequestPageState extends State<PurchaseReturnRequestPage> {
//   final ScrollController _scrollController = ScrollController();

//   String query = "?\$top=10&\$skip=0";

//   int check = 1;
//   TextEditingController filter = TextEditingController();
//   List<dynamic> data = [];
//   late PurchaseReturnRequestCubit _bloc;

//   @override
//   void initState() {
//     super.initState();
//     init(context);
//   }

//   void init(BuildContext context) async {
//     try {
//       // final warehouse = await LocalStorageManger.getString('warehouse');

//       // _bloc = context.read<PurchaseReturnRequestCubit>();
//       // _bloc
//       //     .get(
//       //         "$query&\$filter=DocumentStatus eq 'bost_Open' and U_tl_whsdesc eq '$warehouse'")
//       //     .then((value) => setState(() => data = value));
//       _bloc = context.read<PurchaseReturnRequestCubit>();
//       _bloc
//           .get(
//               "$query&\$filter=DocumentStatus eq 'bost_Open'")
//           .then((value) => setState(() => data = value));
//       _scrollController.addListener(() {
//         if (_scrollController.position.pixels ==
//             _scrollController.position.maxScrollExtent) {
//           final state =
//               BlocProvider.of<PurchaseReturnRequestCubit>(context).state;
//           if (state is PurchaseReturnRequestData && data.length > 0) {
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
//      _bloc
//         .get(
//             "$query&\$filter=DocumentStatus eq 'bost_Open' and contains(CardCode, '${filter.text}')")
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
//           'Return To Supplier Request Lists - OPEN',
//           style: TextStyle(
//               fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
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
//                   hintText: 'Vendor Code...',
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
//               child: BlocConsumer<PurchaseReturnRequestCubit,
//                   PurchaseReturnRequestState>(
//                 listener: (context, state) {},
//                 builder: (context, state) {
//                   if (state is RequestingPurchaseReturnRequest) {
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
//                       if (state is RequestingPaginationPurchaseReturnRequest)
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
import 'package:wms_mobile/feature/outbounce/purchase_return_request/presentation/cubit/purchase_return_request_cubit.dart';
import '/constant/style.dart';
import '/utilies/storage/locale_storage.dart';
import '../../../../helper/helper.dart';

class PurchaseReturnRequestPage extends StatefulWidget {
  const PurchaseReturnRequestPage({super.key});

  @override
  State<PurchaseReturnRequestPage> createState() =>
      _PurchaseReturnRequestPageState();
}

class _PurchaseReturnRequestPageState extends State<PurchaseReturnRequestPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController filter = TextEditingController();

  String query = "?\$top=10&\$skip=0";
  List<dynamic> data = [];
  late PurchaseReturnRequestCubit _bloc;

  @override
  void initState() {
    super.initState();
    init(context);
  }

  void init(BuildContext context) async {
    try {
      _bloc = context.read<PurchaseReturnRequestCubit>();
      _bloc
          .get("$query&\$filter=DocumentStatus eq 'bost_Open'")
          .then((value) => setState(() => data = value));

      _scrollController.addListener(() {
        if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          final state =
              BlocProvider.of<PurchaseReturnRequestCubit>(context).state;
          if (state is PurchaseReturnRequestData && data.isNotEmpty) {
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
            "$query&\$filter=DocumentStatus eq 'bost_Open' and contains(CardCode, '${filter.text}')")
        .then((value) {
      if (!mounted) return;
      setState(() => data = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: PRIMARY_COLOR,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Return To Supplier Request - OPEN',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Column(
          children: [
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
                          hintText: 'Vendor Code...',
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

            SizedBox(
              height: 5,
            ),

            Expanded(
              child: BlocConsumer<PurchaseReturnRequestCubit,
                  PurchaseReturnRequestState>(
                listener: (context, state) {},
                builder: (context, state) {
                  if (state is RequestingPurchaseReturnRequest) {
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
                                  "No return to supplier request found !",
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
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F3F3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${getDataFromDynamic(po['CardCode'])} - ${getDataFromDynamic(po['DocNum'])}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      'Doc Date: ${getDataFromDynamic(po['DocDueDate'], isDate: true)}',
                                      style: const TextStyle(
                                          fontSize: 13, color: Colors.black87),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        getDataFromDynamic(po['Comments']),
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                    const SizedBox(width: 30),
                                    Text(
                                      'Delivery Date: ${getDataFromDynamic(po['DocDate'], isDate: true)}',
                                      style: const TextStyle(
                                          fontSize: 13, color: Colors.black87),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (state is RequestingPaginationPurchaseReturnRequest)
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
