import 'package:flutter/material.dart';

class FlexTwoArrowWithText extends StatefulWidget {
  const FlexTwoArrowWithText(
      {super.key,
      required this.title,
      this.textData,
      this.textColor,
      this.simple,
      this.req,
      this.requried,
      this.disable
      });
  final title;
  final textData;
  final Color? textColor;
  final FontWeight? simple;
  final req;
  final requried;
   final disable;
  @override
  State<FlexTwoArrowWithText> createState() => _FlexTwoArrowWithTextState();
}

class _FlexTwoArrowWithTextState extends State<FlexTwoArrowWithText> {
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
          widget.req == "true"
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
                          fontSize: 17, color: Color.fromARGB(255, 255, 0, 0)),
                    ),
                  ],
                )
              : Text(
                  "${widget.title}",
                  style: const TextStyle(
                      color: Color.fromARGB(255, 116, 113, 113)),
                ),
          Container(
            child: Row(
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: widget.textData,
                        style:  TextStyle(
                            fontWeight: FontWeight.bold,
                            color:widget.disable == "true"? Color.fromARGB(255, 176, 179, 181): Color.fromARGB(255, 0, 0, 0),
                            fontSize: 12),
                      ),
                      if (widget.textData == null)
                        // Check if textData is null
                        TextSpan(
                          text: widget.requried ??
                              '', // Add asterisk or any symbol indicating it's required
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color.fromARGB(255, 162, 167, 171),
                          ),
                        )
                    ],
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey,
                  size: 18,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
