// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../domain/entity/unit_of_measurement_entity.dart';
// import '../cubit/uom_cubit.dart';
// import '/constant/style.dart';

// class UnitOfMeasurementPage extends StatefulWidget {
//   const UnitOfMeasurementPage({super.key, required this.ids});

//   final List<int> ids;

//   @override
//   State<UnitOfMeasurementPage> createState() => _UnitOfMeasurementPageState();
// }

// class _UnitOfMeasurementPageState extends State<UnitOfMeasurementPage> {
//   String query = "?\$top=100&\$select=AbsEntry,Code,Name";

//   int check = 1;
//   List<UnitOfMeasurementEntity> data = [];
//   late UnitOfMeasurementCubit _bloc;

//   @override
//   void initState() {
//     super.initState();
//     if (mounted) {
//       _bloc = context.read<UnitOfMeasurementCubit>();
//       final state = context.read<UnitOfMeasurementCubit>().state;

//       if (state is UnitOfMeasurementData) {
//         data = state.entities;
//       }

//       if (data.isEmpty) {
//         _bloc.get(query).then((value) {
//           setState(() => data = value);
//           _bloc.set(value);
//         });
//       }

//       setState(() {
//         data;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: PRIMARY_COLOR,
//         iconTheme: IconThemeData(color: Colors.white),
//         title: const Text(
//           'Unit Of Measurement Lists',
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
//             const Divider(thickness: 0.1, height: 15),
//             Expanded(
//               child:
//                   BlocConsumer<UnitOfMeasurementCubit, UnitOfMeasurementState>(
//                 listener: (context, state) {},
//                 builder: (context, state) {
//                   if (state is RequestingUnitOfMeasurement) {
//                     return Center(child: CircularProgressIndicator());
//                   }

//                   return ListView(
//                     children: [
//                       ...data
//                           .where((uom) => widget.ids.contains(uom.id))
//                           .map(
//                             (uom) => GestureDetector(
//                               onTap: () => Navigator.of(context).pop(uom),
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
//                                       "${uom.code} - ${uom.name}",
//                                       style: TextStyle(
//                                         fontWeight: FontWeight.w800,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           )
//                           .toList(),
//                       if (state is RequestingPaginationUnitOfMeasurement)
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
import '../../domain/entity/unit_of_measurement_entity.dart';
import '../cubit/uom_cubit.dart';

class UnitOfMeasurementPage extends StatefulWidget {
  const UnitOfMeasurementPage({super.key, required this.ids});

  final List<int> ids;

  @override
  State<UnitOfMeasurementPage> createState() => _UnitOfMeasurementPageState();
}

class _UnitOfMeasurementPageState extends State<UnitOfMeasurementPage> {
  String query = "?\$top=100&\$select=AbsEntry,Code,Name";

  List<UnitOfMeasurementEntity> data = [];
  List<UnitOfMeasurementEntity> filteredData = [];

  late UnitOfMeasurementCubit _bloc;
  final TextEditingController _filter = TextEditingController();

  @override
  void initState() {
    super.initState();

    _bloc = context.read<UnitOfMeasurementCubit>();
    final state = _bloc.state;

    if (state is UnitOfMeasurementData) {
      data = state.entities;
      filteredData = data;
    }

    if (data.isEmpty) {
      _bloc.get(query).then((value) {
        setState(() {
          data = value;
          filteredData = value;
        });
        _bloc.set(value);
      });
    }

    // Live search listener
    _filter.addListener(() {
      final text = _filter.text.toLowerCase();
      setState(() {
        filteredData = data
            .where((uom) =>
                (uom.code.toLowerCase().contains(text) ||
                    uom.name.toLowerCase().contains(text)) &&
                widget.ids.contains(uom.id))
            .toList();
      });
    });
  }

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
            // 🔹 Header Row with Filter
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
              child: Row(
                children: [
                  const Text(
                    "Unit of Measurement",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Container(
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
                                      filteredData = data
                                          .where((uom) =>
                                              widget.ids.contains(uom.id))
                                          .toList();
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

            // 🔹 Data List
            Expanded(
              child:
                  BlocConsumer<UnitOfMeasurementCubit, UnitOfMeasurementState>(
                listener: (context, state) {},
                builder: (context, state) {
                  if (state is RequestingUnitOfMeasurement) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final displayList = filteredData
                      .where((uom) => widget.ids.contains(uom.id))
                      .toList();

                  return ListView(
                    children: [
                      ...displayList.map(
                        (uom) => GestureDetector(
                          onTap: () => Navigator.of(context).pop(uom),
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: const Color.fromARGB(255, 243, 243, 243),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "${uom.code} - ${uom.name}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (state is RequestingPaginationUnitOfMeasurement)
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
