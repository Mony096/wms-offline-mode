import 'package:flutter/material.dart';
import 'package:wms_mobile/constant/style.dart';

class BlockList extends StatefulWidget {
  const BlockList({
    super.key,
    this.number,
    this.desc,
    this.date,
    this.date2,
  });
  final number;
  final desc;
  final date;
  final date2;
  @override
  State<BlockList> createState() => _BlockListState();
}

class _BlockListState extends State<BlockList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          color: Color.fromARGB(255, 255, 255, 255),
          border: Border(
            left: BorderSide(
              color: Color.fromARGB(255, 200, 196, 196),
              width: 0.5,
            ),
            bottom: BorderSide(
              color: Color.fromARGB(255, 188, 183, 183),
              width: 0.5,
            ),
            right: BorderSide(
              color: Color.fromARGB(255, 192, 188, 188),
              width: 0.5,
            ),
          )),
      padding: const EdgeInsets.all(5),
      width: double.infinity,
      height: 75.0,
      child: Row(
        children: [
          const SizedBox(
            width: 10,
          ),
          Expanded(
              flex: 6,
              child: Container(
                child: Column(children: [
                  Expanded(
                      flex: 3,
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${widget.number}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            SizedBox(
                              child: Row(
                                children: [
                                  Text("PO Date: ",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromARGB(255, 0, 0, 0))),
                                  Text("${widget.date}",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Color.fromARGB(255, 0, 0, 0)))
                                ],
                              ),
                            )
                          ],
                        ),
                      )),
                  Expanded(
                      flex: 3,
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${widget.desc}",
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(
                              child: Row(
                                children: [
                                  Text("DL Date: ",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromARGB(255, 0, 0, 0))),
                                  Text("${widget.date2}",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Color.fromARGB(255, 0, 0, 0)))
                                ],
                              ),
                            )
                          ],
                        ),
                      ))
                ]),
              )),
          Expanded(flex: 1, child: Container(child: Text("")))
        ],
      ),
    );
  }
}
