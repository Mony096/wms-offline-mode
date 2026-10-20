import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_mobile/constant/style.dart';
import 'package:wms_mobile/utilies/dialog/dialog.dart';
import '/helper/helper.dart';
import 'package:wms_mobile/feature/counting/cos/presentation/cubit/cos_offline_cubit.dart'; // 👈 Import your offline cubit

class CosPage extends StatefulWidget {
  const CosPage({super.key});

  @override
  State<CosPage> createState() => _CosPageState();
}

class _CosPageState extends State<CosPage> {
  final TextEditingController filter = TextEditingController();
  List<dynamic> filteredData = [];

  @override
  void initState() {
    super.initState();
    final cubit = context.read<COSOfflineCubit>();
    filteredData = cubit.state; // Load initial data
  }

  void onFilter() {
    final cubit = context.read<COSOfflineCubit>();
    final allData = cubit.getJsonData();
    final query = filter.text.trim().toLowerCase();

    setState(() {
      if (query.isEmpty) {
        filteredData = allData;
      } else {
        filteredData = allData
            .where((item) => getDataFromDynamic(item['DocumentNumber'])
                .toString()
                .toLowerCase()
                .contains(query))
            .toList();
      }
    });
  }

  void onFind(String code) async {
    try {
      MaterialDialog.loading(context);

      final cubit = context.read<COSOfflineCubit>();
      final allData = cubit.getJsonData();

      final result = allData.firstWhere(
        (e) => getDataFromDynamic(e['DocumentEntry']).toString() == code,
        orElse: () => {},
      );

      MaterialDialog.close(context);

      if (result.isEmpty) {
        MaterialDialog.success(context,
            title: 'Invalid', body: 'Counting Sheet not found - $code');
      } else {
        Navigator.pop(context, result);
      }
    } catch (e) {
      MaterialDialog.close(context);
      MaterialDialog.success(context,
          title: 'Error', body: 'Something went wrong.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<COSOfflineCubit, List<dynamic>>(
        builder: (context, state) {
          final cubit = context.read<COSOfflineCubit>();

          // Refresh filtered list when data changes
          final allData = cubit.getJsonData();
          if (filter.text.isEmpty) filteredData = allData;

          if (filteredData.isEmpty) {
            return const Center(
              child: Text("No offline data found.",
                  style: TextStyle(fontSize: 15)),
            );
          }

          return Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white,
            child: Column(
              children: [
                const SizedBox(height: 50),
                // 🔹 Header Row with Back Button
                Container(
                  margin: const EdgeInsets.only(left: 9),
                  padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                  child: Row(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.all(8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(Icons.arrow_back, size: 20),
                      ),
                      const SizedBox(width: 20),
                      const Text(
                        "Counting Sheet Lists",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 🔹 Search Bar
                Container(
                  margin: const EdgeInsets.only(left: 20, top: 25, right: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: TextField(
                    controller: filter,
                    onChanged: (_) => onFilter(),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search Document Number...',
                      suffixIcon: filter.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                filter.clear();
                                onFilter();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // 🧾 Offline List
              Expanded(
                child: ListView.builder(
                  itemCount: filteredData.length,
                  itemBuilder: (context, index) {
                    final cos = filteredData[index];
                    return GestureDetector(
                      onTap: () => onFind(
                          getDataFromDynamic(cos['DocumentEntry']).toString()),
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text.rich(
                                    TextSpan(
                                      text: "Document No. : ",
                                      style: const TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 13.5),
                                      children: [
                                        TextSpan(
                                          text: getDataFromDynamic(
                                              cos['DocumentNumber']),
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Text.rich(
                                  TextSpan(
                                    text: "Count Date : ",
                                    style: const TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 13.5),
                                    children: [
                                      TextSpan(
                                        text: getDataFromDynamic(
                                                cos['CountDate'] ?? '-')
                                            .split('T')[0],
                                        // style: const TextStyle(
                                        //     color: Colors.black,
                                        //     fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text.rich(
                                    TextSpan(
                                      text: "Status              : ",
                                      style: const TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 13.5),
                                      children: [
                                        TextSpan(
                                          text: getDataFromDynamic(
                                              cos['DocumentStatus']
                                                      ?.split("cds")
                                                      .last ??
                                                  "-"),
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Text.rich(
                                  TextSpan(
                                    text: "Count Time : ",
                                    style: const TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 13.5),
                                    children: [
                                      TextSpan(
                                        text: getDataFromDynamic(
                                            '${cos['CountTime']}     ' ??
                                                cos['Time'] ??
                                                '-'),
                                        // style: const TextStyle(
                                        //     color: Colors.black,
                                        //     fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
      ),
    );
  }

  @override
  void dispose() {
    filter.dispose();
    super.dispose();
  }
}
