// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../domain/entity/grt_entity.dart';
// import '../cubit/grt_cubit.dart';
// import '/constant/style.dart';

// class GrtPage extends StatefulWidget {
//   const GrtPage({
//     super.key,
//   });

//   @override
//   State<GrtPage> createState() => _GrtPageState();
// }

// class _GrtPageState extends State<GrtPage> {
//   String query = "?\$top=100&\$select=Code,Name";

//   int check = 1;
//   List<GrtEntity> data = [];
//   late GrtCubit _bloc;

//   @override
//   void initState() {
//     super.initState();
//     if (mounted) {
//       _bloc = context.read<GrtCubit>();
//       final state = context.read<GrtCubit>().state;

//       if (state is GrtData) {
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
//       print(data);
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
//           'Good Receipt Type Lists',
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
//               child: BlocConsumer<GrtCubit, GrtState>(
//                 listener: (context, state) {},
//                 builder: (context, state) {
//                   if (state is RequestingGrt) {
//                     return Center(child: CircularProgressIndicator());
//                   }

//                   return ListView(
//                     children: [
//                       ...data
//                           .map(
//                             (Grt) => GestureDetector(
//                               onTap: () => Navigator.of(context).pop(Grt),
//                               child: Container(
//                                 padding: const EdgeInsets.all(12),
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                 ),
//                                 margin: const EdgeInsets.only(bottom: 8),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Row(
//                                       children: [
//                                         Text(
//                                           Grt.code,
//                                           style: TextStyle(
//                                             fontWeight: FontWeight.w800,
//                                           ),
//                                         ),
//                                         SizedBox(
//                                           width: 5,
//                                         ),
//                                         Text(
//                                           "-",
//                                           style: TextStyle(
//                                             fontWeight: FontWeight.w800,
//                                           ),
//                                         ),
//                                         SizedBox(
//                                           width: 5,
//                                         ),
//                                         Text(
//                                           Grt.name,
//                                           style: TextStyle(
//                                             fontWeight: FontWeight.w800,
//                                           ),
//                                         ),
//                                       ],
//                                     )
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           )
//                           .toList(),
//                       if (state is RequestingPaginationGrt)
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
import '../../domain/entity/grt_entity.dart';
import '../cubit/grt_cubit.dart';
import '/constant/style.dart';

class GrtPage extends StatefulWidget {
  const GrtPage({super.key});

  @override
  State<GrtPage> createState() => _GrtPageState();
}

class _GrtPageState extends State<GrtPage> {
  String query = "?\$top=100&\$select=Code,Name";
  List<GrtEntity> data = [];
  List<GrtEntity> filteredData = [];

  late GrtCubit _bloc;
  final TextEditingController _filter = TextEditingController();

  @override
  void initState() {
    super.initState();

    _bloc = context.read<GrtCubit>();
    final state = _bloc.state;

    if (state is GrtData) {
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

    // 🔹 Live Search Filter
    _filter.addListener(() {
      final text = _filter.text.toLowerCase();
      setState(() {
        filteredData = data
            .where((item) =>
                item.code.toLowerCase().contains(text) ||
                item.name.toLowerCase().contains(text))
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
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Column(
          children: [
            const SizedBox(height: 50),

            // 🔹 Header Row with Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  const Text(
                    "Good Receipt Types",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100], // bg-slate style
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

            // const SizedBox(height: 10),

            // 🔹 Data List
            Expanded(
              child: BlocConsumer<GrtCubit, GrtState>(
                listener: (context, state) {},
                builder: (context, state) {
                  if (state is RequestingGrt) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return ListView.builder(
                    itemCount: filteredData.length,
                    itemBuilder: (context, index) {
                      final item = filteredData[index];

                      return GestureDetector(
                        onTap: () => Navigator.of(context).pop(item),
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
                                  "${item.code} - ${item.name}",
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
