import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_mobile/constant/style.dart';
import '../cubit/receipt_type_offline_cubit.dart';

class GrtPage extends StatefulWidget {
  const GrtPage({super.key});

  @override
  State<GrtPage> createState() => _GrtOfflinePageState();
}

class _GrtOfflinePageState extends State<GrtPage> {
  List<dynamic> data = [];
  List<dynamic> filteredData = [];

  final TextEditingController _filter = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Listen to cubit state (list of receipt types from Hive)
    final state = context.read<ReceiptTypeOfflineCubit>().state;
    data = state;
    filteredData = data;

    // Listen for updates (optional but useful if data changes in background)
    context.read<ReceiptTypeOfflineCubit>().stream.listen((items) {
      setState(() {
        data = items;
        filteredData = items;
      });
    });

    // 🔹 Live Search Filter
    _filter.addListener(() {
      final text = _filter.text.toLowerCase();
      setState(() {
        filteredData = data
            .where((item) =>
                (item['Code']?.toString().toLowerCase().contains(text) ??
                    false) ||
                (item['Name']?.toString().toLowerCase().contains(text) ??
                    false))
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
                    "Goods Receipt Types",
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

            // 🔹 Data List
            Expanded(
              child: BlocBuilder<ReceiptTypeOfflineCubit, List<dynamic>>(
                builder: (context, state) {
                  if (state.isEmpty) {
                    return const Center(child: Text("No Data Available"));
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
                                  "${item['Code']} - ${item['Name']}",
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
