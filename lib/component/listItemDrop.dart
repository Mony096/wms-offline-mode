import 'package:flutter/material.dart';

class ListItem extends StatelessWidget {
  ListItem(
      {Key? key,
      required this.index,
      required this.selectedRadio,
      required this.onSelect,
      required this.desc,
     required this.code,
      required this.twoRow,
      required this.lastIndex
      })
      : super(key: key);

  final int index;
  final int selectedRadio;
  final Function(int) onSelect;
  final bool twoRow;
  final String desc;
  final String code;
    final lastIndex;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onSelect(index);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 255, 255, 255),
          border: lastIndex == true ? Border(
            top: BorderSide(
              color: Color.fromARGB(255, 233, 228, 228),
              width: 1.0,
            ),
            bottom: BorderSide(
              color: Color.fromARGB(255, 233, 228, 228),
              width: 1.0,
            ),
          ): Border(
                  top: BorderSide(
                    color: Color.fromARGB(255, 233, 228, 228),
                    width: 1.0,
                  ),
                 
                ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: SizedBox(
                height: twoRow ? 80 : 60,
                child: Center(
                  child: Radio(
                    fillColor: MaterialStateColor.resolveWith(
                        (states) => Color.fromARGB(255, 120, 120, 124)),
                    value: index,
                    groupValue: selectedRadio,
                    onChanged: (value) {
                      onSelect(value as int);
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: SizedBox(
                height: twoRow ? 80 : 60,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: twoRow
                      ? [
                          Text(
                            "${desc}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            "${code}",
                          ),
                        ]
                      : [
                          Text(
                            "${desc}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
