import 'package:flutter/material.dart';
import '../../../constant/style.dart';
import '../../../helper/helper.dart';

Widget _column(Widget child, int flex, double width, bool phone,
    {Alignment alignment = Alignment.centerRight}) {
  final content = Align(alignment: alignment, child: child);
  return phone
      ? SizedBox(width: width, child: content)
      : Expanded(flex: flex, child: content);
}

class CountingTableHeader extends StatelessWidget {
  const CountingTableHeader({super.key, this.isPhone = false});
  final bool isPhone;
  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: AppFontSize.tableHeader);
    return Container(
        color: PRIMARY_COLOR,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        child: Row(children: [
          _column(Text('#', style: style), 1, 34, isPhone,
              alignment: Alignment.center),
          const SizedBox(width: 8),
          _column(Text('Item / Description', style: style), 6, 200, isPhone,
              alignment: Alignment.centerLeft),
          _column(Text('UoM', style: style), 2, 70, isPhone,
              alignment: Alignment.center),
          _column(Text('Counted QTY', style: style), 3, 120, isPhone),
          _column(Text('In Warehouse', style: style), 3, 120, isPhone),
          _column(Text('Variance', style: style), 3, 100, isPhone),
        ]));
  }
}

class CountingItemRow extends StatelessWidget {
  const CountingItemRow(
      {super.key,
      required this.item,
      required this.index,
      this.isPhone = false,
      this.isBeingEdited = false});
  final dynamic item;
  final int index;
  final bool isPhone;
  final bool isBeingEdited;
  @override
  Widget build(BuildContext context) {
    final rawCount = item['Quantity']?.toString().replaceAll(',', '');
    final counted = double.tryParse(rawCount ?? '');
    final stock =
        parseQuantity(item['InWhsQty'] ?? item['InWarehouseQuantity'] ?? 0);
    final difference = counted == null ? null : counted - stock;
    final style = TextStyle(
        fontSize: AppFontSize.tableCell, color: const Color(0xFF334155));
    return Container(
        color: isBeingEdited
            ? const Color(0xFFFFFBEB)
            : (index.isEven ? Colors.white : const Color(0xFFF8FAFC)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(children: [
          _column(Text('${index + 1}', style: style), 1, 34, isPhone,
              alignment: Alignment.center),
          const SizedBox(width: 8),
          _column(
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${item['ItemCode'] ?? ''}',
                        style: TextStyle(
                            fontSize: AppFontSize.tableItemTitle,
                            fontWeight: FontWeight.w700)),
                    Text('${item['ItemDescription'] ?? ''}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: AppFontSize.tableItemDesc)),
                    if (item['ManageBatchNumbers'] == 'tYES' ||
                        item['ManageSerialNumbers'] == 'tYES')
                      Text(
                          item['ManageSerialNumbers'] == 'tYES'
                              ? 'SERIAL'
                              : 'BATCH',
                          style: TextStyle(
                              fontSize: AppFontSize.badgeSmall,
                              color: PRIMARY_COLOR)),
                  ]),
              6,
              200,
              isPhone,
              alignment: Alignment.centerLeft),
          _column(
              Text('${item['UoMCode'] ?? ''}', style: style), 2, 70, isPhone,
              alignment: Alignment.center),
          _column(
              Text(counted == null ? 'Not counted' : formatQuantity(counted),
                  style: style),
              3,
              120,
              isPhone),
          _column(Text(formatQuantity(stock), style: style), 3, 120, isPhone),
          _column(
              Text(difference == null ? '-' : formatQuantity(difference),
                  style: style),
              3,
              100,
              isPhone),
        ]));
  }
}
