import 'package:flutter/material.dart';

class PurchaseOrderCodeScreen extends StatefulWidget {
  PurchaseOrderCodeScreen({super.key,});
  @override
  State<PurchaseOrderCodeScreen> createState() =>
      _PurchaseOrderCodeScreenState();
}

class _PurchaseOrderCodeScreenState extends State<PurchaseOrderCodeScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 17, 18, 48),
          title: const Text(
            "Code Scanner",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        body: Container(
          color: const Color.fromARGB(255, 236, 233, 233),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                  child: Container(
                width: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: const Color.fromARGB(255, 255, 255, 255),
                ),
                padding: const EdgeInsets.all(15.0),
                child: const Text(
                  "Document Numbering",
                  textAlign: TextAlign.center,
                ),
              )),
              const SizedBox(
                height: 25,
              ),
              const Center(
                child: SizedBox(
                    width: 200,
                    child: Text(
                      "Code Scanner Here",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20),
                    )),
              ),
            ],
          ),
        ));
  }
}
