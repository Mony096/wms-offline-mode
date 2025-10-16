import 'package:flutter/material.dart';
import 'package:wms_mobile/constant/style.dart';

class BlockList extends StatefulWidget {
  final String name;
  final String date;
  final String status;
  final String qty;
  final Color colorStatus;
  const BlockList(
      {super.key,
      required this.colorStatus,
      required this.name,
      required this.date,
      required this.status,
      required this.qty});
  @override
  State<BlockList> createState() => _BlockListState();
}

class _BlockListState extends State<BlockList> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
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
                color: Color.fromRGBO(192, 188, 188, 1),
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
                              Container(
                                width: 255,
                                child:  Text(
                                "${widget.name}",
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              ),
                             
                              Text(
                                "${widget.status}",
                                style: TextStyle(
                                    color: widget.colorStatus,
                                    fontSize: size(context).width * 0.034),
                              )
                            ],
                          ),
                        )),
                    Expanded(
                        flex: 3,
                        child: SizedBox(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${widget.date}",
                                style: const TextStyle(
                                    fontSize: 13.5,
                                    color: Color.fromARGB(255, 106, 103, 103)),
                              ),
                              Text(
                                "${widget.qty}",
                                style: TextStyle(
                                  color:
                                      const Color.fromARGB(255, 106, 103, 103),
                                  fontSize: size(context).width * 0.035,
                                ),
                              )
                            ],
                          ),
                        ))
                  ]),
                )),
            const Expanded(
                flex: 1,
                child: SizedBox(
                  child: Center(
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 20,
                    ),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
