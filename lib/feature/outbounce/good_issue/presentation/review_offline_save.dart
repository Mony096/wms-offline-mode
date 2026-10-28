import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wms_mobile/constant/style.dart';
import 'package:wms_mobile/feature/bin_location/presentation/cubit/bin_offline_cubit.dart';
import 'package:wms_mobile/feature/outbounce/good_issue/presentation/create_good_issue_screen.dart';
import 'package:wms_mobile/feature/outbounce/good_issue/presentation/cubit/goods_issue_offline_cubit.dart';
import 'package:wms_mobile/helper/helper.dart';

class ReviewGoodsIssueOfflineSave extends StatelessWidget {
  const ReviewGoodsIssueOfflineSave({super.key});

  Future<void> _clearAllData(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          "Clear Saved Data?",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: AppFontSize.dialogTitle,
            color: const Color(0xFF0F172A),
          ),
        ),
        content: Text(
          "This will remove all offline saved data. Are you sure?",
          style: TextStyle(
            fontSize: AppFontSize.md,
            color: const Color(0xFF475569),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              "Cancel",
              style: TextStyle(
                fontSize: AppFontSize.buttonSmall,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              "Clear All",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: AppFontSize.buttonSmall,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    if (!context.mounted) return;
    context.read<GoodsIssueOfflineCubit>().clearData();
  }

  Future<void> _removeById(BuildContext context, dynamic id) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          "Remove this record?",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: AppFontSize.dialogTitle,
            color: const Color(0xFF0F172A),
          ),
        ),
        content: Text(
          "This will remove this offline saved record. Are you sure?",
          style: TextStyle(
            fontSize: AppFontSize.md,
            color: const Color(0xFF475569),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              "No",
              style: TextStyle(
                fontSize: AppFontSize.buttonSmall,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              "Remove",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: AppFontSize.buttonSmall,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    if (!context.mounted) return;
    context.read<GoodsIssueOfflineCubit>().removeByFailId(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: PRIMARY_COLOR,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Data Saved",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: AppFontSize.appBarTitle,
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
        actions: [
          IconButton(
            icon: const Icon(
              Icons.delete_sweep_rounded,
              color: Colors.white,
              size: 24,
            ),
            tooltip: 'Clear All Data',
            onPressed: () => _clearAllData(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<GoodsIssueOfflineCubit, List<dynamic>>(
        builder: (context, records) {
          if (records.isEmpty) {
            return _buildEmptyState();
          }

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 860),
              child: ListView.builder(
                itemCount: records.length,
                padding: EdgeInsets.symmetric(
                  horizontal: AppFontSize.isTablet ? 24 : 14,
                  vertical: 12,
                ),
                itemBuilder: (context, index) {
                  final record = records[index];
                  final lines = record['DocumentLines'] as List<dynamic>? ?? [];
                  final timestamp = record["timestamp"];

                  String formattedTime = '';
                  if (timestamp != null && timestamp.toString().isNotEmpty) {
                    try {
                      final parsedDate = DateTime.parse(timestamp);
                      formattedTime =
                          DateFormat("yyyy-MM-dd • hh:mm a").format(parsedDate);
                    } catch (_) {
                      formattedTime = timestamp.toString();
                    }
                  }

                  return _buildSavedCard(
                    context: context,
                    index: index,
                    record: record,
                    lines: lines,
                    formattedTime: formattedTime,
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: PRIMARY_COLOR.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bookmark_border_rounded,
                size: 48,
                color: PRIMARY_COLOR,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "No Saved Records",
              style: TextStyle(
                fontSize: AppFontSize.sectionTitle,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "There are currently no offline saved records to review.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppFontSize.md,
                color: const Color(0xFF64748B),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedCard({
    required BuildContext context,
    required int index,
    required dynamic record,
    required List<dynamic> lines,
    required String formattedTime,
  }) {
    final issueType = record['U_LK_Type']?.toString().trim() ?? '';
    final warehouse = record['U_lk_whsdesc']?.toString().trim() ?? '';
    final remark = record['Comments']?.toString().trim() ?? '';
    final hasRemark = remark.isNotEmpty && remark != 'null';

    final displayName = issueType.isNotEmpty ? issueType : 'Goods Issue';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Card Header: Record Index + Timestamp + Badge
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
                    Icons.unarchive_outlined,
                    size: 16,
                    color: PRIMARY_COLOR,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Record #${index + 1}',
                        style: TextStyle(
                          fontSize: AppFontSize.cardTitle,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                          letterSpacing: 0.2,
                        ),
                      ),
                      if (formattedTime.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.schedule_rounded,
                              size: 11,
                              color: Color(0xFF94A3B8),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              formattedTime,
                              style: TextStyle(
                                fontSize: AppFontSize.badgeSmall,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Colors.amber.shade300,
                      width: 0.7,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.amber.shade800,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Saved Offline',
                        style: TextStyle(
                          fontSize: AppFontSize.badgeSmall,
                          fontWeight: FontWeight.w700,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(
                height: 1,
                thickness: 0.7,
                color: Color(0xFFF1F5F9),
              ),
            ),

            // 🔹 Issue Type / Title
            Text(
              displayName,
              style: TextStyle(
                fontSize: AppFontSize.value,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),

            // 🔹 Badges (Warehouse)
            if (warehouse.isNotEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                      'Whs: $warehouse',
                      style: TextStyle(
                        fontSize: AppFontSize.badgeSmall,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),

            // 🔹 Remark Banner
            if (hasRemark) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.amber.shade200, width: 0.6),
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
                        remark,
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

            const SizedBox(height: 12),

            // 🔹 Items Section Header
            Row(
              children: [
                Text(
                  "Items",
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
                    "${lines.length} ${lines.length == 1 ? 'item' : 'items'}",
                    style: TextStyle(
                      fontSize: AppFontSize.badgeSmall,
                      fontWeight: FontWeight.w700,
                      color: PRIMARY_COLOR,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 🔹 Line Items Cards
            ...lines.map<Widget>((line) {
              final binCubit = context.read<BinOfflineCubit>();
              final binAllocations = line['DocumentLinesBinAllocations'];
              final binAbsEntry = (binAllocations != null &&
                      binAllocations.isNotEmpty &&
                      binAllocations[0]?['BinAbsEntry'] != null)
                  ? binAllocations[0]['BinAbsEntry']
                  : null;

              final bin = binCubit.state.firstWhere(
                (u) =>
                    u['AbsEntry'] == int.tryParse(binAbsEntry.toString()),
                orElse: () => {},
              );

              final displayBin = bin['BinCode']?.toString() ?? '';
              final itemDesc = line['ItemDescription']?.toString() ?? '';
              final itemCode = line['ItemCode']?.toString() ?? '';
              final uomCode = line['UoMCode']?.toString() ?? '';

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            itemDesc.isNotEmpty
                                ? itemDesc
                                : (itemCode.isNotEmpty ? itemCode : '-'),
                            style: TextStyle(
                              fontSize: AppFontSize.value,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: PRIMARY_COLOR.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: PRIMARY_COLOR.withValues(alpha: 0.2),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            "Qty: ${line['Quantity'] ?? '0'}",
                            style: TextStyle(
                              fontSize: AppFontSize.badgeSmall,
                              fontWeight: FontWeight.w700,
                              color: PRIMARY_COLOR,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (itemCode.isNotEmpty && itemCode != itemDesc) ...[
                      const SizedBox(height: 3),
                      Text(
                        itemCode,
                        style: TextStyle(
                          fontSize: AppFontSize.tableItemDesc,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                    if (uomCode.isNotEmpty || displayBin.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          if (uomCode.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                    color: const Color(0xFFCBD5E1),
                                    width: 0.7),
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
                                    'UoM: $uomCode',
                                    style: TextStyle(
                                      fontSize: AppFontSize.badgeSmall,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF475569),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (displayBin.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                    color: const Color(0xFFCBD5E1),
                                    width: 0.7),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    size: 11,
                                    color: Color(0xFF64748B),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Bin: $displayBin',
                                    style: TextStyle(
                                      fontSize: AppFontSize.badgeSmall,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF475569),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            }),

            const SizedBox(height: 10),

            // 🔹 Action Footer Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Remove Button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      _removeById(context, record['SaveId']);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.red.shade200,
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.delete_outline_rounded,
                            size: 16,
                            color: Colors.red.shade700,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Remove",
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.w700,
                              fontSize: AppFontSize.buttonSmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Edit Button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      goTo(
                        context,
                        CreateGoodIssueScreen(
                          isEdit: record,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: PRIMARY_COLOR,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: PRIMARY_COLOR.withValues(alpha: 0.25),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.edit_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Edit",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: AppFontSize.buttonSmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
