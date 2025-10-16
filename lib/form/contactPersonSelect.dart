import 'package:flutter/material.dart';
import 'package:wms_mobile/component/listItemDrop.dart';
import 'package:wms_mobile/core/error/failure.dart';
import 'package:wms_mobile/utilies/dio_client.dart';

class ContactPersonSelect extends StatefulWidget {
  ContactPersonSelect({Key? key, this.indBack, required this.data})
      : super(
          key: key,
        );
  final indBack;
  List<dynamic> data;

  @override
  State<ContactPersonSelect> createState() => _ContactPersonSelectState();
}

class _ContactPersonSelectState extends State<ContactPersonSelect> {
  int a = 1;
  int selectedRadio = -1;
  final DioClient dio = DioClient();

  // Keep track of the selected radio button
  // final data = [
  //   {
  //     "name": "FELIX PETROLEUM PTE LTD",
  //     "sub": "FUE0001",
  //   },
  //   {
  //     "name": "EQUINOR-FUE",
  //     "sub": "FUE0005",
  //   },
  //   {
  //     "name": "H.A Energy & Shipping PTE Ltd",
  //     "sub": "FUE0009",
  //   },
  // ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      selectedRadio = widget.indBack;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 17, 18, 48),
        title: const Text('Contact Person',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        actions: const [
          Icon(Icons.search),
          SizedBox(width: 10),
          Icon(Icons.sort),
          SizedBox(width: 10),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Color.fromARGB(255, 255, 255, 255),
        child: Column(
          children: [
            Expanded(
              child: widget.data.length == 0
                  ? Container(
                      child: Center(
                          child: Text(
                        "No Record",
                        style: TextStyle(fontSize: 15),
                      )),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                      shrinkWrap: true,
                      itemCount: widget.data.length,
                      itemBuilder: (BuildContext context, int index) {
                         bool isLastIndex = index == widget.data.length - 1;
                        return ListItem(
                           lastIndex: isLastIndex, 
                            twoRow: false,
                            index: index,
                            selectedRadio: selectedRadio,
                            onSelect: (value) {
                              setState(() {
                                selectedRadio = value;
                              });
                            },
                            desc: widget.data[index]["BPLName"],
                            code: "");
                      },
                    ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: EdgeInsets.all(10),
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 17, 18, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onPressed: () {
                    final op = {
                      "name": widget.data[selectedRadio]["BPLName"] ??"",
                      "value": widget.data[selectedRadio]["BPLID"]??"",
                      "index": selectedRadio
                    };
                    if (selectedRadio != -1) {
                      Navigator.pop(context, op);
                    } else {
                      Navigator.pop(context, null);
                    }
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
