import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_mobile/constant/style.dart';
import 'package:wms_mobile/feature/counting/cos/presentation/cubit/cos_offline_cubit.dart';
import 'package:wms_mobile/helper/helper.dart';
import 'package:wms_mobile/utilies/dialog/dialog.dart';

class CosPage extends StatefulWidget {
  const CosPage({super.key});

  @override
  State<CosPage> createState() => _CosPageState();
}

class _CosPageState extends State<CosPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController filter = TextEditingController();
  final TextEditingController filterInput = TextEditingController();

  List<dynamic> filteredData = [];
  late COSOfflineCubit _offlineCubit;
  final FocusNode _focusNode = FocusNode();
  final FocusNode _focusNodeInput = FocusNode();

  bool isClickScan = false;

  @override
  void initState() {
    super.initState();
    _offlineCubit = context.read<COSOfflineCubit>();
    _offlineCubit.loadData();
    _scrollController.addListener(_handlePagination);
  }

  void _handlePagination() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      debugPrint("📜 Reached bottom - pagination trigger (offline)");
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _focusNodeInput.dispose();
    filter.dispose();
    filterInput.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void onFilter() {
    final allData = _offlineCubit.getJsonData();
    final textScan = filter.text.trim().toLowerCase();
    final textInput = filterInput.text.trim().toLowerCase();

    debugPrint("🔎 Filter scan: '$textScan', input: '$textInput'");

    if (textScan.isEmpty && textInput.isEmpty) {
      setState(() => filteredData = allData);
      return;
    }

    final query = textScan.isNotEmpty ? textScan : textInput;

    final results = allData.where((cos) {
      final docNum =
          getDataFromDynamic(cos['DocumentNumber']).toString().toLowerCase();
      final docEntry =
          getDataFromDynamic(cos['DocumentEntry']).toString().toLowerCase();
      final remarks =
          getDataFromDynamic(cos['Remarks'] ?? cos['Comments'])
              .toString()
              .toLowerCase();

      final lines = (cos['InventoryCountingLines'] as List<dynamic>?) ?? [];
      String whsCode = getDataFromDynamic(cos['WarehouseCode']).toLowerCase();
      if (whsCode.isEmpty && lines.isNotEmpty) {
        whsCode = getDataFromDynamic(lines[0]['WarehouseCode']).toLowerCase();
      }

      final matchesLines = lines.any((line) {
        final itemCode =
            getDataFromDynamic(line['ItemCode']).toString().toLowerCase();
        final itemDesc = getDataFromDynamic(
                line['ItemDescription'] ?? line['ItemName'])
            .toString()
            .toLowerCase();
        final lineWhs =
            getDataFromDynamic(line['WarehouseCode']).toString().toLowerCase();
        return itemCode.contains(query) ||
            itemDesc.contains(query) ||
            lineWhs.contains(query);
      });

      return docNum.contains(query) ||
          docEntry.contains(query) ||
          whsCode.contains(query) ||
          remarks.contains(query) ||
          matchesLines;
    }).toList();

    setState(() => filteredData = results);
  }

  void onSelect(dynamic cos) {
    if (cos != null && cos is Map && cos.isNotEmpty) {
      Navigator.pop(context, cos);
    } else {
      final docEntry = getDataFromDynamic(cos?['DocumentEntry']).toString();
      onFind(docEntry);
    }
  }

  void onFind(String code) async {
    try {
      MaterialDialog.loading(context);

      final cubit = context.read<COSOfflineCubit>();
      final allData = cubit.getJsonData();

      final result = allData.firstWhere(
        (e) =>
            getDataFromDynamic(e['DocumentEntry']).toString() == code ||
            getDataFromDynamic(e['DocumentNumber']).toString() == code,
        orElse: () => {},
      );

      if (mounted) MaterialDialog.close(context);

      if (result.isEmpty) {
        if (mounted) {
          MaterialDialog.success(context,
              title: 'Invalid', body: 'Counting Sheet not found - $code');
        }
      } else {
        if (mounted) {
          Navigator.pop(context, result);
        }
      }
    } catch (e) {
      if (mounted) MaterialDialog.close(context);
      if (mounted) {
        MaterialDialog.success(context,
            title: 'Error', body: 'Something went wrong.');
      }
    }
  }

  void _handleScanSubmitted(String barcode, FocusNode submittedNode) {
    debugPrint("📦 Scanned Counting Sheet Code: $barcode");
    setState(() {
      filter.text = barcode;
      isClickScan = false;
    });
    onFilter();
  }

  void _requestFocus(FocusNode node) {
    if (!node.hasFocus) {
      Future.microtask(() => node.requestFocus());
    }
  }

  void _clearSearch() {
    setState(() {
      filter.clear();
      filterInput.clear();
      isClickScan = false;
    });
    FocusScope.of(context).unfocus();
    onFilter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: PRIMARY_COLOR,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Counting Sheet Lists',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: AppFontSize.appBarTitle,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.white.withValues(alpha: 0.15),
            height: 1,
          ),
        ),
      ),
      body: BlocBuilder<COSOfflineCubit, List<dynamic>>(
        builder: (context, state) {
          final allData = _offlineCubit.getJsonData();
          final hasActiveFilter =
              filter.text.isNotEmpty || filterInput.text.isNotEmpty;

          final displayList = hasActiveFilter ? filteredData : allData;

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 860),
              child: Column(
                children: [
                  // Search & Scanner Header Section
                  _buildSearchHeader(totalCount: allData.length),

                  // Filter Count Bar
                  _buildFilterInfoBar(
                    displayedCount: displayList.length,
                    totalCount: allData.length,
                    hasFilter: hasActiveFilter,
                  ),

                  // Sheet List / Empty State
                  Expanded(
                    child: displayList.isEmpty
                        ? _buildEmptyState(hasFilter: hasActiveFilter)
                        : RefreshIndicator(
                            color: PRIMARY_COLOR,
                            onRefresh: () async {
                              _offlineCubit.loadData();
                              onFilter();
                            },
                            child: ListView.builder(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(14, 6, 14, 20),
                              itemCount: displayList.length,
                              itemBuilder: (context, index) {
                                final cos = displayList[index];
                                return _buildCountingSheetCard(cos);
                              },
                            ),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchHeader({required int totalCount}) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Scan Barcode Trigger Button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      filter.clear();
                      filterInput.clear();
                      isClickScan = true;
                    });
                    FocusScope.of(context).unfocus();
                    Future.delayed(const Duration(milliseconds: 100), () {
                      _requestFocus(_focusNode);
                    });
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isClickScan
                          ? Colors.green.shade50
                          : PRIMARY_COLOR.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isClickScan
                            ? Colors.green.shade600
                            : PRIMARY_COLOR.withValues(alpha: 0.2),
                        width: isClickScan ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.qr_code_scanner_rounded,
                          color: isClickScan
                              ? Colors.green.shade700
                              : PRIMARY_COLOR,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Scan',
                          style: TextStyle(
                            fontSize: AppFontSize.buttonSmall,
                            fontWeight: FontWeight.w700,
                            color: isClickScan
                                ? Colors.green.shade800
                                : PRIMARY_COLOR,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Search Text Field
              Expanded(
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isClickScan
                          ? Colors.green.shade500
                          : const Color(0xFFCBD5E1),
                      width: isClickScan ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 10, right: 6),
                        child: Icon(
                          Icons.search_rounded,
                          color: Color(0xFF64748B),
                          size: 20,
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: isClickScan ? filter : filterInput,
                          focusNode: isClickScan ? _focusNode : _focusNodeInput,
                          keyboardType: isClickScan
                              ? TextInputType.none
                              : TextInputType.text,
                          style: TextStyle(
                            fontSize: AppFontSize.input,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0F172A),
                          ),
                          onTap: () {
                            if (isClickScan) {
                              setState(() {
                                isClickScan = false;
                              });
                              FocusScope.of(context).unfocus();
                              Future.delayed(
                                const Duration(milliseconds: 100),
                                () => _requestFocus(_focusNodeInput),
                              );
                            }
                          },
                          onChanged: (val) => onFilter(),
                          onFieldSubmitted: (barcode) =>
                              _handleScanSubmitted(barcode, _focusNode),
                          decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                            hintText: isClickScan
                                ? 'Scanning... Aim scanner now'
                                : 'Search Sheet No., Warehouse...',
                            hintStyle: TextStyle(
                              fontSize: AppFontSize.hint,
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                      if (filter.text.isNotEmpty || filterInput.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.cancel_rounded, size: 18),
                          color: Colors.grey.shade400,
                          onPressed: _clearSearch,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Active Scanning Mode Feedback Chip
          if (isClickScan) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade400, width: 0.6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: Colors.green.shade700,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Ready to Scan Counting Sheet Barcode',
                    style: TextStyle(
                      fontSize: AppFontSize.badgeSmall,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      setState(() {
                        isClickScan = false;
                      });
                      FocusScope.of(context).unfocus();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.green.shade800.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 13,
                        color: Colors.green.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterInfoBar({
    required int displayedCount,
    required int totalCount,
    required bool hasFilter,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                hasFilter ? 'Search Results' : 'Open Counting Sheets',
                style: TextStyle(
                  fontSize: AppFontSize.label,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF334155),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 1.5),
                decoration: BoxDecoration(
                  color: PRIMARY_COLOR.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$displayedCount',
                  style: TextStyle(
                    fontSize: AppFontSize.badgeSmall,
                    fontWeight: FontWeight.w700,
                    color: PRIMARY_COLOR,
                  ),
                ),
              ),
            ],
          ),
          if (hasFilter)
            InkWell(
              onTap: _clearSearch,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  'Clear Filter',
                  style: TextStyle(
                    fontSize: AppFontSize.badgeSmall,
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCountingSheetCard(dynamic cos) {
    final docNum = getDataFromDynamic(cos['DocumentNumber'] ?? cos['DocNum']);
    final docEntry = getDataFromDynamic(cos['DocumentEntry'] ?? cos['DocEntry']);
    final rawDate = getDataFromDynamic(cos['CountDate'] ?? cos['DocDate']);
    final countDate = rawDate.isNotEmpty
        ? (rawDate.contains('T') ? rawDate.split('T')[0] : rawDate)
        : '-';

    String countTime =
        getDataFromDynamic(cos['CountTime'] ?? cos['Time']).trim();
    if (countTime.isEmpty || countTime == 'null') {
      countTime = '-';
    } else if (countTime.length == 4 && int.tryParse(countTime) != null) {
      countTime =
          '${countTime.substring(0, 2)}:${countTime.substring(2, 4)}';
    } else if (countTime.length == 3 && int.tryParse(countTime) != null) {
      countTime =
          '0${countTime.substring(0, 1)}:${countTime.substring(1, 3)}';
    }

    final rawStatus = getDataFromDynamic(cos['DocumentStatus']);
    final status = rawStatus.contains('cds')
        ? rawStatus.split('cds').last
        : (rawStatus.isNotEmpty ? rawStatus : 'Open');

    final remarks =
        getDataFromDynamic(cos['Remarks'] ?? cos['Comments']).trim();
    final hasRemarks = remarks.isNotEmpty && remarks != 'null';

    final lines = (cos['InventoryCountingLines'] as List<dynamic>?) ?? [];
    final lineCount = lines.length;

    String whsCode = getDataFromDynamic(cos['WarehouseCode']);
    if (whsCode.isEmpty && lines.isNotEmpty) {
      whsCode = getDataFromDynamic(lines[0]['WarehouseCode']);
    }

    final isOpen =
        status.toLowerCase() == 'open' || rawStatus.toLowerCase() == 'cdsopen';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onSelect(cos),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header: Sheet Number + Line count / Status Badges + Arrow
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: PRIMARY_COLOR.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: PRIMARY_COLOR.withValues(alpha: 0.15),
                          width: 0.8,
                        ),
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        size: 17,
                        color: PRIMARY_COLOR,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Sheet #$docNum',
                        style: TextStyle(
                          fontSize: AppFontSize.cardTitle,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (lineCount > 0) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: PRIMARY_COLOR.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: PRIMARY_COLOR.withValues(alpha: 0.2),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          '$lineCount ${lineCount == 1 ? 'Item' : 'Items'}',
                          style: TextStyle(
                            fontSize: AppFontSize.badgeSmall,
                            fontWeight: FontWeight.w700,
                            color: PRIMARY_COLOR,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isOpen
                            ? const Color(0xFFE8F5E9)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isOpen
                              ? Colors.green.shade300
                              : const Color(0xFFCBD5E1),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: AppFontSize.badgeSmall,
                          fontWeight: FontWeight.w700,
                          color: isOpen
                              ? Colors.green.shade800
                              : const Color(0xFF475569),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 13,
                      color: Color(0xFF94A3B8),
                    ),
                  ],
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 9),
                  child: Divider(
                    height: 1,
                    thickness: 0.7,
                    color: Color(0xFFF1F5F9),
                  ),
                ),

                // Warehouse & Document Entry Information
                Row(
                  children: [
                    if (whsCode.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.warehouse_outlined,
                              size: 13,
                              color: Color(0xFF64748B),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Whs: $whsCode',
                              style: TextStyle(
                                fontSize: AppFontSize.badgeSmall,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF475569),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (whsCode.isNotEmpty && docEntry.isNotEmpty)
                      const SizedBox(width: 8),
                    if (docEntry.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.tag_rounded,
                              size: 13,
                              color: Color(0xFF64748B),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'No : $docEntry',
                              style: TextStyle(
                                fontSize: AppFontSize.badgeSmall,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF475569),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 9),

                // Date Information Box
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: Row(
                    children: [
                      // Count Date
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 13,
                              color: Color(0xFF64748B),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Date: ',
                              style: TextStyle(
                                fontSize: AppFontSize.md,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                countDate,
                                style: TextStyle(
                                  fontSize: AppFontSize.md,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF334155),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 14,
                        width: 1,
                        color: const Color(0xFFE2E8F0),
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      // Count Time
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: PRIMARY_COLOR,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Time: ',
                              style: TextStyle(
                                fontSize: AppFontSize.md,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                countTime,
                                style: TextStyle(
                                  fontSize: AppFontSize.md,
                                  fontWeight: FontWeight.w700,
                                  color: PRIMARY_COLOR,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Remarks Note
                if (hasRemarks) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.amber.shade200,
                        width: 0.6,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 12,
                          color: Colors.amber.shade800,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            remarks,
                            style: TextStyle(
                              fontSize: AppFontSize.tableItemDesc,
                              color: Colors.amber.shade900,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({required bool hasFilter}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: PRIMARY_COLOR.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasFilter
                    ? Icons.search_off_rounded
                    : Icons.receipt_long_outlined,
                size: 44,
                color: PRIMARY_COLOR,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              hasFilter ? 'No Matching Sheets' : 'No Counting Sheets',
              style: TextStyle(
                fontSize: AppFontSize.sectionTitle,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hasFilter
                  ? 'No counting sheets matched your search query.\nCheck the document number and try again.'
                  : 'There are currently no open counting sheets available.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppFontSize.md,
                color: const Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            if (hasFilter) ...[
              const SizedBox(height: 18),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: PRIMARY_COLOR,
                  side: const BorderSide(color: PRIMARY_COLOR),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _clearSearch,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: Text(
                  'Reset Search',
                  style: TextStyle(
                    fontSize: AppFontSize.buttonSmall,
                    fontWeight: FontWeight.w600,
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
