import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_mobile/feature/lk_act/presentation/cubit/lk_act_offline_cubit.dart';

class LkActPage extends StatefulWidget {
  final String typeCode;
  const LkActPage({Key? key, required this.typeCode}) : super(key: key);

  @override
  State<LkActPage> createState() => _LkActPageState();
}

class _LkActPageState extends State<LkActPage> {
  List<dynamic> _accounts = [];
  List<dynamic> _filteredAccounts = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();

    // 🔹 Live Search Filter
    _searchController.addListener(() {
      final text = _searchController.text.toLowerCase();
      setState(() {
        _filteredAccounts = _accounts.where((element) {
          final code = (element['U_LK_Acct'] ?? '').toString().toLowerCase();
          return code.contains(text);
        }).toList();
      });
    });
  }

  void _loadData() {
    final state = context.read<LkActOfflineCubit>().state;
    // Find the LK_ACT header that matches the typeCode
    final lkAct = state.firstWhere(
      (element) => element['Code'] == widget.typeCode,
      orElse: () => null,
    );

    if (lkAct != null) {
      // Find the collection (assuming it might be LK_ACT1Collection or similar)
      final collectionKey = lkAct.keys.firstWhere(
        (key) => key.contains('Collection') && lkAct[key] is List,
        orElse: () => '',
      );

      if (collectionKey.isNotEmpty) {
        _accounts = lkAct[collectionKey];
      } else {
        // Fallback if the array is directly inside or has a different name
        for (var value in lkAct.values) {
          if (value is List) {
            _accounts = value;
            break;
          }
        }
      }
    }
    
    _filteredAccounts = _accounts;
    setState(() {});
  }

  @override
  void dispose() {
    _searchController.dispose();
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
                    "Select Account",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search...',
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _filteredAccounts = _accounts;
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 13),
                ),
              ),
            ),
            
            const SizedBox(height: 15),

            // 🔹 Data List
            Expanded(
              child: _accounts.isEmpty
                  ? const Center(child: Text("No Data Available"))
                  : ListView.builder(
                      itemCount: _filteredAccounts.length,
                      itemBuilder: (context, index) {
                        final item = _filteredAccounts[index];
                        final code = item['U_LK_Acct']?.toString() ?? '';

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
                                    code,
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
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
