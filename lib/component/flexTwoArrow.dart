import 'package:flutter/material.dart';

class FlexTwoArrow extends StatefulWidget {
  final title;
  final textData;
  const FlexTwoArrow({super.key, required this.title, this.textData});
  @override
  State<FlexTwoArrow> createState() => _FlexTwoArrowState();
}

class _FlexTwoArrowState extends State<FlexTwoArrow> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
      width: double.infinity,
      height: 50,
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
          Text(
            "${widget.title}",
            style: const TextStyle(color: Color.fromARGB(255, 116, 113, 113)),
          ),
          widget.textData == null
              ? const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey,
                  size: 18,
                )
              : Container(
                  width: 250,
                  child: Text(
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    "${widget.textData}",
                    style: const TextStyle(
                        color: Color.fromARGB(255, 8, 8, 8),
                        fontWeight: FontWeight.bold),
                  ),
                )
        ],
      ),
    );
  }
}
