import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';

class FlexTwoField extends StatefulWidget {
  FlexTwoField(
      {super.key,
      required this.title,
      required this.values,
      this.onMenuClick,
      this.menu,
      this.barcode});
  final title;
  TextEditingController values;
  final onMenuClick;
  final menu;
  final barcode;
  @override
  State<FlexTwoField> createState() => _FlexTwoFieldState();
}

class _FlexTwoFieldState extends State<FlexTwoField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
              flex: 2,
              child: Text(
                "${widget.title}:",
                style: TextStyle(fontSize: 16),
              )),
          Expanded(
            flex: widget.barcode == "true" ? 6 : 7,
            child: Stack(
              children: [
                TextField(
                  controller: widget.values,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    // hintText: 'User Id',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal:
                            10.0), // Adjust the vertical and horizontal padding as needed
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromARGB(235, 28, 60, 176), width: 2.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromARGB(235, 28, 60, 176), width: 2.0),
                    ),
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 0,
                  bottom: 0,
                  child: widget.menu == "true"
                      ? GestureDetector(
                          onTap: widget.onMenuClick,
                          child: Container(
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.menu,
                              color: Color.fromARGB(255, 88, 87, 87),
                              size: 32.0, // Adjust the size as needed
                            ),
                          ),
                        )
                      : Text(""),
                ),
              ],
            ),
          ),
          widget.barcode == "true"
              ? Expanded(
                  flex: 1,
                  child: Container(
                    margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                    child: SvgPicture.asset(
                      width: 25,
                      height: 35,
                      color: Color.fromARGB(235, 76, 77, 80),
                      "images/svg/barcode.svg",
                    ),
                  ),
                )
              : Text("")
        ],
      ),
    );
  }
}
