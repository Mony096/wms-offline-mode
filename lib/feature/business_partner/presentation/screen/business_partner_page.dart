// // // import 'package:flutter/material.dart';
// // // import 'package:flutter_bloc/flutter_bloc.dart';
// // // import 'package:wms_mobile/core/enum/global.dart';
// // // import 'package:wms_mobile/helper/helper.dart';
// // // import 'package:wms_mobile/mobile_function/dashboard.dart';
// // // import 'package:wms_mobile/utilies/storage/locale_storage.dart';
// // // import '../cubit/business_partner_cubit.dart';
// // // import '/constant/style.dart';

// // // class BusinessPartnerPage extends StatefulWidget {
// // //   const BusinessPartnerPage({super.key, required this.type});

// // //   final BusinessPartnerType type;

// // //   @override
// // //   State<BusinessPartnerPage> createState() => _BusinessPartnerPageState();
// // // }

// // // class _BusinessPartnerPageState extends State<BusinessPartnerPage> {
// // //   final ScrollController _scrollController = ScrollController();

// // //   String query = "?\$top=10&\$skip=0";

// // //   int check = 1;
// // //   TextEditingController filter = TextEditingController();
// // //   List<dynamic> data = [];
// // //   late BusinessPartnerCubit _bloc;

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     if (mounted) {
// // //       _bloc = context.read<BusinessPartnerCubit>();
// // //       final state = context.read<BusinessPartnerCubit>().state;

// // //       if (state is BusinessPartnerData) {
// // //         data = state.entities;
// // //       }

// // //       if (data.length == 0) {
// // //         _bloc
// // //             .get("$query&\$filter=${getBPTypeQueryString(widget.type)}")
// // //             .then((value) {
// // //           setState(() => data = value);
// // //           _bloc.set(value);
// // //         });
// // //       }

// // //       setState(() {
// // //         data;
// // //       });

// // //       _scrollController.addListener(() {
// // //         if (_scrollController.position.pixels ==
// // //             _scrollController.position.maxScrollExtent) {
// // //           final state = BlocProvider.of<BusinessPartnerCubit>(context).state;
// // //           if (state is BusinessPartnerData && data.length > 0) {
// // //             _bloc
// // //                 .next(
// // //                     "?\$top=10&\$skip=${data.length}&\$filter=${getBPTypeQueryString(widget.type)} and contains(CardCode,'${filter.text}')")
// // //                 .then((value) {
// // //               if (!mounted) return;
// // //               _bloc.set([...data, ...value]);
// // //               setState(() => data = [...data, ...value]);
// // //             });
// // //           }
// // //         }
// // //       });
// // //     }
// // //   }

// // //   @override
// // //   void dispose() {
// // //     _scrollController.dispose();
// // //     filter.dispose();

// // //     super.dispose();
// // //   }

// // //   void onFilter() async {
// // //     setState(() {
// // //       data = [];
// // //     });
// // //     _bloc
// // //         .get(
// // //             "$query&\$filter=${getBPTypeQueryString(widget.type)} and contains(CardCode, '${filter.text}')")
// // //         .then((value) {
// // //       if (!mounted) return;

// // //       setState(() => data = value);
// // //     });
// // //   }

// // //   void onPressed(dynamic bp) {
// // //     Navigator.pop(context, bp);
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(
// // //         backgroundColor: PRIMARY_COLOR,
// // //         iconTheme: IconThemeData(color: Colors.white),
// // //         title: const Text(
// // //           'Business Partner Lists',
// // //           style: TextStyle(
// // //               fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
// // //         ),
// // //       ),
// // //       // bottomNavigationBar: MyBottomSheet(),
// // //       body: Container(
// // //         width: double.infinity,
// // //         height: double.infinity,
// // //         color: Color.fromARGB(255, 243, 243, 243),
// // //         child: Column(
// // //           children: [
// // //             Container(
// // //               padding:
// // //                   const EdgeInsets.only(left: 14, right: 14, bottom: 6, top: 4),
// // //               width: double.infinity,
// // //               decoration: BoxDecoration(color: Colors.white),
// // //               child: TextFormField(
// // //                 controller: filter,
// // //                 decoration: InputDecoration(
// // //                   enabledBorder: UnderlineInputBorder(
// // //                       borderSide: BorderSide(color: Colors.transparent)),
// // //                   focusedBorder: UnderlineInputBorder(
// // //                       borderSide: BorderSide(color: Colors.transparent)),
// // //                   contentPadding: const EdgeInsets.only(top: 15),
// // //                   hintText: 'BusinessPartner Code...',
// // //                   suffixIcon: IconButton(
// // //                     icon: Icon(
// // //                       Icons.search,
// // //                       color: PRIMARY_COLOR,
// // //                     ),
// // //                     onPressed: onFilter,
// // //                   ),
// // //                 ),
// // //               ),
// // //             ),
// // //             const Divider(thickness: 0.1, height: 15),
// // //             Expanded(
// // //               child: BlocConsumer<BusinessPartnerCubit, BusinessPartnerState>(
// // //                 listener: (context, state) {},
// // //                 builder: (context, state) {
// // //                   if (state is RequestingBusinessPartner) {
// // //                     return Center(child: CircularProgressIndicator());
// // //                   }

// // //                   return ListView(
// // //                     controller: _scrollController,
// // //                     children: [
// // //                       ...data
// // //                           .map(
// // //                             (bp) => GestureDetector(
// // //                               onTap: () => onPressed(bp),
// // //                               child: Container(
// // //                                 padding: const EdgeInsets.all(12),
// // //                                 decoration: BoxDecoration(
// // //                                   color: Colors.white,
// // //                                 ),
// // //                                 margin: const EdgeInsets.only(bottom: 8),
// // //                                 child: Column(
// // //                                   crossAxisAlignment: CrossAxisAlignment.start,
// // //                                   children: [
// // //                                     Text(
// // //                                       getDataFromDynamic(bp['CardCode']),
// // //                                       style: TextStyle(
// // //                                         fontWeight: FontWeight.w800,
// // //                                       ),
// // //                                     ),
// // //                                     const SizedBox(height: 6),
// // //                                     Text(
// // //                                       getDataFromDynamic(bp['CardName']),
// // //                                     ),
// // //                                   ],
// // //                                 ),
// // //                               ),
// // //                             ),
// // //                           )
// // //                           .toList(),
// // //                       if (state is RequestingPaginationBusinessPartner)
// // //                         Container(
// // //                           margin: const EdgeInsets.symmetric(vertical: 20),
// // //                           child: Center(
// // //                             child: SizedBox(
// // //                               width: 30,
// // //                               height: 30,
// // //                               child: CircularProgressIndicator(
// // //                                 strokeWidth: 3,
// // //                               ),
// // //                             ),
// // //                           ),
// // //                         )
// // //                     ],
// // //                   );
// // //                 },
// // //               ),
// // //             )
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// // import 'package:flutter/material.dart';
// // import 'package:flutter_bloc/flutter_bloc.dart';
// // import 'package:wms_mobile/core/enum/global.dart';
// // import 'package:wms_mobile/helper/helper.dart';
// // import 'package:wms_mobile/utilies/dialog/dialog.dart';
// // import '/constant/style.dart';
// // import '../cubit/business_partner_cubit.dart';

// // class BusinessPartnerPage extends StatefulWidget {
// //   const BusinessPartnerPage({super.key, required this.type});

// //   final BusinessPartnerType type;

// //   @override
// //   State<BusinessPartnerPage> createState() => _BusinessPartnerPageState();
// // }

// // class _BusinessPartnerPageState extends State<BusinessPartnerPage> {
// //   final ScrollController _scrollController = ScrollController();
// //   final TextEditingController filter = TextEditingController();

// //   String query = "?\$top=10&\$skip=0";
// //   List<dynamic> data = [];
// //   late BusinessPartnerCubit _bloc;

// //   @override
// //   void initState() {
// //     super.initState();
// //     if (mounted) {
// //       _bloc = context.read<BusinessPartnerCubit>();
// //       final state = _bloc.state;

// //       if (state is BusinessPartnerData) {
// //         data = state.entities;
// //       }

// //       if (data.isEmpty) {
// //         _bloc
// //             .get("$query&\$filter=${getBPTypeQueryString(widget.type)}")
// //             .then((value) {
// //           if (!mounted) return;
// //           setState(() => data = value);
// //           _bloc.set(value);
// //         });
// //       }

// //       _scrollController.addListener(() {
// //         if (_scrollController.position.pixels ==
// //             _scrollController.position.maxScrollExtent) {
// //           final state = _bloc.state;
// //           if (state is BusinessPartnerData && data.isNotEmpty) {
// //             _bloc
// //                 .next(
// //                     "?\$top=10&\$skip=${data.length}&\$filter=${getBPTypeQueryString(widget.type)} and contains(CardCode,'${filter.text}')")
// //                 .then((value) {
// //               if (!mounted) return;
// //               _bloc.set([...data, ...value]);
// //               setState(() => data = [...data, ...value]);
// //             });
// //           }
// //         }
// //       });
// //     }
// //   }

// //   @override
// //   void dispose() {
// //     _scrollController.dispose();
// //     filter.dispose();
// //     super.dispose();
// //   }

// //   void onFilter() async {
// //     setState(() => data = []);
// //     _bloc
// //         .get(
// //             "$query&\$filter=${getBPTypeQueryString(widget.type)} and contains(CardCode, '${filter.text}')")
// //         .then((value) {
// //       if (!mounted) return;
// //       setState(() => data = value);
// //     });
// //   }

// //   void onPressed(dynamic bp) async {
// //     try {
// //       MaterialDialog.loading(context);
// //       await Future.delayed(const Duration(milliseconds: 400));
// //       if (mounted) {
// //         MaterialDialog.close(context);
// //         Navigator.pop(context, bp);
// //       }
// //     } catch (_) {
// //       if (mounted) {
// //         MaterialDialog.success(context,
// //             title: 'Invalid', body: 'Business Partner not found.');
// //       }
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         backgroundColor: PRIMARY_COLOR,
// //         iconTheme: const IconThemeData(color: Colors.white),
// //         title: const Center(
// //           child: Padding(
// //             padding: EdgeInsets.only(right: 70),
// //             child: Text(
// //               "Business Partner Lists",
// //               style: TextStyle(
// //                 fontWeight: FontWeight.bold,
// //                 fontSize: 18,
// //                 color: Colors.white,
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //       body: Container(
// //         width: double.infinity,
// //         height: double.infinity,
// //         color: Colors.white,
// //         child: Column(
// //           children: [
// //             const SizedBox(height: 10),
// //             // 🔍 Search Bar
// //             Container(
// //               padding: const EdgeInsets.all(8),
// //               width: double.infinity,
// //               child: Row(
// //                 children: [
// //                   Expanded(
// //                     child: TextFormField(
// //                       controller: filter,
// //                       decoration: InputDecoration(
// //                         hintText: 'Search Business Partner',
// //                         filled: true,
// //                         fillColor: const Color.fromARGB(255, 243, 243, 243),
// //                         prefixIcon: Icon(Icons.search,
// //                             color: PRIMARY_COLOR), // left icon
// //                         border: OutlineInputBorder(
// //                           borderRadius: BorderRadius.circular(12),
// //                           borderSide:
// //                               BorderSide(color: Colors.grey.shade300, width: 1),
// //                         ),
// //                         enabledBorder: OutlineInputBorder(
// //                           borderRadius: BorderRadius.circular(12),
// //                           borderSide:
// //                               BorderSide(color: Colors.grey.shade300, width: 1),
// //                         ),
// //                         focusedBorder: OutlineInputBorder(
// //                           borderRadius: BorderRadius.circular(12),
// //                           borderSide:
// //                               BorderSide(color: PRIMARY_COLOR, width: 0.2),
// //                         ),
// //                         contentPadding: const EdgeInsets.symmetric(
// //                             vertical: 14, horizontal: 10),
// //                       ),
// //                     ),
// //                   ),
// //                   const SizedBox(width: 8),
// //                   Container(
// //                     height: 48,
// //                     width: 48,
// //                     decoration: BoxDecoration(
// //                       color: PRIMARY_COLOR,
// //                       borderRadius: BorderRadius.circular(12),
// //                     ),
// //                     child: IconButton(
// //                       icon:
// //                           const Icon(Icons.arrow_forward, color: Colors.white),
// //                       onPressed: onFilter,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),

// //             const SizedBox(height: 10),

// //             // 🧾 Business Partner List
// //             Expanded(
// //               child: BlocConsumer<BusinessPartnerCubit, BusinessPartnerState>(
// //                 listener: (context, state) {},
// //                 builder: (context, state) {
// //                   if (state is RequestingBusinessPartner) {
// //                     return const Center(child: CircularProgressIndicator());
// //                   }

// //                   return ListView(
// //                     controller: _scrollController,
// //                     children: [
// //                       ...data.map(
// //                         (bp) => GestureDetector(
// //                           onTap: () => onPressed(bp),
// //                           child: Container(
// //                             padding: const EdgeInsets.all(15),
// //                             decoration: BoxDecoration(
// //                               borderRadius: BorderRadius.circular(10),
// //                               color: const Color.fromARGB(255, 243, 243, 243),
// //                             ),
// //                             margin: const EdgeInsets.only(
// //                                 bottom: 8, left: 15, right: 15),
// //                             child: Column(
// //                               crossAxisAlignment: CrossAxisAlignment.start,
// //                               children: [
// //                                 Text(
// //                                   getDataFromDynamic(bp['CardCode']),
// //                                   style: const TextStyle(
// //                                     fontWeight: FontWeight.w800,
// //                                   ),
// //                                 ),
// //                                 const SizedBox(height: 6),
// //                                 Text(getDataFromDynamic(bp['CardName'])),
// //                               ],
// //                             ),
// //                           ),
// //                         ),
// //                       ),
// //                       if (state is RequestingPaginationBusinessPartner)
// //                         Container(
// //                           margin: const EdgeInsets.symmetric(vertical: 20),
// //                           child: const Center(
// //                             child: SizedBox(
// //                               width: 30,
// //                               height: 30,
// //                               child: CircularProgressIndicator(strokeWidth: 3),
// //                             ),
// //                           ),
// //                         ),
// //                     ],
// //                   );
// //                 },
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// // import 'package:flutter/material.dart';
// // import 'package:flutter_bloc/flutter_bloc.dart';
// // import 'package:wms_mobile/core/enum/global.dart';
// // import 'package:wms_mobile/helper/helper.dart';
// // import 'package:wms_mobile/mobile_function/dashboard.dart';
// // import 'package:wms_mobile/utilies/storage/locale_storage.dart';
// // import '../cubit/business_partner_cubit.dart';
// // import '/constant/style.dart';

// // class BusinessPartnerPage extends StatefulWidget {
// //   const BusinessPartnerPage({super.key, required this.type});

// //   final BusinessPartnerType type;

// //   @override
// //   State<BusinessPartnerPage> createState() => _BusinessPartnerPageState();
// // }

// // class _BusinessPartnerPageState extends State<BusinessPartnerPage> {
// //   final ScrollController _scrollController = ScrollController();

// //   String query = "?\$top=10&\$skip=0";

// //   int check = 1;
// //   TextEditingController filter = TextEditingController();
// //   List<dynamic> data = [];
// //   late BusinessPartnerCubit _bloc;

// //   @override
// //   void initState() {
// //     super.initState();
// //     if (mounted) {
// //       _bloc = context.read<BusinessPartnerCubit>();
// //       final state = context.read<BusinessPartnerCubit>().state;

// //       if (state is BusinessPartnerData) {
// //         data = state.entities;
// //       }

// //       if (data.length == 0) {
// //         _bloc
// //             .get("$query&\$filter=${getBPTypeQueryString(widget.type)}")
// //             .then((value) {
// //           setState(() => data = value);
// //           _bloc.set(value);
// //         });
// //       }

// //       setState(() {
// //         data;
// //       });

// //       _scrollController.addListener(() {
// //         if (_scrollController.position.pixels ==
// //             _scrollController.position.maxScrollExtent) {
// //           final state = BlocProvider.of<BusinessPartnerCubit>(context).state;
// //           if (state is BusinessPartnerData && data.length > 0) {
// //             _bloc
// //                 .next(
// //                     "?\$top=10&\$skip=${data.length}&\$filter=${getBPTypeQueryString(widget.type)} and contains(CardCode,'${filter.text}')")
// //                 .then((value) {
// //               if (!mounted) return;
// //               _bloc.set([...data, ...value]);
// //               setState(() => data = [...data, ...value]);
// //             });
// //           }
// //         }
// //       });
// //     }
// //   }

// //   @override
// //   void dispose() {
// //     _scrollController.dispose();
// //     filter.dispose();

// //     super.dispose();
// //   }

// //   void onFilter() async {
// //     setState(() {
// //       data = [];
// //     });
// //     _bloc
// //         .get(
// //             "$query&\$filter=${getBPTypeQueryString(widget.type)} and contains(CardCode, '${filter.text}')")
// //         .then((value) {
// //       if (!mounted) return;

// //       setState(() => data = value);
// //     });
// //   }

// //   void onPressed(dynamic bp) {
// //     Navigator.pop(context, bp);
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         backgroundColor: PRIMARY_COLOR,
// //         iconTheme: IconThemeData(color: Colors.white),
// //         title: const Text(
// //           'Business Partner Lists',
// //           style: TextStyle(
// //               fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
// //         ),
// //       ),
// //       // bottomNavigationBar: MyBottomSheet(),
// //       body: Container(
// //         width: double.infinity,
// //         height: double.infinity,
// //         color: Color.fromARGB(255, 243, 243, 243),
// //         child: Column(
// //           children: [
// //             Container(
// //               padding:
// //                   const EdgeInsets.only(left: 14, right: 14, bottom: 6, top: 4),
// //               width: double.infinity,
// //               decoration: BoxDecoration(color: Colors.white),
// //               child: TextFormField(
// //                 controller: filter,
// //                 decoration: InputDecoration(
// //                   enabledBorder: UnderlineInputBorder(
// //                       borderSide: BorderSide(color: Colors.transparent)),
// //                   focusedBorder: UnderlineInputBorder(
// //                       borderSide: BorderSide(color: Colors.transparent)),
// //                   contentPadding: const EdgeInsets.only(top: 15),
// //                   hintText: 'BusinessPartner Code...',
// //                   suffixIcon: IconButton(
// //                     icon: Icon(
// //                       Icons.search,
// //                       color: PRIMARY_COLOR,
// //                     ),
// //                     onPressed: onFilter,
// //                   ),
// //                 ),
// //               ),
// //             ),
// //             const Divider(thickness: 0.1, height: 15),
// //             Expanded(
// //               child: BlocConsumer<BusinessPartnerCubit, BusinessPartnerState>(
// //                 listener: (context, state) {},
// //                 builder: (context, state) {
// //                   if (state is RequestingBusinessPartner) {
// //                     return Center(child: CircularProgressIndicator());
// //                   }

// //                   return ListView(
// //                     controller: _scrollController,
// //                     children: [
// //                       ...data
// //                           .map(
// //                             (bp) => GestureDetector(
// //                               onTap: () => onPressed(bp),
// //                               child: Container(
// //                                 padding: const EdgeInsets.all(12),
// //                                 decoration: BoxDecoration(
// //                                   color: Colors.white,
// //                                 ),
// //                                 margin: const EdgeInsets.only(bottom: 8),
// //                                 child: Column(
// //                                   crossAxisAlignment: CrossAxisAlignment.start,
// //                                   children: [
// //                                     Text(
// //                                       getDataFromDynamic(bp['CardCode']),
// //                                       style: TextStyle(
// //                                         fontWeight: FontWeight.w800,
// //                                       ),
// //                                     ),
// //                                     const SizedBox(height: 6),
// //                                     Text(
// //                                       getDataFromDynamic(bp['CardName']),
// //                                     ),
// //                                   ],
// //                                 ),
// //                               ),
// //                             ),
// //                           )
// //                           .toList(),
// //                       if (state is RequestingPaginationBusinessPartner)
// //                         Container(
// //                           margin: const EdgeInsets.symmetric(vertical: 20),
// //                           child: Center(
// //                             child: SizedBox(
// //                               width: 30,
// //                               height: 30,
// //                               child: CircularProgressIndicator(
// //                                 strokeWidth: 3,
// //                               ),
// //                             ),
// //                           ),
// //                         )
// //                     ],
// //                   );
// //                 },
// //               ),
// //             )
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:wms_mobile/core/enum/global.dart';
// import 'package:wms_mobile/helper/helper.dart';
// import 'package:wms_mobile/utilies/dialog/dialog.dart';
// import '/constant/style.dart';
// import '../cubit/business_partner_cubit.dart';

// class BusinessPartnerPage extends StatefulWidget {
//   const BusinessPartnerPage({super.key, required this.type});

//   final BusinessPartnerType type;

//   @override
//   State<BusinessPartnerPage> createState() => _BusinessPartnerPageState();
// }

// class _BusinessPartnerPageState extends State<BusinessPartnerPage> {
//   final ScrollController _scrollController = ScrollController();
//   final TextEditingController filter = TextEditingController();

//   String query = "?\$top=10&\$skip=0";
//   List<dynamic> data = [];
//   late BusinessPartnerCubit _bloc;

//   @override
//   void initState() {
//     super.initState();
//     if (mounted) {
//       _bloc = context.read<BusinessPartnerCubit>();
//       final state = _bloc.state;

//       if (state is BusinessPartnerData) {
//         data = state.entities;
//       }

//       if (data.isEmpty) {
//         _bloc
//             .get("$query&\$filter=${getBPTypeQueryString(widget.type)}")
//             .then((value) {
//           if (!mounted) return;
//           setState(() => data = value);
//           _bloc.set(value);
//         });
//       }

//       _scrollController.addListener(() {
//         if (_scrollController.position.pixels ==
//             _scrollController.position.maxScrollExtent) {
//           final state = _bloc.state;
//           if (state is BusinessPartnerData && data.isNotEmpty) {
//             _bloc
//                 .next(
//                     "?\$top=10&\$skip=${data.length}&\$filter=${getBPTypeQueryString(widget.type)} and contains(CardCode,'${filter.text}')")
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
//     setState(() => data = []);
//     _bloc
//         .get(
//             "$query&\$filter=${getBPTypeQueryString(widget.type)} and contains(CardCode, '${filter.text}')")
//         .then((value) {
//       if (!mounted) return;
//       setState(() => data = value);
//     });
//   }

//   void onPressed(dynamic bp) async {
//     try {
//       MaterialDialog.loading(context);
//       await Future.delayed(const Duration(milliseconds: 400));
//       if (mounted) {
//         MaterialDialog.close(context);
//         Navigator.pop(context, bp);
//       }
//     } catch (_) {
//       if (mounted) {
//         MaterialDialog.success(context,
//             title: 'Invalid', body: 'Business Partner not found.');
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: PRIMARY_COLOR,
//         iconTheme: const IconThemeData(color: Colors.white),
//         title: const Center(
//           child: Padding(
//             padding: EdgeInsets.only(right: 70),
//             child: Text(
//               "Business Partner Lists",
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 18,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//         ),
//       ),
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         color: Colors.white,
//         child: Column(
//           children: [
//             const SizedBox(height: 10),
//             // 🔍 Search Bar
//             Container(
//               padding: const EdgeInsets.all(8),
//               width: double.infinity,
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: TextFormField(
//                       controller: filter,
//                       decoration: InputDecoration(
//                         hintText: 'Search Business Partner',
//                         filled: true,
//                         fillColor: const Color.fromARGB(255, 243, 243, 243),
//                         prefixIcon: Icon(Icons.search,
//                             color: PRIMARY_COLOR), // left icon
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide:
//                               BorderSide(color: Colors.grey.shade300, width: 1),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide:
//                               BorderSide(color: Colors.grey.shade300, width: 1),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide:
//                               BorderSide(color: PRIMARY_COLOR, width: 0.2),
//                         ),
//                         contentPadding: const EdgeInsets.symmetric(
//                             vertical: 14, horizontal: 10),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Container(
//                     height: 48,
//                     width: 48,
//                     decoration: BoxDecoration(
//                       color: PRIMARY_COLOR,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: IconButton(
//                       icon:
//                           const Icon(Icons.arrow_forward, color: Colors.white),
//                       onPressed: onFilter,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 10),

//             // 🧾 Business Partner List
//             Expanded(
//               child: BlocConsumer<BusinessPartnerCubit, BusinessPartnerState>(
//                 listener: (context, state) {},
//                 builder: (context, state) {
//                   if (state is RequestingBusinessPartner) {
//                     return const Center(child: CircularProgressIndicator());
//                   }

//                   return ListView(
//                     controller: _scrollController,
//                     children: [
//                       ...data.map(
//                         (bp) => GestureDetector(
//                           onTap: () => onPressed(bp),
//                           child: Container(
//                             padding: const EdgeInsets.all(15),
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(10),
//                               color: const Color.fromARGB(255, 243, 243, 243),
//                             ),
//                             margin: const EdgeInsets.only(
//                                 bottom: 8, left: 15, right: 15),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   getDataFromDynamic(bp['CardCode']),
//                                   style: const TextStyle(
//                                     fontWeight: FontWeight.w800,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 6),
//                                 Text(getDataFromDynamic(bp['CardName'])),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                       if (state is RequestingPaginationBusinessPartner)
//                         Container(
//                           margin: const EdgeInsets.symmetric(vertical: 20),
//                           child: const Center(
//                             child: SizedBox(
//                               width: 30,
//                               height: 30,
//                               child: CircularProgressIndicator(strokeWidth: 3),
//                             ),
//                           ),
//                         ),
//                     ],
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_mobile/core/enum/global.dart';
import 'package:wms_mobile/feature/business_partner/presentation/cubit/bussinessPartner_offline_cubit.dart';
import 'package:wms_mobile/helper/helper.dart';
import 'package:wms_mobile/utilies/dialog/dialog.dart';
import '/constant/style.dart';

class BusinessPartnerPage extends StatefulWidget {
  const BusinessPartnerPage({super.key, required this.type});

  final BusinessPartnerType type;

  @override
  State<BusinessPartnerPage> createState() => _BusinessPartnerPageState();
}

class _BusinessPartnerPageState extends State<BusinessPartnerPage> {
  final TextEditingController filter = TextEditingController();
  List<dynamic> filteredData = [];

  @override
  void initState() {
    super.initState();
    // Initial filter on load
    final offlineData = context.read<BusinessOfflineCubit>().state;
    _applyFilter(offlineData);
  }

  void _applyFilter(List<dynamic> allData) {
    final searchText = filter.text.trim().toLowerCase();
    final cardType = _mapType(widget.type);

    final results = allData.where((bp) {
      final typeMatch =
          getDataFromDynamic(bp['CardType']).toString().toLowerCase() ==
              cardType.toLowerCase();
      final code = getDataFromDynamic(bp['CardCode']).toLowerCase();
      final name = getDataFromDynamic(bp['CardName']).toLowerCase();

      if (searchText.isEmpty) return typeMatch;
      return typeMatch &&
          (code.contains(searchText) || name.contains(searchText));
    }).toList();

    setState(() => filteredData = results);
    debugPrint(
        "🔎 Filter: '$searchText', type: '$cardType' → ${filteredData.length} results");
  }

  // Map enum to SAP CardType
  String _mapType(BusinessPartnerType type) {
    switch (type) {
      case BusinessPartnerType.customer:
        return "cCustomer"; // or 'C' depending on your API data
      case BusinessPartnerType.supplier:
        return "cSupplier";
      default:
        return "";
    }
  }

  void onFilterPressed() {
    final allData = context.read<BusinessOfflineCubit>().state;
    _applyFilter(allData);
  }

  void onPressed(dynamic bp) async {
    try {
      MaterialDialog.loading(context);
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        MaterialDialog.close(context);
        Navigator.pop(context, bp);
      }
    } catch (_) {
      if (mounted) {
        MaterialDialog.success(context,
            title: 'Invalid', body: 'Business Partner not found.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: PRIMARY_COLOR,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Center(
          child: Padding(
            padding: EdgeInsets.only(right: 70),
            child: Text(
              "Business Partner Lists",
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
        color: Colors.white,
        child: Column(
          children: [
            const SizedBox(height: 10),
            // 🔍 Search Bar
            Container(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: filter,
                      decoration: InputDecoration(
                        hintText: 'Search Business Partner',
                        filled: true,
                        fillColor: const Color.fromARGB(255, 243, 243, 243),
                        prefixIcon: Icon(Icons.search, color: PRIMARY_COLOR),
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
                      onPressed: onFilterPressed,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // 🧾 Offline Business Partner List
            Expanded(
              child: BlocBuilder<BusinessOfflineCubit, List<dynamic>>(
                builder: (context, state) {
                  // final allData = state;
                  // if (filteredData.isEmpty && filter.text.isEmpty) {
                  //   _applyFilter(allData);
                  // }

                  // if (filteredData.isEmpty) {
                  //   return const Center(
                  //     child: Text("No matching business partners found."),
                  //   );
                  // }
                  // Apply filter only once after first frame
                  if (filteredData.isEmpty && filter.text.isEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _applyFilter(state);
                    });
                  }

                  if (filteredData.isEmpty) {
                    return const Center(
                      child: Text("No matching business partners found."),
                    );
                  }
                  return ListView.builder(
                    itemCount: filteredData.length,
                    itemBuilder: (context, index) {
                      final bp = filteredData[index];
                      return GestureDetector(
                        onTap: () => onPressed(bp),
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 243, 243, 243),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                getDataFromDynamic(bp['CardCode']),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                getDataFromDynamic(bp['CardName']),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
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
}
