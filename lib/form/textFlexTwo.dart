import 'package:flutter/material.dart';

class TextFlexTwo extends StatefulWidget {
  const TextFlexTwo({super.key, required this.title, this.textData, this.req});
  final textData;
  final title;
  final req;
  @override
  State<TextFlexTwo> createState() => _TextFlexTwoState();
}

class _TextFlexTwoState extends State<TextFlexTwo> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,

      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
      width: double.infinity,
      // height: 50,
      decoration: const BoxDecoration(
          color: Color.fromARGB(255, 255, 255, 255),
          border: Border(
            left: BorderSide(
              color: Color.fromARGB(255, 215, 213, 213),
              width: 0.5,
            ),
            top: BorderSide(
              color: Color.fromARGB(255, 215, 213, 213),
              width: 0.5,
            ),
            right: BorderSide(
              color: Color.fromARGB(255, 215, 213, 213),
              width: 0.5,
            ),
          )),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: widget.req == "true"
                ? Row(
                    children: [
                      Text(
                        "${widget.title}",
                        style: const TextStyle(
                            color: Color.fromARGB(255, 116, 113, 113)),
                      ),
                      const SizedBox(
                        width: 6,
                      ),
                      const Text(
                        "*",
                        style: TextStyle(
                            fontSize: 17,
                            color: Color.fromARGB(255, 255, 0, 0)),
                      ),
                    ],
                  )
                : Text(
                    "${widget.title}",
                    style: const TextStyle(
                        color: Color.fromARGB(255, 116, 113, 113)),
                  ),
          ),
          // Text(
          //   "${widget.values}",
          //   style: const TextStyle(
          //       color: Color.fromARGB(255, 0, 0, 0),
          //       fontWeight: FontWeight.bold),
          // ),
          Expanded(
            flex: 4,
            child: TextField(
              // onChanged: widget.onChanged(),
              controller: widget.textData,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontWeight: FontWeight.bold,
                  fontSize: 14.3),
              decoration: const InputDecoration(
                hintStyle:
                    TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                // hintText: "Supplier Ref No.",
                isDense: true,
                border: InputBorder.none,
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
