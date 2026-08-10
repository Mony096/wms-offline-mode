import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_mobile/constant/style.dart';
import 'package:wms_mobile/feature/item/presentation/cubit/items_offline_cubit.dart';
import 'package:wms_mobile/helper/helper.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _allData = [];
  List<dynamic> _filteredData = [];
  
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'IT Equipment', 'Laptop', 'Screen', 'Mouse', 'Keyboard'];

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  void _loadData() {
    final offlineData = context.read<ItemOfflineCubit>().state;
    // We add some mock items if the list is empty for demo purposes based on prototype
    if (offlineData.isEmpty) {
      _allData = [
        {"ItemCode": "IT0001", "ItemName": "17-Inch Laptop, 16GB RAM", "Stock": 52},
        {"ItemCode": "IT0002", "ItemName": "Dell 27\" Monitor", "Stock": 40},
        {"ItemCode": "IT0003", "ItemName": "Logitech MX Master 3S", "Stock": 38},
        {"ItemCode": "IT0004", "ItemName": "Keychron K8 Keyboard", "Stock": 36},
        {"ItemCode": "IT0005", "ItemName": "Kingston DDR5 16GB RAM", "Stock": 34},
      ];
    } else {
      _allData = offlineData;
    }
    _filteredData = _allData;
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _applyFilters();
  }

  void _applyFilters() {
    final text = _searchController.text.toLowerCase();
    setState(() {
      _filteredData = _allData.where((item) {
        final code = (item['ItemCode'] ?? '').toString().toLowerCase();
        final name = (item['ItemName'] ?? '').toString().toLowerCase();
        final matchesSearch = code.contains(text) || name.contains(text);
        
        // Mock category filter since we don't have ItemsGroupCode in query yet
        bool matchesCategory = true;
        if (_selectedCategory != 'All') {
          if (_selectedCategory == 'Laptop' && !name.contains('laptop')) matchesCategory = false;
          if (_selectedCategory == 'Screen' && !name.contains('monitor')) matchesCategory = false;
          if (_selectedCategory == 'Keyboard' && !name.contains('keyboard')) matchesCategory = false;
          if (_selectedCategory == 'Mouse' && !name.contains('mouse') && !name.contains('logitech')) matchesCategory = false;
        }
        
        return matchesSearch && matchesCategory;
      }).toList();
    });
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
      appBar: AppBar(
        backgroundColor: PRIMARY_COLOR,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        title: const Center(
          child: Padding(
            padding: EdgeInsets.only(right: 56), // balance back button
            child: Text(
              "Item List",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          
          // Categories list
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                return GestureDetector(
                  onTap: () => _onCategorySelected(category),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF131A3F) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Results Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _filteredData.length.toString().padLeft(2, '0'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Text(
                  'Results',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
          
          // List View
          Expanded(
            child: ListView.builder(
              itemCount: _filteredData.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final item = _filteredData[index];
                final stock = item['QuantityOnStock'] ?? item['Stock'] ?? 0;
                final stockDisplay = stock is num 
                    ? (stock % 1 == 0 ? stock.toInt().toString() : stock.toString()) 
                    : stock.toString();
                
                return GestureDetector(
                  onTap: () {
                    goTo(context, ProductDetailScreen(item: item));
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Mock Image Container
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.computer, color: Colors.blueGrey, size: 28),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['ItemName'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Code: ${item['ItemCode'] ?? ''}',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              stockDisplay,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const Text(
                              'In stock',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
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
  }
}
