import 'package:flutter/material.dart';
import 'package:wms_mobile/component/flexTwo.dart';
import 'package:wms_mobile/constant/style.dart';


class LogisticScreen extends StatefulWidget {
  final Map<String, dynamic> poLogistics;

  const LogisticScreen({super.key, required this.poLogistics});

  @override
  State<LogisticScreen> createState() => _LogisticScreenState();
}

class _LogisticScreenState extends State<LogisticScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: PRIMARY_BG_COLOR,
      child: ListView(
        children: [
          SizedBox(
            height: 30,
          ),
          FlexTwo(
            title: "Ship To",
            values:  "${widget.poLogistics["Address2"] ?? ""}",
          ),
          FlexTwo(
            title: "Bill To",
            values:  "${widget.poLogistics["Address"] ?? ""}",
          ),
        ],
      ),
    );
  }
}
