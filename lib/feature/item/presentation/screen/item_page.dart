import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_mobile/feature/item/presentation/cubit/items_offline_cubit.dart';
import 'package:wms_mobile/feature/unit_of_measurement/presentation/cubit/uom_group_offline_cubit.dart';
import '../../../../core/enum/global.dart';
import '../../../../utilies/dialog/dialog.dart';
import '/constant/style.dart';

class ItemPage extends StatefulWidget {
  const ItemPage({super.key, required this.type});

  final ItemType type;

  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController filter = TextEditingController();

  List<dynamic> data = [];
  List<dynamic> filteredData = [];

  @override
  void initState() {
    super.initState();

    // Load initial data from offline cubit
    final offlineCubit = context.read<ItemOfflineCubit>();
    final offlineData = offlineCubit.state
        .where((item) => getItemType(item))
        .toList();
    data = offlineData;
    filteredData = offlineData;

    // Listen to search/filter changes
    filter.addListener(_onFilterChanged);
  }

  @override
  void dispose() {
    filter.removeListener(_onFilterChanged);
    _scrollController.dispose();
    filter.dispose();
    super.dispose();
  }

  void _onFilterChanged() {
    final text = filter.text.trim().toLowerCase();
    setState(() {
      if (text.isEmpty) {
        filteredData = data;
      } else {
        filteredData = data.where((item) {
          final code = (item['ItemCode'] ?? '').toString().toLowerCase();
          final name = (item['ItemName'] ?? '').toString().toLowerCase();
          return code.contains(text) || name.contains(text);
        }).toList();
      }
    });
  }

  bool getItemType(dynamic item) {
    if (widget.type == ItemType.purchase) {
      return item['PurchaseItem'] == 'tYES';
    }
    if (widget.type == ItemType.sale) {
      return item['SalesItem'] == 'tYES';
    }
    if (widget.type == ItemType.inventory) {
      return item['InventoryItem'] == 'tYES';
    }
    return true;
  }

  String get _typeLabel {
    switch (widget.type) {
      case ItemType.purchase:
        return 'Purchase';
      case ItemType.sale:
        return 'Sales';
      case ItemType.inventory:
        return 'Inventory';
    }
  }

  void onFind(dynamic item) async {
    try {
      if (!mounted) return;

      MaterialDialog.loading(context);

      // Load UOM data from offline cubit
      final uomCubit = context.read<UOMGroupOfflineCubit>();
      final uomGroup = uomCubit.state.firstWhere(
        (u) => u['AbsEntry'] == item['UoMGroupEntry'],
        orElse: () => {},
      );

      final itemMapped = {
        ...item,
        'BaseUoM': uomGroup['BaseUoM'],
        'UoMGroupDefinitionCollection': uomGroup['UoMGroupDefinitionCollection'],
      };

      if (mounted) {
        MaterialDialog.close(context);
        Navigator.pop(context, itemMapped);
      }
    } catch (e) {
      if (mounted) {
        MaterialDialog.close(context);
        MaterialDialog.success(
          context,
          title: 'Invalid',
          body: 'Item not found',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: PRIMARY_COLOR,
        foregroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Select Item',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.inventory_2_outlined,
                  size: 14,
                  color: Colors.white,
                ),
                const SizedBox(width: 5),
                Text(
                  '${filteredData.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: BlocListener<ItemOfflineCubit, List<dynamic>>(
        listener: (context, state) {
          final offlineData = state.where((item) => getItemType(item)).toList();
          setState(() {
            data = offlineData;
            _onFilterChanged();
          });
        },
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              // Search & Filter Header
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                child: Column(
                  children: [
                    // Search bar
                    Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: filter.text.isNotEmpty
                              ? PRIMARY_COLOR.withValues(alpha: 0.35)
                              : const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: filter,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF0F172A),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search by item code or name...',
                          hintStyle: TextStyle(
                            fontSize: 13.5,
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.normal,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            size: 22,
                            color: PRIMARY_COLOR,
                          ),
                          suffixIcon: filter.text.isNotEmpty
                              ? IconButton(
                                  splashRadius: 18,
                                  icon: const Icon(
                                    Icons.cancel_rounded,
                                    size: 18,
                                    color: Color(0xFF94A3B8),
                                  ),
                                  onPressed: () {
                                    filter.clear();
                                    FocusScope.of(context).unfocus();
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Results Count & Type Pill
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          filter.text.isEmpty
                              ? 'Total items: ${filteredData.length}'
                              : 'Results found: ${filteredData.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2.5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: PRIMARY_COLOR,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                _typeLabel,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF334155),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

              // Item List
              Expanded(
                child: filteredData.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
                        itemCount: filteredData.length,
                        itemBuilder: (context, index) {
                          return _buildItemCard(filteredData[index]);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemCard(dynamic item) {
    final String itemCode = (item['ItemCode'] ?? '').toString();
    final String itemName = (item['ItemName'] ?? '').toString();
    final bool isBatch =
        (item['ManageBatchNumbers'] ?? '').toString() == 'tYES';
    final bool isSerial =
        (item['ManageSerialNumbers'] ?? '').toString() == 'tYES';
    final String uom = (item['InventoryUOM'] ?? '').toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onFind(item),
          splashColor: PRIMARY_COLOR.withValues(alpha: 0.08),
          highlightColor: PRIMARY_COLOR.withValues(alpha: 0.04),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Item Icon Box
                Container(
                  width: 38,
                  height: 38,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color: PRIMARY_COLOR.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: PRIMARY_COLOR.withValues(alpha: 0.15),
                      width: 0.8,
                    ),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    size: 20,
                    color: PRIMARY_COLOR,
                  ),
                ),
                const SizedBox(width: 12),

                // Main Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Item Code & Badges
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              itemCode.isEmpty ? '-' : itemCode,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                                letterSpacing: 0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isBatch) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: Colors.blue.shade200,
                                  width: 0.6,
                                ),
                              ),
                              child: Text(
                                'BATCH',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.blue.shade800,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ],
                          if (isSerial) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.purple.shade50,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: Colors.purple.shade200,
                                  width: 0.6,
                                ),
                              ),
                              child: Text(
                                'SERIAL',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.purple.shade800,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),

                      // Item Name / Description
                      if (itemName.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          itemName,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF475569),
                            fontWeight: FontWeight.w400,
                            height: 1.35,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      // UoM Chip
                      if (uom.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: const Color(0xFFCBD5E1),
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.straighten_rounded,
                                size: 11,
                                color: Color(0xFF64748B),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'UoM: $uom',
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Trailing Arrow
                Container(
                  margin: const EdgeInsets.only(left: 8, top: 8),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 44,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Items Found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              filter.text.isNotEmpty
                  ? 'No items match "${filter.text}".\nTry searching with a different item code or keyword.'
                  : 'No offline items found for this module.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            if (filter.text.isNotEmpty) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  filter.clear();
                  FocusScope.of(context).unfocus();
                },
                icon: const Icon(Icons.clear_rounded, size: 16),
                label: const Text('Clear Search'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: PRIMARY_COLOR,
                  side: const BorderSide(color: PRIMARY_COLOR, width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
