import 'package:flutter/material.dart';
import 'package:wms_mobile/component/flexTwo.dart';

class LogisticScreen extends StatefulWidget {
  LogisticScreen({super.key, required this.grrLogistic});
  Map<String, dynamic> grrLogistic;
  @override
  State<LogisticScreen> createState() => _LogisticScreenState();
}

class _LogisticScreenState extends State<LogisticScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color.fromARGB(255, 236, 233, 233),
      child: ListView(
        children: [
          SizedBox(
            height: 30,
          ),
          FlexTwo(
            title: "Ship To",
            values: widget.grrLogistic["Address2"] ?? "",
          ),
          FlexTwo(
            title: "Bill To",
            values: widget.grrLogistic["Address"] ?? "",
          ),
          FlexTwo(
            title: "Shipping Type",
            values: widget.grrLogistic["ShippingMethod"] ?? "",
          ),
          const SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }
}
