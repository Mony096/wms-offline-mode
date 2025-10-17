// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '/constant/style.dart';
// import '../../domain/entity/unit_of_measurement_entity.dart';
// import '../cubit/uom_cubit.dart';

// class UnitOfMeasurementPage extends StatefulWidget {
//   const UnitOfMeasurementPage({super.key, required this.ids});

//   final List<int> ids;

//   @override
//   State<UnitOfMeasurementPage> createState() => _UnitOfMeasurementPageState();
// }

// class _UnitOfMeasurementPageState extends State<UnitOfMeasurementPage> {
//   String query = "?\$top=100&\$select=AbsEntry,Code,Name";

//   List<UnitOfMeasurementEntity> data = [];
//   List<UnitOfMeasurementEntity> filteredData = [];

//   late UnitOfMeasurementCubit _bloc;
//   final TextEditingController _filter = TextEditingController();

//   @override
//   void initState() {
//     super.initState();

//     _bloc = context.read<UnitOfMeasurementCubit>();
//     final state = _bloc.state;

//     if (state is UnitOfMeasurementData) {
//       data = state.entities;
//       filteredData = data;
//     }

//     if (data.isEmpty) {
//       _bloc.get(query).then((value) {
//         setState(() {
//           data = value;
//           filteredData = value;
//         });
//         _bloc.set(value);
//       });
//     }

//     // Live search listener
//     _filter.addListener(() {
//       final text = _filter.text.toLowerCase();
//       setState(() {
//         filteredData = data
//             .where((uom) =>
//                 (uom.code.toLowerCase().contains(text) ||
//                     uom.name.toLowerCase().contains(text)) &&
//                 widget.ids.contains(uom.id))
//             .toList();
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _filter.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         color: Colors.white,
//         child: Column(
//           children: [
//             const SizedBox(height: 50),
//             // 🔹 Header Row with Filter
//             Padding(
//               padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
//               child: Row(
//                 children: [
//                   const Text(
//                     "Unit of Measurement",
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(width: 20),
//                   Expanded(
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: Colors.grey[100],
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: Colors.grey[300]!),
//                       ),
//                       child: TextField(
//                         controller: _filter,
//                         decoration: InputDecoration(
//                           prefixIcon: const Icon(Icons.search),
//                           hintText: 'Search...',
//                           suffixIcon: _filter.text.isNotEmpty
//                               ? IconButton(
//                                   icon: const Icon(Icons.clear),
//                                   onPressed: () {
//                                     _filter.clear();
//                                     setState(() {
//                                       filteredData = data
//                                           .where((uom) =>
//                                               widget.ids.contains(uom.id))
//                                           .toList();
//                                     });
//                                   },
//                                 )
//                               : null,
//                           border: InputBorder.none,
//                           contentPadding:
//                               const EdgeInsets.symmetric(vertical: 13),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // 🔹 Data List
//             Expanded(
//               child:
//                   BlocConsumer<UnitOfMeasurementCubit, UnitOfMeasurementState>(
//                 listener: (context, state) {},
//                 builder: (context, state) {
//                   if (state is RequestingUnitOfMeasurement) {
//                     return const Center(child: CircularProgressIndicator());
//                   }

//                   final displayList = filteredData
//                       .where((uom) => widget.ids.contains(uom.id))
//                       .toList();

//                   return ListView(
//                     children: [
//                       ...displayList.map(
//                         (uom) => GestureDetector(
//                           onTap: () => Navigator.of(context).pop(uom),
//                           child: Container(
//                             padding: const EdgeInsets.all(15),
//                             margin: const EdgeInsets.symmetric(
//                                 horizontal: 10, vertical: 5),
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(10),
//                               color: const Color.fromARGB(255, 243, 243, 243),
//                             ),
//                             child: Row(
//                               children: [
//                                 Expanded(
//                                   child: Text(
//                                     "${uom.code} - ${uom.name}",
//                                     style: const TextStyle(
//                                       fontWeight: FontWeight.w800,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                       if (state is RequestingPaginationUnitOfMeasurement)
//                         const Padding(
//                           padding: EdgeInsets.symmetric(vertical: 20),
//                           child: Center(
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
import '../cubit/uom_offline_cubit.dart'; // 🟡 Use your offline cubit

class UnitOfMeasurementPage extends StatefulWidget {
  const UnitOfMeasurementPage({super.key, required this.ids});

  final List<int> ids;

  @override
  State<UnitOfMeasurementPage> createState() => _UnitOfMeasurementPageState();
}

class _UnitOfMeasurementPageState extends State<UnitOfMeasurementPage> {
  List<dynamic> data = [];
  List<dynamic> filteredData = [];

  final TextEditingController _filter = TextEditingController();

  @override
  void initState() {
    super.initState();

    final offlineCubit = context.read<UOMOfflineCubit>();
    final offlineData = offlineCubit.state;
    print(widget.ids);
    // 🧠 Filter only items matching the given IDs
    data =
        offlineData.where((e) => widget.ids.contains(e['AbsEntry'])).toList();

    filteredData = data;

    // 🔍 Live search
    _filter.addListener(() {
      final text = _filter.text.toLowerCase();
      setState(() {
        filteredData = data
            .where((uom) =>
                (uom['Code'].toString().toLowerCase().contains(text) ||
                    uom['Name'].toString().toLowerCase().contains(text)) &&
                widget.ids.contains(uom['AbsEntry']))
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

            // 🔹 Header with Search
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
                                          .where((uom) => widget.ids
                                              .contains(uom['AbsEntry']))
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

            // 🔹 Offline Data List
            Expanded(
              child: BlocBuilder<UOMOfflineCubit, List<dynamic>>(
                builder: (context, state) {
                  final displayList = filteredData
                      .where((uom) => widget.ids.contains(uom['AbsEntry']))
                      .toList();

                  if (displayList.isEmpty) {
                    return const Center(
                      child: Text(
                        "No data found",
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: displayList.length,
                    itemBuilder: (context, index) {
                      final uom = displayList[index];
                      return GestureDetector(
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
                                  "${uom['Code']} - ${uom['Name']}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
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
