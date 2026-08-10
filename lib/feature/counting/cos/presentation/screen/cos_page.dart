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
      appBar: AppBar(
        backgroundColor: PRIMARY_COLOR,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Counting Sheet Lists',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: "Reload Offline Data",
            onPressed: () {
              final cubit = context.read<COSOfflineCubit>();
              cubit.loadData();
              setState(() => filteredData = cubit.state);
            },
          ),
        ],
      ),
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

          return Column(
            children: [
              const SizedBox(height: 4),
              // 🔍 Search Bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                            hintText: 'Search Document Number...',
                              hintStyle: const TextStyle(
                            fontSize: 13.5,
                            color: Colors.grey,
                          ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 14, horizontal: 10),
                          ),
                          onChanged: (_) => onFilter(),
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
