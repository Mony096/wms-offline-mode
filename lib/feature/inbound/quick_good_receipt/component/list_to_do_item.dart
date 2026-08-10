import 'package:flutter/material.dart';
import 'package:wms_mobile/constant/style.dart';

class ListToDoItem extends StatefulWidget {
  const ListToDoItem({
    super.key,
    this.itemCode,
    this.uom,
    this.qty,
    this.openQty,
    this.desc,
    this.isPhone = false,
  });
  final itemCode;
  final uom;
  final qty;
  final openQty;
  final desc;
  final bool isPhone;

  @override
  State<ListToDoItem> createState() => _ListToDoItemState();
}

class _ListToDoItemState extends State<ListToDoItem> {
  String getDataFromDynamic(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  Widget _buildColumn(Widget child, int flex, double fixedWidth) {
    if (widget.isPhone) return SizedBox(width: fixedWidth, child: child);
    return Expanded(flex: flex, child: child);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade50,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildColumn(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      getDataFromDynamic(widget.itemCode),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      getDataFromDynamic(widget.desc),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                3,
                220,
              ),
              _buildColumn(
                Text(
                  getDataFromDynamic(widget.uom),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13),
                ),
                1,
                60,
              ),
              _buildColumn(
                Text(
                  getDataFromDynamic(widget.qty),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13),
                ),
                1,
                90,
              ),
              _buildColumn(
                Text(
                  getDataFromDynamic(widget.openQty),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13),
                ),
                1,
                80,
              ),
            ],
          ),

          // Divider
          const SizedBox(height: 8),
          Divider(
            height: 1,
            thickness: 0.6,
            color: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }
}
